
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payfond/Firebase/auth_methods.dart';
import 'package:payfond/utils/utils.dart';
import 'package:payfond/validation/auth_validation_methods.dart';
import 'package:payfond/views/auth_views/sign_up.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController(text: 'payfond.test@gmail.com');
  TextEditingController password = TextEditingController(text: 'World@2019');
  bool passwordHideShow = true;
  final _signInFormKey = GlobalKey<FormState>();

  bool isLoading = false;

  void loginUser() async {
    if(isLoading == false){
      setState(() {
        isLoading = true;
      });
      String res = await AuthMethods().loginUser(
          email: email.text, password: password.text);
      if (res == 'success') {
        if (context.mounted) {
          toastMsg('Login Successfully');
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const MainScreen()
              ));
        }
      } else {
        if (context.mounted) {
          toastMsg("Login Failed");
          // showSnackBar(context, res);
        }
      }
      setState(() {
        isLoading = false;
      });
    }

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
                    height: 400,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(40),topRight: Radius.circular(40)),
                    ),
                    child: signInBody(),
                  )
              )
            ],
          )
        )
    );
  }

  Widget signInBody(){
    return Form(
        key: _signInFormKey,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Welcome',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.blueGrey
                ),
              ),
              const SizedBox(height: 20),
                TextFormField(
                    enabled: false,
                    obscureText:true,
                  //initialValue: 'payfond.test@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.start,
                    onChanged: (value) {},
                    controller: email,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp("[0-9@a-zA-Z.]")),
                    ],
                    validator: AuthValidation.validateEmail,
                    autocorrect: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Email',
                    )),
              const SizedBox(height: 8.0),
              TextFormField(
                enabled: false,
                 // initialValue: 'World@2019',
                  obscureText: passwordHideShow,
                  textAlign: TextAlign.start,
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
                      hintText: 'Password'),
                  controller: password,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                  onPressed: loginUser,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      minimumSize: const Size(double.infinity, 50),
                      elevation: 10,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)))
                  ),
                  child: isLoading? CircularProgressIndicator(color: Colors.white60,) : const Text('Log In',
                  style: TextStyle(color: Colors.white),
                  )),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RegistrationScreen()));
                  },
                  child: RichText(text: const TextSpan(
                      text: 'Click here to ',
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400
                      ),
                      children: [
                        TextSpan(
                            text: 'Sign Up',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w800
                            )
                        )
                      ]
                  )),
                ),
              )
            ],
          ),
        )
    );
  }
}