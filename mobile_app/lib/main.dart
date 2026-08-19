import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SeniorSocialApp());
}

class SeniorSocialApp extends StatelessWidget {
  const SeniorSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Senior Social India',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FBFF),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFF59E0B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [BoxShadow(blurRadius: 20, color: Color(0x1A1E3A8A))],
                  ),
                  child: const Icon(Icons.groups_rounded, size: 66, color: Color(0xFF1E3A8A)),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Senior Social India',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFF14275F)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connect • Engage • Belong',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E8B57)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Helping India’s seniors connect, join activities, share interests and feel supported in a safe community.',
                style: TextStyle(fontSize: 17, height: 1.45, color: Color(0xFF374151)),
              ),
              const SizedBox(height: 28),
              _InfoCard(
                title: 'Global Access',
                body: 'Access for Indian families in India, United Kingdom, United States, Canada, Australia, UAE and Singapore. Events begin India-first.',
                icon: Icons.public_rounded,
              ),
              const SizedBox(height: 14),
              _InfoCard(
                title: 'Safe first',
                body: 'Members are registered, verified and reviewed before being connected with activities or groups.',
                icon: Icons.verified_user_rounded,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text('Register Interest'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('Already registered? Login'),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: () => _openUrl('https://seniorsocial.in/privacy.html'),
                  child: const Text('Privacy Policy'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _city = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _interests = TextEditingController();
  bool _busy = false;
  String _message = '';

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _city.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _interests.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _message = 'Creating registration...';
    });

    try {
      final auth = FirebaseAuth.instance;
      final db = FirebaseFirestore.instance;
      final credential = await auth.createUserWithEmailAndPassword(
        email: _email.text.trim().toLowerCase(),
        password: _password.text.trim(),
      );
      final user = credential.user!;
      await user.updateDisplayName(_name.text.trim());
      await user.sendEmailVerification();

      await db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'fullName': _name.text.trim(),
        'age': int.tryParse(_age.text.trim()),
        'city': _city.text.trim(),
        'phone': _phone.text.trim(),
        'email': _email.text.trim().toLowerCase(),
        'interests': _interests.text.trim(),
        'lookingFor': 'Friendship and companionship',
        'preferredVerificationMethod': 'Email / mobile verification',
        'emailVerified': user.emailVerified,
        'phoneVerified': false,
        'familyContactVerified': false,
        'adminApproved': false,
        'profileStatus': 'Pending Review',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() => _message = 'Registration saved. Please check email verification. Profile is pending admin review.');
    } on FirebaseAuthException catch (e) {
      setState(() => _message = e.message ?? 'Unable to register.');
    } catch (e) {
      setState(() => _message = 'Unable to register. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Interest')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _field(_name, 'Full name', required: true),
                _field(_age, 'Age', keyboardType: TextInputType.number),
                _field(_city, 'City', required: true),
                _field(_phone, 'Mobile number', required: true, keyboardType: TextInputType.phone),
                _field(_email, 'Email', required: true, keyboardType: TextInputType.emailAddress),
                _field(_password, 'Create password', required: true, obscureText: true),
                _field(_interests, 'Interests', maxLines: 3),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy ? null : _register,
                    child: Text(_busy ? 'Saving...' : 'Register Interest'),
                  ),
                ),
                const SizedBox(height: 14),
                Text(_message, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _message = '';

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim().toLowerCase(),
        password: _password.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PendingApprovalScreen()));
    } on FirebaseAuthException catch (e) {
      setState(() => _message = e.message ?? 'Unable to login.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _field(_email, 'Email', required: true, keyboardType: TextInputType.emailAddress),
            _field(_password, 'Password', required: true, obscureText: true),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: _login, child: const Text('Login'))),
            const SizedBox(height: 14),
            Text(_message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Status')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.hourglass_top_rounded, size: 72, color: Color(0xFFF59E0B)),
            const SizedBox(height: 20),
            Text('Welcome ${user?.displayName ?? ''}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            const Text('Your profile is pending admin review. Senior Social India will verify and approve profiles before connecting members with groups or activities.', style: TextStyle(fontSize: 16, height: 1.45)),
            const SizedBox(height: 22),
            FilledButton(onPressed: () => _openUrl('mailto:info@seniorsocial.in'), child: const Text('Contact Support')),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;

  const _InfoCard({required this.title, required this.body, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(blurRadius: 16, color: Color(0x111E3A8A))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1E3A8A), size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF14275F))),
                const SizedBox(height: 6),
                Text(body, style: const TextStyle(height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _field(
  TextEditingController controller,
  String label, {
  bool required = false,
  bool obscureText = false,
  int maxLines = 1,
  TextInputType? keyboardType,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: required ? '$label *' : label, border: const OutlineInputBorder()),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) return 'Required';
        if (label == 'Create password' && (value == null || value.length < 6)) return 'Minimum 6 characters';
        return null;
      },
    ),
  );
}

Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
