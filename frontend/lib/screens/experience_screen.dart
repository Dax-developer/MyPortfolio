import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/experience.dart';
import '../utils/responsive.dart';
import '../utils/add_dialogs.dart';
import '../utils/globals.dart';

class ExperienceScreen extends StatefulWidget {
  const ExperienceScreen({Key? key}) : super(key: key);

  @override
  State<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
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
        title: const Text('My Experience'),
      ),
      body: FutureBuilder<List<Experience>>(
        future: ApiService.fetchExperience(),
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
                  const SizedBox(height: 16),
                  Text('Error: ${snap.error}'),
                ],
              ),
            );
          }

          final experiences = snap.data ?? [];
          if (experiences.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No experience added yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: Responsive.spacingL(context),
              horizontal: Responsive.spacingM(context),
            ),
            itemCount: experiences.length,
            itemBuilder: (context, i) {
              return FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      i * 0.1,
                      (i + 1) * 0.1,
                      curve: Curves.easeInOut,
                    ),
                  ),
                ),
                child: _buildExperienceCard(context, experiences[i]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildExperienceCard(BuildContext context, Experience exp) {
    final isMobile = Responsive.isMobile(context);

    return Card(
      margin: EdgeInsets.only(bottom: Responsive.spacingL(context)),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.business_center,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: Responsive.spacingL(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exp.position.isEmpty ? "Position Not Specified" : exp.position,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 16 : 18,
                          ),
                        ),
                        SizedBox(height: Responsive.spacingXS(context)),
                        Text(
                          exp.company.isEmpty ? "Institution / Project Not Specified" : exp.company,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.spacingL(context)),
              // Date Range
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    exp.startDate.isEmpty ? 'N/A' : exp.startDate,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    ' - ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    exp.isCurrently ? 'Present' : exp.endDate ?? 'N/A',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: exp.isCurrently ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.spacingL(context)),
              // Description
              if (exp.description.isNotEmpty)
                Text(
                  exp.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
              SizedBox(height: Responsive.spacingL(context)),
              // Technologies
              Wrap(
                spacing: Responsive.spacingS(context),
                runSpacing: Responsive.spacingS(context),
                children: exp.technologies
                    .map(
                      (tech) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 10 : 12,
                          vertical: isMobile ? 5 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          tech,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: isMobile ? 10 : 11,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
