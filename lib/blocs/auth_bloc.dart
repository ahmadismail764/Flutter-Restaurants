import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../utils/validators.dart';
import '../services/api_service.dart';
import '../utils/service_locator.dart';
import '../models/user.dart';

class AuthBloc with Validators {
  final ApiService _apiService = getIt<ApiService>();

  // Streams for UI (Input Controllers)
  final _email = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  final _confirmPassword = BehaviorSubject<String>();
  final _name = BehaviorSubject<String>();
  final _gender = BehaviorSubject<String?>();
  final _level = BehaviorSubject<int?>();
  
  final _isLoading = BehaviorSubject<bool>.seeded(false);
  final _authStatus = PublishSubject<User>();
  final _errorStatus = PublishSubject<String>();

  // Getters for Sinks (Inputs)
  Function(String) get changeEmail => _email.sink.add;
  Function(String) get changePassword => _password.sink.add;
  Function(String) get changeConfirmPassword => _confirmPassword.sink.add;
  Function(String) get changeName => _name.sink.add;
  Function(String?) get changeGender => _gender.sink.add;
  Function(int?) get changeLevel => _level.sink.add;

  // Getters for Streams (Outputs with Validation)
  Stream<String> get email => _email.stream.transform(validateEmail);
  Stream<String> get password => _password.stream.transform(validatePassword);
  
  Stream<String> get confirmPassword => Rx.combineLatest2<String, String, String>(
    _password.stream.startWith(''),
    _confirmPassword.stream,
    (pass, confirmPass) {
      if (confirmPass.length < 8) {
        throw 'Password must be at least 8 characters';
      }
      if (pass.isEmpty) {
        throw 'Enter password first';
      }
      if (pass != confirmPass) {
        throw 'Passwords do not match';
      }
      return confirmPass;
    }
  );

  Stream<String> get name => _name.stream.transform(validateName);
  Stream<String?> get gender => _gender.stream;
  Stream<int?> get level => _level.stream;
  
  Stream<bool> get isLoading => _isLoading.stream;
  Stream<User> get authStatus => _authStatus.stream;
  Stream<String> get errorStatus => _errorStatus.stream;

  // Form Validation Streams
  Stream<bool> get submitLoginValid => Rx.combineLatest2(email, password, (e, p) => true);
  
  Stream<bool> get submitSignupValid => Rx.combineLatest4(
    name, 
    email, 
    password, 
    confirmPassword, 
    (n, e, p, cp) => true
  );

  // Actions
  Future<void> submitLogin() async {
    if (!_email.hasValue || !_password.hasValue) return;
    _isLoading.sink.add(true);
    try {
      final user = await _apiService.login(_email.value, _password.value);
      _authStatus.sink.add(user);
    } catch (e) {
      _errorStatus.sink.add(e.toString());
    } finally {
      _isLoading.sink.add(false);
    }
  }

  Future<void> submitSignup() async {
    if (!_name.hasValue || !_email.hasValue || !_password.hasValue) return;
    _isLoading.sink.add(true);
    try {
      final user = await _apiService.signup(
        name: _name.value,
        email: _email.value,
        password: _password.value,
        gender: _gender.hasValue ? _gender.value : null,
        level: _level.hasValue ? _level.value : null,
      );
      _authStatus.sink.add(user);
    } catch (e) {
      _errorStatus.sink.add(e.toString());
    } finally {
      _isLoading.sink.add(false);
    }
  }

  void dispose() {
    _email.close();
    _password.close();
    _confirmPassword.close();
    _name.close();
    _gender.close();
    _level.close();
    _isLoading.close();
    _authStatus.close();
    _errorStatus.close();
  }
}
