import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/rider_notice.dart';

abstract final class AppLinks {
  static const androidPackage = 'com.basittransportservice.riders.rider_app';
  static const shareMessage =
      'I deliver with BTS. Join Basit Transport and earn on every trip. https://play.google.com/store/apps/details?id=$androidPackage';

  static Future<void> shareApp(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        text: shareMessage,
        subject: 'BTS Rider',
        sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  static Future<void> rateApp(BuildContext context) async {
    final ios = !kIsWeb && Platform.isIOS;
    final uri = ios
        ? Uri.parse('https://apps.apple.com/gh/search?term=BTS%20Rider%20Basit%20Transport')
        : Uri.parse('https://play.google.com/store/apps/details?id=$androidPackage');
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      showRiderNotice(
        context,
        message: 'The store listing opens once BTS Rider is published.',
        tone: RiderNoticeTone.info,
      );
    }
  }
}
