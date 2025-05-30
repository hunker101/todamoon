import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CoinDetailPage extends StatefulWidget {
  final String coinId;
  final String coinName;

  const CoinDetailPage({
    super.key,
    required this.coinId,
    required this.coinName,
  });

  @override
  State<CoinDetailPage> createState() => _CoinDetailPageState();
}

class _CoinDetailPageState extends State<CoinDetailPage> {
  List<FlSpot> _chartData = [];
  List<String> _xLabels = [];
  bool _isLoading = true;
  bool _isFavorite = false;
  Map<String, dynamic>? _coinData;
  String _selectedTimeframe = '2';

  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    fetchChartData();
    fetchCoinData();
    checkIfFavorite();
  }

  Future<void> fetchCoinData() async {
    try {
      final url = 'https://api.coingecko.com/api/v3/coins/${widget.coinId}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _coinData = json.decode(response.body);
        });
      }
    } catch (e) {
      print('❌ Error fetching coin data: $e');
    }
  }

  Future<void> fetchChartData([String days = '2']) async {
    setState(() => _isLoading = true);

    try {
      final url =
          'https://api.coingecko.com/api/v3/coins/${widget.coinId}/market_chart?vs_currency=usd&days=$days';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prices = data['prices'] as List;

        final List<FlSpot> spots = [];
        final List<String> labels = [];

        for (int i = 0; i < prices.length; i++) {
          double time = i.toDouble();
          double price = (prices[i][1] as num).toDouble();

          DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
            prices[i][0],
          );
          String label =
              days == '1'
                  ? DateFormat.Hm().format(timestamp)
                  : DateFormat.MMMd().format(timestamp);

          spots.add(FlSpot(time, price));
          labels.add(label);
        }

        setState(() {
          _chartData = spots;
          _xLabels = labels;
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load chart data: ${response.statusCode}");
      }
    } catch (e) {
      print('❌ Error fetching chart data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> checkIfFavorite() async {
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('watchlist')
            .doc(widget.coinId)
            .get();

    setState(() {
      _isFavorite = doc.exists;
    });
  }

  Future<void> toggleFavorite() async {
    if (uid == null) return;

    final watchlistRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('watchlist')
        .doc(widget.coinId);

    if (_isFavorite) {
      await watchlistRef.delete();
    } else {
      await watchlistRef.set({
        'name': widget.coinName,
        'symbol': widget.coinId.toUpperCase(),
        'image':
            'https://assets.coingecko.com/coins/images/1/large/${widget.coinId}.png',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    setState(() => _isFavorite = !_isFavorite);
  }

  Widget _buildPriceHeader() {
    if (_coinData == null) return const SizedBox.shrink();

    final currentPrice = _coinData!['market_data']['current_price']['usd'];
    final priceChange24h =
        _coinData!['market_data']['price_change_percentage_24h'];
    final isPositive = priceChange24h > 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1C1F2A), const Color(0xFF0A0E21)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.lightBlueAccent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    _coinData!['image']['large'] ?? '',
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(
                          Icons.currency_bitcoin,
                          size: 32,
                          color: Colors.orange,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.coinName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _coinData!['symbol'].toString().toUpperCase(),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '\$${NumberFormat('#,##0.00').format(currentPrice)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${isPositive ? '+' : ''}${priceChange24h.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '24h',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (_coinData == null) return const SizedBox.shrink();

    final marketData = _coinData!['market_data'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F2A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Market Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Market Cap',
                  '\$${NumberFormat.compact().format(marketData['market_cap']['usd'])}',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '24h Volume',
                  '\$${NumberFormat.compact().format(marketData['total_volume']['usd'])}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '24h High',
                  '\$${NumberFormat('#,##0.00').format(marketData['high_24h']['usd'])}',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '24h Low',
                  '\$${NumberFormat('#,##0.00').format(marketData['low_24h']['usd'])}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeSelector() {
    final timeframes = {'1': '1D', '7': '1W', '30': '1M', '90': '3M'};

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F2A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            timeframes.entries.map((entry) {
              final isSelected = _selectedTimeframe == entry.key;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedTimeframe = entry.key);
                  fetchChartData(entry.key);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Colors.lightBlueAccent
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey[400],
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F2A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Price Chart',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildTimeframeSelector(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (_xLabels.length / 4).floorToDouble(),
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index >= 0 && index < _xLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _xLabels[index],
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget:
                          (value, _) => Text(
                            '\$${NumberFormat.compact().format(value)}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10,
                            ),
                          ),
                      reservedSize: 50,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: null,
                  getDrawingHorizontalLine:
                      (value) => FlLine(
                        color: Colors.white.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    curveSmoothness: 0.3,
                    spots: _chartData,
                    color: Colors.lightBlueAccent,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.lightBlueAccent.withOpacity(0.3),
                          Colors.lightBlueAccent.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
        title: Text(
          widget.coinName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1C1F2A),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow:
                  _isFavorite
                      ? [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : null,
            ),
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.star : Icons.star_border,
                color: _isFavorite ? Colors.amber : Colors.grey[400],
                size: 28,
              ),
              onPressed: toggleFavorite,
            ),
          ),
        ],
      ),
      body:
          _isLoading && _coinData == null
              ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.lightBlueAccent,
                  strokeWidth: 3,
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildPriceHeader(),
                    const SizedBox(height: 20),
                    _buildStatsGrid(),
                    const SizedBox(height: 20),
                    _isLoading
                        ? Container(
                          height: 300,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1F2A),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.lightBlueAccent,
                              strokeWidth: 3,
                            ),
                          ),
                        )
                        : _chartData.isEmpty
                        ? Container(
                          height: 300,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1F2A),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.show_chart,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No chart data available',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : _buildChart(),
                  ],
                ),
              ),
    );
  }
}
