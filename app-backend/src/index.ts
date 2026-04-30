import 'express-async-errors';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { env } from './config/env';
import { runMigrations } from './db/migrate';
import { requestLogger } from './middleware/logger';
import { errorHandler } from './middleware/errorHandler';

import authRoutes from './routes/auth';
import usersRoutes from './routes/users';
import productsRoutes from './routes/products';
import cartRoutes from './routes/cart';
import ordersRoutes from './routes/orders';
import paymentsRoutes from './routes/payments';
import vendorsRoutes from './routes/vendors';
import giftCardsRoutes from './routes/giftCards';
import customOrdersRoutes from './routes/customOrders';
import stylistRoutes from './routes/stylist';
import legalRoutes from './routes/legal';

const app = express();

app.set('trust proxy', 1);
app.use(helmet());
app.use(cors({ origin: '*' }));

// Raw body required for Cashfree webhook signature verification
app.use('/api/v1/payments/webhook', express.raw({ type: 'application/json' }));
app.use(express.json({ limit: '1mb' }));

const limiter = rateLimit({ windowMs: 60_000, max: 100, standardHeaders: true, legacyHeaders: false });
app.use('/api/', limiter);

const strictLimiter = rateLimit({ windowMs: 60_000, max: 20, standardHeaders: true, legacyHeaders: false });
app.use('/api/v1/stylist/', strictLimiter);

app.use(requestLogger);

app.get('/health', (_req, res) => res.json({ status: 'ok', env: env.nodeEnv, version: '2.0.0' }));

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

app.use((_req, res) => res.status(404).json({ error: 'Not found' }));
app.use(errorHandler);

runMigrations().catch(err => {
  console.error('[DB] Migration failed:', err);
  process.exit(1);
}).then(() => {
  app.listen(env.port, () => {
    console.log(`[AURAMIKA API v2] running on port ${env.port} — env=${env.nodeEnv}`);
  });
});

export default app;
