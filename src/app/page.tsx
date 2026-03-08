import Navigation from "@/components/Navigation";
import Hero from "@/components/Hero";
import FeaturedCategories from "@/components/FeaturedCategories";
import TrendingCarousel from "@/components/TrendingCarousel";
import GiftingSuite from "@/components/GiftingSuite";
import ProductDetails from "@/components/ProductDetails";
import ProductShopGrid from "@/components/ProductShopGrid";
import Marquee from "@/components/Marquee";
import EditorialVibe from "@/components/EditorialVibe";
import FeaturesBento from "@/components/FeaturesBento";
import Footer from "@/components/Footer";

export default function Home() {
  return (
    <main className="min-h-screen bg-brand-light">
      <Navigation />
      <Hero />
      <Marquee />
      <TrendingCarousel />
      <GiftingSuite />
      <EditorialVibe />
      <ProductShopGrid />
      <FeaturedCategories />
      <FeaturesBento />
      <ProductDetails />
      <Footer />
    </main>
  );
}
