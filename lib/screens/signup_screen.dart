import 'package:flutter/material.dart';
import '../blocs/auth_bloc.dart';
import 'restaurant_list_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    
    _authBloc.authStatus.listen((user) {
      if (!mounted) return;
      // Navigate to Restaurant List Screen upon successful signup
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RestaurantListScreen()),
      );
    });
    
    _authBloc.errorStatus.listen((error) {
      if (!mounted) return;
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
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name (Mandatory)
            StreamBuilder<String>(
              stream: _authBloc.name,
              builder: (context, snapshot) {
                return TextField(
                  onChanged: _authBloc.changeName,
                  decoration: InputDecoration(
                    labelText: 'Name (Mandatory)',
                    errorText: snapshot.hasError ? snapshot.error.toString() : null,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Email (Mandatory)
            StreamBuilder<String>(
              stream: _authBloc.email,
              builder: (context, snapshot) {
                return TextField(
                  onChanged: _authBloc.changeEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address (Mandatory)',
                    errorText: snapshot.hasError ? snapshot.error.toString() : null,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Gender (Optional - Radio Buttons)
            const Text('Gender (Optional):', style: TextStyle(fontSize: 16)),
            StreamBuilder<String?>(
              stream: _authBloc.gender,
              builder: (context, snapshot) {
                return Row(
                  children: [
                    Radio<String>(
                      value: 'Male',
                      groupValue: snapshot.data,
                      onChanged: _authBloc.changeGender,
                    ),
                    const Text('Male'),
                    const SizedBox(width: 20),
                    Radio<String>(
                      value: 'Female',
                      groupValue: snapshot.data,
                      onChanged: _authBloc.changeGender,
                    ),
                    const Text('Female'),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Level (Optional - Dropdown)
            StreamBuilder<int?>(
              stream: _authBloc.level,
              builder: (context, snapshot) {
                return DropdownButtonFormField<int>(
                  value: snapshot.data,
                  decoration: const InputDecoration(
                    labelText: 'Level (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.star),
                  ),
                  items: [1, 2, 3, 4].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('Level $value'),
                    );
                  }).toList(),
                  onChanged: _authBloc.changeLevel,
                );
              },
            ),
            const SizedBox(height: 16),

            // Password (Mandatory)
            StreamBuilder<String>(
              stream: _authBloc.password,
              builder: (context, snapshot) {
                return TextField(
                  onChanged: _authBloc.changePassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password (Mandatory)',
                    errorText: snapshot.hasError ? snapshot.error.toString() : null,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Confirm Password (Mandatory)
            StreamBuilder<String>(
              stream: _authBloc.confirmPassword,
              builder: (context, snapshot) {
                return TextField(
                  onChanged: _authBloc.changeConfirmPassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password (Mandatory)',
                    errorText: snapshot.hasError ? snapshot.error.toString() : null,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Signup Button
            StreamBuilder<bool>(
              stream: _authBloc.isLoading,
              builder: (context, isLoadingSnapshot) {
                if (isLoadingSnapshot.data == true) {
                  return const Center(child: CircularProgressIndicator());
                }
                return StreamBuilder<bool>(
                  stream: _authBloc.submitSignupValid,
                  builder: (context, validSnapshot) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: validSnapshot.hasData && validSnapshot.data == true
                          ? _authBloc.submitSignup
                          : null,
                      child: const Text('SIGN UP', style: TextStyle(fontSize: 16)),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
