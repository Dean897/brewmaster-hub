class Coupon {
  const Coupon({
    required this.id,
    required this.title,
    required this.merchant,
    required this.expiryDate,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      merchant: json['merchant']?.toString() ?? '',
      expiryDate: DateTime.parse(json['expiryDate'] as String).toLocal(),
    );
  }

  final String id;
  final String title;
  final String merchant;
  final DateTime expiryDate;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'merchant': merchant,
    'expiryDate': expiryDate.toUtc().toIso8601String(),
  };

  bool get isExpired => expiryDate.isBefore(DateTime.now());
}
