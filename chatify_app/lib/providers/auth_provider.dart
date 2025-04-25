import 'package:chatify_app/services/database_service.dart';
import 'package:chatify_app/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/snackbar_service.dart';

enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error,
}

enum AuthCheckStatus { Checking, Done }

class AuthProvider extends ChangeNotifier {
  User? user;
  late AuthStatus status = AuthStatus.NotAuthenticated;
  //SnackbarService _service = SnackbarService.instance;

  late FirebaseAuth _auth;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  static AuthProvider instance = AuthProvider();

  // AuthProvider();
  AuthCheckStatus authCheckStatus = AuthCheckStatus.Checking;

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    checkCurrentUser();
  }

  Future<void> autoLogin() async {
    if (user != null) {
      await DatabaseService.instance.updateUserLastSeen(user!.uid);
      return NavigationService.instance.navigateToReplacement('home');
    }
  }

  void checkCurrentUser() async {
    user = await _auth.currentUser;
    authCheckStatus = AuthCheckStatus.Done;
    if (user != null) {
      notifyListeners();
      await autoLogin();
    }
  }

  void loginUserWithEmailAndPassword(String _email, String _password) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential _result = await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      user = _result.user;
      status = AuthStatus.Authenticated;
      SnackbarService.instance.showSnackBarSuccess("Welcome, ${user?.email}");
      await DatabaseService.instance.updateUserLastSeen(user!.uid);
      NavigationService.instance.navigateToReplacement('home');
    } catch (e) {
      status = AuthStatus.Error;
      user = null;
      SnackbarService.instance.showSnackBarError("Error Authenticating $e");
    }
    notifyListeners();
  }

  void registerUser(
      String email, String password, Future<void> onSuccess(String uid)) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      UserCredential _result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = _result.user;
      status = AuthStatus.Authenticated;

      await onSuccess(user!.uid);
      SnackbarService.instance.showSnackBarSuccess("Welcome, ${user?.email}");
      await DatabaseService.instance.updateUserLastSeen(user!.uid);
      NavigationService.instance.goBack();
      NavigationService.instance.navigateToReplacement('home');
    } catch (e) {
      status = AuthStatus.Error;
      user = null;
      SnackbarService.instance.showSnackBarError("Error Authenticating $e");
    }
    notifyListeners();
  }

  void logout(Future<void> onSuccess()) async{
    try {
      await _auth.signOut();
      user = null;
      status = AuthStatus.NotAuthenticated;
      await onSuccess();
      NavigationService.instance.navigateToReplacement('login');
      SnackbarService.instance.showSnackBarSuccess('Logout Successfully');
    } catch (e) {
      print(e);
      SnackbarService.instance.showSnackBarError('error cannot logout');
    }
    notifyListeners();
  }
}
