import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/education.dart';
import '../services/api_service.dart';
import '../models/profile.dart'; 
import 'package:flutter/services.dart';
import '../models/language.dart';

class AddDialogs {
  static void handleCentralAdd(BuildContext context, GlobalKey<NavigatorState> navigatorKey, VoidCallback onRefresh) async {
    final verified = await _verifyPasscode(navigatorKey);
    if (verified == true) {
      showAddMenu(context, navigatorKey, onRefresh);
    }
  }

  static Widget buildAddButton(BuildContext context, GlobalKey<NavigatorState> navigatorKey, VoidCallback onRefresh) {
    return IconButton(
      icon: Icon(Icons.add, color: Colors.black.withOpacity(0.05)),
      onPressed: () => handleCentralAdd(context, navigatorKey, onRefresh),
      tooltip: 'Add Content',
    );
  }

  static void handleCentralDelete(BuildContext context, GlobalKey<NavigatorState> navigatorKey, VoidCallback onRefresh) async {
    final verified = await _verifyPasscode(navigatorKey);
    if (verified == true) {
      showDeleteMenu(context, navigatorKey, onRefresh);
    }
  }

  static Widget buildDeleteButton(BuildContext context, GlobalKey<NavigatorState> navigatorKey, VoidCallback onRefresh) {
    return IconButton(
      icon: Icon(Icons.delete_outline, color: Colors.black.withOpacity(0.05)),
      onPressed: () => handleCentralDelete(context, navigatorKey, onRefresh),
      tooltip: 'Delete Content',
    );
  }

  static void handleCentralManage(BuildContext context, GlobalKey<NavigatorState> navigatorKey, VoidCallback onRefresh) async {
    final verified = await _verifyPasscode(navigatorKey);
    if (verified == true) {
      showManagementMenu(context, navigatorKey, onRefresh);
    }
  }

  static Widget buildManageButton(BuildContext context, GlobalKey<NavigatorState> navigatorKey, VoidCallback onRefresh) {
    return IconButton(
      icon: Icon(Icons.settings, color: Colors.black.withOpacity(0.05)),
      onPressed: () => handleCentralManage(context, navigatorKey, onRefresh),
      tooltip: 'Admin Management',
    );
  }

