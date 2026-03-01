import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project.dart';
import '../models/skill.dart';
import '../models/experience.dart';
import '../models/education.dart';
import '../models/profile.dart';
import '../models/certificate.dart';
import '../models/announcement.dart';
import '../models/language.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart'; 
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  // Base URL for API
  // PROD: Replace with your actual Vercel project URL
  // Example: 'https://myportfolio-backend.vercel.app/api'
  static const prodUrl = 'https://YOUR_VERCEL_URL.vercel.app/api';
  static const localUrl = 'http://127.0.0.1:5000/api'; 

  static String get baseUrl {
    if (kIsWeb) {
      // On web, if we're not local, use the current domain's /api
      final currentUri = Uri.base;
      if (currentUri.host == 'localhost' || currentUri.host == '127.0.0.1') {
        return localUrl;
      }
      return '${currentUri.origin}/api';
    }
    // On mobile, use production URL (or local if debugging on emulator)
    return prodUrl;
  }

  static String? _sessionToken;

  static Future<String?> getToken() async {
    if (_sessionToken != null) return _sessionToken;
    final prefs = await SharedPreferences.getInstance();
    _sessionToken = prefs.getString('auth_token');
    return _sessionToken;
  }

  static Future<void> saveToken(String token, {bool permanent = true}) async {
    _sessionToken = token;
    if (permanent) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    }
  }

  static Future<void> logout() async {
    _sessionToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> login(String email, String password, {bool rememberMe = true}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      final data = json.decode(res.body);
      if (res.statusCode == 200) {
        await saveToken(data['token'], permanent: rememberMe);
        return {'success': true, 'message': data['message'] ?? 'Login successful'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error. Check your internet.'};
    }
  }

  static Future<Map<String, dynamic>> signup(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      final data = json.decode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'OTP sent to email'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Signup failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error. Check your internet.'};
    }
  }

  static Future<bool> verifyOtp(String email, String otp, {bool rememberMe = true}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'otp': otp}),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        await saveToken(data['token'], permanent: rememberMe);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }


  static Future<bool> forgotPassword(String email) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> resetPassword(String email, String otp, String newPassword) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Project>> fetchProjects() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/projects'));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        return data.map((e) => Project.fromJson(e)).toList();
      }
      throw Exception('Failed to load projects: ${res.statusCode}');
    } catch (e) {
      if (e is FormatException) {
        throw Exception('API returned invalid format. Is the backend running?');
      }
      rethrow;
    }
  }

  static Future<Project> createProject(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/projects'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );
    if (res.statusCode == 201) {
      return Project.fromJson(json.decode(res.body));
    }
    final errorData = json.decode(res.body);
    throw Exception(errorData['error'] ?? errorData['message'] ?? 'Failed to create project (${res.statusCode})');
  }

  static Future<Project> updateProject(String id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/projects/$id'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );
    if (res.statusCode == 200) {
      return Project.fromJson(json.decode(res.body));
    }
    throw Exception('Failed to update project: ${res.body}');
  }

  static Future<void> deleteProject(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/projects/$id'),
      headers: await _getHeaders(),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to delete project');
    }
  }

  static Future<void> deleteProjectsBulk(List<String> ids) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/projects/bulk'),
      headers: await _getHeaders(),
      body: json.encode({'ids': ids}),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to delete projects: ${res.body}');
    }
  }

  static Future<List<Skill>> fetchSkills() async {
    final res = await http.get(Uri.parse('$baseUrl/skills'));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => Skill.fromJson(e)).toList();
    }
    throw Exception('Failed to load skills');
  }

  static Future<Skill> createSkill(String name, {String? level}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/skills'),
      headers: await _getHeaders(),
      body: json.encode({'name': name, 'level': level ?? 'Expert'}),
    );
    if (res.statusCode == 201) {
      return Skill.fromJson(json.decode(res.body));
    }
    final errorData = json.decode(res.body);
    throw Exception(errorData['error'] ?? errorData['message'] ?? 'Failed to create skill (${res.statusCode})');
  }

  static Future<Skill> updateSkill(String id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/skills/$id'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );
    if (res.statusCode == 200) {
      return Skill.fromJson(json.decode(res.body));
    }
    throw Exception('Failed to update skill: ${res.body}');
  }

  static Future<List<Skill>> createSkillsBulk(List<String> names) async {
    final res = await http.post(
      Uri.parse('$baseUrl/skills/bulk'),
      headers: await _getHeaders(),
      body: json.encode({'names': names}),
    );
    if (res.statusCode == 201) {
      final List data = json.decode(res.body);
      return data.map((e) => Skill.fromJson(e)).toList();
    }
    throw Exception('Failed to create skills: ${res.body}');
  }

  static Future<void> deleteSkill(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/skills/$id'),
      headers: await _getHeaders(),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to delete skill');
    }
  }

  static Future<void> deleteSkillsBulk(List<String> ids) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/skills/bulk'),
      headers: await _getHeaders(),
      body: json.encode({'ids': ids}),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to delete skills: ${res.body}');
    }
  }

  static Future<List<Experience>> fetchExperience() async {
    final res = await http.get(Uri.parse('$baseUrl/experience'));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => Experience.fromJson(e)).toList();
    }
    throw Exception('Failed to load experience');
  }

  static Future<Experience> createExperience(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/experience'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );
    if (res.statusCode == 201) {
      return Experience.fromJson(json.decode(res.body));
    }
    final errorData = json.decode(res.body);
    throw Exception(errorData['error'] ?? errorData['message'] ?? 'Failed to create experience (${res.statusCode})');
  }

  static Future<Experience> updateExperience(String id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/experience/$id'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );
    if (res.statusCode == 200) {
      return Experience.fromJson(json.decode(res.body));
    }
    throw Exception('Failed to update experience: ${res.body}');
  }

  static Future<void> deleteExperience(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/experience/$id'),
      headers: await _getHeaders(),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to delete experience');
    }
  }

  static Future<List<Education>> fetchEducation() async {
    final res = await http.get(Uri.parse('$baseUrl/education'));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => Education.fromJson(e)).toList();
    }
    throw Exception('Failed to load education');
  }

  static Future<Education> createEducation(Map<String, String> fields, {List<int>? fileBytes, String? fileName}) async {
    final uri = Uri.parse('$baseUrl/education');
    final request = http.MultipartRequest('POST', uri);
    
    // Add headers
    final token = await getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    // Add fields
    request.fields.addAll(fields);
    
    // Add file
    if (fileBytes != null && fileName != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'certificate',
        fileBytes,
        filename: fileName,
      ));
    }
    
    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);
    
    if (res.statusCode == 201) {
      return Education.fromJson(json.decode(res.body));
    }
    throw Exception('Failed to create education: ${res.body}');
  }


  static Future<void> deleteEducation(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/education/$id'),
      headers: await _getHeaders(),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to delete education');
    }
  }


  static Future<Profile> getProfile() async {
    final res = await http.get(Uri.parse('$baseUrl/profile'));
    if (res.statusCode == 200) {
      return Profile.fromJson(json.decode(res.body));
    }
    throw Exception('Failed to load profile');
  }

  static Future<Profile> updateProfile(Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );
    if (res.statusCode == 200) {
      return Profile.fromJson(json.decode(res.body));
    }
    final errorData = json.decode(res.body);
    throw Exception(errorData['error'] ?? errorData['message'] ?? 'Failed to update profile (${res.statusCode})');
  }


  static Future<void> downloadGeneratedResume() async {
    final url = Uri.parse('$baseUrl/resume/download');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw new Exception('Could not launch $url');
    }
  }

  static Future<void> sendContactMessage(String name, String email, String mobile, {String? message}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/contact'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'mobile': mobile,
        'message': message ?? '',
      }),
    );
    if (res.statusCode != 200) {
      final error = json.decode(res.body);
      throw Exception(error['message'] ?? 'Failed to send message');
    }
  }

  static Future<Profile> uploadProfilePhoto(List<int> fileBytes, String fileName) async {
    final uri = Uri.parse('$baseUrl/profile/photo');
    final request = http.MultipartRequest('PATCH', uri);
    
    final token = await getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    request.files.add(http.MultipartFile.fromBytes(
      'photo',
      fileBytes,
      filename: fileName,
    ));
    
    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);
    
    if (res.statusCode == 200) {
      return Profile.fromJson(json.decode(res.body));
    }
    throw Exception('Failed to upload photo: ${res.body}');
  }

  static Future<Profile> deleteProfilePhoto() async {
    final res = await http.delete(
      Uri.parse('$baseUrl/profile/photo'),
      headers: await _getHeaders(),
    );
    if (res.statusCode == 200) {
      return Profile.fromJson(json.decode(res.body));
    }
    throw Exception('Failed to delete photo');
  }

  // Certificate Methods
  static Future<List<Certificate>> fetchCertificates() async {
    final res = await http.get(Uri.parse('$baseUrl/certificates'));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => Certificate.fromJson(e)).toList();
    }
    throw Exception('Failed to load certificates');
  }

  static Future<Certificate> uploadCertificate(List<int> fileBytes, String name, String? description, String fileName) async {
    final uri = Uri.parse('$baseUrl/certificates');
    final request = http.MultipartRequest('POST', uri);
    
    final token = await getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    request.fields['name'] = name;
    if (description != null) {
      request.fields['description'] = description;
    }
    
    request.files.add(http.MultipartFile.fromBytes(
      'certificate',
      fileBytes,
      filename: fileName,
    ));
    
    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);
    
    if (res.statusCode == 201) {
      return Certificate.fromJson(json.decode(res.body));
    }
    throw Exception('Failed to upload certificate: ${res.body}');
  }

  static Future<void> deleteCertificate(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/certificates/$id'),
      headers: await _getHeaders(),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to delete certificate');
    }
  }

  static Future<void> deleteCertificatesBulk(List<String> ids) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/certificates/bulk'),
      headers: await _getHeaders(),
      body: json.encode({'ids': ids}),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to delete certificates: ${res.body}');
    }
  }

  // Announcement Methods
  static Future<List<Announcement>> fetchAnnouncements() async {
    final res = await http.get(Uri.parse('$baseUrl/announcements'));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => Announcement.fromJson(e)).toList();
    }
    throw Exception('Failed to load announcements');
  }

  static Future<Announcement> createAnnouncement(String text) async {
    final res = await http.post(
      Uri.parse('$baseUrl/announcements'),
      headers: await _getHeaders(),
      body: json.encode({'text': text}),
    );
    if (res.statusCode == 201) {
      return Announcement.fromJson(json.decode(res.body));
    }
    throw Exception('Failed to create announcement: ${res.body}');
  }

  static Future<void> deleteAnnouncement(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/announcements/$id'),
      headers: await _getHeaders(),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to delete announcement');
    }
  }

  static Future<Education> updateEducation(String id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/education/$id'),
      headers: await _getHeaders(),
      body: json.encode(data),
    );
    if (res.statusCode == 200) {
      return Education.fromJson(json.decode(res.body));
    }
    throw Exception('Failed to update education: ${res.body}');
  }

  // Admin Passcode Management
  static Future<bool> verifyAdminPasscode(String passcode) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/admin/verify-passcode'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'passcode': passcode}),
    );
    return res.statusCode == 200;
  }

  static Future<void> requestAdminPasscodeOtp() async {
    final res = await http.post(Uri.parse('$baseUrl/auth/admin/forgot-passcode'));
    if (res.statusCode != 200) {
      throw Exception('Failed to request OTP: ${res.body}');
    }
  }

  static Future<void> resetAdminPasscode(String otp, String newPasscode) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/admin/reset-passcode'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'otp': otp, 'newPasscode': newPasscode}),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to reset passcode: ${res.body}');
    }
  }

  // Language Management
  static Future<List<Language>> fetchLanguages() async {
    final res = await http.get(Uri.parse('$baseUrl/languages'));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => Language.fromJson(e)).toList();
    }
    throw Exception('Failed to load languages');
  }

  static Future<Language> addLanguage(String name, String proficiency) async {
    final res = await http.post(
      Uri.parse('$baseUrl/languages'),
      headers: await _getHeaders(),
      body: json.encode({'name': name, 'proficiency': proficiency}),
    );
    if (res.statusCode == 201) {
      return Language.fromJson(json.decode(res.body));
    }
    throw Exception('Failed to add language');
  }

  static Future<void> deleteLanguage(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/languages/$id'),
      headers: await _getHeaders(),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to delete language');
    }
  }

  // Analytics & Stats
  static Future<Map<String, dynamic>> fetchStats() async {
    final res = await http.get(Uri.parse('$baseUrl/portfolio/analytics'));
    if (res.statusCode == 200) {
      return json.decode(res.body);
    }
    throw Exception('Failed to load stats');
  }

  // Reviews
  static Future<void> addReview(String name, double rating, String comment) async {
    final res = await http.post(
      Uri.parse('$baseUrl/portfolio/reviews'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'rating': rating,
        'comment': comment,
      }),
    );
    if (res.statusCode != 201) {
      throw Exception('Failed to submit review');
    }
  }
}
