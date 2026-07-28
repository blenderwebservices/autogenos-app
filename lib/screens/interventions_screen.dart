import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/intervention_provider.dart';

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
                final intervention = provider.interventions[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    title: Text('Order #${intervention.id} - ${intervention.type.toUpperCase()}'),
                    subtitle: Text('Status: ${intervention.status}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Symptoms: ${intervention.symptoms ?? "N/A"}'),
                            if (intervention.aiSuggestions != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text('AI Diagnostics: ${intervention.aiSuggestions.toString()}'),
                              ),
                            SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: Icon(Icons.smart_toy),
                              label: Text('Ask GenTech AI'),
                              onPressed: () {
                                provider.generateAiDiagnostic(intervention.id).then((result) {
                                  if (result != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('AI Diagnostic Generated!')),
                                    );
                                  }
                                });
                              },
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}
