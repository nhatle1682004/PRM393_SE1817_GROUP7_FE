import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waste_collection_management_system/presentation/login/login_screen.dart';
import 'package:waste_collection_management_system/presentation/home/home_screen.dart';
import 'package:waste_collection_management_system/presentation/admin/admin_screen.dart';
import 'package:waste_collection_management_system/presentation/enterprise/enterprise_screen.dart';
import 'package:waste_collection_management_system/presentation/collector/collector_screen.dart';
import 'package:waste_collection_management_system/services/storage_service.dart';
import 'package:waste_collection_management_system/data/constants/app_roles.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize location services
  await _initializeLocation();
  
  runApp(const WasteCollectionApp());
}

Future<void> _initializeLocation() async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, app will work without GPS
      return;
    }
    
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  } catch (e) {
    // Silently fail - app can work without location
  }
}

class WasteCollectionApp extends StatefulWidget {
  const WasteCollectionApp({super.key});

  @override
  State<WasteCollectionApp> createState() => _WasteCollectionAppState();
}

class _WasteCollectionAppState extends State<WasteCollectionApp> {
  bool _isChecking = true;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _checkAuthToken();
  }

  Future<void> _checkAuthToken() async {
    final storage = StorageService();
    await storage.getToken(); // Check token exists
    final profile = await storage.getUserProfile();
    
    if (mounted) {
      setState(() {
        _userProfile = profile;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waste Collection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Arial',
      ),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_isChecking) {
      // Loading screen while checking token
      return const Scaffold(
        backgroundColor: Color(0xfff8f9fa),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.eco,
                color: Color(0xff10b981),
                size: 64,
              ),
              SizedBox(height: 24),
              Text(
                'Waste Collection',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0f172a),
                ),
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(
                color: Color(0xff10b981),
              ),
            ],
          ),
        ),
      );
    }

    // Navigate based on token and user role
    if (_userProfile != null) {
      // Check user roleId and navigate accordingly
      // RoleId: 1=Citizen, 2=Enterprise, 3=Collector, 4=Admin
      switch (_userProfile!.roleId) {
        case AppRoles.admin:
          return const AdminScreen();
        case AppRoles.enterprise:
          return const EnterpriseScreen();
        case AppRoles.collector:
          return const CollectorScreen();
        case AppRoles.citizen:
        default:
          return const HomeScreen();
      }
    }
    return const LoginScreen();
  }
}
