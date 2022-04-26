import 'dart:async';
import 'package:der/screens/main/signup_screen.dart';
import 'package:der/social_login/ui/app-scale.dart';
import 'package:der/social_login/ui/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:der/main.dart';
import 'package:flutter/material.dart';
import 'package:der/entities/site/user.dart';
import 'package:http/http.dart' as Http;
import 'dart:convert';
import 'package:der/entities/objectlist.dart';
import 'package:der/entities/trial.dart';

//hive
import 'package:hive/hive.dart';
import 'package:der/entities/site/trial.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:der/utils/constants.dart';

Box? _UserBox;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  void initHive() {
    _UserBox = Hive.box("Users");
    for (int i = 0; i < _UserBox!.length; i++) {
      //print("user Name ${i} : ${_UserBox!.getAt(i).userName.toString()}");
      items.add(_UserBox!.getAt(i).userName.toString());
    }
  }

  bool _rememberMe = false;
  void initState() {
    print("login screen");
    //initHive();
    super.initState();
    // _UserBox = Hive.box("Users");
    initHive();
    //print("--------test--------");
    // print(Hive.box("Users"));
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Username',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.white,
              ),
              hintText: 'Enter your Username',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            obscureText: true,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Enter your Password',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: () => print('Forgot Password Button Pressed'),
        padding: EdgeInsets.only(right: 0.0),
        child: Text(
          'Forgot Password?',
          style: kLabelStyle,
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Container(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: _rememberMe,
              checkColor: Colors.green,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value!;
                });
              },
            ),
          ),
          Text(
            'Remember me',
            style: kLabelStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginBtn() {
    AppScale scale = AppScale(context);
    return Container(
        color: HexColor('#FFFFFF'),
        width: scale.ofWidth(1),
        padding: EdgeInsets.fromLTRB(
            0, scale.ofHeight(0.027), 0, scale.ofHeight(0.027)),
        child: Column(
          children: [
            /*RaisedButton(
            elevation: 5.0,
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(NEWFIRSTPAGE_ROUTE);
            },
            padding: EdgeInsets.all(15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            color: Colors.white,
            child: Text(
              'New login User',
              style: TextStyle(
                color: Color(0xFF527DAA),
                letterSpacing: 1.5,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
          ),*/

            Utils.getButton(
                text: 'Sign In with Email',
                color: Colors.white,
                bgColor: HexColor('#4D4D4D'),
                mini: false,
                fontScale: 0.020, //0.025
                height: 40, //60
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                icon: Image.asset('assets/images/email.png', width: 40),
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed(NEW_FIRSTPAGE_ROUTE)),
            Utils.getButton(
                text: 'Sign In with Google',
                color: Colors.white,
                bgColor: HexColor('#4D4D4D'),
                mini: false,
                fontScale: 0.020, //0.025
                height: 40, //60
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                icon: Image.asset('assets/images/google.png', width: 40),
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed(GOOGLE_LOGIN_ROUTE)),
            Utils.getButton(
                text: 'Sign In with Microsoft',
                fontScale: 0.020, //0.025
                color: Colors.white,
                bgColor: HexColor('#4D4D4D'),
                mini: false,
                height: 40, //60
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                icon: Image.asset('assets/images/ms.png', width: 40),
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed(MICROSOFT_LOGIN_ROUTE)),
          ],
        ));
  }

  Widget _buildSignInWithText() {
    return Column(
      children: <Widget>[
        Text(
          '- OR -',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 20.0),
        Text(
          'Sign in with',
          style: kLabelStyle,
        ),
      ],
    );
  }

  Widget _buildSocialBtn(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(DIGIT_ROUTE);
      },
      child: Container(
        height: 30.0, //60
        width: 30.0, //60
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBtnRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // _buildSocialBtn(
          //   () => print('Login with Facebook'),
          //   AssetImage(
          //     'assets/images/facebook.jpg',
          //     // 'assets/logos/facebook.jpg',
          //   ),
          // ),
          _buildSocialBtn(
            () => print('Login with Google'),
            AssetImage(
              'assets/images/google.jpg',
              // 'assets/logos/google.jpg',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownUser() {
    return Container(
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          isExpanded: true,
          hint: Row(
            children: const [
              Icon(
                Icons.account_circle,
                size: 25, //3
                color: Color(0xFF398AE5),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  'User in this Device',
                  style: TextStyle(
                    fontSize: 16, //18
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF398AE5),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 16, //18
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF398AE5),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          value: selectedValue,
          onChanged: (value) {
            setState(() {
              selectedValue = value as String;
              print("selectedValue  : ${selectedValue}");
              userNameNow = selectedValue;
            });

            Navigator.of(context).pushReplacementNamed(DIGIT_ROUTE);
          },
          onTap: () => {
            () => Navigator.of(context).pushReplacementNamed(DIGIT_ROUTE),
          },
          icon: const Icon(
            Icons.arrow_forward_ios_outlined,
          ),
          iconSize: 14,
          iconEnabledColor: Color(0xFF398AE5),
          iconDisabledColor: Colors.grey,
          buttonHeight: 50, //70
          buttonWidth: 400, //520
          buttonPadding: const EdgeInsets.only(left: 14, right: 14),
          buttonDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.black26,
            ),
            color: Colors.white,
          ),
          buttonElevation: 2,
          itemHeight: 40, //50
          itemPadding: const EdgeInsets.only(left: 14, right: 14),
          dropdownMaxHeight: 205,
          dropdownWidth: 520,
          dropdownPadding: null,
          dropdownDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          dropdownElevation: 8,
          scrollbarRadius: const Radius.circular(10),
          scrollbarThickness: 6,
          scrollbarAlwaysShow: true,
          offset: const Offset(0, -1),
        ),
      ),
    );
  }

  // Widget _buildSignupBtn() {
  //   return GestureDetector(
  //     onTap: () => print('Sign Up Button Pressed'),
  //     child: RichText(
  //       text: TextSpan(
  //         children: [
  //           TextSpan(
  //             text: 'Don\'t have an Account? ',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 18.0,
  //               fontWeight: FontWeight.w400,
  //             ),
  //           ),
  //           TextSpan(
  //             text: 'Sign Up',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 18.0,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  String dropdownValue = 'User in this Device';

  late String country_id;

  List<String> country = [
    "America",
    "Brazil",
    "Canada",
    "India",
    "Mongalia",
    "USA",
    "China",
    "Russia",
    "Germany"
  ];

  String? selectedValue;

  List<String> items = [];
  DateTime _lastExitTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      // Colors.white
                      //Blue
                      Color(0xFF73AEF5),
                      Color(0xFF61A4F1),
                      Color(0xFF478DE0),
                      Color(0xFF398AE5),
                      //Green
                      // Color(0xFF2EB62C),
                      // Color(0xFF2EB62C),
                      // Color(0xFF57C84D),
                      // Color(0xFF57C84D),
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 110.0, //120
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 10.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(600),
                        child: Image(
                          image: AssetImage(
                            'assets/images/syngenta_vector_logo.png',
                          ),
                          width: 130, //200
                          height: 130, //200
                        ),
                      ),
                      SizedBox(height: 250.0), //290
                      _buildDropdownUser(),
                      SizedBox(height: 15.0), // 30
                      Text(
                        '- OR -',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 15), //20
                      ),
                      SizedBox(height: 15.0), //20
                      // // _buildEmailTF(),
                      // _buildPasswordTF(),
                      // _buildForgotPasswordBtn(),
                      // _buildRememberMeCheckbox(),
                      _buildLoginBtn(),
                      // _buildSignInWithText(),
                      // _buildSocialBtnRow(),
                      // _buildSignupBtn(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
