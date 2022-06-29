
import 'package:swallow_monitoring/fingerprint.dart';
import 'package:swallow_monitoring/registrationpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:swallow_monitoring/verificationpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swallow_monitoring/homepage.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //Form Key
  final _formkey = GlobalKey<FormState>();

  //Editing Controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  //firebase
  final _auth = FirebaseAuth.instance;

  // string for displaying the error Message
  String? errorMessage;

  String value = "";

  @override
  Widget build(BuildContext context) {
    //Email Field
    final emailField = TextFormField(
      autofocus: false,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      onSaved: (value)
      {
        emailController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "E-Mail",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
    );

    //Password field
    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      controller: passwordController,
      onSaved: (value)
      {
        passwordController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Password",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
    );

    //Login Button
    final loginButton = Material(
      elevation: 100,
      borderRadius: BorderRadius.circular(15),
      color: Colors.green,

      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        onPressed: () {signIn(emailController.text, passwordController.text);},
        child: Text("Login", textAlign: TextAlign.center, style: TextStyle(
          fontSize: 25, color: Colors.white,
        ),),
      ),
    );

    return Scaffold(
      body: Container(

        // For Background
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/back.png"),
            fit: BoxFit.cover,
          ),
        ),

        child: Container(
          child: Form(
            key: _formkey,
            child: SingleChildScrollView(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget> [

                  SizedBox(height: 330),
                  const Align(
                    alignment: Alignment(-0.95,0),
                    child:  Text('Login', style: TextStyle(fontSize: 36, color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 50),

                  emailField,
                  SizedBox(height: 20),

                  passwordField,
                  SizedBox(height: 10),


                  Center(
                    child: Container(
                      child: IconButton(
                        icon: Image.asset("assets/fingerprint.png"),
                        alignment: Alignment.topRight,
                        color: Colors.green,
                        iconSize: 60,
                        onPressed: () async {
                          bool isAuthenticated = await FingerPrint.authenticateWithFingerPrint();
                          SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

                          if (isAuthenticated) {
                            String? email = sharedPreferences.getString("email");
                            String? pass = sharedPreferences.getString("pass");
                            signInWithFinger(email!, pass!);
                          } else {
                            Fluttertoast.showToast(msg: 'Authenticated Failed');
                          }
                        },
                      ),),
                  ),
                  SizedBox(height: 75),


                  Align(
                    alignment: Alignment(0.8,0),
                    child: loginButton,
                  ),

                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget> [
                        Text("New Here?" , style: TextStyle(fontSize: 19, color: Colors.white)), GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationPage()));
                          },
                          child: Text(" Register", style: TextStyle(fontSize: 19, color: Colors.white, fontWeight: FontWeight.bold)),
                        )
                      ]
                  ),


                ]
            ),
            ),),
        ),

      ),);
  }
  // login function
  void signIn(String email, String password) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (_formkey.currentState!.validate()) {
      try {
        await _auth
            .signInWithEmailAndPassword(email: email, password: password)
            .then((uid) => {
          if (uid.user!.emailVerified){
            Fluttertoast.showToast(msg: "Login Successful"),
            sharedPreferences.setString("email", email),
            sharedPreferences.setString("pass", password),
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()))
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => VerificationPage()))
          }
        });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        Fluttertoast.showToast(msg: errorMessage!);
        print(error.code);
      }
    }
  }
  void signInWithFinger(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        await _auth
            .signInWithEmailAndPassword(email: email, password: password)
            .then((uid) => {
          if (uid.user!.emailVerified){
            Fluttertoast.showToast(msg: "Login Successful"),
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()))
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (context) => VerificationPage()))
          }
        });
      } on FirebaseAuthException catch (error) {
        Fluttertoast.showToast(msg: "Something Error, Please use Email To login");
        print(error.code);
      }
    }
  }

}