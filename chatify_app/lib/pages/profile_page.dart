import 'package:chatify_app/models/contact.dart';
import 'package:chatify_app/providers/auth_provider.dart';
import 'package:chatify_app/services/database_service.dart';
//import 'package:chatify_app/services/snackbar_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// ignore: must_be_immutable
class ProfilePage extends StatelessWidget {
  ProfilePage(this._height, this._width, {super.key});

  final double _height, _width;
  AuthProvider? _auth;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      width: _width,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: profilePageUI(),
      ),
    );
  }

  Widget profilePageUI() {
    return Builder(builder: (_context) {
      _auth = Provider.of<AuthProvider>(_context);
      return StreamBuilder<Contact>(
        stream: DatabaseService.instance.getUserData(_auth!.user!.uid),
        builder: (BuildContext context, AsyncSnapshot<Contact> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return Text('No user Data');
          }
          var _userData = snapshot.data;
          return snapshot.hasData
              ? Center(
                  child: SizedBox(
                    height: _height * 0.50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _userImage(_userData!.image),
                        _userNameWidget(_userData.name),
                        _userEmailWidget(_userData.email),
                        _logoutButton(),
                      ],
                    ),
                  ),
                )
              : const SpinKitWanderingCubes(
                  color: Colors.blue,
                  size: 50.0,
                );
        },
      );
    });
  }

  Widget _userImage(String _image) {
    double _imageRadius = _height * 0.20;
    return Container(
      height: _imageRadius,
      width: _imageRadius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_imageRadius),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(_image),
        ),
      ),
    );
  }

  Widget _userNameWidget(String _userName) {
    return Container(
      height: _height * 0.05,
      width: _width,
      child: Text(
        _userName,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30),
      ),
    );
  }

  Widget _userEmailWidget(String _email) {
    return Container(
      height: _height * 0.05,
      width: _width,
      child: Text(
        _email,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white24, fontSize: 15),
      ),
    );
  }

  Widget _logoutButton() {
    return Container(
      height: _height * 0.06,
      width: _width * 0.80,
      child: MaterialButton(
        onPressed: (){
          print(_auth!.user);
          _auth!.logout(() async{
            //SnackbarService.instance.showSnackBarSuccess('Logout Successfully');
          });
        },
        color: Colors.red,
        child: Text(
          'Logout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
