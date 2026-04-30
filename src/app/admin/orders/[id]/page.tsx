import { prisma } from '@/lib/prisma';
import { notFound } from 'next/navigation';
import OrderDetailClient from './OrderDetailClient';

export default async function OrderDetailPage({ params }: { params: { id: string } }) {
  const order = await prisma.order.findUnique({
    where: { id: params.id },
    include: { items: true },
  });

  if (!order) notFound();

  // Convert Date objects so the client component can receive them as strings
  return (
    <OrderDetailClient
      order={{
        ...order,
        createdAt: order.createdAt.toISOString(),
        updatedAt: order.updatedAt.toISOString(),
      } as Parameters<typeof OrderDetailClient>[0]['order']}
    />
  );
}
