import 'package:ecoclean_app/main.dart';
import 'package:ecoclean_app/screens/auth/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    // Menampilkan nama user saat ini di TextField
    _nameController.text = user?.displayName ?? "";
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Fungsi untuk update nama di Firebase
  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);
    try {
      await user?.updateDisplayName(_nameController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil diperbarui!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memperbarui profil: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil EcoClean"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Bagian Header / Avatar
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    (user?.displayName != null && user!.displayName!.isNotEmpty)
                        ? user!.displayName![0].toUpperCase()
                        : "U",
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Input Nama
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Nama Lengkap",
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Email: ${user?.email ?? '-'}",
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Tombol Simpan
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _updateProfile,
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text("SIMPAN PERUBAHAN"),
            ),
          ),

          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 10),

          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, _) {
              return SwitchListTile(
                title: const Text("Mode Gelap"),
                subtitle: const Text("Ubah tampilan aplikasi"),
                secondary: Icon(
                  currentMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: Colors.green,
                ),
                activeColor: Colors.green,
                value: currentMode == ThemeMode.dark,
                onChanged: (bool value) {
                  themeNotifier.value = value
                      ? ThemeMode.dark
                      : ThemeMode.light;
                },
              );
            },
          ),

          const SizedBox(height: 40),

          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (mounted) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                  (route) => false,
                );
              }
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout),
                SizedBox(width: 10),
                Text(
                  "KELUAR DARI AKUN",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
