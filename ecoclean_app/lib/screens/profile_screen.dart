import 'package:ecoclean_app/main.dart';
import 'package:ecoclean_app/screens/auth/sign_in_screen.dart';
import 'package:ecoclean_app/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? "";
  }

  
  void _showChangePasswordDialog() {
    final oldPass = TextEditingController();
    final newPass = TextEditingController();
    final confirmPass = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Ubah Password Keamanan",
          style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPass,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password Lama",
                  prefixIcon: Icon(Icons.lock_open),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPass,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password Baru",
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPass,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Konfirmasi Password Baru",
                  prefixIcon: Icon(Icons.check_circle_outline),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              if (newPass.text != confirmPass.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Konfirmasi password tidak cocok!"),
                  ),
                );
                return;
              }
              try {
                
                AuthCredential credential = EmailAuthProvider.credential(
                  email: user!.email!,
                  password: oldPass.text,
                );
                await user!.reauthenticateWithCredential(credential);
                await user!.updatePassword(newPass.text);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Password berhasil diperbarui!"),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal: ${e.toString()}")),
                );
              }
            },
            child: const Text(
              "Update Password",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateName() async {
    setState(() => _isSaving = true);
    try {
      await user?.updateDisplayName(_nameController.text.trim());
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nama berhasil diperbarui!")),
        );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isAdmin = DatabaseService.checkIsAdmin(user?.email);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Identity & Security",
          style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.green.shade50,
                    child: Text(
                      user?.displayName?.substring(0, 1).toUpperCase() ?? "U",
                      style: GoogleFonts.urbanist(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  user?.displayName ?? "User Name",
                  style: GoogleFonts.urbanist(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? "",
                  style: GoogleFonts.urbanist(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 10),
                // Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAdmin ? "ADMINISTRATOR" : "VERIFIED USER",
                    style: GoogleFonts.urbanist(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isAdmin ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 35),

          
          _buildSectionTitle("Informasi Pribadi"),
          _buildLuxuryCard(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Nama Lengkap",
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Colors.green,
                    ),
                    suffixIcon: IconButton(
                      icon: _isSaving
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check, color: Colors.green),
                      onPressed: _updateName,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          
          _buildSectionTitle("Keamanan & Preferensi"),
          _buildLuxuryCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_reset, color: Colors.blue),
                  title: const Text("Ubah Password Akun"),
                  subtitle: const Text("Tingkatkan keamanan login Anda"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showChangePasswordDialog,
                ),
                const Divider(),
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeNotifier,
                  builder: (context, mode, _) => SwitchListTile(
                    title: const Text("Mode Tampilan Gelap"),
                    secondary: Icon(
                      mode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: Colors.amber,
                    ),
                    value: mode == ThemeMode.dark,
                    onChanged: (v) => themeNotifier.value = v
                        ? ThemeMode.dark
                        : ThemeMode.light,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                  (r) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text(
              "KELUAR DARI APLIKASI",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.urbanist(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildLuxuryCard({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: child,
    );
  }
}
