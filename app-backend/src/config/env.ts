import dotenv from 'dotenv';
dotenv.config();

function required(key: string): string {
  const val = process.env[key];
  if (!val) throw new Error(`Missing required env var: ${key}`);
  return val;
}

// Support either a single FIREBASE_SERVICE_ACCOUNT_JSON (full JSON file content)
// or three separate FIREBASE_PROJECT_ID / FIREBASE_CLIENT_EMAIL / FIREBASE_PRIVATE_KEY vars.
// The JSON approach avoids all private-key newline mangling issues in Render/Heroku.
function resolveFirebaseCredentials() {
  const json = process.env['FIREBASE_SERVICE_ACCOUNT_JSON'];
  if (json) {
    const sa = JSON.parse(json) as {
      project_id: string;
      client_email: string;
      private_key: string;
    };
    return {
      projectId: sa.project_id,
      clientEmail: sa.client_email,
      privateKey: sa.private_key,
    };
  }
  return {
    projectId: required('FIREBASE_PROJECT_ID'),
    clientEmail: required('FIREBASE_CLIENT_EMAIL'),
    privateKey: required('FIREBASE_PRIVATE_KEY').replace(/\\n/g, '\n'),
  };
}

export const env = {
  port: parseInt(process.env['PORT'] ?? '4000', 10),
  nodeEnv: process.env['NODE_ENV'] ?? 'development',

  firebase: resolveFirebaseCredentials(),

  cashfree: {
    appId: process.env['CASHFREE_APP_ID'] ?? '',
    secretKey: process.env['CASHFREE_SECRET_KEY'] ?? '',
    env: (process.env['CASHFREE_ENV'] ?? 'TEST') as 'TEST' | 'PROD',
    // Hard-disable mock in production so a stray env var can't silently
    // confirm real customer orders for free.
    mock:
      process.env['CASHFREE_MOCK'] === 'true' &&
      process.env['NODE_ENV'] !== 'production',
    get baseUrl() {
      return this.env === 'PROD'
        ? 'https://api.cashfree.com/pg'
        : 'https://sandbox.cashfree.com/pg';
    },
  },

  openai: {
    apiKey: process.env['OPENAI_API_KEY'] ?? '',
  },

  vendor: {
    jwtSecret: process.env['VENDOR_JWT_SECRET'] ?? 'change-me-in-production',
    jwtExpiresIn: '30d',
  },

  aws: {
    accessKeyId: process.env['AWS_ACCESS_KEY_ID'] ?? '',
    secretAccessKey: process.env['AWS_SECRET_ACCESS_KEY'] ?? '',
    region: process.env['AWS_REGION'] ?? 'ap-south-1',
    s3Bucket: process.env['AWS_S3_BUCKET'] ?? '',
  },

  adminUids: (process.env['ADMIN_UIDS'] ?? '').split(',').filter(Boolean),

  databaseUrl: required('DATABASE_URL'),
} as const;
