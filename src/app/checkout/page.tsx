'use client';

import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { useCart } from "@/context/CartContext";
import { useRouter } from "next/navigation";
import { ChevronLeft, ShieldCheck, Lock } from "lucide-react";
import { useState, useEffect } from "react";
import { load } from "@cashfreepayments/cashfree-js";

const STATES = ['Maharashtra', 'Delhi', 'Karnataka', 'Tamil Nadu', 'Gujarat', 'Rajasthan', 'Uttar Pradesh', 'West Bengal', 'Telangana', 'Kerala'];

export default function CheckoutPage() {
    const { cart, subtotal, clearCart } = useCart();
    const router = useRouter();
    const deliveryFee = subtotal > 999 ? 0 : 99;
    const total = subtotal + deliveryFee;

    const [step, setStep] = useState<'address' | 'payment'>('address');
    const [form, setForm] = useState({ name: '', phone: '', email: '', address: '', city: '', state: 'Maharashtra', pincode: '' });
    const [errors, setErrors] = useState<Record<string, string>>({});
    const [isLoading, setIsLoading] = useState(false);
    const [payError, setPayError] = useState('');

    // Preload Cashfree SDK
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const [cashfree, setCashfree] = useState<any>(null);
    useEffect(() => {
        load({ mode: (process.env.NEXT_PUBLIC_CASHFREE_ENV as 'production' | 'sandbox') || 'sandbox' })
            .then(cf => setCashfree(cf))
            .catch(console.error);
    }, []);

    const validate = () => {
        const e: Record<string, string> = {};
        if (!form.name) e.name = 'Name is required';
        if (!/^[6-9]\d{9}$/.test(form.phone)) e.phone = 'Enter valid 10-digit phone';
        if (!/\S+@\S+\.\S+/.test(form.email)) e.email = 'Enter valid email';
        if (!form.address) e.address = 'Address is required';
        if (!form.city) e.city = 'City is required';
        if (!/^\d{6}$/.test(form.pincode)) e.pincode = 'Enter valid 6-digit pincode';
        setErrors(e);
        return Object.keys(e).length === 0;
    };

    const handleAddressNext = () => {
        if (validate()) setStep('payment');
    };

    const handlePayment = async () => {
        setIsLoading(true);
        setPayError('');
        try {
            // 1. Create order on our backend
            const res = await fetch('/api/orders/create', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    customer: form,
                    cart: cart.map(item => ({
                        name: item.name,
                        price: item.price,
                        quantity: item.quantity,
                        image: item.image,
                    })),
                    subtotal,
                    deliveryFee,
                    total,
                }),
            });

            if (!res.ok) throw new Error('Could not create order');
            const { orderId, paymentSessionId } = await res.json();

            // 2. Launch Cashfree payment modal
            const checkoutOptions = {
                paymentSessionId,
                redirectTarget: '_modal',
            };

            cashfree.checkout(checkoutOptions).then(async (result: { error?: { message: string }; redirect?: boolean; paymentDetails?: unknown }) => {
                if (result?.error) {
                    setPayError(result.error.message || 'Payment failed. Please try again.');
                    setIsLoading(false);
                    return;
                }
                // 3. Verify payment
                const verifyRes = await fetch('/api/orders/verify', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ orderId }),
                });
                const { status } = await verifyRes.json();

                clearCart();
                if (status === 'PAID') {
                    router.push(`/order-success?order_id=${orderId}`);
                } else {
                    setPayError('Payment could not be confirmed. Please contact support with Order ID: ' + orderId);
                    setIsLoading(false);
                }
            });
        } catch (err) {
            setPayError(err instanceof Error ? err.message : 'Something went wrong');
            setIsLoading(false);
        }
    };

    const Field = ({ label, id, type = 'text', ...props }: { label: string; id: string; type?: string; [k: string]: unknown }) => (
        <div>
            <label className="block font-outfit text-xs tracking-widest uppercase text-brand-dark/50 mb-2">{label}</label>
            <input
                id={id} type={type}
                value={form[id as keyof typeof form]}
                onChange={e => setForm(f => ({ ...f, [id]: e.target.value }))}
                className={`w-full border-b bg-transparent py-3 font-outfit text-sm focus:outline-none transition-colors ${errors[id] ? 'border-red-400' : 'border-brand-dark/20 focus:border-brand-dark'}`}
                {...props}
            />
            {errors[id] && <p className="mt-1 font-outfit text-xs text-red-500">{errors[id]}</p>}
        </div>
    );

    if (cart.length === 0) {
        router.push('/cart');
        return null;
    }

    return (
        <div className="min-h-screen bg-brand-light">
            <Navigation />
            <div className="max-w-[1100px] mx-auto px-4 sm:px-6 pt-28 pb-16">
                <button onClick={() => step === 'payment' ? setStep('address') : router.back()}
                    className="flex items-center gap-2 font-outfit text-sm text-brand-dark/50 hover:text-brand-dark mb-8 group transition-colors">
                    <ChevronLeft className="w-4 h-4 group-hover:-translate-x-1 transition-transform" />
                    {step === 'payment' ? 'Edit Address' : 'Back to Cart'}
                </button>
                <h1 className="font-playfair text-4xl md:text-6xl text-brand-dark mb-3">Checkout</h1>
                <div className="flex items-center gap-2 mb-10">
                    <span className={`font-outfit text-xs tracking-widest uppercase ${step === 'address' ? 'text-brand-dark' : 'text-brand-dark/30'}`}>1. Address</span>
                    <span className="text-brand-dark/20">—</span>
                    <span className={`font-outfit text-xs tracking-widest uppercase ${step === 'payment' ? 'text-brand-dark' : 'text-brand-dark/30'}`}>2. Payment</span>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
                    <div className="lg:col-span-2">
                        {step === 'address' && (
                            <div className="space-y-6">
                                <Field label="Full Name" id="name" placeholder="Priya Sharma" />
                                <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
                                    <Field label="Phone Number" id="phone" type="tel" placeholder="9876543210" />
                                    <Field label="Email Address" id="email" type="email" placeholder="priya@email.com" />
                                </div>
                                <Field label="Flat / House No., Building, Street" id="address" placeholder="12B, Sunrise Apartments, MG Road" />
                                <div className="grid grid-cols-1 sm:grid-cols-3 gap-6">
                                    <Field label="City" id="city" placeholder="Mumbai" />
                                    <div>
                                        <label className="block font-outfit text-xs tracking-widest uppercase text-brand-dark/50 mb-2">State</label>
                                        <select value={form.state} onChange={e => setForm(f => ({ ...f, state: e.target.value }))}
                                            className="w-full border-b border-brand-dark/20 bg-transparent py-3 font-outfit text-sm focus:outline-none focus:border-brand-dark transition-colors">
                                            {STATES.map(s => <option key={s}>{s}</option>)}
                                        </select>
                                    </div>
                                    <Field label="Pincode" id="pincode" placeholder="400001" maxLength={6} />
                                </div>
                                <button onClick={handleAddressNext}
                                    className="w-full bg-brand-dark text-brand-light py-4 font-outfit font-bold tracking-widest uppercase hover:bg-brand-accent transition-colors mt-4">
                                    Continue to Payment
                                </button>
                            </div>
                        )}

                        {step === 'payment' && (
                            <div>
                                <div className="border border-brand-dark/10 p-5 mb-6 bg-white">
                                    <h3 className="font-outfit text-xs tracking-widest uppercase text-brand-dark/50 mb-3">Delivering to</h3>
                                    <p className="font-outfit text-brand-dark font-medium">{form.name}</p>
                                    <p className="font-outfit text-sm text-brand-dark/60">{form.address}, {form.city}, {form.state} — {form.pincode}</p>
                                    <p className="font-outfit text-sm text-brand-dark/60">{form.phone} · {form.email}</p>
                                </div>

                                {payError && (
                                    <div className="bg-red-50 border border-red-200 text-red-600 font-outfit text-sm p-4 mb-6">
                                        {payError}
                                    </div>
                                )}

                                <div className="border border-brand-dark/10 p-6 mb-8 bg-white">
                                    <h3 className="font-playfair text-xl text-brand-dark mb-4">Pay Securely via Cashfree</h3>
                                    <p className="font-outfit text-sm text-brand-dark/60 mb-6 leading-relaxed">
                                        Supports UPI, Credit/Debit Cards, Net Banking, Wallets & EMI.
                                    </p>
                                    <div className="flex gap-4 mb-6 opacity-60 grayscale">
                                        <img src="https://upload.wikimedia.org/wikipedia/commons/4/41/Visa_Logo.png" alt="Visa" className="h-5 object-contain" />
                                        <img src="https://upload.wikimedia.org/wikipedia/commons/b/b7/MasterCard_Logo.svg" alt="Mastercard" className="h-6 object-contain" />
                                        <img src="https://upload.wikimedia.org/wikipedia/commons/e/e1/UPI-Logo-vector.svg" alt="UPI" className="h-5 object-contain" />
                                    </div>
                                    <button
                                        onClick={handlePayment}
                                        disabled={isLoading || !cashfree}
                                        className="w-full bg-brand-dark text-brand-light py-5 font-outfit font-bold tracking-widest uppercase hover:bg-brand-accent transition-colors flex items-center justify-center gap-3 disabled:opacity-70"
                                    >
                                        <Lock className="w-4 h-4" />
                                        {isLoading ? 'Processing...' : !cashfree ? 'Loading Payment...' : `Pay ₹ ${total.toLocaleString('en-IN')} Securely`}
                                    </button>
                                </div>
                                <div className="flex items-center gap-2 text-brand-dark/40 justify-center">
                                    <ShieldCheck className="w-4 h-4 text-brand-accent" />
                                    <span className="font-outfit text-xs">Your payment is 100% secured by Cashfree Payments</span>
                                </div>
                            </div>
                        )}
                    </div>

                    {/* Order Summary */}
                    <div className="lg:col-span-1">
                        <div className="bg-white border border-brand-dark/8 p-6 lg:sticky lg:top-28">
                            <h2 className="font-playfair text-2xl mb-6">Order Summary</h2>
                            <div className="space-y-4 mb-6 pb-6 border-b border-brand-dark/10">
                                {cart.map(item => (
                                    <div key={item.id} className="flex gap-3">
                                        <div className="w-14 h-14 flex-shrink-0 overflow-hidden bg-brand-dark/5">
                                            <img src={item.image} alt={item.name} className="w-full h-full object-cover" />
                                        </div>
                                        <div className="flex-1 min-w-0">
                                            <p className="font-outfit text-xs font-medium leading-tight truncate">{item.name}</p>
                                            <p className="font-outfit text-xs text-brand-dark/40 mt-0.5">Qty: {item.quantity}</p>
                                        </div>
                                        <span className="font-outfit text-xs font-semibold flex-shrink-0">₹ {(item.price * item.quantity).toLocaleString('en-IN')}</span>
                                    </div>
                                ))}
                            </div>
                            <div className="space-y-2 pb-4 border-b border-brand-dark/10 mb-4">
                                <div className="flex justify-between font-outfit text-sm text-brand-dark/60"><span>Subtotal</span><span>₹ {subtotal.toLocaleString('en-IN')}</span></div>
                                <div className="flex justify-between font-outfit text-sm text-brand-dark/60"><span>Delivery</span><span>{deliveryFee === 0 ? <span className="text-green-600">FREE</span> : `₹ ${deliveryFee}`}</span></div>
                            </div>
                            <div className="flex justify-between font-playfair text-xl text-brand-dark"><span>Total</span><span>₹ {total.toLocaleString('en-IN')}</span></div>
                        </div>
                    </div>
                </div>
            </div>
            <Footer />
        </div>
    );
}
