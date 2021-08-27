import 'package:chat_email_firebase/helper/helper_functions.dart';
import 'package:chat_email_firebase/services/auth.dart';
import 'package:chat_email_firebase/views/chatroom_screen.dart';
import 'package:chat_email_firebase/services/database.dart';
import 'package:chat_email_firebase/views/signin.dart';
import 'package:chat_email_firebase/views/signup.dart';
import 'package:chat_email_firebase/widgets/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  final Function toggle;
  const SignUp({Key? key, required this.toggle}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameTextEditingController =
      new TextEditingController();
  TextEditingController emailTextEditingController =
      new TextEditingController();
  TextEditingController passwordTextEditingController =
      new TextEditingController();
  late String email, name, password;
  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  HelperFunction helperFunction = new HelperFunction();
  //AuthService authService = new AuthService();
  bool _isLoading = false;
  signUp() async {
    if (_formKey.currentState!.validate()) {
      Map<String, String> userInfoMap = {
        "name": usernameTextEditingController.text,
        "email": emailTextEditingController.text,
      };

      HelperFunction.saveUserEmailSharedPreference(
          emailTextEditingController.text);
      HelperFunction.saveUserNameSharedPreference(
          usernameTextEditingController.text);

      setState(() {
        _isLoading = true;
      });
      await authMethods
          .signUpWithEmailAndPassword(emailTextEditingController.text,
              passwordTextEditingController.text)
          .then((value) {
        if (value != null) {
          setState(() {
            _isLoading = false;
          });

          databaseMethods.uploadUserInfo(userInfoMap);
           
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ChatRoom()));
        }
      });
    }
  }

  bool isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Center(child: appBar(context, 'Register', 'Screen')),
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
                      Image.asset(
                        "assets/images/people.gif",
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        validator: (val) {
                          return val!.isEmpty || val.length < 2
                              ? "Enter a valid name"
                              : null;
                        },
                        controller: usernameTextEditingController,
                        style: TextStyle(color: Colors.white),
                        decoration: textFieldInputDecoration('Enter Username'),
                        onChanged: (val) {
                          name = val;
                        },
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      TextFormField(
                        validator: (val) {
                          // return RegExp(
                          //             r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          //         .hasMatch(val!)
                          val!.isEmpty || val.length < 2
                              ? null
                              : "Enter a valid email Id";
                        },
                        controller: emailTextEditingController,
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
                          return val!.isEmpty || val.length > 6
                              ? "Enter correct password"
                              : null;
                        },
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            hintText:
                                "Enter Password(Password should be minimum 6 characters)",
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
                      SizedBox(
                        height: 48,
                      ),
                      GestureDetector(
                          onTap: () {
                            signUp();
                          },
                          child: blueButton(context, 'Register')),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                          onTap: () {
                            //signIn();
                          },
                          child: whiteButton(context, 'Continue with Google')),
                      const SizedBox(
                        height: 18,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style:
                                TextStyle(fontSize: 15.5, color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigator.pushReplacement(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => SignIn()));
                              widget.toggle();
                            },
                            child: const Text(
                              "Log In",
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
