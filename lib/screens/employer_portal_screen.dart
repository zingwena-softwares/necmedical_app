import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../core/constants.dart';
import '../widgets/skeleton_loaders.dart';

// ============================================================
// TEMPORARY IMPLEMENTATION — WebView wrapper.
//
// Once necmedical-portal.net confirms API access (login, statements,
// returns, payments, employees — see the requirements sent to them),
// replace the single WebViewWidget below with native screens:
//   - EmployerLoginScreen
//   - EmployerDashboardScreen (statements / returns / payments / employees)
//
// Keep this file as a fallback in case API access is delayed or partial.
// ============================================================

class EmployerPortalScreen extends StatefulWidget {
  const EmployerPortalScreen({super.key});

  @override
  State<EmployerPortalScreen> createState() => _EmployerPortalScreenState();
}

class _EmployerPortalScreenState extends State<EmployerPortalScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(ApiConstants.employerPortalWebUrl));
  }

  @override
  Widget build(BuildContext context) {
    _controller.setBackgroundColor(Theme.of(context).scaffoldBackgroundColor);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employer Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const WebPageSkeleton(),
        ],
      ),
    );
  }
}
