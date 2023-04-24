import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inspirational Quote App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Montserrat',
            ),
      ),
      home: const QuotePage(),
    );
  }
}

class QuotePage extends StatefulWidget {
  const QuotePage({Key? key}) : super(key: key);

  @override
  QuotePageState createState() => QuotePageState();
}

class QuotePageState extends State<QuotePage>
    with SingleTickerProviderStateMixin {
  String quote = 'Press the button to get an inspirational quote';
  String author = '';
  late AnimationController _controller;
  late Animation<double> _animation;
  int _buttonTaps = 0;
  InterstitialAd? _interstitialAd;

  Future<void> fetchQuote() async {
    final response =
        await http.get(Uri.parse('https://api.quotable.io/random'));
    if (response.statusCode == 200) {
      _controller.reset();
      _controller.forward();
      setState(() {
        quote = jsonDecode(response.body)['content'];
        author = '- ${jsonDecode(response.body)['author']}';
      });
      _buttonTaps++;
      if (_buttonTaps % 2 == 0) {
        _showInterstitialAd();
      }
    } else {
      throw Exception('Failed to load quote');
    }
  }

  void _showInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-8816215996841265/6589936768',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
            },
          );
          _interstitialAd!.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final hueRanges = [
      [200, 230], // Blue
    ];
    final hueRange = hueRanges[random.nextInt(hueRanges.length)];
    final hue = random.nextInt(hueRange[1] - hueRange[0]) + hueRange[0];
    final saturation = random.nextDouble() * 0.6 + 0.2;
    final lightness1 = random.nextDouble() * 0.4 + 0.3;
    final lightness2 = lightness1 + random.nextDouble() * 0.4 - 0.2;
    final color1 = HSLColor.fromAHSL(1, hue.toDouble(), saturation, lightness1).toColor();
    final color2 = HSLColor.fromAHSL(1, hue.toDouble(), saturation, lightness2).toColor();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 8.0,
        shadowColor: Colors.black.withOpacity(0.4),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: Colors.yellow.shade600,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text(
              'Inspirational Quotes App',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [color1, color2],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _animation,
                  child: Text(
                    quote,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  author,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: fetchQuote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Get New Quote'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
