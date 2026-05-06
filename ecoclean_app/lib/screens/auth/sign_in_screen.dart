import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../navigation_wrapper.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  
  void _signIn() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showError("Email dan password wajib diisi");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) _navigateToHome();
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Login Gagal");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  
  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    User? user = await AuthService.signInWithGoogle();

    if (user != null && mounted) {
      _navigateToHome();
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError("Gagal masuk dengan Google");
      }
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const NavigationWrapper()),
      (route) => false,
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          
          _buildBackground(isDark),

        
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  Hero(
                    tag: 'logo',
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset('assets/images/logo.png', height: 80),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "EcoClean",
                    style: GoogleFonts.urbanist(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                      color: isDark ? Colors.white : Colors.green.shade900,
                    ),
                  ),
                  Text(
                    "Lestarikan bumi dengan satu langkah.",
                    style: GoogleFonts.dmSans(
                      color: Colors.blueGrey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 50),

                
                  _buildInput(
                    controller: _emailController,
                    hint: "Email Aktif",
                    icon: Icons.alternate_email_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 15),
                  _buildInput(
                    controller: _passwordController,
                    hint: "Password",
                    icon: Icons.lock_outline_rounded,
                    isDark: isDark,
                    isPass: true,
                  ),

                  const SizedBox(height: 35),

                 
                  _buildPrimaryButton(isDark),

                  const SizedBox(height: 20),

                
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.grey.withOpacity(0.3)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "atau",
                          style: GoogleFonts.dmSans(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Colors.grey.withOpacity(0.3)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

               
                  _buildGoogleButton(isDark),

                  const SizedBox(height: 30),

                  // SIGN UP LINK
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: "Belum punya akun? ",
                        style: GoogleFonts.dmSans(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: "Daftar Sekarang",
                            style: TextStyle(
                              color: isDark
                                  ? Colors.green.shade400
                                  : Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

         
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }

 

  Widget _buildBackground(bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Colors.green.withOpacity(isDark ? 0.05 : 0.03),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -50,
            child: CircleAvatar(
              radius: 120,
              backgroundColor: Colors.green.withOpacity(isDark ? 0.03 : 0.02),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool isPass = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        style: GoogleFonts.dmSans(),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.green, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: _isLoading ? null : _signIn,
        child: Text(
          "MASUK",
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey.shade300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: isDark
              ? Colors.white.withOpacity(0.02)
              : Colors.white,
        ),
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            const Icon(
              Icons.g_mobiledata_rounded,
              color: Colors.redAccent,
              size: 35,
            ),
            const SizedBox(width: 8),
            Text(
              "Masuk dengan Google",
              style: GoogleFonts.dmSans(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
