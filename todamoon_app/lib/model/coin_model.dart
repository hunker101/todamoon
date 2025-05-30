class Coin {
  final String id;
  final String name;
  final String symbol;
  final double price;
  final String image;

  Coin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.price,
    required this.image,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'].toUpperCase(),
      price: (json['current_price'] as num).toDouble(),
      image: json['image'],
    );
  }
}
