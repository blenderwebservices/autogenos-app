import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'interventions_screen.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Welcome, ${user?.name ?? 'User'}', style: Theme.of(context).textTheme.headlineSmall),
            Text('Role: ${user?.role.toUpperCase() ?? 'N/A'}', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 32),
            
            if (user?.role == 'technician' || user?.role == 'admin')
              ElevatedButton.icon(
                icon: Icon(Icons.build),
                label: Text('My Interventions'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => InterventionsScreen()),
                  );
                },
              ),
              
            if (user?.role == 'client')
              ElevatedButton.icon(
                icon: Icon(Icons.inventory),
                label: Text('My Equipment'),
                onPressed: () {
                  // TODO: Go to Equipment Screen
                },
              ),
          ],
        ),
      ),
    );
  }
}
