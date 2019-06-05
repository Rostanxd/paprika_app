import 'dart:async';

class LoginValidator {
  static Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  static RegExp regex = new RegExp(pattern);

  final validateEmail = StreamTransformer<String, String>.fromHandlers(
      handleData: (email, sink){
        if (regex.hasMatch(email)){
          sink.add(email);
        } else if (email.isNotEmpty){
          sink.addError('Email inválido');
        }
      }
  );

  final validatePassword = StreamTransformer<String, String>.fromHandlers(
      handleData: (password, sink){
        if (password.isNotEmpty) {
          sink.add(password);
        }else{
          sink.addError('Enter the password to continue.');
        }
      }
  );
}