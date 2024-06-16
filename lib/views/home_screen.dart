import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payfond/provider/screenChangeProvider.dart';
import 'package:payfond/utils/utils.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('transaction').where('uid',isEqualTo: loggedInUser!.uid.toString()).snapshots(),
        builder: (context,AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        return Consumer<ScreenChangeProvider>(
            builder: (context,screenChangeProviderModel,child) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(left: 10,right: 10,top: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      ElevatedButton(
                        style: ButtonStyle(
                          visualDensity: VisualDensity.comfortable,
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          // foregroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                          overlayColor: MaterialStateProperty.all<Color>(Colors.grey.shade300),
                          surfaceTintColor: MaterialStateProperty.all(Colors.white),
                          shadowColor: MaterialStateProperty.all<Color>(Colors.grey),

                          elevation: MaterialStateProperty.all<double>(2.1),
                          fixedSize: MaterialStateProperty.all<Size>(Size(double.infinity, 180)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)
                          )),
                          side: MaterialStateProperty.all(BorderSide(
                            color: Colors.white24
                          ))



                        ),
                        child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Icon(Icons.payment,color: Colors.black38,),
                        SizedBox(width: 10),
                        Text('Click to pay now',
                        style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: Colors.black38
                        )),
                        ],
                        ),
                        onPressed: () {
                          screenChangeProviderModel.screenChange('cardPay');
                        },
                      ),
                      const SizedBox(height: 15),
                      Divider(
                        endIndent: 30,
                        indent:   30),
                      const SizedBox(height: 15),
                      Expanded(
                        child: ListView.separated(
                            reverse: false,
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            physics: const AlwaysScrollableScrollPhysics(),
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                          return transactionContainer(double.parse(snapshot.data!.docs[index]['amount'].toString()), dateConverter(snapshot.data!.docs[index]['transactionEndTime']), snapshot.data!.docs[index]['cardNumber'].toString().split(' ').last, snapshot.data!.docs[index]['paymentStatus'], snapshot.data!.docs[index].id);
                        }),
                      ),
                    ]));
          });
      });
  }
  Widget transactionContainer(num amount, String tranDate, String cardDigits, String status, refId){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 12),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        //border: Border.all(color: Colors.white60),
        boxShadow: const [
          BoxShadow(
            offset: Offset(2, 2),
            blurRadius: 5,
            color: Color.fromRGBO(0, 0, 0, 0.0),
          )]
      ),
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Amount",style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16
                  ),),
                  Row(

                      children:[
                        Icon(Icons.attach_money_sharp,color: Colors.black,size:17),
                        Text("${amount.toStringAsFixed(2)}"),
                   ]
                  )
                ],
              ),
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Transaction Date",style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16
              )),
                  Text(tranDate),
                ],
              )
            ],
          ),
          const Spacer(),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Last 4 digits",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey
                  )),
                  Text(cardDigits),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Status",style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey
                  )),
                  Text(status),
                ]
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Reference ID",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey
                    ),
                  ),
                  Text(refId),
                ],
              )
            ],
          )
        ],
      )
    );
  }
}
