import 'package:swallow_monitoring/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swallow_monitoring/db/db.dart';


class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {

  //Form Key
  final _formkey = GlobalKey<FormState>();

  //Editing Controller
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();

  //firebase
  final _auth = FirebaseAuth.instance;

  // string for displaying the error Message
  String? errorMessage;

  @override
  Widget build(BuildContext context) {

    //Username field
    final firstnameField = TextFormField(
      autofocus: false,
      controller: firstnameController,
      //Validator
      onSaved: (value)
      {
        firstnameController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "First Name",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
    );

    //Last Name
    final lastnameField = TextFormField(
      autofocus: false,
      controller: lastnameController,
      //Validator
      onSaved: (value)
      {
        lastnameController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Last Name",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
    );

    //Email Field
    final emailField = TextFormField(
      autofocus: false,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      //Validator
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
      //Validator
      validator: (value) {
        RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~_.-]).{8,}$');
        if (value!.isEmpty) {
          return ("Please Enter Your Password");
        }
        if (!regex.hasMatch(value)) {
          return ("Password Min.8 Character,lowercase & uppercase,number,symbol");
        }
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

    //Confirm Pass
    final _passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      controller: confirmpassController,
      //Validator
      validator: (value) {
        if (value!.isEmpty) {
          return "Please Confirm the Password";
        } else if (value != passwordController.text) {
          return "Password must be same as above";
        }
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Confirm Password",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
    );

    //Registration Button
    final registrationButton = Material(
      elevation: 100,
      borderRadius: BorderRadius.circular(15),
      color: Colors.green,

      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        onPressed: () {signUp(emailController.text, passwordController.text);},
        child: Text("Register", textAlign: TextAlign.center, style: TextStyle(
          fontSize: 25, color: Colors.white,
        ),),
      ),
    );

    return Scaffold(
      body: Container(

        //For Background
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

                  SizedBox(height: 310),
                  const Align(
                    alignment: Alignment(-0.95,0),
                    child:  Text('Registration', style: TextStyle(fontSize: 36, color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 20),

                  firstnameField,
                  SizedBox(height: 20),

                  lastnameField,
                  SizedBox(height: 20),

                  emailField,
                  SizedBox(height: 20),

                  passwordField,
                  SizedBox(height: 20),

                  _passwordField,
                  SizedBox(height: 35),

                  Align(
                    alignment: Alignment(0.8,0),
                    child: registrationButton,
                  ),

                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget> [
                        Text("Already have an Account?" , style: TextStyle(fontSize: 17, color: Colors.white)), GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                          },
                          child: Text(" Login", style: TextStyle(fontSize: 19, color: Colors.white, fontWeight: FontWeight.bold)),
                        )
                      ]
                  ),
                ]
            ),),
          ),
        ),
      ),
    );
  }
  void signUp(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        await _auth
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((value) => {postDetailsToFirestore()})
            .catchError((e) {
          Fluttertoast.showToast(msg: e!.message);
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
  postDetailsToFirestore() async {

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    db userData = db();

    // writing the values
    userData.email = user!.email;
    userData.uid = user.uid;
    userData.firstName = firstnameController.text;
    userData.lastName = lastnameController.text;

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userData.toMap());
    Fluttertoast.showToast(msg: "Account created successfully :) ");

    Navigator.pushAndRemoveUntil(
        (context),
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false);
  }
}