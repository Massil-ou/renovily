import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../App/Manager.dart';
import '../../App/AppLanguage.dart';
import 'ClientProfileData.dart';
import 'ClientProfileManager.dart';

class ClientProfileView extends StatefulWidget {
  final Manager manager;
  const ClientProfileView({super.key, required this.manager});

  @override
  State<ClientProfileView> createState() => _ClientProfileViewState();
}

class _ClientProfileViewState extends State<ClientProfileView> {
  final _scrollCtrl = ScrollController();
  final _formKey = GlobalKey<FormState>();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _number = TextEditingController();
  final _wilaya = TextEditingController();
  final _commune = TextEditingController();

  bool _editMode = false;
  bool _dirty = false;

  late final ClientProfileManager m = widget.manager.clientProfileManager;

  @override
  void initState() {
    super.initState();
    m.addListener(_onManagerChanged);
    _hydrateFromCurrentUser();
  }

  void _onManagerChanged() {
    if (!mounted) return;

    if (!_editMode && !_dirty) {
      _hydrateFromCurrentUser();
    }

    setState(() {});
  }

  @override
  void dispose() {
    m.removeListener(_onManagerChanged);
    _scrollCtrl.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _number.dispose();
    _wilaya.dispose();
    _commune.dispose();
    super.dispose();
  }

  void _hydrateFromCurrentUser() {
    final user = widget.manager.currentUser;
    if (user == null) return;

    _firstName.text = user.firstName ?? '';
    _lastName.text = user.lastName ?? '';
    _number.text = user.number ?? '';
    _wilaya.text = user.wilaya ?? '';
    _commune.text = user.commune ?? '';

    _dirty = false;
  }

  Future<void> _showInfoDialog({
    required String title,
    required String message,
    IconData icon = Icons.error_outline,
    Color iconColor = Colors.redAccent,
  }) async {
    if (!mounted) return;

    final s = widget.manager.renovilyTranslation;

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

  Future<void> _save() async {
    final s = widget.manager.renovilyTranslation;

    if (!_formKey.currentState!.validate()) return;

    final data = ClientProfileData(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      number: _number.text.trim(),
      wilaya: _wilaya.text.trim(),
      commune: _commune.text.trim(),
    );

    final r = await m.updateProfile(data);

    if (!mounted) return;

    if (r.success) {
      setState(() {
        _editMode = false;
        _dirty = false;
      });

      _hydrateFromCurrentUser();
    } else {
      await _showInfoDialog(
        title: s.clientProfileTitle,
        message: r.message.isNotEmpty ? r.message : 'error_${r.code}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.manager.renovilyTranslation;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: RefreshIndicator(
        onRefresh: () async {
          _hydrateFromCurrentUser();
          setState(() {});
        },
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

  Widget _buildHeader(Renovily s) {
    return _glassContainer(
      child: Row(
        children: [
          Expanded(
            child: Text(
              s.clientProfileTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(Renovily s) {
    return _glassContainer(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _field(
              _firstName,
              s.firstName,
              _editMode,
              required: true,
              requiredMessage: s.requiredField,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            _field(
              _lastName,
              s.lastName,
              _editMode,
              required: true,
              requiredMessage: s.requiredField,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            _field(
              _number,
              s.phoneNumber,
              _editMode,
              required: true,
              requiredMessage: s.requiredField,
              keyboard: TextInputType.phone,
              formatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            _field(
              _wilaya,
              s.wilaya,
              _editMode,
              required: true,
              requiredMessage: s.requiredField,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            _field(
              _commune,
              s.commune,
              _editMode,
              required: true,
              requiredMessage: s.requiredField,
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(Renovily s) {
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
            s.edit,
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
        onPressed: m.isSaving ? null : _save,
        child: m.isSaving
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : Text(
          s.save,
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
        bool required = false,
        String? requiredMessage,
        TextInputType? keyboard,
        List<TextInputFormatter>? formatters,
        TextCapitalization textCapitalization = TextCapitalization.none,
      }) {
    return TextFormField(
      controller: ctrl,
      enabled: enabled,
      keyboardType: keyboard,
      inputFormatters: formatters,
      textCapitalization: textCapitalization,
      onChanged: (_) {
        if (!_dirty) setState(() => _dirty = true);
      },
      style: const TextStyle(color: Colors.white, fontSize: 14),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
        enabledBorder: UnderlineInputBorder(
          borderSide:
          BorderSide(color: Colors.white.withOpacity(0.4), width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.4),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide:
          BorderSide(color: Colors.white.withOpacity(0.25), width: 1),
        ),
        contentPadding: const EdgeInsets.only(bottom: 6),
      ),
      validator: required
          ? (v) =>
      (v == null || v.trim().isEmpty) ? (requiredMessage ?? 'Required') : null
          : null,
    );
  }
}