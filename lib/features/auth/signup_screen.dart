import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _userRepo = UserRepository();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ─── ACTIONS ────────────────────────────────────────────

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    // Check if email already registered
    if (_userRepo.emailExists(_emailController.text.trim())) {
      setState(() => _isLoading = false);
      _showError(AppStrings.emailAlreadyExists);
      return;
    }

    // Create and save user
    final user = UserModel(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      createdAt: DateTime.now(),
    );

    await _userRepo.saveUser(user);

    if (!mounted) return;
    setState(() => _isLoading = false);

    _showSuccess(AppStrings.signupSuccess);

    // Short delay so user sees the success message
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: AppColors.success, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  // ─── BUILD ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  _buildHeader(),
                  const SizedBox(height: 36),
                  _buildForm(),
                  const SizedBox(height: 32),
                  _buildSignupButton(),
                  const SizedBox(height: 24),
                  _buildLoginLink(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Create Account',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Set up your Silent SOS profile.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Full Name
          TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: AppStrings.fullName,
              prefixIcon: Icon(Icons.person_outline, size: 20),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return AppStrings.fieldRequired;
              }
              if (val.trim().length < 2) return 'Name is too short';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: AppStrings.email,
              prefixIcon: Icon(Icons.mail_outline, size: 20),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return AppStrings.fieldRequired;
              }
              if (!RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$')
                  .hasMatch(val.trim())) {
                return AppStrings.invalidEmail;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Phone
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: AppStrings.phoneNumber,
              prefixIcon: Icon(Icons.phone_outlined, size: 20),
              hintText: '+91 9999999999',
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return AppStrings.fieldRequired;
              }
              final digits = val.replaceAll(RegExp(r'[\s\+\-\(\)]'), '');
              if (digits.length < 10) return AppStrings.invalidPhone;
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: AppStrings.password,
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: AppColors.textHint,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return AppStrings.fieldRequired;
              if (val.length < 6) return AppStrings.passwordTooShort;
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirm Password
          TextFormField(
            controller: _confirmController,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _signup(),
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: AppStrings.confirmPassword,
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: AppColors.textHint,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return AppStrings.fieldRequired;
              if (val != _passwordController.text) {
                return AppStrings.passwordMismatch;
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Password strength hint
          _buildPasswordHint(),
        ],
      ),
    );
  }

  Widget _buildPasswordHint() {
    final password = _passwordController.text;
    if (password.isEmpty) return const SizedBox.shrink();

    final hasLength = password.length >= 6;
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          _hintChip('6+ chars', hasLength),
          const SizedBox(width: 8),
          _hintChip('Uppercase', hasUpper),
          const SizedBox(width: 8),
          _hintChip('Number', hasNumber),
        ],
      ),
    );
  }

  Widget _hintChip(String label, bool met) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 13,
          color: met ? AppColors.success : AppColors.textHint,
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: met ? AppColors.success : AppColors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signup,
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(AppStrings.createAccount),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: TextButton(
        onPressed: () => context.pop(),
        child: RichText(
          text: const TextSpan(
            text: 'Already have an account? ',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            children: [
              TextSpan(
                text: 'Login',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
