import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/report.dart';
import '../services/database_service.dart';
import 'detail_screen.dart';
import 'add_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Tambahkan Controller dan variabel untuk menampung query pencarian
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 2. Modifikasi AppBar agar lebih interaktif dan estetik
      appBar: AppBar(
        title: const Text(
          "EcoClean Feed",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Cari kategori atau deskripsi...",
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = "";
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Report>>(
        stream: DatabaseService.getReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada laporan kebersihan."));
          }

          // 3. LOGIKA FILTERING: Menyaring data berdasarkan input user
          final allReports = snapshot.data!;
          final filteredReports = allReports.where((report) {
            final category = report.category?.toLowerCase() ?? "";
            final description = report.description?.toLowerCase() ?? "";
            return category.contains(_searchQuery) ||
                description.contains(_searchQuery);
          }).toList();

          if (filteredReports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  Text(
                    "Laporan '$_searchQuery' tidak ditemukan",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: filteredReports.length,
            itemBuilder: (context, i) {
              final report = filteredReports[i];
              return Card(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(report: report),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (report.image != null)
                        Stack(
                          children: [
                            Image.memory(
                              base64Decode(report.image!),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            // Badge Kategori di atas gambar agar lebih modern
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  report.category ?? "Umum",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.description ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      report.userFullName ?? "Anonim",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.favorite,
                                      size: 14,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      "${report.favoriteBy.length}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPostScreen()),
        ),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }
}
