// ignore_for_file: file_names
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:der/controller/login_service.dart';
import 'package:der/utils/shake_widget.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:der/entities/site/user.dart';
import 'package:der/entities/response.dart' as EntityResponse;


//hive
import 'package:hive/hive.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:der/utils/constants.dart';
import 'package:der/entities/token.dart';
import 'package:der/entities/user.dart';

//check internet
import 'package:connectivity_plus/connectivity_plus.dart';


import 'package:der/env.dart';


//const SERVER_IP = 'http://10.0.2.2:8080';
String? userNameNow;
ConnectivityResult? _connectivityResult;
bool _isConnectionSuccessful = false;

// const SERVER_IP = 'http://10.0.2.2:8005';
//const SERVER_IP = 'http://10.0.2.2:8080';
//const SERVER_IP = 'http://192.168.3.199:8080';

//const SERVER_IP = 'http://10.0.2.2:8005';

//const SERVER_IP = 'http://192.168.3.199:8080';

class NewUserScreen extends StatefulWidget {
  _NewUserScreenState createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {

  late Box? _UserBox;

  final _shakeKeyUserName = GlobalKey<ShakeWidgetState>();

  final _shakeKeyPassWord = GlobalKey<ShakeWidgetState>();

  bool _rememberMe = false;

  @override
  void initState() {
    //print("--------test--------");
    //print(Hive.box("Users"));
    _UserBox = Hive.box("Users");

    super.initState();
  }

  Future<void> _tryConnection() async {
    try {
      final response = await InternetAddress.lookup('www.google.com');
      setState(() {
        _isConnectionSuccessful = response.isNotEmpty;
        //print("Success");
      });
    } on SocketException catch (e) {
      setState(() {
        _isConnectionSuccessful = false;
        print("failed");
      });
    }
  }

  var _userNameColor = Colors.white;
  var _userNameText = " Username";

  Widget _buildEmailTF() {

    TextField _userNameTextField = TextField(
      controller: usernameController,
      onChanged: (e) => _userNameTFToggle(e),
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
          color: _userNameColor,
        ),
        hintText: 'Enter your Username',
        hintStyle: kHintTextStyle,
      ),
    ) ;

