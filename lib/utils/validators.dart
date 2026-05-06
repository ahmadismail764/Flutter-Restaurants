import 'dart:async';

mixin Validators {
  final validateName = StreamTransformer<String, String>.fromHandlers(
    handleData: (name, sink) {
      if (name.trim().isNotEmpty) {
        sink.add(name);
      } else {
        sink.addError('Name is required');
      }
    },
  );

  final validateEmail = StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink) {
      final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
      if (emailRegex.hasMatch(email)) {
        sink.add(email);
      } else {
        sink.addError('Enter a valid email');
      }
    },
  );

  final validatePassword = StreamTransformer<String, String>.fromHandlers(
    handleData: (password, sink) {
      if (password.length >= 8) {
        sink.add(password);
      } else {
        sink.addError('Password must be at least 8 characters');
      }
    },
  );
}
