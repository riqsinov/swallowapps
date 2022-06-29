import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:swallow_monitoring/homepage.dart';
import 'package:swallow_monitoring/loginpage.dart';

class VerificationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _VerificationStatePage();
}

class _VerificationStatePage extends State<VerificationPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Waiting Email Verification..."),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.currentUser!.reload();
                    bool isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
                    if(isEmailVerified){
                      Fluttertoast.showToast(msg: "Email Verified");
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
                    } else {
                      Fluttertoast.showToast(msg: "Email Is Not Verified");
                    }
                  },
                  child: Text('Check Again'),
              )
            ],
          ),
        )
    );
  }
}