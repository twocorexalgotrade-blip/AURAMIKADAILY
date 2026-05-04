class Vendor {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final bool isVerified;
  final double rating;
  final String username;

  const Vendor({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    required this.isVerified,
    required this.rating,
    required this.username,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        logoUrl: json['logo_url'] as String?,
        isVerified: json['is_verified'] as bool? ?? false,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        username: json['username'] as String? ?? '',
      );
}
