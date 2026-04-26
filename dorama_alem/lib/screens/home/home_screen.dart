import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../viewer/viewer_home.dart';
import '../editor/editor_home.dart';
import '../admin/admin_home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  String _userRole = 'viewer';
  String _userName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final role = await _authService.getUserRole();
    final userData = await _authService.getUserData();
    
    setState(() {
      _userRole = role;
      _userName = userData?['name'] ?? 'Пайдаланушы';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    Widget homeWidget;
    switch (_userRole) {
      case 'admin':
        homeWidget = AdminHome(userName: _userName);
        break;
      case 'editor':
        homeWidget = EditorHome(userName: _userName);
        break;
      default:
        homeWidget = ViewerHome(userName: _userName);
    }

    return homeWidget;
  }
}