import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../core/constants.dart';
import '../widgets/skeleton_loaders.dart';

// ============================================================
// TEMPORARY IMPLEMENTATION — WebView wrapper.
//
// Once SanganaAfrica confirms API access (register/login, submit case,
// track case, hearings, arbitration, notifications — see the
// requirements sent to them), replace this WebView with native screens:
//   - CaseAuthScreen (register / login for employee & employer)
//   - SubmitCaseScreen (unfair dismissal / accident / harassment forms)
//   - MyCasesScreen (list + status tracking)
//   - CaseDetailScreen (hearing/arbitration details)
//
// Keep this file as a fallback in case API access is delayed or partial.
// ============================================================

class SelfServiceScreen extends StatefulWidget {
  const SelfServiceScreen({super.key});

  @override
  State<SelfServiceScreen> createState() => _SelfServiceScreenState();
}

class _SelfServiceScreenState extends State<SelfServiceScreen> {
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
      ..loadRequest(Uri.parse(ApiConstants.selfServiceWebUrl));
  }

  @override
  Widget build(BuildContext context) {
    _controller.setBackgroundColor(Theme.of(context).scaffoldBackgroundColor);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Self Service'),
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