  static Future<bool?> _verifyPasscode(GlobalKey<NavigatorState> navigatorKey) async {
    final controller = TextEditingController();
    final context = navigatorKey.currentContext!;
    bool isLoading = false;

    return showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Admin Access Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter Secret Passcode',
                  hintText: 'Passcode',
                ),
                autofocus: true,
                onSubmitted: isLoading ? null : (val) async {
                  setDialogState(() => isLoading = true);
                  final success = await ApiService.verifyAdminPasscode(val);
                  setDialogState(() => isLoading = false);
                  if (success) {
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect Passcode')));
                  }
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                  _showAdminPasscodeResetDialog(context);
                },
                child: const Text('Forgot Passcode?'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                setDialogState(() => isLoading = true);
                final success = await ApiService.verifyAdminPasscode(controller.text);
                setDialogState(() => isLoading = false);
                if (success) {
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect Passcode')));
                }
              },
              child: isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                : const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }

  static void _showAdminPasscodeResetDialog(BuildContext context) async {
    final otpController = TextEditingController();
    final newPasscodeController = TextEditingController();
    bool isOtpSent = false;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Reset Admin Passcode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isOtpSent)
                const Text('OTP will be sent to your registered email (daxpatel230005@gmail.com).'),
              if (isOtpSent) ...[
                TextField(controller: otpController, decoration: const InputDecoration(labelText: 'Enter OTP')),
                TextField(controller: newPasscodeController, decoration: const InputDecoration(labelText: 'New Passcode'), obscureText: true),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                setDialogState(() => isLoading = true);
                try {
                  if (!isOtpSent) {
                    await ApiService.requestAdminPasscodeOtp();
                    setDialogState(() {
                      isOtpSent = true;
                      isLoading = false;
                    });
                  } else {
                    await ApiService.resetAdminPasscode(otpController.text, newPasscodeController.text);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passcode reset successful!')));
                    }
                  }
                } catch (e) {
                  setDialogState(() => isLoading = false);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                : Text(isOtpSent ? 'Reset' : 'Send OTP'),
            ),
          ],
        ),
      ),
    );
  }

  static void showAddMenu(BuildContext context, GlobalKey<NavigatorState> navigatorKey, VoidCallback onRefresh) {
    showModalBottomSheet(
      context: navigatorKey.currentContext!,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.work),
                title: const Text('Add Project'),
                onTap: () {
                  Navigator.pop(context);
                  showAddProjectDialog(navigatorKey.currentContext!, onRefresh);
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Manage Languages'),
                onTap: () {
                  Navigator.pop(context);
                  showLanguageManager(navigatorKey.currentContext!, onRefresh);
                },
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Add Skill'),
                onTap: () {
                  Navigator.pop(context);
                  showAddSkillDialog(navigatorKey.currentContext!, onRefresh);
                },
              ),
              ListTile(
                leading: const Icon(Icons.business_center),
                title: const Text('Add Experience'),
                onTap: () {
                  Navigator.pop(context);
                  showAddExperienceDialog(navigatorKey.currentContext!, onRefresh);
                },
              ),
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text('Add Education'),
                onTap: () {
                  Navigator.pop(context);
                  showAddEducationDialog(navigatorKey.currentContext!, onRefresh);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.orange),
                title: const Text('Edit About Me', style: TextStyle(color: Colors.orange)),
                onTap: () {
                  Navigator.pop(context);
                  showEditAboutDialog(navigatorKey.currentContext!, onRefresh);
                },
              ),
              ListTile(
                leading: const Icon(Icons.verified, color: Colors.blue),
                title: const Text('Upload Certificate', style: TextStyle(color: Colors.blue)),
                onTap: () {
                  Navigator.pop(context);
                  showAddCertificateDialog(navigatorKey.currentContext!, onRefresh);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.blueAccent),
                title: const Text('Change Profile Photo', style: TextStyle(color: Colors.blueAccent)),
                onTap: () {
                  Navigator.pop(context);
                  showChangePhotoDialog(navigatorKey.currentContext!, onRefresh);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.announcement, color: Colors.purple),
                title: const Text('Manage Announcements', style: TextStyle(color: Colors.purple)),
                onTap: () {
                  Navigator.pop(context);
                  showAnnouncementManager(navigatorKey.currentContext!, onRefresh);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.teal),
                title: const Text('Edit Content', style: TextStyle(color: Colors.teal)),
                onTap: () {
                  Navigator.pop(context);
                  showEditMenu(context, navigatorKey, onRefresh);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Lock Sessions', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await ApiService.logout();
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(const SnackBar(content: Text('Sessions locked')));
                    onRefresh();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showManagementMenu(BuildContext context, GlobalKey<NavigatorState> navigatorKey, VoidCallback onRefresh) {
    showModalBottomSheet(
      context: navigatorKey.currentContext!,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add_circle_outline, color: Colors.green),
                title: const Text('Add Menu'),
                onTap: () {
                  Navigator.pop(context);
                  showAddMenu(context, navigatorKey, onRefresh);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete Menu'),
                onTap: () {
                  Navigator.pop(context);
                  showDeleteMenu(context, navigatorKey, onRefresh);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.orange),
                title: const Text('Edit Menu'),
                onTap: () {
                  Navigator.pop(context);
                  showEditMenu(context, navigatorKey, onRefresh);
                },
              ),
              ListTile(
                leading: const Icon(Icons.announcement, color: Colors.purple),
                title: const Text('Manage Announcements'),
                onTap: () {
                  Navigator.pop(context);
                  showAnnouncementManager(navigatorKey.currentContext!, onRefresh);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showEditMenu(BuildContext context, GlobalKey<NavigatorState> navigatorKey, VoidCallback onRefresh) {
    showModalBottomSheet(
      context: navigatorKey.currentContext!,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.work, color: Colors.orange),
              title: const Text('Edit Projects'),
              onTap: () {
                Navigator.pop(context);
                _showEditProjectsPicker(navigatorKey.currentContext!, onRefresh);
              },
            ),
            ListTile(
              leading: const Icon(Icons.code, color: Colors.orange),
              title: const Text('Edit Skills'),
              onTap: () {
                Navigator.pop(context);
                _showEditSkillsPicker(navigatorKey.currentContext!, onRefresh);
              },
            ),
            ListTile(
              leading: const Icon(Icons.business_center, color: Colors.orange),
              title: const Text('Edit Experience'),
              onTap: () {
                Navigator.pop(context);
                _showEditExperiencePicker(navigatorKey.currentContext!, onRefresh);
              },
            ),
            ListTile(
              leading: const Icon(Icons.school, color: Colors.orange),
              title: const Text('Edit Education'),
              onTap: () {
                Navigator.pop(context);
                _showEditEducationPicker(navigatorKey.currentContext!, onRefresh);
              },
            ),
            ListTile(
              leading: const Icon(Icons.art_track_rounded, color: Colors.orange),
              title: const Text('Edit Footer'),
              onTap: () {
                Navigator.pop(context);
                showEditFooterDialog(navigatorKey.currentContext!, onRefresh);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Colors.orange),
              title: const Text('Change Profile Photo', style: TextStyle(color: Colors.orange)),
              onTap: () {
                Navigator.pop(context);
                showChangePhotoDialog(navigatorKey.currentContext!, onRefresh);
              },
            ),
          ],
        ),
      ),
    );
  }

  static void showDeleteMenu(BuildContext context, GlobalKey<NavigatorState> navigatorKey, VoidCallback onRefresh) {
    showModalBottomSheet(
      context: navigatorKey.currentContext!,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.work, color: Colors.red),
              title: const Text('Delete Projects'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteProjectsPicker(navigatorKey.currentContext!, onRefresh);
              },
            ),
            ListTile(
              leading: const Icon(Icons.code, color: Colors.red),
              title: const Text('Delete Skills'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteSkillsPicker(navigatorKey.currentContext!, onRefresh);
              },
            ),
            ListTile(
              leading: const Icon(Icons.business_center, color: Colors.red),
              title: const Text('Delete Experience'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteExperiencePicker(navigatorKey.currentContext!, onRefresh);
              },
            ),
            ListTile(
              leading: const Icon(Icons.school, color: Colors.red),
              title: const Text('Delete Education'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteEducationPicker(navigatorKey.currentContext!, onRefresh);
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified, color: Colors.red),
              title: const Text('Delete Certificates'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteCertificatesPicker(navigatorKey.currentContext!, onRefresh);
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _showDeleteProjectsPicker(BuildContext context, VoidCallback onRefresh) {
    List<String> selectedIds = [];
    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Projects to Delete'),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<List<dynamic>>(
              future: ApiService.fetchProjects(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snap.hasData || snap.data!.isEmpty) return const Text('No projects found.');
                final projects = snap.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: projects.length,
                  itemBuilder: (context, i) {
                    final p = projects[i];
                    return CheckboxListTile(
                      title: Text(p.title),
                      value: selectedIds.contains(p.id),
                      onChanged: (val) {
                        setDialogState(() {
                          if (val == true) selectedIds.add(p.id);
                          else selectedIds.remove(p.id);
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: (isDeleting || selectedIds.isEmpty) ? null : () async {
                final confirm = await _showConfirmBulkDelete(context, 'Projects', selectedIds.length);
                if (confirm == true) {
                  setDialogState(() => isDeleting = true);
                  try {
                    await ApiService.deleteProjectsBulk(selectedIds);
                    if (context.mounted) {
                      Navigator.pop(context);
                      onRefresh();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${selectedIds.length} projects deleted!')));
                    }
                  } catch (e) {
                    setDialogState(() => isDeleting = false);
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: isDeleting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Delete Selected'),
            ),
          ],
        ),
      ),
    );
  }

  static void _showDeleteSkillsPicker(BuildContext context, VoidCallback onRefresh) {
    List<String> selectedIds = [];
    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Skills to Delete'),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<List<dynamic>>(
              future: ApiService.fetchSkills(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snap.hasData || snap.data!.isEmpty) return const Text('No skills found.');
                final skills = snap.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: skills.length,
                  itemBuilder: (context, i) {
                    final s = skills[i];
                    return CheckboxListTile(
                      title: Text(s.name),
                      value: selectedIds.contains(s.id),
                      onChanged: (val) {
                        setDialogState(() {
                          if (val == true) selectedIds.add(s.id);
                          else selectedIds.remove(s.id);
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: (isDeleting || selectedIds.isEmpty) ? null : () async {
                final confirm = await _showConfirmBulkDelete(context, 'Skills', selectedIds.length);
                if (confirm == true) {
                  setDialogState(() => isDeleting = true);
                  try {
                    await ApiService.deleteSkillsBulk(selectedIds);
                    if (context.mounted) {
                      Navigator.pop(context);
                      onRefresh();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${selectedIds.length} skills deleted!')));
                    }
                  } catch (e) {
                    setDialogState(() => isDeleting = false);
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: isDeleting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Delete Selected'),
            ),
          ],
        ),
      ),
    );
  }

  static void _showDeleteExperiencePicker(BuildContext context, VoidCallback onRefresh) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Experience to Delete'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<dynamic>>(
            future: ApiService.fetchExperience(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snap.hasData || snap.data!.isEmpty) return const Text('No experience found.');
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snap.data!.length,
                itemBuilder: (context, i) {
                  final e = snap.data![i];
                  return ListTile(
                    title: Text(e.position),
                    subtitle: Text(e.company),
                    trailing: const Icon(Icons.delete, color: Colors.red),
                    onTap: () async {
                      final confirm = await _showConfirmDelete(context, 'Experience', e.position);
                      if (confirm == true) {
                        await ApiService.deleteExperience(e.id);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Experience deleted successfully!')));
                        }
                        onRefresh();
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  static void _showDeleteEducationPicker(BuildContext context, VoidCallback onRefresh) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Education to Delete'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<dynamic>>(
            future: ApiService.fetchEducation(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snap.hasData || snap.data!.isEmpty) return const Text('No education entries found.');
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snap.data!.length,
                itemBuilder: (context, i) {
                  final e = snap.data![i];
                  return ListTile(
                    title: Text(e.degree),
                    subtitle: Text(e.institution),
                    trailing: const Icon(Icons.delete, color: Colors.red),
                    onTap: () async {
                      final confirm = await _showConfirmDelete(context, 'Education', e.degree);
                      if (confirm == true) {
                        await ApiService.deleteEducation(e.id);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Education deleted successfully!')));
                        }
                        onRefresh();
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  static void _showDeleteCertificatesPicker(BuildContext context, VoidCallback onRefresh) {
    List<String> selectedIds = [];
    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Certificates to Delete'),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<List<dynamic>>(
              future: ApiService.fetchCertificates(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snap.hasData || snap.data!.isEmpty) return const Text('No certificates found.');
                final certs = snap.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: certs.length,
                  itemBuilder: (context, i) {
                    final c = certs[i];
                    return CheckboxListTile(
                      title: Text(c.name),
                      value: selectedIds.contains(c.id),
                      onChanged: (val) {
                        setDialogState(() {
                          if (val == true) selectedIds.add(c.id);
                          else selectedIds.remove(c.id);
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: (isDeleting || selectedIds.isEmpty) ? null : () async {
                final confirm = await _showConfirmBulkDelete(context, 'Certificates', selectedIds.length);
                if (confirm == true) {
                  setDialogState(() => isDeleting = true);
                  try {
                    await ApiService.deleteCertificatesBulk(selectedIds);
                    if (context.mounted) {
                      Navigator.pop(context);
                      onRefresh();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${selectedIds.length} certificates deleted!')));
                    }
                  } catch (e) {
                    setDialogState(() => isDeleting = false);
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: isDeleting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Delete Selected'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<bool?> _showConfirmDelete(BuildContext context, String category, String name) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this $category: "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  static Future<bool?> _showConfirmBulkDelete(BuildContext context, String category, int count) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Bulk Delete'),
        content: Text('Are you sure you want to delete $count $category?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete All', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  static void showAddProjectDialog(BuildContext context, VoidCallback onRefresh) {
    final titleController = TextEditingController();
    final roleController = TextEditingController();
    final descController = TextEditingController();
    final techController = TextEditingController();
    final githubController = TextEditingController();
    final demoController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add New Project'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Project Title'), autofocus: true),
                  TextField(controller: roleController, decoration: const InputDecoration(labelText: 'Role')),
                  TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                  TextField(controller: techController, decoration: const InputDecoration(labelText: 'Technologies (comma separated)')),
                  TextField(controller: githubController, decoration: const InputDecoration(labelText: 'GitHub URL')),
                  TextField(controller: demoController, decoration: const InputDecoration(labelText: 'Live Demo URL')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: isLoading ? null : () async {
                  final title = titleController.text.trim();
                  if (title.isEmpty) return;
                  setDialogState(() => isLoading = true);
                  try {
                    final projectData = {
                      'title': title,
                      'role': roleController.text.trim(),
                      'description': descController.text.trim(),
                      'tech': techController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                      'githubUrl': githubController.text.trim(),
                      'url': demoController.text.trim(),
                    };
                    await ApiService.createProject(projectData);
                    onRefresh();
                    // Clear fields for another entry
                    titleController.clear();
                    roleController.clear();
                    descController.clear();
                    techController.clear();
                    githubController.clear();
                    demoController.clear();
                    setDialogState(() => isLoading = false);
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project added! Add another or cancel.')));
                  } catch (e) {
                    setDialogState(() => isLoading = false);
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: const Text('Add Another'),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  final title = titleController.text.trim();
                  if (title.isEmpty) return;
                  setDialogState(() => isLoading = true);
                  try {
                    final projectData = {
                      'title': title,
                      'role': roleController.text.trim(),
                      'description': descController.text.trim(),
                      'tech': techController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                      'githubUrl': githubController.text.trim(),
                      'url': demoController.text.trim(),
                    };
                    await ApiService.createProject(projectData);
                    if (context.mounted) {
                      Navigator.pop(context);
                      onRefresh();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project added!')));
                    }
                  } catch (e) {
                    setDialogState(() => isLoading = false);
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Add & Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  static void showAddSkillDialog(BuildContext context, VoidCallback onRefresh) {
    final nameController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Skills (Bulk)'),
            content: TextField(
              controller: nameController, 
              decoration: const InputDecoration(
                labelText: 'Skill Names',
                hintText: 'Flutter, Dart, Node.js...',
              ), 
              autofocus: true,
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  final input = nameController.text.trim();
                  if (input.isEmpty) return;
                  final names = input.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                  if (names.isEmpty) return;

                  setDialogState(() => isLoading = true);
                  try {
                    await ApiService.createSkillsBulk(names);
                    if (context.mounted) {
                      Navigator.pop(context);
                      onRefresh();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${names.length} skills added!')));
                    }
                  } catch (e) {
                    setDialogState(() => isLoading = false);
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Add Skills'),
              ),
            ],
          );
        },
      ),
    );
  }

  static void showAddExperienceDialog(BuildContext context, VoidCallback onRefresh) {
    final titleController = TextEditingController();
    final companyController = TextEditingController();
    final descController = TextEditingController();
    final techController = TextEditingController();
    final startController = TextEditingController();
    final endController = TextEditingController();
    bool isCurrently = false;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Experience / Event'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                  TextField(controller: companyController, decoration: const InputDecoration(labelText: 'Organization')),
                  TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                  TextField(controller: techController, decoration: const InputDecoration(labelText: 'Technologies')),
                  TextField(controller: startController, decoration: const InputDecoration(labelText: 'Start Date')),
                  TextField(controller: endController, decoration: const InputDecoration(labelText: 'End Date')),
                  CheckboxListTile(
                    title: const Text('Currently working'),
                    value: isCurrently,
                    onChanged: (val) => setDialogState(() => isCurrently = val ?? false),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  setDialogState(() => isLoading = true);
                  try {
                    final expData = {
                      'position': titleController.text.trim(),
                      'company': companyController.text.trim(),
                      'description': descController.text.trim(),
                      'technologies': techController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                      'startDate': startController.text.trim(),
                      'endDate': endController.text.trim(),
                      'isCurrently': isCurrently,
                    };
                    await ApiService.createExperience(expData);
                    if (context.mounted) {
                      Navigator.pop(context);
                      onRefresh();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Experience added successfully!')));
                    }
                  } catch (e) {
                    setDialogState(() => isLoading = false);
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  static void showAddEducationDialog(BuildContext context, VoidCallback onRefresh) {
    final degreeController = TextEditingController();
    final collegeController = TextEditingController();
    final yearController = TextEditingController();
    final gradeController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Education'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: degreeController, decoration: const InputDecoration(labelText: 'Degree')),
                  TextField(controller: collegeController, decoration: const InputDecoration(labelText: 'College')),
                  TextField(controller: yearController, decoration: const InputDecoration(labelText: 'Year')),
                  TextField(controller: gradeController, decoration: const InputDecoration(labelText: 'Grade')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  setDialogState(() => isLoading = true);
                  try {
                    final fields = {
                      'degree': degreeController.text.trim(),
                      'institution': collegeController.text.trim(),
                      'year': yearController.text.trim(),
                      'grade': gradeController.text.trim(),
                    };
                    await ApiService.createEducation(fields);
                    if (context.mounted) {
                      Navigator.pop(context);
                      onRefresh();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Education added successfully!')));
                    }
                  } catch (e) {
                    setDialogState(() => isLoading = false);
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  static void showChangePhotoDialog(BuildContext context, VoidCallback onRefresh) async {
    final profile = await ApiService.getProfile();
    final hasPhoto = profile.photoUrl != null;
    XFile? newPhoto;
    bool isLoading = false;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(hasPhoto ? 'Change Profile Photo' : 'Upload Profile Photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (newPhoto != null)
                Column(
                  children: [
                    const Text('Preview:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(Icons.person, size: 50, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(newPhoto!.name, style: const TextStyle(fontSize: 12)),
                  ],
                )
              else if (hasPhoto)
                const Text('Current photo is set. You can replace or delete it.')
              else
                const Text('No profile photo set. Upload one to personalize your header.'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            if (hasPhoto)
              TextButton(
                onPressed: isLoading ? null : () async {
                  setDialogState(() => isLoading = true);
                  try {
                    await ApiService.deleteProfilePhoto();
                    if (context.mounted) {
                      Navigator.pop(context);
                      onRefresh();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo removed')));
                    }
                  } catch (e) {
                    setDialogState(() => isLoading = false);
                  }
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                final picker = ImagePicker();
                final file = await picker.pickImage(source: ImageSource.gallery);
                if (file != null) {
                  setDialogState(() => newPhoto = file);
                  setDialogState(() => isLoading = true);
                  try {
                    final bytes = await file.readAsBytes();
                    await ApiService.uploadProfilePhoto(bytes, file.name);
                    if (context.mounted) {
                      Navigator.pop(context);
                      onRefresh();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo updated!')));
                    }
                  } catch (e) {
                    setDialogState(() => isLoading = false);
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: Text(hasPhoto ? 'Replace' : 'Upload'),
            ),
          ],
        ),
      ),
    );
  }

  static void showEditAboutDialog(BuildContext context, VoidCallback onRefresh) async {
    final profile = await ApiService.getProfile();
    final aboutController = TextEditingController(text: profile.bio);
    bool isLoading = false;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit About Me'),
          content: TextField(
            controller: aboutController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'About Me / Bio',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                setDialogState(() => isLoading = true);
                try {
                  await ApiService.updateProfile({'bio': aboutController.text.trim()});
                  if (context.mounted) {
                    Navigator.pop(context);
                    onRefresh();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('About Me updated!')));
                  }
                } catch (e) {
                  setDialogState(() => isLoading = false);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  static void showContactDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final mobileController = TextEditingController();
    final messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Contact Me'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)),
                    validator: (v) => v == null || v.isEmpty ? 'Please enter your name' : null,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || v.isEmpty || !v.contains('@') ? 'Please enter a valid email' : null,
                  ),
                  TextFormField(
                    controller: mobileController,
                    decoration: const InputDecoration(labelText: 'Mobile Number', prefixIcon: Icon(Icons.phone)),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter your mobile number';
                      if (v.length != 10) return 'Mobile number must be exactly 10 digits';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: messageController,
                    decoration: const InputDecoration(labelText: 'Message (Optional)', prefixIcon: Icon(Icons.message)),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setDialogState(() => isLoading = true);
                        try {
                          await ApiService.sendContactMessage(
                            nameController.text.trim(),
                            emailController.text.trim(),
                            mobileController.text.trim(),
                            message: messageController.text.trim(),
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Message sent successfully!')),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isLoading = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  static void showEditHeroDialog(BuildContext context, VoidCallback onRefresh) async {
    final profile = await ApiService.getProfile();
    final nameController = TextEditingController(text: profile.name);
    final titleController = TextEditingController(text: profile.title);
    final heroSkillsController = TextEditingController(text: profile.heroSkills);
    bool isLoading = false;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Hero Section'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: heroSkillsController,
                  decoration: const InputDecoration(
                    labelText: 'Hero Skills (e.g. Flutter • Node.js • MongoDB)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                setDialogState(() => isLoading = true);
                try {
                  await ApiService.updateProfile({
                    'name': nameController.text.trim(),
                    'title': titleController.text.trim(),
                    'heroSkills': heroSkillsController.text.trim(),
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    onRefresh();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hero Section updated!')));
                  }
                } catch (e) {
                  setDialogState(() => isLoading = false);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  static void showEditFooterDialog(BuildContext context, VoidCallback onRefresh) async {
    final profile = await ApiService.getProfile();
    final brandController = TextEditingController(text: profile.footerBrandName ?? 'MyPortfolio');
    final taglineController = TextEditingController(text: profile.footerTagline ?? 'Digital solutions with passion.');
    final emailController = TextEditingController(text: profile.footerEmail ?? 'daxpatel23@gmail.com');
    final locationController = TextEditingController(text: profile.footerLocation ?? 'Gujarat, India');
    final linkedinController = TextEditingController(text: profile.footerLinkedIn ?? 'https://linkedin.com/in/dax-patel');
    final githubController = TextEditingController(text: profile.footerGitHub ?? 'https://github.com/daxpatel230005');
    final instagramController = TextEditingController(text: profile.footerInstagram ?? 'https://instagram.com/daxpatel');
    final whatsappController = TextEditingController(text: profile.footerWhatsApp ?? 'https://wa.me/91XXXXXXXXXX');
    final copyrightController = TextEditingController(text: profile.footerCopyright ?? 'All Rights Reserved');
    final creditController = TextEditingController(text: profile.footerCredit ?? 'Made By Dax Patel');
    
    bool isLoading = false;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Footer Content'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Brand Info', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                TextField(controller: brandController, decoration: const InputDecoration(labelText: 'Brand Name')),
                TextField(controller: taglineController, decoration: const InputDecoration(labelText: 'Tagline')),
                const SizedBox(height: 15),
                const Text('Contact Info', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
                const SizedBox(height: 15),
                const Text('Social Links', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                TextField(controller: linkedinController, decoration: const InputDecoration(labelText: 'LinkedIn URL')),
                TextField(controller: githubController, decoration: const InputDecoration(labelText: 'GitHub URL')),
                TextField(controller: instagramController, decoration: const InputDecoration(labelText: 'Instagram URL')),
                TextField(controller: whatsappController, decoration: const InputDecoration(labelText: 'WhatsApp URL')),
                const SizedBox(height: 15),
                const Text('Bottom Bar', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                TextField(controller: copyrightController, decoration: const InputDecoration(labelText: 'Copyright Footer Text')),
                TextField(controller: creditController, decoration: const InputDecoration(labelText: 'Credit (e.g. Made By Dax Patel)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                setDialogState(() => isLoading = true);
                try {
                  await ApiService.updateProfile({
                    'footerBrandName': brandController.text.trim(),
                    'footerTagline': taglineController.text.trim(),
                    'footerEmail': emailController.text.trim(),
                    'footerLocation': locationController.text.trim(),
                    'footerLinkedIn': linkedinController.text.trim(),
                    'footerGitHub': githubController.text.trim(),
                    'footerInstagram': instagramController.text.trim(),
                    'footerWhatsApp': whatsappController.text.trim(),
                    'footerCopyright': copyrightController.text.trim(),
                    'footerCredit': creditController.text.trim(),
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    onRefresh();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Footer updated!')));
                  }
                } catch (e) {
                  setDialogState(() => isLoading = false);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  static void showAddCertificateDialog(BuildContext context, VoidCallback onRefresh) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    List<XFile> selectedFiles = [];
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Upload Certificates'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedFiles.length <= 1)
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Certificate Name'),
                    autofocus: true,
                  ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description (Optional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                if (selectedFiles.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      children: [
                        Text('Selected (${selectedFiles.length}):', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ...selectedFiles.take(3).map((f) => Text(f.name, style: const TextStyle(fontSize: 10))),
                        if (selectedFiles.length > 3) Text('... and ${selectedFiles.length - 3} more', style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final files = await picker.pickMultiImage();
                    if (files.isNotEmpty) {
                      setDialogState(() => selectedFiles = files);
                    }
                  },
                  icon: const Icon(Icons.attach_file),
                  label: Text(selectedFiles.isEmpty ? 'Select Certificate Files' : 'Change Files'),
                ),
                if (selectedFiles.length > 1)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text('Note: Multiple files will use their filenames as certificate names.', 
                      style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.orange)),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: (isLoading || selectedFiles.isEmpty) ? null : () async {
                setDialogState(() => isLoading = true);
                try {
                  for (var file in selectedFiles) {
                    final bytes = await file.readAsBytes();
                    final name = selectedFiles.length == 1 
                        ? (nameController.text.trim().isEmpty ? file.name : nameController.text.trim())
                        : file.name;
                    await ApiService.uploadCertificate(
                      bytes, 
                      name, 
                      descController.text.trim(), 
                      file.name
                    );
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    onRefresh();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${selectedFiles.length} certificates uploaded!')));
                  }
                } catch (e) {
                  setDialogState(() => isLoading = false);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                : const Text('Upload All'),
            ),
          ],
        ),
      ),
    );
  }
  static void showAnnouncementManager(BuildContext context, VoidCallback onRefresh) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Announcement Manager'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create New Advertisement'),
                onPressed: () => _showCreateAnnouncementDialog(context, onRefresh),
              ),
              const SizedBox(height: 16),
              const Text('Active Advertisements:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: ApiService.fetchAnnouncements(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (!snap.hasData || snap.data!.isEmpty) return const Text('No ads found.');
                    return ListView.builder(
                      itemCount: snap.data!.length,
                      itemBuilder: (context, i) {
                        final ad = snap.data![i];
                        return ListTile(
                          title: Text(ad.text),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await ApiService.deleteAnnouncement(ad.id);
                              onRefresh();
                              if (context.mounted) Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  static void _showCreateAnnouncementDialog(BuildContext context, VoidCallback onRefresh) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Advertisement'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Ad Text (will animate in red line)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await ApiService.createAnnouncement(controller.text.trim());
              onRefresh();
              if (context.mounted) {
                Navigator.pop(context); // Close create dialog
                Navigator.pop(context); // Close manager to refresh lists
                showAnnouncementManager(context, onRefresh);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  static void _showEditProjectsPicker(BuildContext context, VoidCallback onRefresh) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Project to Edit'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<dynamic>>(
            future: ApiService.fetchProjects(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snap.hasData || snap.data!.isEmpty) return const Text('No projects found.');
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snap.data!.length,
                itemBuilder: (context, i) {
                  final p = snap.data![i];
                  return ListTile(
                    title: Text(p.title),
                    trailing: const Icon(Icons.edit, color: Colors.orange),
                    onTap: () {
                      Navigator.pop(context);
                      _showEditProjectDialog(context, p, onRefresh);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  static void _showEditProjectDialog(BuildContext context, dynamic project, VoidCallback onRefresh) {
    final titleController = TextEditingController(text: project.title);
    final roleController = TextEditingController(text: project.role);
    final descController = TextEditingController(text: project.description);
    final techController = TextEditingController(text: (project.tech as List).join(', '));
    final githubController = TextEditingController(text: project.githubUrl);
    final demoController = TextEditingController(text: project.url);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Project: ${project.title}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: roleController, decoration: const InputDecoration(labelText: 'Role')),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
              TextField(controller: techController, decoration: const InputDecoration(labelText: 'Tech (comma sep)')),
              TextField(controller: githubController, decoration: const InputDecoration(labelText: 'Github')),
              TextField(controller: demoController, decoration: const InputDecoration(labelText: 'Demo')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'title': titleController.text,
                'role': roleController.text,
                'description': descController.text,
                'tech': techController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                'githubUrl': githubController.text,
                'url': demoController.text,
              };
              await ApiService.updateProject(project.id, data);
              onRefresh();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  static void _showEditSkillsPicker(BuildContext context, VoidCallback onRefresh) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Skill to Edit'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<dynamic>>(
            future: ApiService.fetchSkills(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snap.hasData || snap.data!.isEmpty) return const Text('No skills found.');
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snap.data!.length,
                itemBuilder: (context, i) {
                  final s = snap.data![i];
                  return ListTile(
                    title: Text(s.name),
                    trailing: const Icon(Icons.edit, color: Colors.orange),
                    onTap: () {
                      Navigator.pop(context);
                      _showEditSkillDialog(context, s, onRefresh);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  static void _showEditSkillDialog(BuildContext context, dynamic skill, VoidCallback onRefresh) {
    final nameController = TextEditingController(text: skill.name);
    final levelController = TextEditingController(text: skill.level);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Skill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: levelController, decoration: const InputDecoration(labelText: 'Level')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await ApiService.updateSkill(skill.id, {'name': nameController.text, 'level': levelController.text});
              onRefresh();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  static void _showEditExperiencePicker(BuildContext context, VoidCallback onRefresh) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Experience to Edit'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<dynamic>>(
            future: ApiService.fetchExperience(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snap.hasData || snap.data!.isEmpty) return const Text('No experience entries found.');
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snap.data!.length,
                itemBuilder: (context, i) {
                  final e = snap.data![i];
                  return ListTile(
                    title: Text(e.position),
                    subtitle: Text(e.company),
                    trailing: const Icon(Icons.edit, color: Colors.orange),
                    onTap: () {
                      Navigator.pop(context);
                      _showEditExperienceDialog(context, e, onRefresh);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  static void _showEditExperienceDialog(BuildContext context, dynamic experience, VoidCallback onRefresh) {
    final titleController = TextEditingController(text: experience.position);
    final companyController = TextEditingController(text: experience.company);
    final descController = TextEditingController(text: experience.description);
    final techController = TextEditingController(text: (experience.technologies as List).join(', '));
    final startController = TextEditingController(text: experience.startDate);
    final endController = TextEditingController(text: experience.endDate);
    bool isCurrently = experience.isCurrently;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Experience'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                TextField(controller: companyController, decoration: const InputDecoration(labelText: 'Company')),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                TextField(controller: techController, decoration: const InputDecoration(labelText: 'Technologies')),
                TextField(controller: startController, decoration: const InputDecoration(labelText: 'Start Date')),
                TextField(controller: endController, decoration: const InputDecoration(labelText: 'End Date')),
                CheckboxListTile(
                  title: const Text('Currently working'),
                  value: isCurrently,
                  onChanged: (val) => setDialogState(() => isCurrently = val ?? false),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final data = {
                  'position': titleController.text,
                  'company': companyController.text,
                  'description': descController.text,
                  'technologies': techController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                  'startDate': startController.text,
                  'endDate': endController.text,
                  'isCurrently': isCurrently,
                };
                await ApiService.updateExperience(experience.id, data);
                onRefresh();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  static void _showEditEducationPicker(BuildContext context, VoidCallback onRefresh) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Education to Edit'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<dynamic>>(
            future: ApiService.fetchEducation(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snap.hasData || snap.data!.isEmpty) return const Text('No education found.');
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snap.data!.length,
                itemBuilder: (context, i) {
                  final e = snap.data![i];
                  return ListTile(
                    title: Text(e.degree),
                    subtitle: Text(e.institution),
                    trailing: const Icon(Icons.edit, color: Colors.orange),
                    onTap: () {
                      Navigator.pop(context);
                      _showEditEducationDialog(context, e, onRefresh);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  static void _showEditEducationDialog(BuildContext context, dynamic education, VoidCallback onRefresh) {
    final degreeController = TextEditingController(text: education.degree);
    final collegeController = TextEditingController(text: education.institution);
    final yearController = TextEditingController(text: education.year);
    final gradeController = TextEditingController(text: education.grade);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Education'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: degreeController, decoration: const InputDecoration(labelText: 'Degree')),
            TextField(controller: collegeController, decoration: const InputDecoration(labelText: 'College')),
            TextField(controller: yearController, decoration: const InputDecoration(labelText: 'Year')),
            TextField(controller: gradeController, decoration: const InputDecoration(labelText: 'Grade')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'degree': degreeController.text,
                'institution': collegeController.text,
                'year': yearController.text,
                'grade': gradeController.text,
              };
              await ApiService.updateEducation(education.id, data);
              onRefresh();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  static void showLanguageManager(BuildContext context, VoidCallback onRefresh) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Languages'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add New Language'),
                onPressed: () => _showAddLanguageDialog(context, onRefresh),
              ),
              const SizedBox(height: 16),
              const Text('Current Languages:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<Language>>(
                  future: ApiService.fetchLanguages(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (!snap.hasData || snap.data!.isEmpty) return const Center(child: Text('No languages added'));
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snap.data!.length,
                      itemBuilder: (context, i) {
                        final l = snap.data![i];
                        return ListTile(
                          title: Text(l.name),
                          subtitle: Text(l.proficiency),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await ApiService.deleteLanguage(l.id);
                              onRefresh();
                              Navigator.pop(context);
                              showLanguageManager(context, onRefresh);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  static void _showAddLanguageDialog(BuildContext context, VoidCallback onRefresh) {
    final nameController = TextEditingController();
    String proficiency = 'Beginner';
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Language Name')),
              DropdownButton<String>(
                value: proficiency,
                isExpanded: true,
                items: ['Beginner', 'Intermediate', 'Fluent', 'Native']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setDialogState(() => proficiency = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (nameController.text.trim().isEmpty) return;
                setDialogState(() => isLoading = true);
                try {
                  await ApiService.addLanguage(nameController.text.trim(), proficiency);
                  if (context.mounted) {
                    Navigator.pop(context);
                    onRefresh();
                    showLanguageManager(context, onRefresh);
                  }
                } catch (e) {
                  setDialogState(() => isLoading = false);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: isLoading ? const CircularProgressIndicator() : const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  static void showReviewDialog(BuildContext context, VoidCallback onRefresh) {
    final nameController = TextEditingController();
    final commentController = TextEditingController();
    double rating = 5.0;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Write a Review'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Your Name', hintText: 'e.g. John Doe'),
                ),
                const SizedBox(height: 16),
                const Text('Rating:', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () => setDialogState(() => rating = index + 1.0),
                    );
                  }),
                ),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(labelText: 'Your Feedback', hintText: 'What do you think?'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (nameController.text.trim().isEmpty || commentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                  return;
                }
                setDialogState(() => isLoading = true);
                try {
                  await ApiService.addReview(nameController.text.trim(), rating, commentController.text.trim());
                  if (context.mounted) {
                    Navigator.pop(context);
                    onRefresh();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you for your feedback!')));
                  }
                } catch (e) {
                  setDialogState(() => isLoading = false);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: isLoading ? const CircularProgressIndicator() : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

