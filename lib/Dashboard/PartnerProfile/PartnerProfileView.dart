import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'PartnerProfileModel.dart';
import '../../App/Manager.dart';
import '../../App/AppLanguage.dart';
import 'PartnerProfileManager.dart';

class PartnerProfileView extends StatefulWidget {
  final Manager manager;
  const PartnerProfileView({super.key, required this.manager});

  @override
  State<PartnerProfileView> createState() => _PartnerProfileContentState();
}

class _PartnerProfileContentState extends State<PartnerProfileView>
    with WidgetsBindingObserver {
  final _scrollCtrl = ScrollController();
  final _formKey = GlobalKey<FormState>();

  late final PartnerProfileManager m = widget.manager.partnerProfileManager;

  final _companyName = TextEditingController();
  final _tradeName = TextEditingController();
  final _companyType = TextEditingController();
  final _siret = TextEditingController();
  final _rc = TextEditingController();
  final _nif = TextEditingController();
  final _nis = TextEditingController();
  final _tax = TextEditingController();
  final _vat = TextEditingController();

  bool _editMode = false;
  bool _dirty = false;

  bool get _hasProfile => m.hasProfile;

  bool get _formEnabled {
    if (!_hasProfile) return true;
    return _editMode;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    m.addListener(_onManagerChanged);

    m.ensureLoaded().then((_) {
      if (!mounted) return;
      _hydrate();
      _editMode = !_hasProfile;
      setState(() {});
    });
  }

  void _onManagerChanged() {
    if (!mounted) return;

    if (!_editMode && !_dirty) {
      _hydrate();
    }

    setState(() {});
  }

  @override
  void dispose() {
    m.removeListener(_onManagerChanged);
    WidgetsBinding.instance.removeObserver(this);

    _scrollCtrl.dispose();
    _companyName.dispose();
    _tradeName.dispose();
    _companyType.dispose();
    _siret.dispose();
    _rc.dispose();
    _nif.dispose();
    _nis.dispose();
    _tax.dispose();
    _vat.dispose();

    super.dispose();
  }

  Future<void> _showInfoDialog({
    required String title,
    required String message,
    IconData icon = Icons.error_outline,
    Color iconColor = Colors.redAccent,
  }) async {
    if (!mounted) return;

    final s = widget.manager.winyCarTranslation;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) {
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
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: iconColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
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
                      message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: iconColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(s.ok),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _hydrate() {
    final p = m.profile;

    _companyName.text = p?.companyName ?? '';
    _tradeName.text = p?.tradeName ?? '';
    _companyType.text = p?.companyType ?? '';
    _siret.text = p?.siret ?? '';
    _rc.text = p?.rcNumber ?? '';
    _nif.text = p?.nifNumber ?? '';
    _nis.text = p?.nisNumber ?? '';
    _tax.text = p?.taxRegime ?? '';
    _vat.text =
    (p?.vatNumber == null) ? '' : p!.vatNumber!.toStringAsFixed(2);

    _dirty = false;
  }

  String _statusKey() {
    final p = m.profile;
    final raw = (p?.statusPro ?? '').toLowerCase().trim();

    if (raw.isEmpty) return 'pending';

    if (raw.contains('verif') ||
        raw == 'verified' ||
        raw == 'approve' ||
        raw == 'approved') {
      return 'verified';
    }

    if (raw.contains('reject') ||
        raw == 'refused' ||
        raw == 'denied') {
      return 'rejected';
    }

    return 'pending';
  }

  ({String label, IconData icon, Color color, Color bg}) _statusUi(WinyCar s) {
    final k = _statusKey();

    if (k == 'verified') {
      return (
      label: 'Verified',
      icon: Icons.verified_rounded,
      color: Colors.green,
      bg: const Color(0xFFE8F5E9),
      );
    }

    if (k == 'rejected') {
      return (
      label: 'Rejected',
      icon: Icons.cancel_rounded,
      color: Colors.redAccent,
      bg: const Color(0xFFFFEBEE),
      );
    }

    return (
    label: 'Pending',
    icon: Icons.hourglass_top_rounded,
    color: Colors.orange,
    bg: const Color(0xFFFFF3E0),
    );
  }

  Widget _statusPill(WinyCar s) {
    final ui = _statusUi(s);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: ui.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ui.icon, color: ui.color, size: 18),
          const SizedBox(width: 8),
          Text(
            ui.label,
            style: TextStyle(
              color: ui.color,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.manager.winyCarTranslation;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: RefreshIndicator(
        onRefresh: () => m.refresh(),
        child: ListView(
          controller: _scrollCtrl,
          padding: const EdgeInsets.all(0),
          children: [
            _buildHeader(s),
            const SizedBox(height: 12),
            _buildForm(s),
            const SizedBox(height: 16),
            _buildActions(s),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _glassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildHeader(WinyCar s) {
    final has = _hasProfile;
    final status = _statusKey();

    return _glassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  s.proProfileTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              if (has) _statusPill(s),
            ],
          ),
          if (has && status == 'pending') ...[
            const SizedBox(height: 10),
            Text(
              'Votre demande est en attente de validation.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.86),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (has && status == 'verified') ...[
            const SizedBox(height: 10),
            Text(
              'Votre profil professionnel est validé.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.86),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (has && status == 'rejected') ...[
            const SizedBox(height: 10),
            Text(
              'Votre demande a été refusée. Vous pouvez corriger vos informations.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.86),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildForm(WinyCar s) {
    final enabled = _formEnabled;

    return _glassContainer(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _field(_companyName, s.proFieldCompanyName, enabled),
            const SizedBox(height: 12),
            _field(_tradeName, s.proFieldTradeName, enabled),
            const SizedBox(height: 12),
            _field(_companyType, s.proFieldCompanyType, enabled),
            const SizedBox(height: 12),
            _field(
              _siret,
              s.proFieldSiret,
              enabled,
              keyboard: TextInputType.number,
              formatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            _field(
              _rc,
              s.proFieldRc,
              enabled,
              keyboard: TextInputType.number,
              formatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            _field(_nif, s.proFieldNif, enabled),
            const SizedBox(height: 12),
            _field(_nis, s.proFieldNis, enabled),
            const SizedBox(height: 12),
            _field(_tax, s.proFieldTax, enabled),
            const SizedBox(height: 12),
            _field(
              _vat,
              s.proFieldVat,
              enabled,
              keyboard: const TextInputType.numberWithOptions(decimal: true),
              formatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*([.,]\d{0,2})?$'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(WinyCar s) {
    if (!_hasProfile) {
      return SizedBox(
        height: 54,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () async {
            final vatStr = _vat.text.replaceAll(',', '.').trim();
            final vatNum = vatStr.isEmpty ? null : double.tryParse(vatStr);

            final form = PartnerProfileData(
              companyName: _companyName.text.trim(),
              tradeName: _tradeName.text.trim().isEmpty
                  ? null
                  : _tradeName.text.trim(),
              companyType: _companyType.text.trim().isEmpty
                  ? null
                  : _companyType.text.trim(),
              siret: _siret.text.trim().isEmpty ? null : _siret.text.trim(),
              rcNumber: _rc.text.trim().isEmpty ? null : _rc.text.trim(),
              nifNumber: _nif.text.trim().isEmpty ? null : _nif.text.trim(),
              nisNumber: _nis.text.trim().isEmpty ? null : _nis.text.trim(),
              taxRegime: _tax.text.trim().isEmpty ? null : _tax.text.trim(),
              vatNumber: vatNum,
            );

            final r = await m.requestPro(form);

            if (!mounted) return;

            if (r.success) {
              _hydrate();
              setState(() {
                _editMode = false;
                _dirty = false;
              });
            } else {
              await _showInfoDialog(
                title: s.proProfileTitle,
                message: r.message.isNotEmpty
                    ? r.message
                    : 'error_${r.code}',
              );
            }
          },
          child: Text(
            s.proActionSendRequest,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ),
      );
    }

    if (!_editMode) {
      return SizedBox(
        height: 54,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () => setState(() => _editMode = true),
          child: Text(
            s.proActionEdit,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () async {
          final vatStr = _vat.text.replaceAll(',', '.').trim();
          final vatNum = vatStr.isEmpty ? null : double.tryParse(vatStr);

          final patch = <String, dynamic>{
            'company_name': _companyName.text.trim(),
            'trade_name': _tradeName.text.trim().isEmpty
                ? null
                : _tradeName.text.trim(),
            'company_type': _companyType.text.trim().isEmpty
                ? null
                : _companyType.text.trim(),
            'siret': _siret.text.trim().isEmpty ? null : _siret.text.trim(),
            'rc_number': _rc.text.trim().isEmpty ? null : _rc.text.trim(),
            'nif_number': _nif.text.trim().isEmpty ? null : _nif.text.trim(),
            'nis_number': _nis.text.trim().isEmpty ? null : _nis.text.trim(),
            'tax_regime': _tax.text.trim().isEmpty
                ? null
                : _tax.text.trim(),
            'vat_number': vatNum,
          };

          patch.removeWhere(
                (k, v) => v == null || (v is String && v.trim().isEmpty),
          );

          final r = await m.updateProfile(patch);

          if (!mounted) return;

          if (r.success) {
            _hydrate();
            setState(() {
              _editMode = false;
              _dirty = false;
            });
          } else {
            await _showInfoDialog(
              title: s.proProfileTitle,
              message: r.message.isNotEmpty
                  ? r.message
                  : 'error_${r.code}',
            );
          }
        },
        child: Text(
          s.proActionSave,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _field(
      TextEditingController ctrl,
      String label,
      bool enabled, {
        TextInputType? keyboard,
        List<TextInputFormatter>? formatters,
      }) {
    return TextFormField(
      controller: ctrl,
      enabled: enabled,
      keyboardType: keyboard,
      inputFormatters: formatters,
      onChanged: (_) {
        if (!_dirty) setState(() => _dirty = true);
      },
      style: const TextStyle(color: Colors.white, fontSize: 14),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.4),
            width: 1,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.4),
        ),
        contentPadding: const EdgeInsets.only(bottom: 6),
      ),
    );
  }
}