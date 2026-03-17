'use client';

import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { allProducts } from "@/data/products";
import { useCart, Product } from "@/context/CartContext";
import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import { ChevronLeft, ShoppingBag, Heart, Truck, ShieldCheck, Star, Minus, Plus } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";

const reviews = [
    { name: "Priya M.", rating: 5, date: "Feb 2026", text: "The quality is absolutely stunning for the price. Wearing it daily and it hasn't tarnished at all!" },
    { name: "Anjali S.", rating: 5, date: "Jan 2026", text: "Looks exactly like real gold. Got so many compliments. Already ordered two more pieces!" },
    { name: "Riya K.", rating: 4, date: "Dec 2025", text: "Very pretty and feels premium. Delivery was fast too. Would recommend to everyone!" },
];

export default function PDPPage({ params }: { params: { slug: string } }) {
    const router = useRouter();
    const { addToCart } = useCart();
    const [dbProducts, setDbProducts] = useState<Product[]>([]);

    useEffect(() => {
        fetch('/api/products')
            .then(res => res.json())
            .then(data => { if (Array.isArray(data)) setDbProducts(data); })
            .catch(() => {});
    }, []);

    const allCombined = [...allProducts, ...dbProducts];
    const product = allCombined.find(p => p.slug === params.slug) || allProducts[0];
    const related = allCombined.filter(p => p.id !== product.id && p.category === product.category).slice(0, 3);

    const [activeImage, setActiveImage] = useState(0);
    const [qty, setQty] = useState(1);
    const [pincode, setPincode] = useState('');
    const [deliveryMsg, setDeliveryMsg] = useState('');
    const [wishlisted, setWishlisted] = useState(false);
    const [addedToCart, setAddedToCart] = useState(false);

    const checkPincode = () => {
        if (pincode.length === 6) {
            setDeliveryMsg('✓ Delivery available in 3-5 business days via Delhivery.');
        } else {
            setDeliveryMsg('Please enter a valid 6-digit pincode.');
        }
    };

    const handleAdd = () => {
        addToCart(product, qty);
        setAddedToCart(true);
        setTimeout(() => setAddedToCart(false), 2000);
    };

    const handleBuyNow = () => {
        addToCart(product, qty);
        router.push('/cart');
    };

    const discount = Math.round((1 - product.price / product.originalPrice) * 100);

    return (
        <div className="min-h-screen bg-brand-light">
            <Navigation />

            <div className="max-w-[1400px] mx-auto px-4 sm:px-6 pt-28 pb-16">
                {/* Breadcrumb */}
                <button onClick={() => router.back()} className="flex items-center gap-2 font-outfit text-sm text-brand-dark/50 hover:text-brand-dark transition-colors mb-8 group">
                    <ChevronLeft className="w-4 h-4 group-hover:-translate-x-1 transition-transform" />
                    Back to Shop
                </button>

                {/* Main Grid */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-12 lg:gap-24 mb-24">
                    {/* Image Gallery */}
                    <div>
                        <div className="aspect-square overflow-hidden bg-white mb-4">
                            <motion.img
                                key={activeImage}
                                initial={{ opacity: 0 }}
                                animate={{ opacity: 1 }}
                                transition={{ duration: 0.3 }}
                                src={product.images[activeImage]}
                                alt={product.name}
                                className="w-full h-full object-cover"
                            />
                        </div>
                        {product.images.length > 1 && (
                            <div className="flex gap-3">
                                {product.images.map((img, i) => (
                                    <button key={i} onClick={() => setActiveImage(i)}
                                        className={`w-20 h-20 overflow-hidden border-2 transition-colors ${activeImage === i ? 'border-brand-dark' : 'border-transparent'}`}>
                                        <img src={img} alt="" className="w-full h-full object-cover" />
                                    </button>
                                ))}
                            </div>
                        )}
                    </div>

                    {/* Product Info */}
                    <div className="flex flex-col justify-start">
                        {product.badge && (
                            <span className="font-outfit text-xs tracking-widest uppercase bg-brand-dark text-brand-light px-3 py-1 w-fit mb-4">
                                {product.badge}
                            </span>
                        )}
                        <h1 className="font-playfair text-3xl md:text-5xl text-brand-dark mb-4 leading-tight">{product.name}</h1>

                        <div className="flex items-center gap-3 mb-6">
                            <span className="font-outfit text-2xl font-semibold text-brand-dark">₹ {product.price.toLocaleString('en-IN')}</span>
                            <span className="font-outfit text-brand-dark/40 line-through">₹ {product.originalPrice.toLocaleString('en-IN')}</span>
                            <span className="font-outfit text-xs font-bold text-green-600 bg-green-50 px-2 py-1">{discount}% OFF</span>
                        </div>

                        {/* Stars */}
                        <div className="flex items-center gap-2 mb-6">
                            {[...Array(5)].map((_, i) => <Star key={i} className="w-4 h-4 fill-yellow-400 text-yellow-400" />)}
                            <span className="font-outfit text-sm text-brand-dark/50">({reviews.length} reviews)</span>
                        </div>

                        <div className="w-12 h-px bg-brand-dark/20 mb-6" />

                        <p className="font-outfit text-brand-dark/70 leading-relaxed mb-6">{product.description}</p>

                        <ul className="mb-8 space-y-2">
                            {product.features.map(f => (
                                <li key={f} className="font-outfit text-sm text-brand-dark/70 flex items-center gap-2">
                                    <span className="w-1 h-1 rounded-full bg-brand-accent flex-shrink-0" />
                                    {f}
                                </li>
                            ))}
                        </ul>

                        {/* Qty Picker */}
                        <div className="flex items-center gap-4 mb-6">
                            <span className="font-outfit text-xs tracking-widest uppercase text-brand-dark/50">Qty:</span>
                            <div className="flex items-center border border-brand-dark/20">
                                <button onClick={() => setQty(q => Math.max(1, q - 1))} className="px-4 py-2 hover:bg-brand-dark/5 transition-colors"><Minus className="w-3 h-3" /></button>
                                <span className="font-outfit px-4 py-2 text-sm border-x border-brand-dark/20 min-w-[50px] text-center">{qty}</span>
                                <button onClick={() => setQty(q => q + 1)} className="px-4 py-2 hover:bg-brand-dark/5 transition-colors"><Plus className="w-3 h-3" /></button>
                            </div>
                        </div>

                        {/* CTAs */}
                        <div className="flex flex-col sm:flex-row gap-3 mb-8">
                            <button onClick={handleBuyNow}
                                className="flex-1 bg-brand-dark text-brand-light py-4 font-outfit font-bold tracking-widest uppercase text-sm hover:bg-brand-accent transition-colors">
                                Buy Now
                            </button>
                            <button onClick={handleAdd}
                                className={`flex-1 py-4 font-outfit font-bold tracking-widest uppercase text-sm border-2 flex items-center justify-center gap-2 transition-all ${addedToCart ? 'bg-green-600 text-white border-green-600' : 'border-brand-dark text-brand-dark hover:bg-brand-dark/5'
                                    }`}>
                                <ShoppingBag className="w-4 h-4" />
                                {addedToCart ? 'Added to Bag ✓' : 'Add to Bag'}
                            </button>
                            <button onClick={() => setWishlisted(w => !w)}
                                className={`p-4 border-2 transition-colors ${wishlisted ? 'border-red-400 text-red-400' : 'border-brand-dark/20 text-brand-dark/40 hover:border-brand-dark hover:text-brand-dark'}`}>
                                <Heart className={`w-5 h-5 ${wishlisted ? 'fill-red-400' : ''}`} />
                            </button>
                        </div>

                        {/* Delivery Check */}
                        <div className="border border-brand-dark/10 p-5 mb-6">
                            <div className="flex items-center gap-2 mb-3">
                                <Truck className="w-4 h-4 text-brand-accent" />
                                <span className="font-outfit text-xs tracking-widest uppercase text-brand-dark/60">Check Delivery</span>
                            </div>
                            <div className="flex gap-3">
                                <input
                                    type="text" placeholder="Enter 6-digit Pincode"
                                    value={pincode} onChange={e => setPincode(e.target.value)} maxLength={6}
                                    className="flex-1 border-b border-brand-dark/20 bg-transparent py-2 font-outfit text-sm focus:outline-none focus:border-brand-accent transition-colors"
                                />
                                <button onClick={checkPincode} className="font-outfit text-xs tracking-wider uppercase hover:text-brand-accent transition-colors">Check</button>
                            </div>
                            {deliveryMsg && <p className="mt-3 font-outfit text-xs text-brand-dark/60 italic">{deliveryMsg}</p>}
                        </div>

                        {/* Trust */}
                        <div className="flex items-center gap-2 text-brand-dark/40">
                            <ShieldCheck className="w-4 h-4 text-brand-accent" />
                            <span className="font-outfit text-xs tracking-wider">100% Secure Payment · Easy Returns · COD Available</span>
                        </div>
                    </div>
                </div>

                {/* Reviews */}
                <div className="mb-24">
                    <h2 className="font-playfair text-3xl md:text-4xl text-brand-dark mb-10">Customer Reviews</h2>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                        {reviews.map((r, i) => (
                            <motion.div key={i} initial={{ opacity: 0, y: 20 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true }} transition={{ delay: i * 0.1 }}
                                className="p-6 border border-brand-dark/10 bg-white">
                                <div className="flex items-center gap-1 mb-3">
                                    {[...Array(r.rating)].map((_, j) => <Star key={j} className="w-3 h-3 fill-yellow-400 text-yellow-400" />)}
                                </div>
                                <p className="font-outfit text-brand-dark/70 text-sm leading-relaxed mb-4 italic">"{r.text}"</p>
                                <div className="flex justify-between">
                                    <span className="font-outfit text-xs font-bold text-brand-dark">{r.name}</span>
                                    <span className="font-outfit text-xs text-brand-dark/40">{r.date}</span>
                                </div>
                            </motion.div>
                        ))}
                    </div>
                </div>

                {/* Related Products */}
                {related.length > 0 && (
                    <div>
                        <h2 className="font-playfair text-3xl md:text-4xl text-brand-dark mb-10">You May Also Like</h2>
                        <div className="grid grid-cols-2 md:grid-cols-3 gap-6">
                            {related.map(p => (
                                <Link key={p.id} href={`/product/${p.slug}`} className="group">
                                    <div className="aspect-square overflow-hidden bg-white mb-4">
                                        <img src={p.image} alt={p.name} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700" />
                                    </div>
                                    <h3 className="font-outfit text-sm font-medium mb-1">{p.name}</h3>
                                    <p className="font-outfit text-sm text-brand-dark/50">₹ {p.price.toLocaleString('en-IN')}</p>
                                </Link>
                            ))}
                        </div>
                    </div>
                )}
            </div>

            <Footer />
        </div>
    );
}
