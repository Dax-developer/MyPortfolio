import 'dart:async';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'utils/add_dialogs.dart';
import 'utils/globals.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await ApiService.isLoggedIn();
    if (loggedIn) {
      // Pre-fetch data for "instant" load
      ApiService.getProfile().catchError((_) => null);
      ApiService.fetchProjects().catchError((_) => []);
      ApiService.fetchSkills().catchError((_) => []);
    }
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: _isLoading 
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : (_isLoggedIn 
            ? Scaffold(
                appBar: AppBar(
                  title: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('My Portfolio'),
                  ),
                  leadingWidth: 100,
                  leading: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: InkWell(
                        onTap: () async {
                          await ApiService.logout();
                          _checkAuth();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF4B2B), Color(0xFFFF416C)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.logout, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    AddDialogs.buildManageButton(context, navigatorKey, () {
                      if (mounted) setState(() {});
                    }),
                    AddDialogs.buildAddButton(context, navigatorKey, () {
                      if (mounted) setState(() {});
                    }),
                    AddDialogs.buildDeleteButton(context, navigatorKey, () {
                      if (mounted) setState(() {});
                    }),
                  ],
                ),
                body: const HomeScreen(),
              )
            : LoginScreen(onLoginSuccess: _checkAuth)),
    );
  }
}
