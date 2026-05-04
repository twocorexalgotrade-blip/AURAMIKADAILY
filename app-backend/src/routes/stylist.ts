import { Router, Response } from 'express';
import { z } from 'zod';
import https from 'https';
import { requireAuth } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { AuthenticatedRequest } from '../types';
import { env } from '../config/env';
import { pool } from '../config/db';

const router = Router();

const StylistSchema = z.object({
  message: z.string().min(1).max(500),
  conversationHistory: z
    .array(z.object({ role: z.enum(['user', 'assistant']), content: z.string() }))
    .max(10)
    .optional(),
});

const SYSTEM_PROMPT = `You are Aura, AURAMIKA's personal jewellery stylist.
You help customers find the perfect jewellery based on their style, occasion, and preferences.
Keep responses concise (2-4 sentences) and always suggest specific product categories or vibes
available on AURAMIKA: Old Money, Street Wear, Minimal Chic, Boho Goddess, Bridal, Everyday Basics.
Be warm, stylish, and knowledgeable about Indian jewellery traditions and modern trends.`;

// POST /stylist/chat
const DAILY_REQUEST_LIMIT = 20;

router.post('/chat', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  if (!env.openai.apiKey) throw new AppError(503, 'AI Stylist is not configured');

  const parsed = StylistSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  // Upsert daily usage counter; reject if limit already reached.
  const usageRes = await pool.query<{ requests: number }>(
    `INSERT INTO stylist_usage (user_uid, day, requests)
     VALUES ($1, CURRENT_DATE, 1)
     ON CONFLICT (user_uid, day) DO UPDATE
       SET requests = stylist_usage.requests + 1
     RETURNING requests`,
    [req.uid],
  );
  const todayCount = usageRes.rows[0]?.requests ?? 1;
  if (todayCount > DAILY_REQUEST_LIMIT) {
    throw new AppError(429, `Daily AI stylist limit reached (${DAILY_REQUEST_LIMIT}/day). Try again tomorrow.`);
  }

  const { message, conversationHistory = [] } = parsed.data;
  const messages = [
    ...conversationHistory.map(m => ({ role: m.role, content: m.content })),
    { role: 'user' as const, content: message },
  ];

  const reply = await openAIChat(messages);
  res.json({ reply, remainingToday: Math.max(0, DAILY_REQUEST_LIMIT - todayCount) });
});

// ── /stylist/recommend  — Magic Mirror image-based recommendation ──────────
//
// Replaces the old client-side OpenAI call. Keeps the API key on the server
// and reuses the same daily rate limit as /chat.
const RecommendSchema = z.object({
  imageBase64: z.string().min(100).max(5_500_000),  // ~4MB image cap
  catalog: z.array(z.object({
    id:       z.string().min(1),
    name:     z.string().optional().default(''),
    material: z.string().optional().default(''),
    price:    z.number().optional().default(0),
    vibe:     z.string().optional().default(''),
    gender:   z.enum(['M', 'F', 'U']),
  })).min(1).max(100),
});

const RECOMMEND_PROMPT = `You are a high-end fashion stylist for AURAMIKA, a luxury Indian jewelry brand.

STEP 1 — Detect gender presentation: Look at the person in the image and determine their gender presentation: M (male), F (female), or U (unclear/non-binary).

STEP 2 — Filter catalog:
  • If M → only consider products where gender is "M" or "U"
  • If F → only consider products where gender is "F" or "U"
  • If U → consider all products

STEP 3 — Select: From the filtered products, pick the SINGLE item that best complements the outfit style, colors, and occasion.

Return ONLY the product ID as a plain string. No markdown, no JSON, no explanation.`;

router.post('/recommend', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  if (!env.openai.apiKey) throw new AppError(503, 'AI Stylist is not configured');

  const parsed = RecommendSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  // Same rate-limit table as /chat — image calls are pricier so each counts.
  const usageRes = await pool.query<{ requests: number }>(
    `INSERT INTO stylist_usage (user_uid, day, requests)
     VALUES ($1, CURRENT_DATE, 1)
     ON CONFLICT (user_uid, day) DO UPDATE
       SET requests = stylist_usage.requests + 1
     RETURNING requests`,
    [req.uid],
  );
  const todayCount = usageRes.rows[0]?.requests ?? 1;
  if (todayCount > DAILY_REQUEST_LIMIT) {
    throw new AppError(429, `Daily AI stylist limit reached (${DAILY_REQUEST_LIMIT}/day). Try again tomorrow.`);
  }

  const { imageBase64, catalog } = parsed.data;
  const catalogJson = JSON.stringify(catalog);

  const messages = [
    { role: 'system', content: RECOMMEND_PROMPT },
    {
      role: 'user',
      content: [
        { type: 'text', text: `Analyze the outfit and recommend one jewelry piece. Catalog: ${catalogJson}` },
        { type: 'image_url', image_url: { url: `data:image/jpeg;base64,${imageBase64}` } },
      ],
    },
  ];

  const replyRaw = await openAIRaw({ model: 'gpt-4o', messages, max_tokens: 50 });
  const productId = replyRaw.trim();
  const valid = catalog.some(p => p.id === productId);

  res.json({
    productId: valid ? productId : null,
    remainingToday: Math.max(0, DAILY_REQUEST_LIMIT - todayCount),
  });
});

function openAIChat(
  messages: Array<{ role: 'user' | 'assistant'; content: string }>,
): Promise<string> {
  return openAIRaw({
    model: 'gpt-4o-mini',
    messages: [{ role: 'system', content: SYSTEM_PROMPT }, ...messages],
    max_tokens: 300,
    temperature: 0.7,
  });
}

// Low-level OpenAI chat-completions caller — accepts arbitrary payload so
// vision messages (image_url content blocks) can be sent without massaging
// the type. Used by both /chat and /recommend.
function openAIRaw(body: Record<string, unknown>): Promise<string> {
  const payload = JSON.stringify(body);

  return new Promise((resolve, reject) => {
    const options: https.RequestOptions = {
      hostname: 'api.openai.com',
      path: '/v1/chat/completions',
      method: 'POST',
      headers: {
        Authorization: `Bearer ${env.openai.apiKey}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload),
      },
    };

    const request = https.request(options, response => {
      let data = '';
      response.on('data', chunk => (data += chunk));
      response.on('end', () => {
        try {
          const parsed = JSON.parse(data) as {
            choices?: Array<{ message?: { content?: string } }>;
            error?: { message: string };
          };
          if (parsed.error) return reject(new AppError(502, parsed.error.message));
          resolve(parsed.choices?.[0]?.message?.content ?? '');
        } catch {
          reject(new Error('Invalid JSON from OpenAI'));
        }
      });
    });

    request.on('error', reject);
    request.write(payload);
    request.end();
  });
}

export default router;
