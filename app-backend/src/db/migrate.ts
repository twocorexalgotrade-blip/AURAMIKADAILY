import { pool } from '../config/db';

export async function runMigrations() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS users (
      uid TEXT PRIMARY KEY,
      name TEXT NOT NULL DEFAULT '',
      phone TEXT NOT NULL DEFAULT '',
      email TEXT,
      dob TEXT,
      image_path TEXT DEFAULT '',
      created_at TIMESTAMPTZ DEFAULT NOW(),
      updated_at TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS addresses (
      id SERIAL PRIMARY KEY,
      user_uid TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
      label TEXT NOT NULL DEFAULT 'Home',
      name TEXT NOT NULL DEFAULT '',
      phone TEXT NOT NULL DEFAULT '',
      line1 TEXT NOT NULL,
      city TEXT NOT NULL,
      pin_code TEXT DEFAULT '',
      created_at TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS vendors (
      id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
      name TEXT NOT NULL,
      description TEXT,
      logo_url TEXT,
      is_verified BOOLEAN DEFAULT false,
      rating NUMERIC(3,2) DEFAULT 0,
      created_at TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS products (
      id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
      vendor_id TEXT REFERENCES vendors(id) ON DELETE SET NULL,
      product_name TEXT NOT NULL,
      brand_name TEXT NOT NULL DEFAULT '',
      description TEXT,
      price NUMERIC(10,2) NOT NULL,
      original_price NUMERIC(10,2),
      category TEXT,
      vibe TEXT,
      material TEXT,
      image_urls TEXT[] DEFAULT '{}',
      is_express BOOLEAN DEFAULT false,
      in_stock BOOLEAN DEFAULT true,
      tags TEXT[] DEFAULT '{}',
      created_at TIMESTAMPTZ DEFAULT NOW(),
      updated_at TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS wishlist_items (
      user_uid TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
      product_id TEXT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
      created_at TIMESTAMPTZ DEFAULT NOW(),
      PRIMARY KEY (user_uid, product_id)
    );

    CREATE TABLE IF NOT EXISTS cart_items (
      id SERIAL PRIMARY KEY,
      user_uid TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
      product_id TEXT NOT NULL,
      quantity INT NOT NULL DEFAULT 1,
      is_express BOOLEAN DEFAULT false,
      updated_at TIMESTAMPTZ DEFAULT NOW(),
      UNIQUE (user_uid, product_id)
    );

    CREATE TABLE IF NOT EXISTS gift_cards (
      code TEXT PRIMARY KEY,
      owner_uid TEXT REFERENCES users(uid) ON DELETE SET NULL,
      original_amount NUMERIC(10,2) NOT NULL,
      remaining_amount NUMERIC(10,2) NOT NULL,
      status TEXT NOT NULL DEFAULT 'active',
      expires_at TIMESTAMPTZ,
      created_at TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS orders (
      id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
      user_uid TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
      subtotal NUMERIC(10,2) NOT NULL,
      delivery_fee NUMERIC(10,2) NOT NULL DEFAULT 49,
      gift_card_code TEXT REFERENCES gift_cards(code),
      gift_card_discount NUMERIC(10,2) DEFAULT 0,
      total NUMERIC(10,2) NOT NULL,
      is_express BOOLEAN DEFAULT false,
      status TEXT NOT NULL DEFAULT 'payment_pending',
      cashfree_order_id TEXT,
      cashfree_payment_id TEXT,
      address_name TEXT,
      address_phone TEXT,
      address_line1 TEXT,
      address_city TEXT,
      address_pincode TEXT,
      created_at TIMESTAMPTZ DEFAULT NOW(),
      updated_at TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS order_items (
      id SERIAL PRIMARY KEY,
      order_id TEXT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
      product_id TEXT NOT NULL,
      product_name TEXT NOT NULL,
      brand_name TEXT NOT NULL DEFAULT '',
      price NUMERIC(10,2) NOT NULL,
      quantity INT NOT NULL DEFAULT 1,
      image_url TEXT
    );

    CREATE TABLE IF NOT EXISTS custom_orders (
      id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
      user_uid TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
      description TEXT NOT NULL,
      budget NUMERIC(10,2),
      image_urls TEXT[] DEFAULT '{}',
      status TEXT NOT NULL DEFAULT 'submitted',
      created_at TIMESTAMPTZ DEFAULT NOW(),
      updated_at TIMESTAMPTZ DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS stylist_usage (
      user_uid  TEXT NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
      day       DATE NOT NULL DEFAULT CURRENT_DATE,
      requests  INT  NOT NULL DEFAULT 0,
      PRIMARY KEY (user_uid, day)
    );
  `);

  // Hot-path indexes — idempotent (IF NOT EXISTS)
  await pool.query(`
    CREATE INDEX IF NOT EXISTS idx_orders_user_uid          ON orders(user_uid);
    CREATE INDEX IF NOT EXISTS idx_orders_cashfree_order_id ON orders(cashfree_order_id);
    CREATE INDEX IF NOT EXISTS idx_order_items_order_id     ON order_items(order_id);
    CREATE INDEX IF NOT EXISTS idx_cart_items_user_uid      ON cart_items(user_uid);
    CREATE INDEX IF NOT EXISTS idx_wishlist_user_uid        ON wishlist_items(user_uid);
    CREATE INDEX IF NOT EXISTS idx_addresses_user_uid       ON addresses(user_uid);
    CREATE INDEX IF NOT EXISTS idx_products_category        ON products(category);
    CREATE INDEX IF NOT EXISTS idx_products_vibe            ON products(vibe);
    CREATE INDEX IF NOT EXISTS idx_products_in_stock        ON products(in_stock, created_at DESC);
  `);

  console.log('[DB] Migrations complete');
}
