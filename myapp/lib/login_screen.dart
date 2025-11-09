// myapp/lib/login_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:getwidget/getwidget.dart';
import 'homepage-modules/homepage.dart';
import 'data/account_store.dart';
import 'setupAccount.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isRegister = false;
  bool showLoginPassword = false;
  bool showRegisterPassword = false;
  bool rememberMe = false;
  bool agreePolicy = false;

  final _loginUsernameController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerUsernameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill login username if SetupAccount or other flows set currentUsername
    final prefill = AccountStore.currentUsername;
    if (prefill != null && prefill.isNotEmpty) {
      _loginUsernameController.text = prefill;
    }
  }

  @override
  void dispose() {
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    _registerUsernameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  void toggleView() {
    setState(() {
      isRegister = !isRegister;
    });
  }

  /// Show terms dialog (card style)
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Terms & Privacy Policy",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 320,
                    child: SingleChildScrollView(
                      child: Text(
                        // Short placeholder terms — replace with real terms text.
                        "By using this app you agree to the Terms & Privacy Policy. "
                        "We collect minimal information to provide the service. "
                        "Don't post abusive or illegal content. Be respectful to others. "
                        "This app is a demo (local-only) unless connected to a backend. "
                        "\n\n(Replace with full legal text for production.)",
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Close"),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ✅ Handle Login
  void _handleLogin() {
    final username = _loginUsernameController.text.trim();
    final password = _loginPasswordController.text;

    if (username.isEmpty || password.isEmpty) {
      GFToast.showToast("Please fill in all fields.", context,
          toastPosition: GFToastPosition.CENTER);
      return;
    }

    final error = AccountStore.login(username, password);
    if (error != null) {
      GFToast.showToast(error, context,
          backgroundColor: Colors.red, textStyle: const TextStyle(color: Colors.white));
      return;
    }

    // Success → Go to HomePage
    GFToast.showToast("Welcome back, $username!", context,
        backgroundColor: Colors.green, textStyle: const TextStyle(color: Colors.white));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  /// ✅ Handle Register -> go to SetupAccountPage (so user can complete profile)
  void _handleRegister() {
    final username = _registerUsernameController.text.trim();
    final email = _registerEmailController.text.trim();
    final password = _registerPasswordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      GFToast.showToast("Please fill in all fields.", context,
          toastPosition: GFToastPosition.CENTER);
      return;
    }

    if (!agreePolicy) {
      GFToast.showToast("Please agree to the Terms & Privacy Policy.", context,
          toastPosition: GFToastPosition.CENTER);
      return;
    }

    final error = AccountStore.registerUser(
      username: username,
      email: email,
      password: password,
    );

    if (error != null) {
      GFToast.showToast(error, context,
          backgroundColor: Colors.red, textStyle: const TextStyle(color: Colors.white));
      return;
    }

    // store username so SetupAccount and Login can reference it
    AccountStore.currentUsername = username;

    // Registration successful locally -> go to SetupAccount to collect display name etc.
    GFToast.showToast("Account created — continue to setup.", context,
        backgroundColor: Colors.green, textStyle: const TextStyle(color: Colors.white));

    // Navigate to SetupAccount and pass username so SetupAccount can set the profile on same account
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SetupAccountPage(username: username)),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      children: [
        GFTextField(
          controller: _loginUsernameController,
          decoration: const InputDecoration(labelText: "Username"),
        ),
        const SizedBox(height: 16),
        GFTextField(
          controller: _loginPasswordController,
          obscureText: !showLoginPassword,
          decoration: InputDecoration(
            labelText: "Password",
            suffixIcon: IconButton(
              icon: Icon(
                showLoginPassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () => setState(() => showLoginPassword = !showLoginPassword),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            GFCheckbox(
              size: GFSize.SMALL,
              inactiveBgColor: Colors.transparent,
              activeBgColor: GFColors.DARK,
              value: rememberMe,
              onChanged: (v) => setState(() => rememberMe = v ?? false),
            ),
            const Text("Remember Me")
          ],
        ),
        const SizedBox(height: 16),
        GFButton(
          onPressed: _handleLogin,
          text: "Login",
          fullWidthButton: true,
          color: Colors.black,
          shape: GFButtonShape.pills,
        ),
      ],
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    return Column(
      children: [
        GFTextField(
          controller: _registerUsernameController,
          decoration: const InputDecoration(labelText: "Username"),
        ),
        const SizedBox(height: 16),
        GFTextField(
          controller: _registerEmailController,
          decoration: const InputDecoration(labelText: "Email"),
        ),
        const SizedBox(height: 16),
        GFTextField(
          controller: _registerPasswordController,
          obscureText: !showRegisterPassword,
          decoration: InputDecoration(
            labelText: "Password",
            suffixIcon: IconButton(
              icon: Icon(showRegisterPassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => showRegisterPassword = !showRegisterPassword),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Terms row: checkbox + clickable terms
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GFCheckbox(
              size: GFSize.SMALL,
              inactiveBgColor: Colors.transparent,
              activeBgColor: GFColors.DARK,
              value: agreePolicy,
              onChanged: (v) => setState(() => agreePolicy = v ?? false),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: 'I agree to the ',
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Terms & Privacy Policy',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = _showTermsDialog,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        GFButton(
          onPressed: _handleRegister,
          text: "Register",
          fullWidthButton: true,
          color: Colors.black,
          shape: GFButtonShape.pills,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffde2e4),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xfff9f9f9),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // SVG Logo
                  SvgPicture.asset(
                    'assets/Webapp.svg',
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(height: 24),

                  // Toggle Login / Register
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xfff5f1f1),
                      border: Border.all(color: Colors.black87),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Stack(
                      children: [
                        AnimatedAlign(
                          alignment: isRegister ? Alignment.centerRight : Alignment.centerLeft,
                          duration: const Duration(milliseconds: 400),
                          child: Container(
                            width: 160,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => setState(() => isRegister = false),
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: isRegister ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: () => setState(() => isRegister = true),
                                child: Text(
                                  "Register",
                                  style: TextStyle(
                                    color: isRegister ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Forms
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 400),
                    crossFadeState: isRegister ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    firstChild: _buildLoginForm(context),
                    secondChild: _buildRegisterForm(context),
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
