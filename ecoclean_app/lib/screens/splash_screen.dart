import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progressValue = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startLoadingSimulation();
  }

  
  void _startLoadingSimulation() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        if (_progressValue < 1.0) {
          _progressValue += 0.01;
        } else {
          _timer?.cancel();
          _navigateToAuthWrapper();
        }
      });
    });
  }

  void _navigateToAuthWrapper() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthWrapper(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(
          milliseconds: 1000,
        ), 
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/splash.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          
          Positioned(
            bottom: 60,
            left: 50,
            right: 50,
            child: Column(
              children: [
                
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progressValue,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 3,
                  ),
                ),
                const SizedBox(height: 15),
                // Teks Status
                Text(
                  "Memulai Perjalanan Hijau Anda...",
                  style: GoogleFonts.urbanist(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
