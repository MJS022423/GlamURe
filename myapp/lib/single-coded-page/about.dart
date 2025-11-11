// myapp/lib/single-coded-page/about.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_bar_builder.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _delayedFade;
  late final Animation<Offset> _delayedSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fade = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(_fade);
    _delayedFade = CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeOut));
    _delayedSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(_delayedFade);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // safe launcher
  Future<void> _openUrl(String raw) async {
    var uriString = raw.trim();
    if (!uriString.startsWith('http')) uriString = 'https://$uriString';
    final uri = Uri.tryParse(uriString);
    if (uri == null) return _showSnack('Invalid URL: $raw');

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) _showSnack('Could not open $uriString');
    } catch (_) {
      _showSnack('Could not open $uriString');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC0CB),
      appBar: _buildAppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: const _Header())),
                  const SizedBox(height: 40),
                  FadeTransition(opacity: _fade, child: SlideTransition(position: _slide, child: const _Content())),
                  const SizedBox(height: 40),
                  FadeTransition(opacity: _delayedFade, child: SlideTransition(position: _delayedSlide, child: const _Tagline())),
                  const SizedBox(height: 60),
                  FadeTransition(
                    opacity: _delayedFade,
                    child: SlideTransition(
                      position: _delayedSlide,
                      child: _ContactSection(onOpen: _openUrl),
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

  // ✅ Removed the back button here
  PreferredSizeWidget _buildAppBar() => buildCustomAppBar("About Us");
}

/* -------------------------
   Small private widgets
   ------------------------- */

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), shape: BoxShape.circle),
          child: SvgPicture.asset('assets/Web-logo.svg', width: 60, height: 60),
        ),
        const SizedBox(height: 24),
        const _AboutTitle(),
      ],
    );
  }
}

class _AboutTitle extends StatelessWidget {
  const _AboutTitle();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.black),
        children: [
          TextSpan(text: 'About '),
          TextSpan(
            text: 'Glamure',
            style: TextStyle(
              color: Colors.black,
              decoration: TextDecoration.underline,
              decorationColor: Colors.black,
              decorationThickness: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _Paragraph(
          'Glamure is more than just a platform — it\'s a vibrant ecosystem built to uplift and empower fashion designers worldwide. Our goal is to inspire creativity, connect communities, and celebrate individuality through the art of design.',
        ),
        SizedBox(height: 24),
        _Paragraph(
          'Every designer — from emerging talents to industry veterans — finds a space to showcase their unique vision. Glamure brings together passion and innovation, creating endless opportunities for artistic growth.',
        ),
      ],
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  const _Paragraph(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, height: 1.6, color: Color(0xFF2C2C2C)),
      );
}

class _Tagline extends StatelessWidget {
  const _Tagline();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.handshake, size: 32, color: Colors.black),
        SizedBox(width: 16),
        Flexible(
          child: Text(
            'Designed for Dreamers. Built for Designers.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
          ),
        ),
      ],
    );
  }
}

class _ContactSection extends StatelessWidget {
  final Future<void> Function(String) onOpen;
  const _ContactSection({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          const Text('Connect With Us', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 20),
          _ContactLink(icon: Icons.discord, label: 'Discord', value: 'https://discord.gg/vdskDjS2', onOpen: onOpen),
          const SizedBox(height: 12),
          _ContactLink(icon: Icons.facebook, label: 'Facebook', value: 'www.facebook.com/kervin.barsaga.902', onOpen: onOpen),
          const SizedBox(height: 12),
          _ContactLink(icon: Icons.camera_alt, label: 'Instagram', value: 'www.instagram.com/ino.zar', onOpen: onOpen),
          const SizedBox(height: 20),
          const Divider(color: Colors.black26),
          const SizedBox(height: 20),
          const Text('For more inquiries, please contact:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF2C2C2C))),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.phone, size: 20, color: Colors.black),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('09701895812', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('09948976959', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Future<void> Function(String) onOpen;
  const _ContactLink({required this.icon, required this.label, required this.value, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onOpen(value),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.black),
          const SizedBox(width: 12),
          Flexible(
            child: Text('$label: $value',
                style: const TextStyle(fontSize: 16, color: Color(0xFF2C2C2C), decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }
}
