//import 'package:chatify_app/pages/login_page.dart';
import 'package:chatify_app/providers/auth_provider.dart';
import 'package:chatify_app/services/database_service.dart';
import 'package:chatify_app/services/snackbar_service.dart';
import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import '../services/media_service.dart';
import 'dart:io';
import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart';
import '../services/cloud_storage_service.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});
  @override
  State<StatefulWidget> createState() {
    return _RegistrationPageState();
  }
}

class _RegistrationPageState extends State<RegistrationPage> {
  double? _deviceHeight, _deviceWidth;
  AuthProvider? _auth;

  GlobalKey<FormState>? _formKey;
  String? _name;
  String? _email;
  String? _password;
  bool _obscureText = true;
  File? _image;

  _RegistrationPageState() {
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      //backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        alignment: Alignment.center,
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: registrationPageUI(),
        ),
      ),
    );
  }

  Widget registrationPageUI() {
    return Builder(builder: (BuildContext context) {
      SnackbarService.instance.buildContext = context;
      _auth = Provider.of<AuthProvider>(context);
      return Container(
        padding: EdgeInsets.symmetric(horizontal: _deviceWidth! * 0.10),
        height: _deviceHeight! * 0.75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headingWidget(),
            _inputForm(),
            _registrationButton(),
            _backtoLoginPage(),
          ],
        ),
      );
    });
  }

  Widget _headingWidget() {
    return Container(
      height: _deviceHeight! * 0.15,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            "Lets get going",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
          ),
          Text(
            "Please enter your details",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w200),
          ),
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Container(
      height: _deviceHeight! * 0.35,
      child: Form(
        key: _formKey,
        onChanged: () {
          _formKey!.currentState!.save();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            _imageSelector(),
            _nameTextField(),
            _emailTextField(),
            _passwordTextField(),
          ],
        ),
      ),
    );
  }

  Widget _imageSelector() {
    return Center(
      child: GestureDetector(
        onTap: () async {
          File? _imageFile = await MediaService.instance.getImage();
          setState(() {
            _image = _imageFile!;
          });
        },
        child: Container(
          height: _deviceHeight! * 0.10,
          width: _deviceHeight! * 0.10,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(500),
            image: DecorationImage(
                image: _image != null
                    ? FileImage(_image!)
                    : NetworkImage(
                        'https://cdn0.iconfinder.com/data/icons/occupation-002/64/programmer-programming-occupation-avatar-512.png')),
          ),
        ),
      ),
    );
  }

  Widget _nameTextField() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(color: Colors.white),
      validator: (_input) {
        if (_input!.isNotEmpty) {
          return null;
        }
        return "Please enter your name";
      },
      onSaved: (_input) {
        setState(() {
          _name = _input;
        });
      },
      cursorColor: Colors.white,
      decoration: const InputDecoration(
          hintText: "Name",
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white))),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(color: Colors.white),
      validator: (_input) {
        // return _input!.isEmpty && _input.contains("@") ? null : "Please enter a valid Email";
        if (_input!.isNotEmpty && _input.contains("@")) {
          return null;
        }
        return "Please enter a valid email";
      },
      onSaved: (_input) {
        setState(() {
          _email = _input;
        });
      },
      cursorColor: Colors.white,
      decoration: const InputDecoration(
          hintText: "Email Address",
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white))),
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      autocorrect: false,
      obscureText: _obscureText,
      style: const TextStyle(color: Colors.white),
      validator: (_input) {
        if (_input!.isEmpty) {
          return "Please enter a password";
        }
        return null;
      },
      onSaved: (_input) {
        setState(() {
          _password = _input;
        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: "password",
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _registrationButton() {
    return _auth!.status != AuthStatus.Authenticating
        ? Container(
            height: _deviceHeight! * 0.06,
            width: _deviceWidth,
            child: MaterialButton(
              onPressed: () {
                if (_formKey!.currentState!.validate() && _image != null) {
                  _auth!.registerUser(
                    _email!,
                    _password!,
                    (String uid) async {
                      var _imageUrl = await CloudStorageService.instance
                          .uploadProfileImage(uid, _image!);
                      await DatabaseService.instance
                          .createUser(uid, _name!, _email!, _imageUrl);
                      //final _imageUrl = await _result.ref.getDownloadURL;
                    },
                  );
                }
              },
              color: Colors.blue,
              child: const Text(
                'Register',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
  }

  Widget _backtoLoginPage() {
    return GestureDetector(
      onTap: () {
        NavigationService.instance.goBack();
      },
      child: Container(
        height: _deviceHeight! * 0.06,
        width: _deviceWidth,
        child: Icon(
          Icons.arrow_back,
          size: 40,
        ),
      ),
    );
  }
}
