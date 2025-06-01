import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todamoon_app/model/coin_model.dart';
import 'coin_detail_page.dart';

class MarketPage extends StatefulWidget {
  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  List<Coin> _coins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCoins();
  }

  Future<void> fetchCoins() async {
    final url =
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=15&page=1';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _coins = List<Coin>.from(data.map((json) => Coin.fromJson(json)));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
        title:  Text('Market', style: TextStyle(fontWeight:FontWeight.bold, color: Colors.white ),),
        centerTitle: true,
        backgroundColor: const Color(0xFF1C1F2A),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.lightBlueAccent),
              )
              : ListView.builder(
                itemCount: _coins.length,
                itemBuilder: (context, index) {
                  final coin = _coins[index];
                  return ListTile(
                    leading: Image.network(coin.image, height: 32),
                    title: Text(
                      coin.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      coin.symbol,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Text(
                      '\$${coin.price.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.lightBlueAccent),
                    ),
                    onTap: () {
                      print(
                        'TAPPED COIN: id=${coin.id}, name=${coin.name}, symbol=${coin.symbol}',
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CoinDetailPage(
      coin: {
        'id': coin.id,
        'name': coin.name,
        'symbol': coin.symbol,
        'price': coin.price,
      },
    ),),
                      );
                    },
                  );
                },
              ),
    );
  }
}
