import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';

import '../weight/weight_sheet.dart';
import 'weight_widget_service.dart';

/// Jembatan antara widget home screen dan app:
/// - klik widget (deep link) → navigasi (mis. langsung buka sheet catat berat)
/// - app kembali ke depan (resume) → segarkan data widget.
class WidgetBridge extends StatefulWidget {
  const WidgetBridge({super.key, required this.router, required this.child});

  final GoRouter router;
  final Widget child;

  @override
  State<WidgetBridge> createState() => _WidgetBridgeState();
}

class _WidgetBridgeState extends State<WidgetBridge>
    with WidgetsBindingObserver {
  StreamSubscription<Uri?>? _clicks;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _clicks = HomeWidget.widgetClicked.listen(_onWidgetClick);
  }

  Future<void> _onWidgetClick(Uri? uri) async {
    if (uri == null || uri.path != '/log_weight') return;
    widget.router.go('/weight');
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final ctx = widget.router.routerDelegate.navigatorKey.currentContext;
    if (ctx != null && ctx.mounted) showWeightSheet(ctx);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refreshWeightWidget();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clicks?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
