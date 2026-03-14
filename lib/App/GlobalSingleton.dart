import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:flutter/widgets.dart';

class GlobalSingleton {

  static final GlobalSingleton _instance = GlobalSingleton._internal();
  factory GlobalSingleton() => _instance;
  GlobalSingleton._internal();

  double width(BuildContext context) => MediaQuery.of(context).size.width;

  bool isMobile(BuildContext context) {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    return (isAndroid || isIOS);
  }

  bool isMobWeb(BuildContext context) {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    return kIsWeb && width(context) < 600 && !isIOS && !isAndroid;
  }

  bool isTablette(BuildContext context) {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    return (isAndroid || isIOS) && width(context) > 600;
  }

  bool isWeb(BuildContext context) {
    return (kIsWeb && !isMobile(context) && !isTablette(context));
  }
}
