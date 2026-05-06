import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/report.dart';
import '../services/database_service.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});
  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _descController = TextEditingController();
  String? _image64, _lat, _lng, _category;
  bool _isLocating = false;
  bool _loading = false;

  final _cats = [
    'Tumpukan Sampah',
    'Saluran Tersumbat',
    'Limbah Berbahaya',
    'Coretan Liar',
  ];

  Future<void> _pickImg() async {
    final img = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() => _image64 = base64Encode(bytes));
    }
  }

  
  Future<void> _getLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _lat = pos.latitude.toString();
        _lng = pos.longitude.toString();
      });
    } finally {
      setState(() => _isLocating = false);
    }
  }

  void _submit() async {
    if (_image64 == null ||
        _category == null ||
        _descController.text.isEmpty ||
        _lat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lengkapi Gambar, Deskripsi, Kategori & Lokasi!"),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    final report = Report(
      image: _image64,
      description: _descController.text,
      category: _category,
      latitude: _lat,
      longitude: _lng,
      userId: user?.uid,
      userFullName: user?.displayName,
    );
    await DatabaseService.addReport(report);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Laporan Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImg,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green),
                ),
                child: _image64 == null
                    ? const Icon(Icons.add_a_photo, size: 40)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.memory(
                          base64Decode(_image64!),
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField(
              hint: const Text("Pilih Kategori"),
              items: _cats
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v as String),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Deskripsi Kondisi",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _getLocation,
                    icon: _isLocating
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(
                      _isLocating ? "Mengambil Koordinat..." : "Get Location",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  _lat != null ? Icons.check_circle : Icons.help_outline,
                  color: _lat != null ? Colors.green : Colors.grey,
                ),
              ],
            ),
            if (_lat != null)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  "Koordinat: $_lat, $_lng",
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("KIRIM LAPORAN"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
