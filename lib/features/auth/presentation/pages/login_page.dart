import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel/core/constants/app_constants.dart';
import 'package:hotel/features/auth/bloc/login_bloc.dart';
import 'package:hotel/features/auth/bloc/login_event.dart';
import 'package:hotel/features/auth/bloc/login_state.dart';
import 'package:hotel/features/auth/data/models/user_model.dart';
import 'package:hotel/features/home/presentation/pages/home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Modern Material Color Palette
  static const Color primaryGradientStart = Color(0xFF667eea);
  static const Color primaryGradientEnd = Color(0xFF764ba2);
  static const Color inputBackground = Color(0xFFF5F7FA);
  static const Color textDark = Color(0xFF2D3748);
  static const Color textMuted = Color(0xFF718096);
  static const Color errorColor = Color(0xFFFC8181);

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(state.errorMessage ?? 'Login Failed'),
                      ),
                    ],
                  ),
                  backgroundColor: errorColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
          }
          if (state.status == LoginStatus.success) {
            final user = UserModel.fromUsername(state.username);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => HomePage(user: user),
              ),
            );
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryGradientStart,
                primaryGradientEnd,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      // Logo and Header
                      _buildHeader(),
                      const SizedBox(height: 48),
                      // Login Form
                      _buildLoginForm(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Animated Icon Container
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.restaurant_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Restaurant POS',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Billing & Management System',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.85),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Username Dropdown
          _buildUsernameDropdown(),
          const SizedBox(height: 24),
          // Password Field
          _buildPasswordField(),
          const SizedBox(height: 32),
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildUsernameDropdown() {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.username != current.username,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Username',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: inputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.username.isNotEmpty
                      ? primaryGradientStart.withValues(alpha: 0.5)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: DropdownButtonFormField<String>(
                initialValue: state.username.isEmpty ? null : state.username,
                decoration: InputDecoration(
                  prefixIcon: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [primaryGradientStart, primaryGradientEnd],
                    ).createShader(bounds),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                hint: Text(
                  'Select your role',
                  style: TextStyle(color: textMuted.withValues(alpha: 0.7)),
                ),
                items: AppConstants.availableUsers.map((user) {
                  return DropdownMenuItem<String>(
                    value: user,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getUserColor(user),
                                _getUserColor(user).withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getUserIcon(user),
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          user.substring(0, 1).toUpperCase() + user.substring(1),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<LoginBloc>().add(LoginUsernameChanged(value));
                  }
                },
                dropdownColor: Colors.white,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Password',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: inputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.password.isNotEmpty
                      ? primaryGradientStart.withValues(alpha: 0.5)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(
                  fontSize: 15,
                  color: textDark,
                ),
                decoration: InputDecoration(
                  prefixIcon: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [primaryGradientStart, primaryGradientEnd],
                    ).createShader(bounds),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: textMuted,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(color: textMuted.withValues(alpha: 0.7)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) {
                  context.read<LoginBloc>().add(LoginPasswordChanged(value));
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final isLoading = state.status == LoginStatus.loading;

        return Column(
          children: [
            // Login Button with Gradient
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryGradientStart, primaryGradientEnd],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primaryGradientStart.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        context.read<LoginBloc>().add(const LoginSubmitted());
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login_rounded, color: Colors.white),
                          SizedBox(width: 12),
                          Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        _passwordController.clear();
                        context.read<LoginBloc>().add(const LoginReset());
                      },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: textMuted.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close_rounded, color: textMuted),
                    const SizedBox(width: 12),
                    Text(
                      'CANCEL',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getUserIcon(String user) {
    switch (user) {
      case 'admin':
        return Icons.admin_panel_settings_rounded;
      case 'manager':
        return Icons.business_center_rounded;
      case 'captain':
        return Icons.star_rounded;
      case 'cashier':
        return Icons.point_of_sale_rounded;
      case 'waiter':
        return Icons.room_service_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Color _getUserColor(String user) {
    switch (user) {
      case 'admin':
        return const Color(0xFFE53E3E); // Red
      case 'manager':
        return const Color(0xFF3182CE); // Blue
      case 'captain':
        return const Color(0xFFD69E2E); // Yellow/Gold
      case 'cashier':
        return const Color(0xFF805AD5); // Purple
      case 'waiter':
        return const Color(0xFF38A169); // Green
      default:
        return primaryGradientStart;
    }
  }
}
