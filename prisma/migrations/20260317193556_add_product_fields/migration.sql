-- AlterTable
ALTER TABLE "Product" ADD COLUMN     "badge" TEXT,
ADD COLUMN     "category" TEXT NOT NULL DEFAULT 'All',
ADD COLUMN     "features" TEXT[],
ADD COLUMN     "originalPrice" DOUBLE PRECISION;
