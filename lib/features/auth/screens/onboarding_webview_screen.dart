import 'dart:async';

import 'package:bts_core/bts_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/rider_colors.dart';
import '../../../data/providers/session_provider.dart';

class OnboardingWebViewScreen extends ConsumerStatefulWidget {
  const OnboardingWebViewScreen({super.key});

  @override
  ConsumerState<OnboardingWebViewScreen> createState() => _OnboardingWebViewScreenState();
}

class _OnboardingWebViewScreenState extends ConsumerState<OnboardingWebViewScreen> {
  Uri? _url;
  String? _error;
  var _loading = true;
  var _closing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openSession());
  }

  Future<void> _openSession() async {
    try {
      final core = ref.read(sessionProvider.notifier).core;
      final session = await core.onboarding.createSession(applicantType: 'rider');
      if (!mounted) return;
      setState(() {
        _url = _rewriteForDevice(session.url, core.env.apiBaseUrl);
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not start verification. Is the API running?';
        _loading = false;
      });
    }
  }

  Uri _rewriteForDevice(Uri url, Uri apiBase) {
    if (url.host == 'localhost' || url.host == '127.0.0.1') {
      return url.replace(scheme: apiBase.scheme, host: apiBase.host, port: apiBase.hasPort ? apiBase.port : null);
    }
    return url;
  }

  bool _isReturnLink(Uri? uri) {
    if (uri == null) return false;
    return uri.scheme == 'gh.bts.rider' && uri.host == 'onboarding';
  }

  Future<void> _finish() async {
    if (_closing) return;
    _closing = true;
    await ref.read(sessionProvider.notifier).refreshMe();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _finish(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_error!, style: const TextStyle(color: RiderColors.mutedText)),
                )
              : InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(_url!.toString())),
                  initialSettings: InAppWebViewSettings(
                    useShouldOverrideUrlLoading: true,
                    mediaPlaybackRequiresUserGesture: false,
                    allowsInlineMediaPlayback: true,
                    javaScriptEnabled: true,
                  ),
                  shouldOverrideUrlLoading: (controller, action) async {
                    final uri = action.request.url;
                    if (_isReturnLink(uri)) {
                      await _finish();
                      return NavigationActionPolicy.CANCEL;
                    }
                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStart: (controller, uri) {
                    if (_isReturnLink(uri)) {
                      unawaited(_finish());
                    }
                  },
                ),
    );
  }
}
