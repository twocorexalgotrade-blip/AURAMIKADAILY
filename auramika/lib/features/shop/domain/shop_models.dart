import 'package:flutter/material.dart';

class ShopModel {
  final String id;
  final String name;
  final String description;
  final String bannerImageUrl;
  final Color brandColor;
  final List<Color> gradientColors; // [darker, lighter]
  final double rating;
  final int totalProducts;
  final List<String> tags;
  final String location;

  const ShopModel({
    required this.id,
    required this.name,
    required this.description,
    required this.bannerImageUrl,
    required this.brandColor,
    required this.gradientColors,
    required this.rating,
    required this.totalProducts,
    required this.tags,
    required this.location,
  });
}

abstract class ShopData {
  static const List<ShopModel> allShops = [
    ShopModel(
      id: 'v1',
      name: 'Auramika Studio',
      description: 'Premium Imitation Jewelry · Gold · Silver · Diamond',
      bannerImageUrl:
          'https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?auto=format&fit=crop&w=800&q=80',
      brandColor: Color(0xFF0C2B1E),  // forest green
      gradientColors: [Color(0xFF061810), Color(0xFF1A4828)],
      rating: 4.8,
      totalProducts: 16,
      tags: ['Gold', 'Silver'],
      location: 'Jaipur, Rajasthan',
    ),
    ShopModel(
      id: 'v2',
      name: 'Pearl & Co.',
      description: 'Timeless Pearl Collections · Old Money Aesthetic',
      bannerImageUrl:
          'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?auto=format&fit=crop&w=800&q=80',
      brandColor: Color(0xFF5A0E1E),  // deep burgundy
      gradientColors: [Color(0xFF380810), Color(0xFF881828)],
      rating: 4.7,
      totalProducts: 24,
      tags: ['Pearls', 'Classic'],
      location: 'Mumbai, Maharashtra',
    ),
    ShopModel(
      id: 'v3',
      name: 'Street Chrome',
      description: 'Bold Statement Pieces · Hypebeast Jewelry',
      bannerImageUrl:
          'https://images.unsplash.com/photo-1611652022419-a9419f74343d?auto=format&fit=crop&w=800&q=80',
      brandColor: Color(0xFF0A1A38),  // royal navy
      gradientColors: [Color(0xFF060F22), Color(0xFF102050)],
      rating: 4.6,
      totalProducts: 18,
      tags: ['Street', 'Chains'],
      location: 'Delhi, NCR',
    ),
    ShopModel(
      id: 'v4',
      name: 'Boho Bazaar',
      description: 'Earthy · Ethnic · Handcrafted Pieces',
      bannerImageUrl:
          'https://images.unsplash.com/photo-1573408301185-9519bf55b5ce?auto=format&fit=crop&w=800&q=80',
      brandColor: Color(0xFF7A2C08),  // warm cognac
      gradientColors: [Color(0xFF4A1A04), Color(0xFFA04818)],
      rating: 4.5,
      totalProducts: 32,
      tags: ['Bohemian', 'Ethnic'],
      location: 'Udaipur, Rajasthan',
    ),
    ShopModel(
      id: 'v5',
      name: 'Minimal Lab',
      description: 'Clean Lines · Office Essentials · Understated',
      bannerImageUrl:
          'https://images.unsplash.com/photo-1600721391776-b5cd0e0048f9?auto=format&fit=crop&w=800&q=80',
      brandColor: Color(0xFF1A1816),  // warm obsidian
      gradientColors: [Color(0xFF0A0908), Color(0xFF2C2A26)],
      rating: 4.9,
      totalProducts: 14,
      tags: ['Minimal', 'Daily'],
      location: 'Bangalore, Karnataka',
    ),
    ShopModel(
      id: 'v6',
      name: 'Glam House',
      description: 'Statement Sparkle · Party-Ready Glam',
      bannerImageUrl:
          'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=800&q=80',
      brandColor: Color(0xFF2C0858),  // deep amethyst
      gradientColors: [Color(0xFF180430), Color(0xFF460A88)],
      rating: 4.7,
      totalProducts: 28,
      tags: ['Glam', 'Party'],
      location: 'Hyderabad, Telangana',
    ),
  ];
}
