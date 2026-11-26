import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/device_provider.dart';
import 'main_navigation_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedLang = 'en';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.register(
      email: _emailController.text,
      password: _passwordController.text,
      fullName: _nameController.text,
      preferredLanguage: _selectedLang,
    );

    if (!mounted) return;

    if (success) {
      Provider.of<DeviceProvider>(context, listen: false)
          .bindUser(auth.currentUser?.uid);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Registration failed'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(loc.translate('register')),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      labelText: loc.translate('fullName'),
                      prefixIcon: const Icon(Icons.person_outline_rounded,
                          color: AppColors.muted),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return loc.translate('errorRequired');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      labelText: loc.translate('email'),
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: AppColors.muted),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return loc.translate('errorRequired');
                      }
                      if (!val.contains('@') || !val.contains('.')) {
                        return loc.translate('errorInvalidEmail');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      labelText: loc.translate('password'),
                      prefixIcon: const Icon(Icons.lock_outline_rounded,
                          color: AppColors.muted),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.muted,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return loc.translate('errorRequired');
                      }
                      if (val.length < 6) {
                        return loc.translate('errorPasswordLength');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedLang,
                    dropdownColor: AppColors.panel,
                    style: const TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      labelText: loc.translate('language'),
                      prefixIcon: const Icon(Icons.language_rounded,
                          color: AppColors.muted),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'en', child: Text('English (EN)')),
                      DropdownMenuItem(
                          value: 'fr', child: Text('Français (FR)')),
                      DropdownMenuItem(
                          value: 'ar', child: Text('العربية (AR)')),
                    ],
                    onChanged: (val) =>
                        setState(() => _selectedLang = val ?? 'en'),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _handleRegister,
                      child: auth.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.bg),
                            )
                          : Text(loc.translate('register')),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      loc.translate('backToLogin'),
                      style: const TextStyle(color: AppColors.textDim),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
