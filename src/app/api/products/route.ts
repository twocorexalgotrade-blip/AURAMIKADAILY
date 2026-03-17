import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

// GET all products shaped for the storefront
export async function GET() {
  try {
    const dbProducts = await prisma.product.findMany({
      orderBy: { createdAt: 'desc' },
    });

    // Map DB products to match the frontend Product type
    const products = dbProducts.map((p, i) => ({
      id: 10000 + i, // offset to avoid collision with hardcoded ids (1-8)
      slug: p.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, ''),
      name: p.name,
      price: p.price,
      originalPrice: p.price,
      category: 'All',
      image: p.images[0] || '/product_chain.png',
      images: p.images.length > 0 ? p.images : ['/product_chain.png'],
      badge: 'New' as string | null,
      description: p.description,
      features: [] as string[],
      inStock: p.quantity > 0,
    }));

    return NextResponse.json(products);
  } catch (error) {
    console.error('Error fetching products:', error);
    return NextResponse.json({ error: 'Failed to fetch products' }, { status: 500 });
  }
}

// POST to create a new product
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { name, description, price, quantity, images, videos } = body;

    if (!name || !price || quantity === undefined) {
      return NextResponse.json({ error: 'Name, price, and quantity are required' }, { status: 400 });
    }

    const newProduct = await prisma.product.create({
      data: {
        name,
        description: description || '',
        price: parseFloat(price),
        quantity: parseInt(quantity, 10),
        images: images || [],
        videos: videos || [],
      },
    });

    return NextResponse.json(newProduct, { status: 201 });
  } catch (error) {
    console.error('Error creating product:', error);
    return NextResponse.json({ error: 'Failed to create product' }, { status: 500 });
  }
}
