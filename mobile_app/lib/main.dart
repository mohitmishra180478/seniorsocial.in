import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_options.dart';

const String legalUndertakingText =
    'I confirm that I am a genuine user and that I will not use Senior Social for abuse, misconduct, harassment, fraud, illegal activity, unsafe behaviour, or misuse of the platform. I understand that any such conduct may lead to suspension/removal and appropriate action or proceedings under applicable Indian law.';

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
      title: 'Senior Social',
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
              const Text('Senior Social', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFF14275F))),
              const SizedBox(height: 8),
              const Text('Connect • Engage • Belong', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E8B57))),
              const SizedBox(height: 24),
              const Text(
                'Helping India’s seniors connect, join activities, share interests and feel supported in a safe community.',
                style: TextStyle(fontSize: 17, height: 1.45, color: Color(0xFF374151)),
              ),
              const SizedBox(height: 28),
              const _InfoCard(
                title: 'Global Access',
                body: 'Access for Indian families in India, United Kingdom, United States, Canada, Australia, UAE and Singapore. Events begin India-first.',
                icon: Icons.public_rounded,
              ),
              const SizedBox(height: 14),
              const _InfoCard(
                title: 'Safe first',
                body: 'Members are registered, email checked, mobile manually reviewed, documents recorded, and admin approved before being connected.',
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
              Center(child: TextButton(onPressed: () => _openUrl('https://seniorsocial.in/privacy.html'), child: const Text('Privacy Policy'))),
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
  final _picker = ImagePicker();

  bool _busy = false;
  bool _legalAccepted = false;
  bool _showPassword = false;
  String _message = '';
  XFile? _passportPhoto;
  XFile? _aadhaarPicture;

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

  String _digits(String value) => value.replaceAll(RegExp(r'\D'), '');

  Future<void> _pickImage({required bool aadhaar}) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    final size = await picked.length();
    if (size > 5 * 1024 * 1024) {
      setState(() => _message = 'Image must be less than 5 MB.');
      return;
    }
    setState(() {
      if (aadhaar) {
        _aadhaarPicture = picked;
      } else {
        _passportPhoto = picked;
      }
    });
  }

  Future<Map<String, dynamic>> _uploadUserFile({required String userUid, required XFile file, required String type}) async {
    final bytes = await file.readAsBytes();
    final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final path = 'users/$userUid/$type-${DateTime.now().millisecondsSinceEpoch}-$safeName';
    final ref = FirebaseStorage.instance.ref(path);
    await ref.putData(bytes, SettableMetadata(contentType: file.mimeType ?? 'image/jpeg'));
    final url = await ref.getDownloadURL();
    return {
      'path': path,
      'url': url,
      'name': file.name,
      'contentType': file.mimeType ?? 'image/jpeg',
      'size': bytes.length,
    };
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _digits(_phone.text.trim());
    final age = int.tryParse(_age.text.trim());

    if (age == null || age < 60) {
      setState(() => _message = 'Age is mandatory and must be 60 years or above.');
      return;
    }
    if (phone.length != 10) {
      setState(() => _message = 'Mobile number must be exactly 10 digits.');
      return;
    }
    if (_passportPhoto == null) {
      setState(() => _message = 'Current passport-size photo is mandatory.');
      return;
    }
    if (_aadhaarPicture == null) {
      setState(() => _message = 'Aadhaar card picture is mandatory for internal records. It is not used for email/mobile verification.');
      return;
    }
    if (!_legalAccepted) {
      setState(() => _message = 'Please accept the legal undertaking before registration.');
      return;
    }

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

      setState(() => _message = 'Uploading passport photo and Aadhaar card picture...');
      final passportPhoto = await _uploadUserFile(userUid: user.uid, file: _passportPhoto!, type: 'passport-photo');
      final aadhaarCardPicture = await _uploadUserFile(userUid: user.uid, file: _aadhaarPicture!, type: 'aadhaar-card');

      await db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'fullName': _name.text.trim(),
        'age': age,
        'city': _city.text.trim(),
        'phone': phone,
        'phoneDisplay': '+91 $phone',
        'email': _email.text.trim().toLowerCase(),
        'interests': _interests.text.trim(),
        'lookingFor': 'Friendship and companionship',
        'preferredVerificationMethod': 'Email verification link plus manual admin mobile/document review',
        'emailVerified': user.emailVerified,
        'phoneVerified': false,
        'phoneVerificationMethod': 'Manual admin verification',
        'familyContactVerified': false,
        'identityDocumentUploaded': true,
        'passportPhotoUploaded': true,
        'passportPhoto': passportPhoto,
        'aadhaarCardPicture': aadhaarCardPicture,
        'aadhaarRecordPurposeOnly': true,
        'aadhaarNotUsedForEmailOrMobileVerification': true,
        'legalUndertakingAccepted': true,
        'legalUndertakingText': legalUndertakingText,
        'adminApproved': false,
        'profileStatus': 'Pending Review',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() => _message = 'Registration saved. Please check your email verification link. Mobile number will be verified manually by admin. Profile is pending admin review.');
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? 'Unable to register.';
      if (e.code == 'email-already-in-use') msg = 'This email is already registered. Please use a different email.';
      if (e.code == 'weak-password') msg = 'Please use a password with at least 6 characters.';
      if (e.code == 'invalid-email') msg = 'Please enter a valid email address.';
      setState(() => _message = msg);
    } catch (_) {
      setState(() => _message = 'Unable to register. Please check Firebase Storage setup and try again.');
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
                _field(_age, 'Age', required: true, keyboardType: TextInputType.number),
                _field(_city, 'City', required: true),
                _field(_phone, 'Mobile number', required: true, keyboardType: TextInputType.phone),
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text('Mobile number must be exactly 10 digits. It will be verified manually by admin; no paid SMS OTP is required.', style: TextStyle(fontSize: 12)),
                ),
                _field(_email, 'Email', required: true, keyboardType: TextInputType.emailAddress),
                _field(_password, 'Create password', required: true, obscureText: !_showPassword),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                    child: Text(_showPassword ? 'Hide password' : 'Show password'),
                  ),
                ),
                _uploadTile(title: 'Current passport-size photo *', file: _passportPhoto, onTap: () => _pickImage(aadhaar: false)),
                _uploadTile(title: 'Aadhaar card picture *', file: _aadhaarPicture, onTap: () => _pickImage(aadhaar: true)),
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text('Aadhaar card picture is collected for internal records only, not for email/mobile verification. JPG, PNG or WEBP, max 5 MB each.', style: TextStyle(fontSize: 12)),
                ),
                _field(_interests, 'Interests', maxLines: 3),
                CheckboxListTile(
                  value: _legalAccepted,
                  onChanged: (value) => setState(() => _legalAccepted = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Legal undertaking *', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text(legalUndertakingText),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(onPressed: _busy ? null : _register, child: Text(_busy ? 'Saving...' : 'Register Interest')),
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
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.text.trim().toLowerCase(), password: _password.text.trim());
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
            const Text('Your profile is pending admin review. Senior Social will verify email, manually review mobile/documents, and approve profiles before connecting members with groups or activities.', style: TextStyle(fontSize: 16, height: 1.45)),
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

Widget _field(TextEditingController controller, String label, {bool required = false, bool obscureText = false, int maxLines = 1, TextInputType? keyboardType}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: required ? '$label *' : label, border: const OutlineInputBorder()),
      validator: (value) {
        final trimmed = value?.trim() ?? '';
        if (required && trimmed.isEmpty) return 'Required';
        if (label == 'Age') {
          final age = int.tryParse(trimmed);
          if (age == null || age < 60) return 'Age must be 60 years or above';
        }
        if (label == 'Mobile number') {
          final digits = trimmed.replaceAll(RegExp(r'\D'), '');
          if (digits.length != 10) return 'Mobile number must be exactly 10 digits';
        }
        if (label == 'Create password' && trimmed.length < 6) return 'Minimum 6 characters';
        return null;
      },
    ),
  );
}

Widget _uploadTile({required String title, required XFile? file, required VoidCallback onTap}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: InputDecorator(
        decoration: InputDecoration(labelText: title, border: const OutlineInputBorder()),
        child: Row(
          children: [
            const Icon(Icons.upload_file_rounded),
            const SizedBox(width: 12),
            Expanded(child: Text(file?.name ?? 'Tap to choose image', overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    ),
  );
}

Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
