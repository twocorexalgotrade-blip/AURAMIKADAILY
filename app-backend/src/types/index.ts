import { Request } from 'express';

declare global {
  namespace Express {
    interface Request {
      uid: string;
    }
  }
}

export type AuthenticatedRequest = Request;

export type OrderStatus =
  | 'pending'
  | 'payment_pending'
  | 'payment_failed'
  | 'confirmed'
  | 'processing'
  | 'shipped'
  | 'delivered'
  | 'cancelled';

export type GiftCardStatus = 'active' | 'used' | 'expired';

export type CustomOrderStatus =
  | 'submitted'
  | 'reviewing'
  | 'quoted'
  | 'accepted'
  | 'in_progress'
  | 'completed'
  | 'rejected';
