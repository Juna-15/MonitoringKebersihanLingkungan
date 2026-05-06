import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "Semua";

  
  final List<String> _categories = [
    'Semua',
    'Tumpukan Sampah',
    'Saluran Tersumbat',
    'Limbah Berbahaya',
    'Coretan Liar',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            
            _buildHeader(user, isDark),

            
            _buildFilterSection(isDark),

            
            Expanded(
              child: StreamBuilder<List<Report>>(
                stream: DatabaseService.getReports(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  
                  final filteredReports = snapshot.data!.where((report) {
                    final matchesSearch =
                        report.description!.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ||
                        report.category!.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        );
                    final matchesCategory =
                        _selectedCategory == "Semua" ||
                        report.category == _selectedCategory;
                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (filteredReports.isEmpty) {
                    return _buildNoResultsState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, i) {
                      return _buildReportCard(filteredReports[i], isDark);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPostScreen()),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 4,
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        label: Text(
          "LAPOR",
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  
  Widget _buildHeader(User? user, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo, Selamat Hari Hijau!",
                    style: GoogleFonts.urbanist(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    user?.displayName?.split(' ')[0] ?? "User",
                    style: GoogleFonts.urbanist(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.eco, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Search Bar Modern
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: "Cari area atau jenis laporan...",
              hintStyle: GoogleFonts.urbanist(fontSize: 14, color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.green),
              filled: true,
              fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildFilterSection(bool isDark) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final bool isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: ChoiceChip(
              label: Text(
                cat,
                style: GoogleFonts.urbanist(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey : Colors.black87),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = cat);
              },
              selectedColor: Colors.green.shade700,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: isSelected ? Colors.green.shade700 : Colors.transparent,
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  
  Widget _buildReportCard(Report report, bool isDark) {
    String formattedTime = report.createdAt != null
        ? DateFormat('dd MMM, HH:mm').format(report.createdAt!.toDate())
        : "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailScreen(report: report)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              if (report.image != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                      child: Image.memory(
                        base64Decode(report.image!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    
                    Positioned(
                      top: 15,
                      left: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade700,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          report.category!,
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
              // Info Detail
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Lihat Lokasi",
                              style: GoogleFonts.urbanist(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.green.shade300,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedTime,
                              style: GoogleFonts.urbanist(
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco_outlined,
            size: 80,
            color: Colors.green.withOpacity(0.2),
          ),
          const SizedBox(height: 10),
          const Text(
            "Belum Ada Laporan",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 60, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            "Hasil tidak ditemukan",
            style: GoogleFonts.urbanist(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