    return Container(

      child: ShakeWidget(
        key: _shakeKeyUserName,
        shakeCount: 3,
        shakeOffset: 10,
        shakeDuration: Duration(milliseconds: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _userNameText,
              style: TextStyle(
                  color: _userNameColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'OpenSans'
              ),

            ),
            SizedBox(height: 10.0),
            Container(
              alignment: Alignment.centerLeft,
              decoration: kBoxDecorationStyle,
              height: 60.0,
              child: _userNameTextField,
            ),
          ],
        ),
      ) ,
    );
  }

  var _passwordColor = Colors.white;
  var _passwordText = " Password";

  Widget _buildPasswordTF() {


    return Container(

      child: ShakeWidget(
        key: _shakeKeyPassWord,
        shakeCount: 3,
        shakeOffset: 10,
        shakeDuration: Duration(milliseconds: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _passwordText,
              style: TextStyle(
                  color: _passwordColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'OpenSans'
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              alignment: Alignment.centerLeft,
              decoration: kBoxDecorationStyle,
              height: 60.0,
              child: TextField(
                onChanged :(e) => _passwordTFToggle(e),
                controller: passwordController,
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
        ),
      ),
    );

   // return ;
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

  void _userNameTFToggle(e) {
    setState(() {
      //_rqVisible = !_rqVisible;
      _userNameText = "Username" ;
      _userNameColor = Colors.white ;

    });
  }

  void _passwordTFToggle(e) {
    setState(() {
      //_rqVisible = !_rqVisible;
      _passwordText = "Password" ;
      _passwordColor = Colors.white ;
    });
  }

  //bool _rqVisible = false;

  // message = "";

  /*Widget _MissingUserNameOrPasswordText(){

    ;
    return Container(

      child: Visibility(
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          visible: _rqVisible,
          child:ShakeWidget(
            key: _shakeKey,
            shakeCount: 3,
            shakeOffset: 10,
            shakeDuration: Duration(milliseconds: 400),
            child:Text(
              message,
            style: TextStyle(
              color: Colors.red,
              letterSpacing: 1.5,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              //fontFamily: 'OpenSans',
            ),
          ),
          ),
      ),

    );
  }*/

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

  showAlertDialog(BuildContext context){
    AlertDialog alert=AlertDialog(
      backgroundColor: Colors.black87,
      content: Container(
        padding: EdgeInsets.all(16),
        color: Colors.black.withOpacity(0.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(padding:  EdgeInsets.only(bottom: 16),

              child:            Container(
                  child: CircularProgressIndicator(

                      strokeWidth: 3
                  ),
                  width: 50,
                  height: 50
              ),
            ),
            Padding(  child: Text( 'Please wait …',

              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16
              ),
              textAlign: TextAlign.center,
            ),
                padding: EdgeInsets.only(bottom: 4)
            ),
          ],),
      )


    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }



  signIn() async {


    if(usernameController.text == ""){
      setState(() {
        _userNameText = "Username is required";
       // _rqVisible = true;
        _userNameColor = Colors.red ;

      });
      _shakeKeyUserName.currentState?.shake();
      return ;
    }else if (passwordController.text == ""){
      setState(() {
        _passwordText = "Password is required";
       // _rqVisible = true;
        _passwordColor = Colors.red ;

      });
      _shakeKeyPassWord.currentState?.shake();
      return ;

    }

    showAlertDialog(context);

    await _tryConnection();
    if (!_isConnectionSuccessful) {

      if( Navigator.of(context).canPop())
        Navigator.of(context).pop();

      useShowDialog("no internet connection", context);

    }
    //showAlertDialog(context);
    LoginService login = LoginService();
    String url = "$LOCAL_SERVER_IP_URL/api/authenticate" ;
    String userName = usernameController.text ;
    var  resp = await login.attemptLogIn(url, userName, passwordController.text);

    usernameController.clear();
    passwordController.clear();

    if( Navigator.of(context).canPop())
      Navigator.of(context).pop();

    if(resp.statusCode == 408){
        useShowDialog("REQUEST TIMEOUT", context);
    }else if(resp.statusCode == 401){
        useShowDialog("UNAUTHRIZED USER", context);
    }else if(resp.statusCode == 200){
      EntityResponse.Response<Token> t = EntityResponse.Response<Token>.fromJson(
          jsonDecode(resp.data), (body) => Token.fromJson(body));
      String token = t.body.token;
      User u = t.body.user;
      u.userName = userNameNow = userName;
      
      if (_UserBox?.get(userNameNow) == null) {
        print(" not  token null");
        OnSiteUser user = OnSiteUser(u.userName, u.firstName, u.lastName,
            u.picture, token, 123, "", [], [], "");
        _UserBox?.put(u.userName, user);
        Navigator.of(context).pushReplacementNamed(SETDIGIT_ROUTE);
      } else {
        print(" save token");
        _UserBox?.get(userNameNow).token = token;
        _UserBox?.get(userNameNow).save();
        Navigator.of(context).pushReplacementNamed(HOME_ROUTE);
      }
    }else if(resp.statusCode == 500){
      useShowDialog("SERVICE UNAVAILABLE", context);
    }

   /*res.then((value){

      if(value == null){
        useShowDialog("SERVICE UNAVAILABLE", context);
      }

      Map<String, dynamic> map = jsonDecode(value);
      int status =  jsonDecode(value)['status'];

      usernameController.clear();
      passwordController.clear();

      if(status != 200){
        useShowDialog("wrong user name or password", context);
      }

      Response<Token> t = Response<Token>.fromJson(
          jsonDecode(value), (body) => Token.fromJson(body));

      print(t.body.user);

      String token = t.body.token;
      User u = t.body.user;
      u.userName = userNameNow = userName;


      if (_UserBox?.get(userNameNow) == null) {
        print(" not  token null");
        OnSiteUser user = OnSiteUser(u.userName, u.firstName, u.lastName,
            u.picture, token, 123, "", [], [], "");
        _UserBox?.put(u.userName, user);
        Navigator.of(context).pushReplacementNamed(SETDIGIT_ROUTE);
      } else {
        print(" save token");
        _UserBox?.get(userNameNow).token = token;
        _UserBox?.get(userNameNow).save();
        Navigator.of(context).pushReplacementNamed(HOME_ROUTE);
      }
    });*/
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () {

          signIn();
        },

        // {
        //   Navigator.of(context).pushNamed(SIGNUP_ROUTE);
        // },
        // onPressed: () {
        //   Navigator.of(context).pushNamed(SIGNUP_ROUTE);
        // },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'LOGIN',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
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
        SizedBox(height: 10.0),
        Text(
          'Sign in with',
          style: kLabelStyle,
        ),
        SizedBox(height: 0.0),
      ],
    );
  }

  Widget _buildSocialBtn(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacementNamed(DIGIT_ROUTE);
      },
      child: Container(
        height: 60.0,
        width: 60.0,
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

  Widget _buildSocialBtn2(
      Function onTap,
      ) {
    return Container(
        width: 500,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.0),
          color: Colors.white,
        ),
        child: InkWell(
            onTap: () {
              Navigator.of(context).pushReplacementNamed(DIGIT_ROUTE);
            },
            child: Center(
              child: Ink(
                color: Colors.white,
                child: Padding(
                  // padding: EdgeInsets.all(6),
                  padding: const EdgeInsets.only(
                      left: 0, right: 14, top: 14, bottom: 14),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/googleLogo.png',
                        height: 30,
                        width: 60,
                      ), // <-- Use 'Image.asset(...)' here
                      SizedBox(width: 15),
                      Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF398AE5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )));
  }

  Widget _buildSocialBtn3(
      Function onTap,
      ) {
    return Container(
        width: 500,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.0),
          color: Colors.white,
        ),
        child: InkWell(
            onTap: () {
              Navigator.of(context).pushReplacementNamed(DIGIT_ROUTE);
            },
            child: Center(
              child: Ink(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(6),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/microsoftLogo.jpg',
                        height: 40,
                        width: 40,
                      ), // <-- Use 'Image.asset(...)' here
                      SizedBox(width: 12),
                      Text(
                        'Sign in with Microsoft',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF398AE5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )));
  }

  Widget _buildDropdownUser() {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        isExpanded: true,
        hint: Row(
          children: const [
            Icon(
              Icons.account_circle,
              size: 30,
              color: Color(0xFF398AE5),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                'User in this Device',
                style: TextStyle(
                  fontSize: 18,
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
              fontSize: 18,
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
          });
        },
        icon: const Icon(
          Icons.arrow_forward_ios_outlined,
        ),
        iconSize: 14,
        iconEnabledColor: Color(0xFF398AE5),
        iconDisabledColor: Colors.grey,
        buttonHeight: 70,
        buttonWidth: 520,
        buttonPadding: const EdgeInsets.only(left: 14, right: 14),
        buttonDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.black26,
          ),
          color: Colors.white,
        ),
        buttonElevation: 2,
        itemHeight: 50,
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

  List<String> items = [
    'Item1',
    'Item2',
    'Item3',
    'Item4',
    'Item5',
    'Item6',
    'Item7',
    'Item8',
  ];

  @override
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();


    super.dispose();
  }

  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        Navigator.pushNamed(context, NEW_LOGIN_ROUTE);
        return true; //  exit the app

      },
      child: Scaffold(
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
                      vertical: 50.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(0),
                          child: Image(
                            image: AssetImage(
                              'assets/images/Syngenta-Logo.png',
                            ),
                            width: 250,
                            height: 100,
                          ),
                        ),
                        Text(
                          'Sign In',
                          style: TextStyle(
                            // color: Color(0xFF398AE5),
                            color: Colors.white,
                            fontFamily: 'OpenSans',
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 0.0),
                        // child: DropdownButtonFormField<String>(
                        //   decoration: InputDecoration(
                        //     enabledBorder: OutlineInputBorder(
                        //       borderSide: BorderSide(
                        //           color: Color(0xFF6CA8F1), width: 1),
                        //       borderRadius: BorderRadius.circular(10),
                        //     ),
                        //     filled: true,
                        //     fillColor: Colors.blueAccent,
                        //   ),
                        //   value: dropdownValue,
                        //   dropdownColor: Colors.white,
                        //   icon: const Icon(
                        //     Icons.account_circle,
                        //     color: Colors.white,
                        //     size: 30,
                        //   ),
                        //   elevation: 16,
                        //   style: kTest,
                        //   onChanged: (String? newValue) {
                        //     setState(() {
                        //       dropdownValue = newValue!;
                        //     });
                        //   },
                        //   items: <String>[
                        //     'Existed User',
                        //     'Test',
                        //     'user1@ku.th',
                        //   ].map<DropdownMenuItem<String>>((String value) {
                        //     return DropdownMenuItem<String>(
                        //       value: value,
                        //       child: Text(value),
                        //     );
                        //   }).toList(),
                        // ),
                        //),
                        SizedBox(height: 40.0),
                        // ignore: avoid_unnecessary_containers
                        // Container(
                        //     child: Divider(
                        //   color: Colors.white54,
                        //   // color: Color(0xFF398AE5),
                        //   height: 10,
                        //   thickness: 3,
                        // )),
                        _buildEmailTF(),
                        SizedBox(height: 10.0),
                        _buildPasswordTF(),
                        //SizedBox(height: 50.0),
                        _buildLoginBtn(),

                        //_MissingUserNameOrPasswordText()
                        //_buildSignInWithText(),
                        //SizedBox(height: 50.0),
                        //_buildSocialBtn3(
                        //  () => Navigator.of(context)
                        //      .pushReplacementNamed(DIGIT_ROUTE),
                        //),
                        //SizedBox(height: 30.0),
                        //_buildSocialBtn2(
                        //  () => Navigator.of(context)
                        //      .pushReplacementNamed(DIGIT_ROUTE),
                        //),
                        //SizedBox(
                        //  height: 30.0,
                        //),
                        // _buildForgotPasswordBtn(),
                        // _buildRememberMeCheckbox(),
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
      ),
    );
  }

