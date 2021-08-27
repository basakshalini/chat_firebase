import 'package:chat_email_firebase/helper/helper_functions.dart';
import 'package:chat_email_firebase/services/auth.dart';
import 'package:chat_email_firebase/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_email_firebase/views/chatroom_screen.dart';
import 'package:chat_email_firebase/views/signup.dart';
import 'package:chat_email_firebase/widgets/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  final Function toggle;

  const SignIn({Key? key, required this.toggle}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  late String email, password;
  TextEditingController usernameTextEditingController =
      new TextEditingController();
  TextEditingController emailTextEditingController =
      new TextEditingController();
  TextEditingController passwordTextEditingController =
      new TextEditingController();
  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  //AuthService authService = new AuthService();

  bool _isLoading = false;
  late QuerySnapshot snapshotUserInfo;
  bool isObscure = true;
  signIn() async {
    if (_formKey.currentState!.validate()) {
      HelperFunction.saveUserEmailSharedPreference(
          emailTextEditingController.text);

      databaseMethods
          .getUserByUseremail(emailTextEditingController.text)
          .then((val) {
        snapshotUserInfo = val;
        HelperFunction.saveUserNameSharedPreference(
            (snapshotUserInfo.docs[0].data() as Map)["name"]);
      });

      setState(() {
        _isLoading = true;
      });

      await authMethods
          .signInEmailAndPass(emailTextEditingController.text,
              passwordTextEditingController.text)
          .then((val) {
        if (val != null) {
          setState(() {
            _isLoading = false;
          });

          HelperFunction.saveUserLoggedInSharedPreference(true);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ChatRoom()));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Center(child: appBar(context, 'SignIn', 'Screen')),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        brightness: Brightness.light,
      ),
      body: _isLoading
          ? Container(
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Image.asset("assets/images/people.gif"),
                      TextFormField(
                        controller: emailTextEditingController,
                        validator: (val) {
                          return val!.isEmpty ? "Enter correct email" : null;
                        },
                        style: TextStyle(color: Colors.white),
                        decoration: textFieldInputDecoration('Enter Email'),
                        onChanged: (val) {
                          email = val;
                        },
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      TextFormField(
                        controller: passwordTextEditingController,
                        obscureText: isObscure,
                        validator: (val) {
                          return val!.isEmpty ? "Enter correct password" : null;
                        },
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            hintText: "Enter Password",
                            hintStyle: TextStyle(color: Colors.white54),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            suffixIcon: IconButton(
                              color: Colors.white,
                              icon: Icon(isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  isObscure = !isObscure;
                                });
                              },
                            )),
                        onChanged: (val) {
                          password = val;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      GestureDetector(
                        onTap: () {
                          authMethods
                              .resetPass(emailTextEditingController.text);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 230),
                          child: Text(
                            'Forgot Password',
                            style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 38,
                      ),
                      GestureDetector(
                          onTap: () {
                            
                            signIn();
                          },
                          child: blueButton(context, 'Sign In')),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                          onTap: () {
                            //signIn();
                          },
                          child: whiteButton(context, 'Sign In with Google')),
                      const SizedBox(
                        height: 18,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style:
                                TextStyle(fontSize: 15.5, color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigator.pushReplacement(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => SignUp()));
                              widget.toggle();
                            },
                            child: const Text(
                              "Register Now",
                              style: TextStyle(
                                  fontSize: 15.5,
                                  color: Colors.white,
                                  decoration: TextDecoration.underline),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
