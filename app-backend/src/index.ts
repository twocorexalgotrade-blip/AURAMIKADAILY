import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { env } from './config/env';
import { requestLogger } from './middleware/logger';
import { errorHandler } from './middleware/errorHandler';

// Feature routers
import authRoutes from './features/auth/auth.routes';
import usersRoutes from './features/users/users.routes';
import productsRoutes from './features/products/products.routes';
import cartRoutes from './features/cart/cart.routes';
import ordersRoutes from './features/orders/orders.routes';
import paymentsRoutes from './features/payments/payments.routes';
import vendorsRoutes from './features/vendors/vendors.routes';
import giftCardsRoutes from './features/gift-cards/gift-cards.routes';
import customOrdersRoutes from './features/custom-orders/custom-orders.routes';
import stylistRoutes from './features/stylist/stylist.routes';
import legalRoutes from './features/legal/legal.routes';

const app = express();

// ── Security & parsing ────────────────────────────────────────────────────────
app.set('trust proxy', 1);
app.use(helmet());
app.use(cors({ origin: '*' }));

// Raw body for Cashfree webhook signature verification
app.use('/api/v1/payments/webhook', express.raw({ type: 'application/json' }));
app.use(express.json({ limit: '1mb' }));

// ── Rate limiting ─────────────────────────────────────────────────────────────
const limiter = rateLimit({ windowMs: 60_000, max: 100, standardHeaders: true, legacyHeaders: false });
app.use('/api/', limiter);

const strictLimiter = rateLimit({ windowMs: 60_000, max: 20, standardHeaders: true, legacyHeaders: false });
app.use('/api/v1/stylist/', strictLimiter);

// ── Logging ───────────────────────────────────────────────────────────────────
app.use(requestLogger);

// ── Health check ──────────────────────────────────────────────────────────────
app.get('/health', (_req, res) => res.json({ status: 'ok', env: env.nodeEnv }));

// ── API routes ────────────────────────────────────────────────────────────────
const v1 = '/api/v1';
app.use(`${v1}/auth`, authRoutes);
app.use(`${v1}/users`, usersRoutes);
app.use(`${v1}/products`, productsRoutes);
app.use(`${v1}/cart`, cartRoutes);
app.use(`${v1}/orders`, ordersRoutes);
app.use(`${v1}/payments`, paymentsRoutes);
app.use(`${v1}/vendors`, vendorsRoutes);
app.use(`${v1}/gift-cards`, giftCardsRoutes);
app.use(`${v1}/custom-orders`, customOrdersRoutes);
app.use(`${v1}/stylist`, stylistRoutes);
app.use(`${v1}/legal`, legalRoutes);

// ── 404 ───────────────────────────────────────────────────────────────────────
app.use((_req, res) => res.status(404).json({ error: 'Not found' }));

// ── Error handler ─────────────────────────────────────────────────────────────
app.use(errorHandler);

app.listen(env.port, () => {
  console.log(`[AURAMIKA API] running on port ${env.port} — env=${env.nodeEnv}`);
});

export default app;
