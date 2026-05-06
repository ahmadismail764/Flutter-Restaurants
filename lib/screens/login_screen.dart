import 'package:flutter/material.dart';
import '../blocs/auth_bloc.dart';
import 'signup_screen.dart';
import 'restaurant_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    
    // Listen to authentication status
    _authBloc.authStatus.listen((user) {
      // Navigate to Restaurant List Screen upon successful login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RestaurantListScreen()),
      );
    });
    
    // Listen to error status
    _authBloc.errorStatus.listen((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    });
  }

  @override
  void dispose() {
    _authBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.restaurant, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 40),
              
              // Email Field
              StreamBuilder<String>(
                stream: _authBloc.email,
                builder: (context, snapshot) {
                  return TextField(
                    onChanged: _authBloc.changeEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      errorText: snapshot.hasError ? snapshot.error.toString() : null,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Password Field
              StreamBuilder<String>(
                stream: _authBloc.password,
                builder: (context, snapshot) {
                  return TextField(
                    onChanged: _authBloc.changePassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: snapshot.hasError ? snapshot.error.toString() : null,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Login Button
              StreamBuilder<bool>(
                stream: _authBloc.isLoading,
                builder: (context, isLoadingSnapshot) {
                  if (isLoadingSnapshot.data == true) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  return StreamBuilder<bool>(
                    stream: _authBloc.submitLoginValid,
                    builder: (context, validSnapshot) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: validSnapshot.hasData && validSnapshot.data == true
                            ? _authBloc.submitLogin
                            : null,
                        child: const Text('LOGIN', style: TextStyle(fontSize: 16)),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Navigate to Signup
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  );
                },
                child: const Text('Don\'t have an account? Sign up'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
