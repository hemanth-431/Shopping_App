import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
Timer _authTimer;
  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {


    final url = 'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=AIzaSyDIB08MicNyXOW630DiByqMOuVe7ukT25w';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _autologout();
      notifyListeners();
final preferences= await SharedPreferences.getInstance();  // auto Login
      final userData=json.encode(({'token':_token,'userId':_userId,'expiryDate':_expiryDate.toIso8601String()}));
preferences.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signupNewUser');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'verifyPassword');
  }

  Future<bool> tryAutologin() async {
final pref=await SharedPreferences.getInstance();
if(!pref.containsKey('userData')){
return false;
}
final extractedUsersData=json.decode(pref.getString('userData')) as Map<String,Object>;
final expirtDate=DateTime.parse(extractedUsersData['_expiryDate']);
if(expirtDate.isBefore(DateTime.now())){
  return false;
}
_token=extractedUsersData['token'];
_userId=extractedUsersData['userId'];
_expiryDate=expirtDate;
_autologout();
return true;
  }


  Future<void> logout() async{
    _token=null;
    _userId=null;
    _expiryDate=null;
    if(_authTimer != null){
      _authTimer.cancel();
      _authTimer=null;
    }
    notifyListeners();
final prefs=await SharedPreferences.getInstance();
//prefs.remove('userData');
prefs.clear();
  }
  void _autologout(){
    if(_authTimer != null)
      {
        _authTimer.cancel();
      }
  final timetoExpirey= _expiryDate.difference(DateTime.now()).inSeconds;
Timer(Duration(seconds: timetoExpirey),logout);//Timer(Duration(seconds: 3),logout);
    //it will logout after 3 seconds
  }
}
