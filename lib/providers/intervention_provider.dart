import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/intervention.dart';

class InterventionProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  List<Intervention> _interventions = [];
  bool _isLoading = false;
  final Set<int> _generatingDiagnostics = {};
  
  List<Intervention> get interventions => _interventions;
  bool get isLoading => _isLoading;
  
  bool isGeneratingDiagnostic(int id) => _generatingDiagnostics.contains(id);

  Future<void> fetchInterventions({bool showLoader = true}) async {
    if (showLoader) {
      _isLoading = true;
      notifyListeners();
    }
    
    try {
      final response = await _apiClient.dio.get('interventions');
      final data = response.data['data'] as List;
      _interventions = data.map((json) => Intervention.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint('Error fetching interventions: ${e.message}');
    }
    
    if (showLoader) {
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>?> generateAiDiagnostic(int interventionId) async {
    _generatingDiagnostics.add(interventionId);
    notifyListeners();
    
    try {
      final response = await _apiClient.dio.post('interventions/$interventionId/ai-diagnostic');
      await fetchInterventions(showLoader: false); // Refresh list without global loader
      return response.data;
    } on DioException catch (e) {
      debugPrint('Error generating AI Diagnostic: ${e.response?.data}');
      return null;
    } finally {
      _generatingDiagnostics.remove(interventionId);
      notifyListeners();
    }
  }
  Future<bool> updateInterventionSymptoms(int id, String symptoms) async {
    try {
      await _apiClient.dio.put('interventions/$id', data: {'symptoms': symptoms});
      await fetchInterventions(showLoader: false);
      return true;
    } on DioException catch (e) {
      debugPrint('Error updating symptoms: ${e.response?.data}');
      return false;
    }
  }
}
