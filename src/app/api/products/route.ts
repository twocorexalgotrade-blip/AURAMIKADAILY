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
      id: 10000 + i,
      slug: p.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, ''),
      name: p.name,
      price: p.price,
      originalPrice: p.originalPrice ?? p.price,
      category: p.category || 'All',
      image: p.images[0] || '/product_chain.png',
      images: p.images.length > 0 ? p.images : ['/product_chain.png'],
      badge: p.badge ?? null,
      description: p.description,
      features: p.features ?? [],
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
    const { name, description, price, originalPrice, quantity, category, badge, features, images, videos } = body;

    if (!name || !price || quantity === undefined) {
      return NextResponse.json({ error: 'Name, price, and quantity are required' }, { status: 400 });
    }

    const newProduct = await prisma.product.create({
      data: {
        name,
        description: description || '',
        price: parseFloat(price),
        originalPrice: originalPrice ? parseFloat(originalPrice) : null,
        quantity: parseInt(quantity, 10),
        category: category || 'All',
        badge: badge || null,
        features: features || [],
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
