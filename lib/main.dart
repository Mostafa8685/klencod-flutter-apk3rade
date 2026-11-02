import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF087A45),
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF064E2E),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const Apk3radeApp());
}

class Apk3radeApp extends StatelessWidget {
  const Apk3radeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF079455);
    return MaterialApp(
      title: 'apk3rade',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: green,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      home: const StoreWebViewPage(),
    );
  }
}

class StoreWebViewPage extends StatefulWidget {
  const StoreWebViewPage({super.key});

  @override
  State<StoreWebViewPage> createState() => _StoreWebViewPageState();
}

class _StoreWebViewPageState extends State<StoreWebViewPage> {
  static const String homeUrl = 'https://apk3rade.mangoad.online/';
  late final WebViewController _controller;
  int _progress = 0;
  bool _hasError = false;
  bool _isLoading = true;
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() {
              _progress = progress;
              _isLoading = progress < 100;
            });
          },
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _hasError = false;
              _isLoading = true;
              _progress = 0;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _progress = 100;
            });
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true && mounted) {
              setState(() {
                _hasError = true;
                _isLoading = false;
              });
            }
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;
            if (uri.scheme == 'http' || uri.scheme == 'https') {
              final host = uri.host.toLowerCase();
              if (host == 'apk3rade.mangoad.online' ||
                  host.endsWith('.apk3rade.mangoad.online') ||
                  host == 'mangoad.online' ||
                  host.endsWith('.mangoad.online')) {
                return NavigationDecision.navigate;
              }
              _openExternal(uri);
              return NavigationDecision.prevent;
            }
            _openExternal(uri);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(homeUrl));
  }

  Future<void> _openExternal(Uri uri) async {
    if (uri.scheme == 'mailto' || uri.scheme == 'tel' ||
        uri.scheme == 'tg' || uri.scheme == 'intent') {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
      return;
    }
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  Future<bool> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('اضغط رجوع مرة أخرى للخروج من المتجر'),
            duration: Duration(seconds: 2),
          ));
      }
      return false;
    }
    return true;
  }

  Future<void> _reload() async {
    setState(() {
      _hasError = false;
      _isLoading = true;
      _progress = 0;
    });
    await _controller.loadRequest(Uri.parse(homeUrl));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _handleBack();
        if (shouldExit && mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading && !_hasError)
                Align(
                  alignment: Alignment.topCenter,
                  child: LinearProgressIndicator(
                    value: _progress == 0 ? null : _progress / 100,
                    minHeight: 3,
                    backgroundColor: const Color(0xFFE3F4EA),
                    color: const Color(0xFF079455),
                  ),
                ),
              if (_hasError)
                Container(
                  color: Colors.white,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          size: 64, color: Color(0xFF079455)),
                      const SizedBox(height: 16),
                      const Text(
                        'تعذر فتح المتجر',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF173B2A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'تأكد من اتصالك بالإنترنت ثم حاول مرة أخرى.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _reload,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('إعادة المحاولة'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF079455),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}