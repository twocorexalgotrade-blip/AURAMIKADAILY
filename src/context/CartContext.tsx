'use client';

import { createContext, useContext, useState, useCallback, ReactNode } from 'react';

export type Product = {
    id: number;
    slug: string;
    name: string;
    price: number;
    originalPrice: number;
    category: string;
    image: string;
    images: string[];
    badge: string | null;
    description: string;
    features: string[];
    inStock: boolean;
};

export type CartItem = Product & { quantity: number };

type CartContextType = {
    cart: CartItem[];
    addToCart: (product: Product, qty?: number) => void;
    removeFromCart: (id: number) => void;
    updateQty: (id: number, qty: number) => void;
    clearCart: () => void;
    totalItems: number;
    subtotal: number;
};

const CartContext = createContext<CartContextType | null>(null);

export function CartProvider({ children }: { children: ReactNode }) {
    const [cart, setCart] = useState<CartItem[]>([]);

    const addToCart = useCallback((product: Product, qty = 1) => {
        setCart(prev => {
            const existing = prev.find(i => i.id === product.id);
            if (existing) {
                return prev.map(i => i.id === product.id ? { ...i, quantity: i.quantity + qty } : i);
            }
            return [...prev, { ...product, quantity: qty }];
        });
    }, []);

    const removeFromCart = useCallback((id: number) => {
        setCart(prev => prev.filter(i => i.id !== id));
    }, []);

    const updateQty = useCallback((id: number, qty: number) => {
        if (qty < 1) return;
        setCart(prev => prev.map(i => i.id === id ? { ...i, quantity: qty } : i));
    }, []);

    const clearCart = useCallback(() => setCart([]), []);

    const totalItems = cart.reduce((sum, i) => sum + i.quantity, 0);
    const subtotal = cart.reduce((sum, i) => sum + i.price * i.quantity, 0);

    return (
        <CartContext.Provider value={{ cart, addToCart, removeFromCart, updateQty, clearCart, totalItems, subtotal }}>
            {children}
        </CartContext.Provider>
    );
}

export function useCart() {
    const ctx = useContext(CartContext);
    if (!ctx) throw new Error('useCart must be used within CartProvider');
    return ctx;
}
