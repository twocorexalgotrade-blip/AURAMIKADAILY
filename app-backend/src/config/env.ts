import dotenv from 'dotenv';
dotenv.config();

function required(key: string): string {
  const val = process.env[key];
  if (!val) throw new Error(`Missing required env var: ${key}`);
  return val;
}

export const env = {
  port: parseInt(process.env['PORT'] ?? '4000', 10),
  nodeEnv: process.env['NODE_ENV'] ?? 'development',

  firebase: {
    projectId: required('FIREBASE_PROJECT_ID'),
    clientEmail: required('FIREBASE_CLIENT_EMAIL'),
    privateKey: required('FIREBASE_PRIVATE_KEY').replace(/\\n/g, '\n'),
  },

  cashfree: {
    appId: required('CASHFREE_APP_ID'),
    secretKey: required('CASHFREE_SECRET_KEY'),
    env: (process.env['CASHFREE_ENV'] ?? 'TEST') as 'TEST' | 'PROD',
    get baseUrl() {
      return this.env === 'PROD'
        ? 'https://api.cashfree.com/pg'
        : 'https://sandbox.cashfree.com/pg';
    },
  },

  openai: {
    apiKey: process.env['OPENAI_API_KEY'] ?? '',
  },

  adminUids: (process.env['ADMIN_UIDS'] ?? '').split(',').filter(Boolean),
} as const;
