import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:getwidget/getwidget.dart';

import 'homepage-modules/homepage.dart';

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

  void toggleView() {
    setState(() {
      isRegister = !isRegister;
    });
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
                  // SVG Logo at top
                  SvgPicture.asset(
                    'assets/Webapp.svg',
                    height: 120, // Bigger size
                    width: 120,
                  ),
                  const SizedBox(height: 24),

                  // Toggle Buttons for Login/Register
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
                          alignment: isRegister
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          duration: const Duration(milliseconds: 500),
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

                  // Login/Register Forms
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 400),
                    crossFadeState: isRegister
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
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
              onPressed: () =>
                  setState(() => showLoginPassword = !showLoginPassword),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            GFCheckbox(
              size: GFSize.SMALL,
              activeBgColor: GFColors.DARK,
              value: rememberMe,
              onChanged: (v) => setState(() => rememberMe = v ?? false),
            ),
            const Text("Remember Me")
          ],
        ),
        const SizedBox(height: 16),
        GFButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
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
              icon: Icon(showRegisterPassword
                  ? Icons.visibility_off
                  : Icons.visibility),
              onPressed: () =>
                  setState(() => showRegisterPassword = !showRegisterPassword),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            GFCheckbox(
              size: GFSize.SMALL,
              activeBgColor: GFColors.DARK,
              value: agreePolicy,
              onChanged: (v) => setState(() => agreePolicy = v ?? false),
            ),
            const Expanded(
              child: Text("I agree to the Terms & Privacy Policy"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GFButton(
          onPressed: () {
            if (!agreePolicy) {
              GFToast.showToast(
                "Please agree to continue.",
                context,
                toastPosition: GFToastPosition.BOTTOM,
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
          text: "Register",
          fullWidthButton: true,
          color: Colors.black,
          shape: GFButtonShape.pills,
        ),
      ],
    );
  }
}
