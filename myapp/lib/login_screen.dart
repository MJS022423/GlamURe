import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const LoginScreen({super.key, this.onBack});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isRegister = false;

  // Text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();

  // Handle login
  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar('Please fill in all fields');
      return;
    }

    // TODO: Add your real authentication logic here
    _showSnackbar('Login successful');
  }

  // Handle register
  void _handleRegister() {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackbar('Please fill in all fields');
      return;
    }

    if (password != confirmPassword) {
      _showSnackbar('Passwords do not match');
      return;
    }

    // TODO: Add your real registration logic here
    _showSnackbar('Account created successfully');
  }

  // Snackbar helper
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Toggle between login/register
  Widget _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => setState(() => _isRegister = false),
          style: ElevatedButton.styleFrom(
            backgroundColor: !_isRegister ? Colors.pinkAccent : Colors.grey[300],
            foregroundColor: !_isRegister ? Colors.white : Colors.black,
          ),
          child: const Text('Login'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () => setState(() => _isRegister = true),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isRegister ? Colors.pinkAccent : Colors.grey[300],
            foregroundColor: _isRegister ? Colors.white : Colors.black,
          ),
          child: const Text('Register'),
        ),
      ],
    );
  }

  // Login form
  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login'),
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            minimumSize: const Size.fromHeight(45),
          ),
          child: const Text('Login'),
        ),
      ],
    );
  }

  // Register form
  Widget _buildRegisterForm() {
    return Column(
      key: const ValueKey('register'),
      children: [
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Confirm Password'),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _handleRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            minimumSize: const Size.fromHeight(45),
          ),
          child: const Text('Register'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          children: [
            // Back Button
            if (widget.onBack != null)
              Positioned(
                top: 20,
                left: 24,
                child: TextButton.icon(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  label: const Text(
                    'Back',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),

            // ✅ Responsive layout starts here
            LayoutBuilder(
              builder: (context, constraints) {
                // Wide screen (desktop/web)
                if (constraints.maxWidth > 700) {
                  return Row(
                    children: [
                      // Left - Logo
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Image.asset(
                              'assets/Webapp.svg',
                              height: 200,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.account_circle,
                                  size: 100,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // Divider
                      Container(
                        width: 1,
                        margin: const EdgeInsets.symmetric(vertical: 40),
                        color: Colors.black,
                      ),

                      // Right - Forms
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildToggleButtons(),
                              const SizedBox(height: 40),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (child, animation) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(
                                          _isRegister ? 0.4 : -0.4, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: _isRegister
                                    ? _buildRegisterForm()
                                    : _buildLoginForm(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // Small screen (mobile/tablet)
                else {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Image.asset(
                              'assets/Webapp.svg',
                              height: 120,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.account_circle,
                                  size: 80,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildToggleButtons(),
                        const SizedBox(height: 24),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin:
                                    Offset(_isRegister ? 0.4 : -0.4, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: _isRegister
                              ? _buildRegisterForm()
                              : _buildLoginForm(),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
