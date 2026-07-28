class Intervention {
  final int id;
  final int equipmentId;
  final String status;
  final String type;
  final String? symptoms;
  final String? recommendedAction;
  final Map<String, dynamic>? aiSuggestions;
  
  Intervention({
    required this.id,
    required this.equipmentId,
    required this.status,
    required this.type,
    this.symptoms,
    this.recommendedAction,
    this.aiSuggestions,
  });
  
  factory Intervention.fromJson(Map<String, dynamic> json) {
    return Intervention(
      id: json['id'],
      equipmentId: json['equipment_id'],
      status: json['status'] ?? 'pending',
      type: json['type'] ?? 'preventive',
      symptoms: json['symptoms'],
      recommendedAction: json['recommended_action'],
      aiSuggestions: json['ai_suggestions'] != null ? Map<String, dynamic>.from(json['ai_suggestions']) : null,
    );
  }
}
