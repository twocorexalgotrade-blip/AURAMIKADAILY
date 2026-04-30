import { Request } from 'express';

declare global {
  namespace Express {
    interface Request {
      uid: string;
    }
  }
}

export type AuthenticatedRequest = Request;

// ── Product ───────────────────────────────────────────────────────────────────
export interface Product {
  id: string;
  brandName: string;
  productName: string;
  price: number;
  material: string;
  imageUrl?: string;
  images?: string[];
  description?: string;
  category: string;
  vibe?: string;
  isExpressAvailable: boolean;
  stock: number;
  vendorId: string;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

// ── Cart ──────────────────────────────────────────────────────────────────────
export interface CartItem {
  productId: string;
  quantity: number;
  isExpress: boolean;
}

export interface Cart {
  userId: string;
  items: CartItem[];
  updatedAt: FirebaseFirestore.Timestamp;
}

// ── Order ─────────────────────────────────────────────────────────────────────
export type OrderStatus =
  | 'pending'
  | 'payment_pending'
  | 'payment_failed'
  | 'confirmed'
  | 'processing'
  | 'shipped'
  | 'delivered'
  | 'cancelled';

export interface OrderAddress {
  name: string;
  phone: string;
  line1: string;
  city: string;
  pincode: string;
}

export interface OrderItem {
  productId: string;
  productName: string;
  brandName: string;
  price: number;
  quantity: number;
  imageUrl?: string;
}

export interface Order {
  id: string;
  userId: string;
  items: OrderItem[];
  address: OrderAddress;
  subtotal: number;
  deliveryFee: number;
  total: number;
  isExpress: boolean;
  giftCardCode?: string;
  giftCardDiscount?: number;
  status: OrderStatus;
  cashfreeOrderId?: string;
  cashfreePaymentId?: string;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

// ── Vendor ────────────────────────────────────────────────────────────────────
export interface Vendor {
  id: string;
  name: string;
  description?: string;
  logoUrl?: string;
  bannerUrl?: string;
  rating?: number;
  totalReviews?: number;
  isVerified: boolean;
  createdAt: FirebaseFirestore.Timestamp;
}

// ── User Profile ──────────────────────────────────────────────────────────────
export interface UserProfile {
  uid: string;
  name: string;
  phone: string;
  email?: string;
  addresses?: OrderAddress[];
  isNewUser: boolean;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

// ── Gift Card ─────────────────────────────────────────────────────────────────
export type GiftCardStatus = 'active' | 'used' | 'expired';

export interface GiftCard {
  code: string;
  amount: number;
  remainingAmount: number;
  status: GiftCardStatus;
  ownerId?: string;
  expiresAt?: FirebaseFirestore.Timestamp;
  createdAt: FirebaseFirestore.Timestamp;
}

// ── Custom Order ──────────────────────────────────────────────────────────────
export type CustomOrderStatus = 'submitted' | 'reviewing' | 'quoted' | 'accepted' | 'in_progress' | 'completed' | 'rejected';

export interface CustomOrder {
  id: string;
  userId: string;
  description: string;
  budget?: number;
  imageUrls?: string[];
  status: CustomOrderStatus;
  vendorId?: string;
  quotedPrice?: number;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}
