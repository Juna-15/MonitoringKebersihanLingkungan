import 'package:ecoclean_app/screens/auth/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _signUp() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Data tidak boleh kosong!")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      // Jeda sebentar dan paksa logout
      await Future.delayed(const Duration(milliseconds: 500));
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi Berhasil! Silakan Login.")),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal: ${e.message}")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // PERBAIKAN DI SINI: Menggunakan extendBodyBehindAppBar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Registrasi Akun"),
        backgroundColor:
            Colors.transparent, // Transparan agar menyatu dengan background
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.green.shade800,
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F2027), const Color(0xFF203A43)]
                : [Colors.white, Colors.green.shade50],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            100,
            24,
            24,
          ), // Padding atas agar tidak tertutup AppBar
          child: Column(
            children: [
              Image.asset('assets/images/logo.png', height: 100),
              const SizedBox(height: 10),
              Text(
                "Bergabung dengan Kami",
                style: GoogleFonts.urbanist(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 40),
              _buildInput(
                controller: _nameController,
                label: "Nama Lengkap",
                icon: Icons.person_outline,
                isDark: isDark,
              ),
              const SizedBox(height: 15),
              _buildInput(
                controller: _emailController,
                label: "Email",
                icon: Icons.email_outlined,
                isDark: isDark,
              ),
              const SizedBox(height: 15),
              _buildInput(
                controller: _passwordController,
                label: "Password",
                icon: Icons.lock_outline,
                isDark: isDark,
                isObscure: true,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "DAFTAR SEKARANG",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk Text Field
  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool isObscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: isDark
              ? BorderSide(color: Colors.grey.shade800)
              : BorderSide.none,
        ),
      ),
    );
  }
}