/*Future<LoginStatus> signIn(String username, String password) async {

    await _tryConnection();
    if (!_isConnectionSuccessful) {
      return LoginStatus.no_internet_connection;
    }

    userNameNow = username;
    print("userNameNow " + userNameNow!);
    LoginService login = LoginService();
    String url = "$LOCAL_SERVER_IP_URL/api/authenticate" ;
    var res = login.attemptLogIn(url,username, password);

    if (res == null) {
      print("web don't have service or don't have web");
      return LoginStatus.service_unavailable;
    }

    res.then((value) {

      Map<String, dynamic> map = jsonDecode(value);
      int status =  jsonDecode(value)['status'];

      if(status != 200) {

        return LoginStatus.unauthorized;
      }

      Response<Token> t = Response<Token>.fromJson(
          jsonDecode(value), (body) => Token.fromJson(body));


      String token = t.body.token;
      print("####################### ${token}");
      User u = t.body.user;
      u.userName = username;

      if (_UserBox?.get(userNameNow) == null) {
        print(" not  token null");
        OnSiteUser user = OnSiteUser(u.userName, u.firstName, u.lastName,
            u.picture, token, 123, "", [], [], "");
        _UserBox?.put(u.userName, user);
      } else {
        print(" save token");
        _UserBox?.get(userNameNow).token = token;
        _UserBox?.get(userNameNow).save();
      }

    });
    return LoginStatus.success;
  }*/
}

useShowDialog(String title, BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text('Please try again'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

useShowDialogSSO(String title, BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text('Please try again'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(NEW_LOGIN_ROUTE);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
