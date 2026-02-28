import 'package:flutter/material.dart';
import 'projects_screen.dart';
import 'skills_screen.dart';

import 'package:image_picker/image_picker.dart';
import '../utils/responsive.dart';
import '../models/profile.dart';
import '../services/api_service.dart';
import 'experience_screen.dart';
import 'education_screen.dart';
import '../utils/add_dialogs.dart';
import '../utils/globals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'certificate_screen.dart';
import '../models/language.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onLogout;
  const HomeScreen({Key? key, this.onLogout}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Profile? _profile;
  bool _isLoadingProfile = true;
  late Animation<double> _fadeAnimation;
  late Animation<double> _avatarScaleAnimation;
  late Animation<Offset> _avatarSlideAnimation;
  late Animation<Offset> _nameSlideAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<Offset> _chipsSlideAnimation;
  
  // Background/Content Animations
  late Animation<Offset> _heroContainerSlideAnimation;
  late Animation<Offset> _contentTitleSlideAnimation;
  late Animation<Offset> _aboutSectionSlideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _heroContainerSlideAnimation = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _avatarScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _avatarSlideAnimation = Tween<Offset>(begin: const Offset(0, -1.0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _nameSlideAnimation = Tween<Offset>(begin: const Offset(-0.5, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _titleSlideAnimation = Tween<Offset>(begin: const Offset(0.5, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _chipsSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _contentTitleSlideAnimation = Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _aboutSectionSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final p = await ApiService.getProfile();
      if (mounted) {
        setState(() {
          _profile = p;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final horizontalPadding = isMobile ? 20.0 : 40.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAnnouncementMarquee(),
          // Hero Section
          SlideTransition(
            position: _heroContainerSlideAnimation,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor,
                    Colors.white,
                    Colors.white,
                  ],
                  stops: const [0.0, 0.5, 0.5, 1.0],
                ),
              ),
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 30 : 100,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar Left (Blue Section)
                        Expanded(
                          flex: 1,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Medium size that is proportionate to the section width
                              final double avatarSize = isMobile 
                                  ? (constraints.maxWidth * 0.7).clamp(120.0, 160.0)
                                  : (constraints.maxWidth * 0.5).clamp(180.0, 240.0);
                              
                              return Center(
                                child: SlideTransition(
                                  position: _avatarSlideAnimation,
                                  child: ScaleTransition(
                                    scale: _avatarScaleAnimation,
                                    child: Container(
                                      width: avatarSize,
                                      height: avatarSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: isMobile ? 4 : 6,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: isMobile ? 15 : 25,
                                            spreadRadius: 3,
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: _profile?.photoUrl != null
                                            ? Image.network(
                                                '${ApiService.baseUrl.replaceAll('/api', '')}${_profile!.photoUrl}',
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => _buildAssetAvatar(avatarSize),
                                              )
                                            : _buildAssetAvatar(avatarSize),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Text Right (White Section)
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: isMobile ? 10 : 40,
                              right: isMobile ? 10 : 40,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SlideTransition(
                                  position: _nameSlideAnimation,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      _profile?.name ?? 'Dax Patel',
                                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                        color: Theme.of(context).primaryColor,
                                        letterSpacing: 1.0,
                                        fontSize: isMobile ? 28 : 56,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                SlideTransition(
                                  position: _titleSlideAnimation,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      _profile?.title ?? 'Student / Full Stack Developer',
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                        fontSize: isMobile ? 14 : 28,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                SlideTransition(
                                  position: _chipsSlideAnimation,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 12 : 24,
                                        vertical: isMobile ? 6 : 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        _profile?.heroSkills ?? 'Flutter • Node.js • MongoDB',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isMobile ? 11 : 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content Section
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: Responsive.spacingXL(context),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Access Buttons
                    SlideTransition(
                      position: _contentTitleSlideAnimation,
                      child: Text(
                        'Explore My Work',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.headingMedium(context),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.spacingL(context)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 20),
                      child: GridView.count(
                        crossAxisCount: isMobile ? 3 : 6,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: isMobile ? 1.5 : 2.0,
                        children: [
                        _buildAnimatedCard(
                          0,
                          _buildQuickAccessCard(
                            context,
                            icon: Icons.work,
                            title: 'Projects',
                            description: 'View all projects',
                            color: Theme.of(context).primaryColor,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProjectsScreen()),
                            ),
                          ),
                        ),
                        _buildAnimatedCard(
                          1,
                          _buildQuickAccessCard(
                            context,
                            icon: Icons.code,
                            title: 'Skills',
                            description: 'Tech stack',
                            color: Theme.of(context).colorScheme.secondary,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SkillsScreen()),
                            ),
                          ),
                        ),
                        _buildAnimatedCard(
                          2,
                          _buildQuickAccessCard(
                            context,
                            icon: Icons.business_center,
                            title: 'Experience',
                            description: 'Work history',
                            color: Color(0xFF27AE60),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ExperienceScreen()),
                            ),
                          ),
                        ),
                        _buildAnimatedCard(
                          3,
                          _buildQuickAccessCard(
                            context,
                            icon: Icons.school,
                            title: 'Education',
                            description: 'Qualifications',
                            color: Color(0xFF8E44AD),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EducationScreen()),
                            ),
                          ),
                        ),
                        _buildAnimatedCard(
                          4,
                          _buildQuickAccessCard(
                            context,
                            icon: Icons.verified,
                            title: 'Certificate',
                            description: 'My qualifications',
                            color: Color(0xFF6C5CE7),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CertificateScreen()),
                              );
                            },
                          ),
                        ),
                        _buildAnimatedCard(
                          5,
                          _buildQuickAccessCard(
                            context,
                            icon: Icons.contact_mail,
                            title: 'Contact',
                            description: 'Get in touch',
                            color: Color(0xFFE67E22),
                            onTap: () => AddDialogs.showContactDialog(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.spacingXL(context)),

                    // About Section
                    SlideTransition(
                      position: _aboutSectionSlideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About Me',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.headingMedium(context),
                            ),
                          ),
                          SizedBox(height: Responsive.spacingL(context)),
                          Container(
                            padding: Responsive.cardPadding(context),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _profile?.bio ?? 'I\'m a passionate full-stack developer with expertise in Flutter, Node.js, and MongoDB. I love building beautiful, responsive applications that solve real-world problems. Always learning and improving my craft.',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.6,
                                color: Colors.grey[700],
                                fontSize: Responsive.bodyLarge(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.spacingXL(context)),
                    // Languages Known Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Languages Known',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.headingMedium(context),
                          ),
                        ),
                        SizedBox(height: Responsive.spacingL(context)),
                        FutureBuilder<List<Language>>(
                          future: ApiService.fetchLanguages(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
                            if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text('No languages added yet');
                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: snapshot.data!.map((l) => _buildLanguageChip(
                                context, 
                                l.name, 
                                l.proficiency, 
                                _getLanguageColor(l.name),
                              )).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.spacingXL(context)),
                  ],
                ),
              ),
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }



  Widget _buildAnimatedCard(int index, Widget child) {
    final animation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.6 + (index * 0.05),
          0.9,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return SlideTransition(
      position: animation,
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.6 + (index * 0.05), 0.9, curve: Curves.easeIn),
        ),
        child: child,
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isMobile = Responsive.isMobile(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black, width: 1.0),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: isMobile ? 14 : 16,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 10 : 12,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: isMobile ? 7 : 8,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildAssetAvatar(double avatarSize) {
    return Image.asset(
      'assets/images/photo.jpeg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.white.withOpacity(0.2),
          child: Icon(
            Icons.person,
            size: avatarSize * 0.6,
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildLanguageChip(BuildContext context, String language, String proficiency, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            language,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              proficiency,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLanguageColor(String name) {
    switch (name.toLowerCase()) {
      case 'english': return Colors.blue;
      case 'hindi': return Colors.orange;
      case 'gujarati': return Colors.green;
      default: return Theme.of(context).primaryColor;
    }
  }

  Widget _buildFooter(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E), // Professional Dark Navy
      ),
      child: Column(
        children: [
          // Analytics Row (Compact)
          FutureBuilder<Map<String, dynamic>>(
            future: ApiService.fetchStats(),
            builder: (context, snapshot) {
              final stats = snapshot.data ?? {'users': 0, 'contacts': 0, 'reviews': 0};
              return Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: isMobile ? 20 : 50,
                    runSpacing: 10,
                    children: [
                      _buildStatItem(Icons.people_alt_rounded, '${stats['users']}+', 'Users'),
                      _buildStatItem(Icons.reviews_rounded, '${stats['reviews']}+', 'Reviews'),
                      _buildStatItem(Icons.contact_mail_rounded, '${stats['contacts']}+', 'Contacted'),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () => AddDialogs.showReviewDialog(context, () => setState(() {})),
                    icon: const Icon(Icons.rate_review_rounded, size: 14),
                    label: const Text('Write a Review', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent.withOpacity(0.1),
                      foregroundColor: Colors.blueAccent,
                      side: const BorderSide(color: Colors.blueAccent, width: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      elevation: 0,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 25),
          if (!isMobile)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildFooterBrand(context)),
                Expanded(flex: 2, child: _buildFooterContact(context)),
                Expanded(flex: 1, child: _buildFooterSocials(context)),
              ],
            )
          else
            Column(
              children: [
                _buildFooterBrand(context),
                const SizedBox(height: 20),
                _buildFooterContact(context),
                const SizedBox(height: 20),
                _buildFooterSocials(context),
              ],
            ),
          const SizedBox(height: 25),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          const SizedBox(height: 15),
          isMobile 
            ? Column(
                children: [
                  Text(
                    '© ${DateTime.now().year} ${_profile?.footerCopyright ?? 'All Rights Reserved'}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _profile?.footerCredit ?? 'Made By Dax Patel',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '© ${DateTime.now().year} ${_profile?.footerCopyright ?? 'All Rights Reserved'}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                  Text(
                    _profile?.footerCredit ?? 'Made By Dax Patel',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blueAccent, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterBrand(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          _profile?.footerBrandName ?? 'MyPortfolio',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _profile?.footerTagline ?? 'Digital solutions with passion.',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFooterContact(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        _buildFooterLink(
          context,
          icon: Icons.email_outlined,
          text: _profile?.footerEmail ?? 'daxpatel23@gmail.com',
          onTap: () async {
            final uri = Uri.parse('mailto:${_profile?.footerEmail ?? 'daxpatel23@gmail.com'}');
            if (await canLaunchUrl(uri)) await launchUrl(uri);
          },
        ),
        const SizedBox(height: 6),
        _buildFooterLink(
          context,
          icon: Icons.location_on_outlined,
          text: _profile?.footerLocation ?? 'Gujarat, India',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildFooterSocials(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.end,
      children: [
        const Text(
          'Follow',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMiniSocialIcon(FontAwesomeIcons.linkedin, _profile?.footerLinkedIn ?? 'https://linkedin.com/in/dax-patel', Colors.white),
            const SizedBox(width: 8),
            _buildMiniSocialIcon(FontAwesomeIcons.github, _profile?.footerGitHub ?? 'https://github.com/daxpatel230005', Colors.white),
            const SizedBox(width: 8),
            _buildMiniSocialIcon(FontAwesomeIcons.instagram, _profile?.footerInstagram ?? 'https://instagram.com/daxpatel', Colors.white),
            const SizedBox(width: 8),
            _buildMiniSocialIcon(FontAwesomeIcons.whatsapp, _profile?.footerWhatsApp ?? 'https://wa.me/91XXXXXXXXXX', Colors.white),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterLink(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMiniSocialIcon(IconData icon, String url, Color color) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildSocialIcon(BuildContext context, {required IconData icon, required String url, required Color color}) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildAnnouncementMarquee() {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.fetchAnnouncements(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
        final texts = snapshot.data!.map((e) => e.text).join(' • ');
        return Container(
          height: 30,
          color: Colors.red,
          child: _MarqueeWidget(text: texts),
        );
      },
    );
  }
}

class _MarqueeWidget extends StatefulWidget {
  final String text;
  const _MarqueeWidget({required this.text});

  @override
  _MarqueeWidgetState createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<_MarqueeWidget> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late double _scrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (_scrollController.hasClients) {
        _scrollPosition += 2.0;
        if (_scrollPosition > _scrollController.position.maxScrollExtent) {
          _scrollPosition = 0;
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(_scrollPosition);
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.text,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        );
      },
      itemCount: 100, // Large number to simulate infinite
    );
  }
}

