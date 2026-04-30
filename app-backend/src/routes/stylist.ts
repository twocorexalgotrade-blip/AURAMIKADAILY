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

function openAIChat(
  messages: Array<{ role: 'user' | 'assistant'; content: string }>,
): Promise<string> {
  const payload = JSON.stringify({
    model: 'gpt-4o-mini',
    messages: [{ role: 'system', content: SYSTEM_PROMPT }, ...messages],
    max_tokens: 300,
    temperature: 0.7,
  });

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
          resolve(parsed.choices?.[0]?.message?.content ?? 'Sorry, I could not generate a response.');
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
