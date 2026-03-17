import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../Shared/GlassWidgets.dart';
import 'Accueil/AccueilView.dart';
import '../App/AppLanguage.dart';
import '../App/Manager.dart';
import 'LanguageService.dart';
import 'OfferSetting/OfferSettingView.dart';
import 'PartnerSettings/PartnerSettingsView.dart';

class DashboardView extends StatefulWidget {
  final Manager manager;
  final String? initialPath;

  const DashboardView({
    super.key,
    required this.manager,
    this.initialPath,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  ModalRoute<dynamic>? _route;
  bool _didAttachPopCallback = false;

  late final VoidCallback _langListener;

  String _appVersion = '';

  Future<bool> _preventPop() async => false;

  bool get _isProfileSelected => widget.initialPath == '/dashboard/profile';
  bool get _isMyAdsSelected => widget.initialPath == '/dashboard/myads';
  bool get _isHomeSelected => !_isProfileSelected && !_isMyAdsSelected;

  bool get _showBackButton =>
      widget.initialPath != null && widget.initialPath != '/dashboard/accueil';

  @override
  void initState() {
    super.initState();

    _langListener = () {
      if (!mounted) return;
      setState(() {});
    };

    widget.manager.languageService.language.addListener(_langListener);
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _appVersion = 'v${info.version}');
    } catch (_) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route != null && _route != route) {
      if (_didAttachPopCallback && _route != null) {
        _route!.removeScopedWillPopCallback(_preventPop);
      }
      _route = route;
      _route!.addScopedWillPopCallback(_preventPop);
      _didAttachPopCallback = true;
    }
  }

  @override
  void dispose() {
    widget.manager.languageService.language.removeListener(_langListener);

    if (_didAttachPopCallback && _route != null) {
      _route!.removeScopedWillPopCallback(_preventPop);
    }

    super.dispose();
  }

  void _openMenu() => _scaffoldKey.currentState?.openEndDrawer();

  void _goHome({bool closeDrawer = false}) {
    if (closeDrawer) Navigator.of(context).pop();
    context.go('/dashboard/accueil');
  }

  void _goProfile({bool closeDrawer = false}) {
    if (closeDrawer) Navigator.of(context).pop();
    context.go('/dashboard/profile');
  }

  void _goMyAds({bool closeDrawer = false}) {
    if (closeDrawer) Navigator.of(context).pop();
    context.go('/dashboard/myads');
  }

  Future<void> _confirmAndSignOut() async {
    final Renovily s = widget.manager.renovilyTranslation;

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => _LogoutDialog(s: s),
    );

    if (ok != true) return;

    try {
      await widget.manager.logoutManager.logout();
    } catch (_) {}

    if (!mounted) return;
    context.go('/home');
  }

  Widget _resolveBody() {
    switch (widget.initialPath) {
      case '/dashboard/profile':
        return PartnerSettingsView(manager: widget.manager);

      case '/dashboard/myads':
        return OfferSettingView(manager: widget.manager);

      case '/dashboard/accueil':
      default:
        return AccueilView(manager: widget.manager);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: widget.manager.languageService.language,
      builder: (_, __, ___) {
        final Renovily s = widget.manager.renovilyTranslation;

        return WillPopScope(
          onWillPop: _preventPop,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.grey[50],
            extendBodyBehindAppBar: true,
            appBar: _buildMobileAppBar(s),
            body: _resolveBody(),
            endDrawerEnableOpenDragGesture: true,
            endDrawer: _buildEndDrawer(s),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildMobileAppBar(Renovily s) {
    final double w = MediaQuery.of(context).size.width;
    final bool isMobile = w <= 600;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: false,
      titleSpacing: _showBackButton ? 8 : 16,
      automaticallyImplyLeading: false,
      leading: _showBackButton
          ? Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Center(
          child: _GlassCircleIconButton(
            tooltip: s.back,
            icon: Icons.arrow_back_ios_new,
            onTap: _goHome,
          ),
        ),
      )
          : null,
      title: isMobile
          ? _GlassTitlePill(manager: widget.manager, onTap: _goHome)
          : _GlassTitlePill(manager: widget.manager, onTap: _goHome),
      actions: [
        Center(
          child: SizedBox(
            height: 38,
            child: GlassCircleLanguageButton(
              manager: widget.manager,
              tooltip: s.language,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _GlassCircleIconButton(
          tooltip: s.menu,
          icon: Icons.menu,
          onTap: _openMenu,
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildEndDrawer(Renovily s) {
    return Drawer(
      width: 320,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: const SizedBox.expand(),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: 0.6,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _goHome(closeDrawer: true),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.9),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.directions_car,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    s.appName,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _appVersion,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                s.dashboard,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: [
                        _MenuTile(
                          icon: Icons.home_outlined,
                          selectedIcon: Icons.home,
                          selected: _isHomeSelected,
                          label: s.menuHome,
                          onTap: () {
                            Navigator.of(context).pop();
                            _goHome();
                          },
                        ),
                        _MenuTile(
                          icon: Icons.person_outline,
                          selectedIcon: Icons.person,
                          selected: _isProfileSelected,
                          label: s.profile,
                          onTap: () {
                            Navigator.of(context).pop();
                            _goProfile();
                          },
                        ),
                        _MenuTile(
                          icon: Icons.campaign_outlined,
                          selectedIcon: Icons.campaign,
                          selected: _isMyAdsSelected,
                          label: s.myAds,
                          onTap: () {
                            Navigator.of(context).pop();
                            _goMyAds();
                          },
                        ),
                        const Divider(
                          height: 28,
                          thickness: 0.4,
                          color: Colors.black26,
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.logout,
                            color: Colors.redAccent,
                          ),
                          title: Text(
                            s.signOut,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onTap: () async {
                            Navigator.of(context).pop();
                            await _confirmAndSignOut();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutDialog extends StatelessWidget {
  final Renovily s;

  const _LogoutDialog({required this.s});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Dialog(
          backgroundColor: Colors.white.withOpacity(0.92),
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withOpacity(0.9),
              width: 0.8,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFE5E5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        s.signOut,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  s.confirmSignOut,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.black.withOpacity(0.15),
                          ),
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(s.cancel),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(s.confirm),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassTitlePill extends StatelessWidget {
  final Manager manager;
  final VoidCallback? onTap;

  const _GlassTitlePill({required this.manager, this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = manager.renovilyTranslation;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.38),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withOpacity(0.35),
                  width: 0.8,
                ),
              ),
              child: Text(
                s.appName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const _GlassCircleIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.38),
          border: Border.all(
            color: Colors.white.withOpacity(0.32),
            width: 0.8,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Tooltip(
              message: tooltip ?? '',
              child: Icon(
                icon,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? Colors.white : Colors.transparent,
          width: selected ? 1.2 : 0,
        ),
      ),
      child: ListTile(
        leading: Icon(
          selected ? (selectedIcon ?? icon) : icon,
          color: Colors.black87,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        selected: selected,
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
      ),
    );
  }
}