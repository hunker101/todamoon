import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<NewsArticle> articles = [];
  bool isLoading = true;
  String selectedCategory = 'cryptocurrency,forex,blockchain';
  
  final String apiKey = 'FMNRQ0CDQBSEDH9P';
  
  final Map<String, String> categories = {
    'cryptocurrency': 'CRYPTOCURRENCY',
    'forex': 'FOREX',
    'blockchain': 'BLOCKCHAIN', 
    'general': 'GENERAL',
    
  };

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://www.alphavantage.co/query?function=NEWS_SENTIMENT&topics=$selectedCategory&apikey=$apiKey&limit=50'
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['feed'] != null) {
          final List<dynamic> feedData = data['feed'];
          setState(() {
            articles = feedData.map((item) => NewsArticle.fromJson(item)).toList();
            isLoading = false;
          });
        } else {
          throw Exception('No news data available');
        }
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading news: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open article')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text(
          'Market News',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1C1F2A),
        elevation: 0,
       
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final categoryKey = categories.keys.elementAt(index);
                final categoryLabel = categories[categoryKey]!;
                final isSelected = categoryKey == selectedCategory;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = categoryKey;
                    });
                    fetchNews();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.lightBlueAccent : const Color(0xFF1C1F2A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.lightBlueAccent : Colors.grey.shade600,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        categoryLabel,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // News List
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                    ),
                  )
                : articles.isEmpty
                    ? const Center(
                        child: Text(
                          'No news available',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchNews,
                        color: Colors.lightBlueAccent,
                        child: ListView.builder(
                          itemCount: articles.length,
                          itemBuilder: (context, index) {
                            final article = articles[index];
                            return NewsCard(
                              article: article,
                              onTap: () => _launchURL(article.url),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class NewsArticle {
  final String title;
  final String summary;
  final String url;
  final String timePublished;
  final String source;
  final String? bannerImage;
  final double overallSentimentScore;
  final String overallSentimentLabel;

  NewsArticle({
    required this.title,
    required this.summary,
    required this.url,
    required this.timePublished,
    required this.source,
    this.bannerImage,
    required this.overallSentimentScore,
    required this.overallSentimentLabel,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      url: json['url'] ?? '',
      timePublished: json['time_published'] ?? '',
      source: json['source'] ?? '',
      bannerImage: json['banner_image'],
      overallSentimentScore: (json['overall_sentiment_score'] ?? 0.0).toDouble(),
      overallSentimentLabel: json['overall_sentiment_label'] ?? 'Neutral',
    );
  }
}

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const NewsCard({
    Key? key,
    required this.article,
    required this.onTap,
  }) : super(key: key);

  Color _getSentimentColor(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'bullish':
      case 'somewhat-bullish':
        return Colors.green;
      case 'bearish':
      case 'somewhat-bearish':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeAgo(String timePublished) {
    try {
      final publishedTime = DateTime.parse(timePublished);
      final now = DateTime.now();
      final difference = now.difference(publishedTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1F2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with source and time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    article.source,
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _formatTimeAgo(article.timePublished),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Title
            Text(
              article.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            
            // Summary
            Text(
              article.summary,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            
            // Sentiment indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSentimentColor(article.overallSentimentLabel).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getSentimentColor(article.overallSentimentLabel),
                    ),
                  ),
                  child: Text(
                    article.overallSentimentLabel.toUpperCase(),
                    style: TextStyle(
                      color: _getSentimentColor(article.overallSentimentLabel),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}