import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class CoinDetailPage extends StatefulWidget {
  final Map<String, dynamic> coin;

  const CoinDetailPage({super.key, required this.coin});

  @override
  State<CoinDetailPage> createState() => _CoinDetailPageState();
}

class _CoinDetailPageState extends State<CoinDetailPage> {
  final user = FirebaseAuth.instance.currentUser;
  bool isInWatchlist = false;
  bool isLoading = true;
  String selectedTimeFrame = '1D';
  
  Map<String, dynamic> coinDetails = {};
  List<FlSpot> chartData = [];
  double? priceChangePercentage;

  @override
  void initState() {
    super.initState();
    checkWatchlist(widget.coin['id']);
    fetchCoinDetails();
    fetchChartData('1');
  }

  Future<void> checkWatchlist(String coinId) async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('watchlist')
        .doc(coinId);

    final snapshot = await ref.get();
    setState(() => isInWatchlist = snapshot.exists);
  }

  Future<void> toggleWatchlist() async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('watchlist')
        .doc(widget.coin['id']);

    final snapshot = await ref.get();

    if (snapshot.exists) {
      await ref.delete();
      setState(() => isInWatchlist = false);
    } else {
      await ref.set({
        'id': widget.coin['id'],
        'name': widget.coin['name'],
        'symbol': widget.coin['symbol'],
        'price': widget.coin['price'],
        'image': coinDetails['image']?['small'],
        'addedAt': FieldValue.serverTimestamp(),
      });
      setState(() => isInWatchlist = true);
    }
  }

  Future<void> fetchCoinDetails() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.coingecko.com/api/v3/coins/${widget.coin['id']}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          coinDetails = data;
          priceChangePercentage = data['market_data']?['price_change_percentage_24h']?.toDouble();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error fetching coin details: $e');
    }
  }

  Future<void> fetchChartData(String days) async {
    try {
      setState(() {
        // Clear chart data while loading new data
        chartData = [];
      });

      final response = await http.get(
        Uri.parse('https://api.coingecko.com/api/v3/coins/${widget.coin['id']}/market_chart?vs_currency=usd&days=$days'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prices = data['prices'] as List;
        
        List<FlSpot> newChartData = [];
        for (int i = 0; i < prices.length; i++) {
          final price = prices[i];
          if (price is List && price.length >= 2) {
            newChartData.add(FlSpot(i.toDouble(), price[1].toDouble()));
          }
        }
        
        setState(() {
          chartData = newChartData;
        });
      } else {
        debugPrint('Failed to fetch chart data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching chart data: $e');
      setState(() {
        chartData = [];
      });
    }
  }

  void onTimeFrameChanged(String timeFrame) {
    if (selectedTimeFrame == timeFrame) return; // Don't refetch if same timeframe
    
    setState(() {
      selectedTimeFrame = timeFrame;
    });
    
    String days;
    switch (timeFrame) {
      case '1D':
        days = '1';
        break;
      case '1W':
        days = '7';
        break;
      case '1M':
        days = '30';
        break;
      case '3M':
        days = '90';
        break;
      default:
        days = '1';
    }
    
    fetchChartData(days);
  }

  Widget _buildTimeFrameButton(String timeFrame) {
    bool isSelected = selectedTimeFrame == timeFrame;
    return Flexible(
      child: GestureDetector(
        onTap: () => onTimeFrameChanged(timeFrame),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.lightBlueAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            timeFrame,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.coin['name'] ?? 'Unknown',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1C1F2A),
        actions: [
          IconButton(
            icon: Icon(
              isInWatchlist ? Icons.star : Icons.star_border,
              color: Colors.amber,
            ),
            onPressed: toggleWatchlist,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.lightBlueAccent,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Coin Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1F2A),
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1C1F2A),
                          const Color(0xFF0A0E21).withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (coinDetails['image']?['small'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.network(
                                  coinDetails['image']['small'],
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.coin['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    (widget.coin['symbol'] ?? '').toString().toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '\$${widget.coin['price']?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (priceChangePercentage != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                priceChangePercentage! >= 0
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                color: priceChangePercentage! >= 0
                                    ? Colors.green
                                    : Colors.red,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${priceChangePercentage!.toStringAsFixed(2)}% 24h',
                                  style: TextStyle(
                                    color: priceChangePercentage! >= 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Market Statistics
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1F2A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Market Statistics',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildStatItem(
                              'Market Cap',
                              '\$${((coinDetails['market_data']?['market_cap']?['usd'] ?? 0) / 1e9).toStringAsFixed(1)}B',
                            ),
                            const SizedBox(width: 12),
                            _buildStatItem(
                              '24h Volume',
                              '\$${((coinDetails['market_data']?['total_volume']?['usd'] ?? 0) / 1e9).toStringAsFixed(1)}B',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildStatItem(
                              '24h High',
                              '\$${coinDetails['market_data']?['high_24h']?['usd']?.toStringAsFixed(2) ?? '0.00'}',
                            ),
                            const SizedBox(width: 12),
                            _buildStatItem(
                              '24h Low',
                              '\$${coinDetails['market_data']?['low_24h']?['usd']?.toStringAsFixed(2) ?? '0.00'}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Price Chart
                  Container(
                    width: double.infinity,
                    height: 350,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1F2A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Price Chart',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildTimeFrameButton('1D'),
                                _buildTimeFrameButton('1W'),
                                _buildTimeFrameButton('1M'),
                                _buildTimeFrameButton('3M'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: chartData.isNotEmpty
                              ? LineChart(
                                  LineChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: null,
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: Colors.grey.withOpacity(0.2),
                                          strokeWidth: 1,
                                        );
                                      },
                                    ),
                                    titlesData: FlTitlesData(
                                      show: false,
                                    ),
                                    borderData: FlBorderData(show: false),
                                    minX: 0,
                                    maxX: chartData.isNotEmpty ? chartData.length.toDouble() - 1 : 0,
                                    minY: chartData.isNotEmpty 
                                        ? chartData.map((e) => e.y).reduce((a, b) => a < b ? a : b) * 0.995
                                        : 0,
                                    maxY: chartData.isNotEmpty 
                                        ? chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.005
                                        : 100,
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: chartData,
                                        isCurved: true,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.lightBlueAccent,
                                            Colors.blue,
                                          ],
                                        ),
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(show: false),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.lightBlueAccent.withOpacity(0.3),
                                              Colors.lightBlueAccent.withOpacity(0.1),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(
                                  height: 200,
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          color: Colors.lightBlueAccent,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Loading chart data...',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}