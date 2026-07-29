import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  String? _errorEndpoint;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.electrical_services, size: 80, color: Colors.blueGrey),
              SizedBox(height: 24),
              Text('GenTech Field App', style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
              ),
              SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Error: $_errorMessage\n(Endpoint: $_errorEndpoint)',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (auth.isLoading)
                CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _errorMessage = null;
                      _errorEndpoint = null;
                    });
                    
                    final result = await auth.login(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );
                    
                    debugPrint('UI received login result: $result');
                    
                    if (result.$1) {
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => DashboardScreen()),
                      );
                    } else {
                      if (!mounted) return;
                      setState(() {
                        _errorMessage = result.$2;
                        _errorEndpoint = result.$3;
                      });
                      debugPrint('Set UI errorMessage to: $_errorMessage');
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('Login'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
