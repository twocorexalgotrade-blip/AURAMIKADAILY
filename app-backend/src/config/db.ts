import { Pool, types } from 'pg';
import { env } from './env';

// pg returns NUMERIC columns as strings by default — parse them as floats.
types.setTypeParser(1700, (val) => parseFloat(val));

export const pool = new Pool({
  connectionString: env.databaseUrl,
  ssl: { rejectUnauthorized: false },
  max: 10,
  idleTimeoutMillis: 30000,
});
