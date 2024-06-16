import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payfond/Firebase/auth_methods.dart';
import 'package:payfond/validation/auth_validation_methods.dart';
import 'package:payfond/views/auth_views/login.dart';
import 'package:payfond/views/main_screen.dart';
import 'package:payfond/widgets/toastWidget.dart';


const kTextFieldDecoration = InputDecoration(
  hintStyle: TextStyle(color: Colors.grey),
  counterText: '',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.grey)
  ),
  enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey)
  ),
  focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey)
  ),

);

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _signUpFormKey = GlobalKey<FormState>();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController mobileNo = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool passwordHideShow = true;
  bool signUpLoading = false;

  void signUpUser() async {
    setState(() {
      signUpLoading = true;
    });
    bool isSignFormValid = _signUpFormKey.currentState!.validate();
    if(isSignFormValid){
      String res = await AuthMethods().signUpUser(
          firstName: firstName.text,
          lastName: lastName.text,
          mobileNo: mobileNo.text,
          email: email.text,
          password: password.text,
          userActive: true,
          userSalt: '',
          userCreationDate: DateTime.now(),
          userLoginTime: DateTime.now().millisecondsSinceEpoch,
          isAdmin: false,
      );
      if (res == "success") {
        if (context.mounted) {
          toastMsg("You Have Registered Successfully");
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
        }
      }
      else {
        if (context.mounted) {
          toastMsg("Your Registration is Failed\ntry again.");
          // showSnackBar(context, res);
        }
      }
    }
    setState(() {
      signUpLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Container(
                  color: const Color.fromRGBO(227, 240, 240, 1)),
              Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    'assets/logo.png',
                    width: 200,
                    height: 200,
                  )),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 500,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40)),
                    ),
                    child: signUpBody(),
                  )
              )
            ],
          )
      ),
    );
  }
  Widget signUpBody() {
    return Form(
      key: _signUpFormKey,
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Create Account',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.blueGrey
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                  keyboardType: TextInputType.name,
                  textAlign: TextAlign.start,
                  controller: firstName,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
                  ],
                  autocorrect: false,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (value) {},
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'First Name')),
              const SizedBox(
                  height: 10),
              TextFormField(
                  keyboardType: TextInputType.name,
                  textAlign: TextAlign.start,
                  controller: lastName,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
                  ],
                  autocorrect: false,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (value) {},
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Last Name')),
              const SizedBox(height: 10),
              TextFormField(
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.start,
                  maxLength: 10,
                  controller: mobileNo,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                  ],
                  autocorrect: false,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: AuthValidation.validateMobile,
                  onChanged: (value) {},
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Mobile No')),
              const SizedBox(
                  height: 10),
              TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.start,
                  controller: email,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp("[0-9@a-zA-Z.]")),
                  ],
                  validator: AuthValidation.validateEmail,
                  autocorrect: false,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (value) {},
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Email')),
              const SizedBox(
                height: 8.0),
              TextFormField(
                  obscureText: passwordHideShow,
                  textAlign: TextAlign.start,
                  controller: password,
                  onChanged: (value) {},
                  autocorrect: false,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: AuthValidation.validatePassword,
                  keyboardType: TextInputType.visiblePassword,

                  decoration: kTextFieldDecoration.copyWith(
                    suffixIcon: IconButton(onPressed: (){
                      setState(() {
                        passwordHideShow = !passwordHideShow;
                      });
                    }, icon: Icon(passwordHideShow?Icons.visibility_rounded:Icons.visibility_off_rounded),
                                color: Colors.grey,
                    ),
                      hintText: 'Password')),
              const SizedBox(height: 24.0),
              ElevatedButton(
                  onPressed:signUpUser,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      minimumSize: const Size(double.infinity, 60),
                      elevation: 10,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30))
                      )),
                  child: signUpLoading? Center(child: CircularProgressIndicator()):
                    const Text('Sign Up',
                        style: TextStyle(
                        color: Colors.white
                      )
                  )),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
                child: RichText(text: const TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400
                    ),
                    children: [
                      TextSpan(
                          text: 'Sign in',
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w800
                          )
                      )
                    ]
                )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
