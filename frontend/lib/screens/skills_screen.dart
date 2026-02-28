import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/skill.dart';
import '../widgets/skill_chip.dart';
import '../utils/responsive.dart';
import '../utils/add_dialogs.dart';
import '../utils/globals.dart';
import './login_screen.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({Key? key}) : super(key: key);

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  Future<void> _checkAdminStatus() async {
    final status = await ApiService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isAdmin = status;
      });
    }
  }

  Future<void> _navigateToLogin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    if (result == true) {
      _checkAdminStatus();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: _navigateToLogin, // Hidden way to login
          child: const Text('My Skills'),
        ),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ApiService.logout();
                _checkAdminStatus();
              },
            ),
        ],
      ),
      body: FutureBuilder<List<Skill>>(
        future: ApiService.fetchSkills(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text('Error: ${snap.error}'),
                ],
              ),
            );
          }

          final skills = snap.data ?? [];
          if (skills.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.code_off,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No skills added yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: Responsive.pagePadding(context),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Technical Excellence',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.headingMedium(context),
                        ),
                      ),
                      SizedBox(height: Responsive.spacingS(context)),
                      Text(
                        'Skills and technologies I work with',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                          fontSize: Responsive.bodyLarge(context),
                        ),
                      ),
                      SizedBox(height: Responsive.spacingXL(context)),
                      FadeTransition(
                        opacity: Tween<double>(begin: 0, end: 1).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeIn,
                          ),
                        ),
                        child: Wrap(
                          spacing: Responsive.spacingM(context),
                          runSpacing: Responsive.spacingM(context),
                          children: skills
                              .map((skill) => SkillChip(
                                    skill.name,
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}
