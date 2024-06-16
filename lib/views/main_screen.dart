import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payfond/Firebase/auth_methods.dart';
import 'package:payfond/provider/screenChangeProvider.dart';
import 'package:payfond/views/adminTransView.dart';
import 'package:payfond/views/auth_views/login.dart';
import 'package:payfond/views/card_pay_screen.dart';
import 'package:payfond/views/home_screen.dart';
import 'package:payfond/widgets/toastWidget.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _auth = FirebaseAuth.instance;

  User? loggedInUser;
  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
      }
    } catch (e) {
      e;
    }
  }
  String greetingMsg = "";
  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    greetingMsg = greeting();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Consumer<ScreenChangeProvider>(
          builder: (context,screenChangeProviderModel,child) {
          return StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').doc(loggedInUser!.uid).snapshots(),
              builder: (context,userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                  return PopScope(
                    canPop: screenChangeProviderModel.screen!='home'?false:true,
                    onPopInvoked: (v){
                      if(screenChangeProviderModel.screen!='home'){
                        setState(() {
                        Provider.of<ScreenChangeProvider>(context, listen: false).screenChange("home");
                        });
                    }
                },
                child: Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: const Color.fromARGB(255,241,241,246),
                  appBar: AppBar(
                    backgroundColor: Colors.blueGrey,
                    title: const Text('Payfond'),
                  ),
                  drawer: Container(
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(30),bottomRight: Radius.circular(30))
                    ),
                    child: ListView(
                      children: [
                        Container(
                          height: 200,
                            decoration:  BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(topRight: Radius.circular(30)),
                                border: Border.all(color: Colors.transparent)
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("assets/icon/appicon.png",
                                    height: 70,
                                    width: 70,
                                  ),
                                  SizedBox(height: 10),
                                  Text('$greetingMsg\n${loggedInUser!.displayName}',
                                    style: const TextStyle(
                                        color: Colors.black54,
                                        // fontWeight: FontWeight.w600,
                                        fontSize: 16
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ]),
                            )),
                        Divider(
                          height: 6,
                          color: Colors.grey.shade300,
                          thickness: 2,
                          indent: 10,
                          endIndent: 10),
                        drawerTile("Home",Icons.home_outlined),
                        if(userSnapshot.data!['isAdmin'])
                        drawerTile("Transaction",Icons.payment_outlined),
                        drawerTile("Logout",Icons.logout_outlined)
                      ],
                    )
                  ),
                  body: screenChangeProviderModel.screen=='home'?
                  const HomeScreen():
                  screenChangeProviderModel.screen=='transaction'?
                  const AdminTransactionView():
                  const CardPayScreen()
                ),
              );
            }
          );
        }
      ),
    );
  }

  Widget drawerTile(String titleText, IconData tileIcon){
    return ListTile(
      onTap: () async {
          if(titleText == 'Logout'){
            logout();
          }else if(titleText =='Home'){
            _scaffoldKey.currentState!.openEndDrawer();
            setState(() {
              Provider.of<ScreenChangeProvider>(context, listen: false).screenChange("home");
            });
          }else if(titleText =='Transaction'){
            _scaffoldKey.currentState!.openEndDrawer();
            setState(() {
              Provider.of<ScreenChangeProvider>(context, listen: false).screenChange("transaction");
            });
          }
      },
      title: Text(titleText,
        style: const TextStyle(
            color: Colors.black54,
            // fontWeight: FontWeight.w600
        ),
      ),
      trailing: Icon(tileIcon,color: Colors.black54),
    );
  }

  logout() async {
    await AuthMethods().signOut();
    if (context.mounted) {
      Provider.of<ScreenChangeProvider>(context, listen: false).screenChange("home");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
          const LoginScreen(),
        ),
      );
      toastMsg('Logged Out Successfully!');
    }
  }
}


