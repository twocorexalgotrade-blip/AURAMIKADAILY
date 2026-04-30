import { Pool } from 'pg';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '@prisma/client';

const connectionString = `${process.env.DATABASE_URL}`;

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

// Only initialize the pool and adapter if we need a new client
const getPrismaClient = () => {
  const pool = new Pool({ connectionString });
  const adapter = new PrismaPg(pool as any);
  return new PrismaClient({ adapter });
};

export const prisma =
  globalForPrisma.prisma ?? getPrismaClient();

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
