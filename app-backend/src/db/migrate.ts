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


  // ── Seed product catalog (idempotent — safe to re-run on every boot) ──
  await pool.query(`INSERT INTO products (id, product_name, brand_name, price, vibe, material, image_urls, in_stock) VALUES
('e1', 'Chunky Gold Hoops', 'AURAMIKA', 499, 'Daily Minimalist', 'Gold Plated', ARRAY['assets/images/products/e1_gold_hoops.jpg'], true),
('e2', 'Crystal Drop Earrings', 'AURAMIKA', 899, 'Party / Glam', 'Silver / Diamond', ARRAY['assets/images/products/e2_crystal_drop.jpg'], true),
('e3', 'Pearl Studs', 'AURAMIKA', 299, 'Old Money', 'Gold Plated', ARRAY['assets/images/products/e3_pearl_studs.jpg'], true),
('e4', 'Vintage Coin Dangelers', 'AURAMIKA', 649, 'Street Wear', 'Antique Gold', ARRAY['assets/images/products/e4_coin_dangle.jpg'], true),
('e5', 'Emerald Cut Solitaire Studs', 'AURAMIKA', 599, 'Old Money', 'Silver / Zircon', ARRAY['assets/images/products/e5_emerald_studs.jpg'], true),
('e6', 'Rose Gold Huggies', 'AURAMIKA', 399, 'Daily Minimalist', 'Rose Gold', ARRAY['assets/images/products/e6_rose_huggies.jpg'], true),
('e7', 'Oversized Geometric Hoops', 'AURAMIKA', 449, 'Street Wear', 'Silver Plated', ARRAY['assets/images/products/e7_geo_hoops.jpg'], true),
('e8', 'Kundan Chandbali', 'AURAMIKA', 1299, 'Party / Glam', 'Gold Plated', ARRAY['assets/images/products/e8_kundan_chandbali.jpg'], true),
('e9', 'Chain Link Drop', 'AURAMIKA', 549, 'Street Wear', 'Gold Plated', ARRAY['assets/images/products/e9_chain_drop.jpg'], true),
('e10', 'Diamond Heart Studs', 'AURAMIKA', 349, 'Daily Minimalist', 'Silver / Zircon', ARRAY['assets/images/products/e10_heart_studs.jpg'], true),
('e11', 'Matte Gold Statement', 'AURAMIKA', 799, 'Old Money', 'Matte Gold', ARRAY['assets/images/products/e11_matte_statement.jpg'], true),
('e12', 'Silver Needle Threaders', 'AURAMIKA', 249, 'Daily Minimalist', 'Silver Plated', ARRAY['assets/images/products/e12_silver_threaders.jpg'], true),
('e13', 'Baroque Pearl Drop', 'AURAMIKA', 999, 'Old Money', 'Gold Plated', ARRAY['assets/images/products/e13_baroque_pearl.jpg'], true),
('e14', 'Rainbow Stone Hoops', 'AURAMIKA', 599, 'Party / Glam', 'Gold Plated', ARRAY['assets/images/products/e14_rainbow_hoops.jpg'], true),
('e15', 'Black Enamel Studs', 'AURAMIKA', 399, 'Street Wear', 'Gold / Enamel', ARRAY['https://images.unsplash.com/photo-1716461114307-6e6bf4e75ba5?auto=format&fit=crop&w=600&q=80'], true),
('n1', 'Herringbone Chain', 'AURAMIKA', 699, 'Old Money', 'Gold Plated', ARRAY['assets/images/products/n1_herringbone.jpg'], true),
('n2', 'Diamond Tennis Necklace', 'AURAMIKA', 1499, 'Party / Glam', 'Silver / Zircon', ARRAY['assets/images/products/n2_tennis_neck.jpg'], true),
('n3', 'Layered Coin Necklace', 'AURAMIKA', 799, 'Street Wear', 'Gold Plated', ARRAY['assets/images/products/n3_layered_coin.jpg'], true),
('n4', 'Pearl Choker', 'AURAMIKA', 599, 'Old Money', 'Faux Pearl', ARRAY['assets/images/products/n4_pearl_choker.jpg'], true),
('n5', 'Initial Pendant', 'AURAMIKA', 399, 'Daily Minimalist', 'Gold Plated', ARRAY['assets/images/products/n5_initial_pendant.jpg'], true),
('n6', 'Evil Eye Charm', 'AURAMIKA', 449, 'Daily Minimalist', 'Silver / Enamel', ARRAY['assets/images/products/n6_evil_eye.jpg'], true),
('n7', 'Crystal Y-Necklace', 'AURAMIKA', 899, 'Party / Glam', 'Rose Gold', ARRAY['assets/images/products/n7_y_necklace.jpg'], true),
('n8', 'Chunky Curb Chain', 'AURAMIKA', 999, 'Street Wear', 'Gold Plated', ARRAY['assets/images/products/n8_curb_chain.jpg'], true),
('n9', 'Snake Chain', 'AURAMIKA', 549, 'Daily Minimalist', 'Silver Plated', ARRAY['assets/images/products/n9_snake_chain.jpg'], true),
('n10', 'Emerald Stone Pendant', 'AURAMIKA', 699, 'Old Money', 'Gold Plated', ARRAY['assets/images/products/n10_emerald_pendant.jpg'], true),
('n11', 'Butterfly Charm Necklace', 'AURAMIKA', 499, 'Daily Minimalist', 'Rose Gold', ARRAY['assets/images/products/n11_butterfly.jpg'], true),
('n12', 'Heavy Temple Necklace', 'AURAMIKA', 2499, 'Party / Glam', 'Antique Gold', ARRAY['assets/images/products/n12_temple_neck.jpg'], true),
('n13', 'Paperclip Chain', 'AURAMIKA', 649, 'Street Wear', 'Gold Plated', ARRAY['assets/images/products/n13_paperclip.jpg'], true),
('n14', 'Black Bead Mangalsutra', 'AURAMIKA', 399, 'Daily Minimalist', 'Gold Plated', ARRAY['assets/images/products/n14_mangalsutra.jpg'], true),
('n15', 'Zircon Statement Choker', 'AURAMIKA', 1999, 'Party / Glam', 'Silver / Zircon', ARRAY['assets/images/products/n15_zircon_choker.jpg'], true),
('r1', 'Signet Ring', 'AURAMIKA', 499, 'Old Money', 'Gold Plated', ARRAY['assets/images/products/r1_signet.jpg'], true),
('r2', 'Solitaire Ring', 'AURAMIKA', 599, 'Daily Minimalist', 'Silver / Zircon', ARRAY['assets/images/products/r2_solitaire.jpg'], true),
('r3', 'Stackable Band Set', 'AURAMIKA', 399, 'Daily Minimalist', 'Rose Gold', ARRAY['assets/images/products/r3_stack_set.jpg'], true),
('r4', 'Chunky Abstract Ring', 'AURAMIKA', 549, 'Street Wear', 'Gold Plated', ARRAY['assets/images/products/r4_abstract_ring.jpg'], true),
('r5', 'Cocktail Stone Ring', 'AURAMIKA', 899, 'Party / Glam', 'Gold / Ruby', ARRAY['assets/images/products/r5_cocktail_ring.jpg'], true),
('r6', 'Pearl Ring', 'AURAMIKA', 449, 'Old Money', 'Gold / Pearl', ARRAY['assets/images/products/r6_pearl_ring.jpg'], true),
('r7', 'Serpent Ring', 'AURAMIKA', 499, 'Street Wear', 'Antique Silver', ARRAY['assets/images/products/r7_serpent_ring.jpg'], true),
('r8', 'Eternity Band', 'AURAMIKA', 699, 'Party / Glam', 'Silver / Zircon', ARRAY['assets/images/products/r8_eternity_band.jpg'], true),
('r9', 'Heart Signet', 'AURAMIKA', 399, 'Daily Minimalist', 'Gold Plated', ARRAY['assets/images/products/r9_heart_signet.jpg'], true),
('r10', 'Adjustable Evil Eye', 'AURAMIKA', 299, 'Daily Minimalist', 'Gold / Enamel', ARRAY['assets/images/products/r10_adjust_eye.jpg'], true),
('b1', 'Tennis Bracelet', 'AURAMIKA', 999, 'Party / Glam', 'Silver / Zircon', ARRAY['assets/images/products/b1_tennis_bracelet.jpg'], true),
('b2', 'Gold Link Bracelet', 'AURAMIKA', 699, 'Old Money', 'Gold Plated', ARRAY['assets/images/products/b2_gold_link.jpg'], true),
('b3', 'Charm Bracelet', 'AURAMIKA', 799, 'Daily Minimalist', 'Rose Gold', ARRAY['assets/images/products/b3_charm_bracelet.jpg'], true),
('b4', 'Cuff Bangle', 'AURAMIKA', 599, 'Old Money', 'Gold Plated', ARRAY['assets/images/products/b4_cuff_bangle.jpg'], true),
('b5', 'Black Leather Wristband', 'AURAMIKA', 499, 'Street Wear', 'Leather / Silver', ARRAY['assets/images/products/b5_leather_band.jpg'], true),
('b6', 'Evil Eye Bracelet', 'AURAMIKA', 349, 'Daily Minimalist', 'Silver / Enamel', ARRAY['assets/images/products/b6_evil_eye_brace.jpg'], true),
('b7', 'Pearl Bracelet', 'AURAMIKA', 549, 'Old Money', 'Faux Pearl', ARRAY['assets/images/products/b7_pearl_bracelet.jpg'], true),
('b8', 'Zircon Bangles (Set)', 'AURAMIKA', 1499, 'Party / Glam', 'Gold / Zircon', ARRAY['assets/images/products/b8_zircon_bangles.jpg'], true),
('b9', 'Minimalist Chain', 'AURAMIKA', 299, 'Daily Minimalist', 'Silver Plated', ARRAY['assets/images/products/b9_min_chain.jpg'], true),
('b10', 'Chunky Curb Bracelet', 'AURAMIKA', 799, 'Street Wear', 'Gold Plated', ARRAY['assets/images/products/b10_curb_brace.jpg'], true),
('sw1', 'Miami Cuban Chain', 'AURAMIKA', 1299, 'Street Wear', 'Gold Plated', ARRAY['assets/images/products/n8_curb_chain.jpg'], true),
('sw2', 'Ear Cuff Cluster Set', 'AURAMIKA', 599, 'Street Wear', 'Silver Plated', ARRAY['assets/images/products/e7_geo_hoops.jpg'], true),
('sw3', 'Spike Collar Choker', 'AURAMIKA', 699, 'Street Wear', 'Black / Silver', ARRAY['assets/images/products/n15_zircon_choker.jpg'], true),
('sw4', 'Armour Finger Ring Set', 'AURAMIKA', 849, 'Street Wear', 'Antique Silver', ARRAY['assets/images/products/r4_abstract_ring.jpg'], true),
('sw5', 'Gold Body Chain', 'AURAMIKA', 1099, 'Street Wear', 'Gold Plated', ARRAY['assets/images/products/n3_layered_coin.jpg'], true),
('sw6', 'Chain Anklet Stack', 'AURAMIKA', 499, 'Street Wear', 'Gold Plated', ARRAY['assets/images/products/b10_curb_brace.jpg'], true),
('sw7', 'Gothic Cross Pendant', 'AURAMIKA', 449, 'Street Wear', 'Black / Gold', ARRAY['assets/images/products/sw7_gothic_cross.jpg'], true),
('sw8', 'XL Hoop Ear Weights', 'AURAMIKA', 349, 'Street Wear', 'Silver Plated', ARRAY['assets/images/products/e1_gold_hoops.jpg'], true)
ON CONFLICT (id) DO UPDATE SET
  product_name=EXCLUDED.product_name, brand_name=EXCLUDED.brand_name, price=EXCLUDED.price,
  vibe=EXCLUDED.vibe, material=EXCLUDED.material, image_urls=EXCLUDED.image_urls, in_stock=true;`);

  console.log('[DB] Migrations complete');
}
