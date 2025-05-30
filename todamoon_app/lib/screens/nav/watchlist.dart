import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todamoon_app/screens/nav/coin_detail_page.dart';

class WatchlistPage extends StatelessWidget {
  final String uid;

  const WatchlistPage({super.key, required this.uid});

  // Fallback images for common cryptocurrencies
  String _getFallbackImage(String symbol) {
    final symbolLower = symbol.toLowerCase();
    switch (symbolLower) {
      case 'btc':
        return 'https://assets.coingecko.com/coins/images/1/large/bitcoin.png';
      case 'eth':
        return 'https://assets.coingecko.com/coins/images/279/large/ethereum.png';
      case 'sol':
        return 'https://assets.coingecko.com/coins/images/4128/large/solana.png';
      case 'ada':
        return 'https://assets.coingecko.com/coins/images/975/large/cardano.png';
      case 'dot':
        return 'https://assets.coingecko.com/coins/images/12171/large/polkadot.png';
      case 'bnb':
        return 'https://assets.coingecko.com/coins/images/825/large/bnb-icon2_2x.png';
      case 'xrp':
        return 'https://assets.coingecko.com/coins/images/44/large/xrp-symbol-white-128.png';
      case 'doge':
        return 'https://assets.coingecko.com/coins/images/5/large/dogecoin.png';
      case 'avax':
        return 'https://assets.coingecko.com/coins/images/12559/large/Avalanche_Circle_RedWhite_Trans.png';
      case 'matic':
        return 'https://assets.coingecko.com/coins/images/4713/large/matic-token-icon.png';
      default:
        return 'https://assets.coingecko.com/coins/images/1/large/bitcoin.png'; // Default fallback
    }
  }

  Widget _buildCoinImage(String? imageUrl, String symbol) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child:
            imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                  imageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // If network image fails, try fallback
                    return Image.network(
                      _getFallbackImage(symbol),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // If fallback also fails, show icon
                        return Container(
                          color: const Color(0xFF1C1F2A),
                          child: Icon(
                            Icons.currency_bitcoin,
                            color: Colors.orange,
                            size: 24,
                          ),
                        );
                      },
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: const Color(0xFF1C1F2A),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.lightBlueAccent,
                            strokeWidth: 2,
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        ),
                      ),
                    );
                  },
                )
                : Image.network(
                  _getFallbackImage(symbol),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF1C1F2A),
                      child: Icon(
                        Icons.currency_bitcoin,
                        color: Colors.orange,
                        size: 24,
                      ),
                    );
                  },
                ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text(
          'My Watchlist',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1C1F2A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('watchlist')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.lightBlueAccent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading watchlist: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, color: Colors.grey, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'No coins in watchlist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add coins to your watchlist to track them here',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final coins = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: coins.length,
            itemBuilder: (context, index) {
              final coin = coins[index];
              final coinId = coin.id;
              final coinName = coin['name'] ?? 'Unknown';
              final symbol = coin['symbol'] ?? '';
              final imageUrl = coin['image'];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1F2A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: _buildCoinImage(imageUrl, symbol),
                  title: Text(
                    coinName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    symbol.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.lightBlueAccent,
                      size: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => CoinDetailPage(
                              coinId: coinId,
                              coinName: coinName,
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
