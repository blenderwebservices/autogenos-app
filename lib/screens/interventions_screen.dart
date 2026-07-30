import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/intervention_provider.dart';
import '../models/intervention.dart';

class InterventionsScreen extends StatefulWidget {
  @override
  _InterventionsScreenState createState() => _InterventionsScreenState();
}

class _InterventionsScreenState extends State<InterventionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InterventionProvider>(context, listen: false).fetchInterventions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InterventionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Interventions'),
      ),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.interventions.length,
              itemBuilder: (context, index) {
                return _InterventionCard(
                  intervention: provider.interventions[index],
                );
              },
            ),
    );
  }
}

class _InterventionCard extends StatefulWidget {
  final Intervention intervention;

  const _InterventionCard({Key? key, required this.intervention}) : super(key: key);

  @override
  __InterventionCardState createState() => __InterventionCardState();
}

class __InterventionCardState extends State<_InterventionCard> {
  bool _isEditing = false;
  bool _isSaving = false;
  late TextEditingController _symptomsController;

  @override
  void initState() {
    super.initState();
    _symptomsController = TextEditingController(text: widget.intervention.symptoms ?? '');
  }

  @override
  void didUpdateWidget(covariant _InterventionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.intervention.symptoms != widget.intervention.symptoms && !_isEditing) {
      _symptomsController.text = widget.intervention.symptoms ?? '';
    }
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InterventionProvider>(context, listen: false);
    final intervention = widget.intervention;

    return Card(
      margin: EdgeInsets.all(8.0),
      child: ExpansionTile(
        key: PageStorageKey('intervention_${intervention.id}'),
        title: Text('Order #${intervention.id} - ${intervention.type.toUpperCase()}'),
        subtitle: Text('Status: ${intervention.status}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Symptoms:', style: TextStyle(fontWeight: FontWeight.bold)),
                    _isSaving 
                      ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(
                          icon: Icon(_isEditing ? Icons.save : Icons.edit),
                          onPressed: () async {
                            if (_isEditing) {
                              setState(() => _isSaving = true);
                              bool success = await provider.updateInterventionSymptoms(intervention.id, _symptomsController.text);
                              setState(() {
                                _isSaving = false;
                                if (success) {
                                  _isEditing = false;
                                }
                              });
                            } else {
                              setState(() => _isEditing = true);
                            }
                          },
                        ),
                  ],
                ),
                _isEditing
                  ? TextField(
                      controller: _symptomsController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Enter symptoms...',
                        border: OutlineInputBorder(),
                      ),
                    )
                  : Text(intervention.symptoms ?? "N/A"),
                if (intervention.aiSuggestions != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('AI Diagnostics: ${intervention.aiSuggestions.toString()}'),
                  ),
                SizedBox(height: 16),
                Consumer<InterventionProvider>(
                  builder: (context, provider, child) {
                    return provider.isGeneratingDiagnostic(intervention.id)
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text('GenTech AI is thinking...', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : ElevatedButton.icon(
                            icon: Icon(Icons.smart_toy),
                            label: Text('Ask GenTech AI'),
                            onPressed: () {
                              provider.generateAiDiagnostic(intervention.id).then((result) {
                                if (result != null) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('AI Diagnostic Generated!')),
                                  );
                                }
                              });
                            },
                          );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
