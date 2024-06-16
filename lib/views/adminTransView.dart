import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payfond/provider/screenChangeProvider.dart';
import 'package:payfond/utils/utils.dart';
import 'package:provider/provider.dart';

class AdminTransactionView extends StatefulWidget {
  const AdminTransactionView({super.key, this.restorationId});
  final String? restorationId;

  @override
  State<AdminTransactionView> createState() => _AdminTransactionViewState();
}

class _AdminTransactionViewState extends State<AdminTransactionView> with RestorationMixin{

  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();

  DateTime? startDateTime;
  DateTime? endDateTime;

  String fieldCheck = "";
  String dateFormatConvert(int dateValue){
    int epochMilliseconds = dateValue;
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epochMilliseconds);
    DateFormat dateFormat = DateFormat("dd/MM/yyyy");
    String formattedDate = dateFormat.format(dateTime);
    return formattedDate;
  }

  @override
  String? get restorationId => widget.restorationId;

  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture = RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
      BuildContext context,
      Object? arguments,
      ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {

        _selectedDate.value = newSelectedDate;

        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(_selectedDate.value.millisecondsSinceEpoch);

        DateFormat dateFormat = DateFormat("dd/MM/yyyy");


        if(fieldCheck == "s"){
          startDateTime = dateTime;
          startDate.text = dateFormat.format(dateTime);
        }
        else{
          endDateTime = dateTime;
          endDate.text = dateFormat.format(dateTime);
        }
      });
    }
  }

  Stream<QuerySnapshot> eventsStream() {
    return FirebaseFirestore.instance.collection('transaction').
    where('transactionStartTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDateTime!)).
    where('transactionStartTime', isLessThanOrEqualTo: Timestamp.fromDate(endDateTime!)).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;
    if(startDate.text.isNotEmpty && endDate.text.isNotEmpty) {
      return StreamBuilder(
          stream: eventsStream(),
          builder: (context,snapshot) {
            return Consumer<ScreenChangeProvider>(
                builder: (context, screenChangeProviderModel, child) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 80,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: const [
                                  BoxShadow(
                                    offset: Offset(2, 2),
                                    blurRadius: 12,
                                    color: Color.fromRGBO(0, 0, 0, 0.16),
                                  ),
                                ]
                            ),
                            child:  Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                dateContainer(startDate.text,"From Date"),
                                Container(
                                  width: 2,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                ),
                                dateContainer(endDate.text,"End Date")
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Divider(
                              endIndent: 30,
                              indent:   30,
                          ),
                          const SizedBox(height: 15),
                          Expanded(
                            child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                physics: const AlwaysScrollableScrollPhysics(),
                                separatorBuilder: (context,
                                    index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return transactionContainer(double.parse(
                                      snapshot.data!.docs[index]['amount']
                                          .toString()), snapshot.data!
                                      .docs[index]['transactionEndTime'],
                                      snapshot.data!.docs[index]['cardNumber']
                                          .toString()
                                          .split(' ')
                                          .last, snapshot.data!
                                          .docs[index]['paymentStatus'],
                                      snapshot.data!.docs[index].id);
                                }),
                          ),
                        ]),
                  );
                }
            );
          }
      );
    }
    else{
      return StreamBuilder(
          stream: FirebaseFirestore.instance.collection('transaction').snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            return Consumer<ScreenChangeProvider>(
                builder: (context, screenChangeProviderModel, child) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 80,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                  BoxShadow(
                                    offset: Offset(2, 2),
                                    blurRadius: 12,
                                    color: Color.fromRGBO(0, 0, 0, 0.16),
                                  ),
                                ]
                            ),
                            child:  Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                dateContainer(startDate.text,"From Date"),
                                Container(
                                  width: 2,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey,
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                ),
                                dateContainer(endDate.text,"End Date")
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Divider(
                              endIndent: 30,
                              indent:   30
                          ),
                          const SizedBox(height: 15),
                          Expanded(
                            child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                physics: const AlwaysScrollableScrollPhysics(),
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return transactionContainer(double.parse(snapshot.data!.docs[index]['amount'].toString()),
                                      dateConverter(snapshot.data!.docs[index]['transactionEndTime']),
                                      snapshot.data!.docs[index]['userName'],
                                      snapshot.data!.docs[index]['paymentStatus'],
                                      snapshot.data!.docs[index].id);
                                }),
                          )
                        ]),
                  );
                }
            );
          }
      );
    }
  }

  Widget transactionContainer(num amount, String tranDate, String userName, String status, refId){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 12),
      height: 120,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white60),
          boxShadow: const [
            BoxShadow(
              offset: Offset(2, 2),
              blurRadius: 7,
              color: Color.fromRGBO(0, 0, 0, 0.16),
              spreadRadius: 0
            ),
          ]
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
                 // Icon(Icons.attach_money_sharp,color: Colors.black,size:17),
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
                  const Text("User Name",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey
                    ),
                  ),
                  Text(userName),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Status",style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey
                  ),),
                  Text(status),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Reference ID",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey
                    ),
                  ),
                  Text(refId),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget dateContainer(String dateText, String titleText){
    return GestureDetector(
      onTap: (){
        if(titleText == "From Date"){
          fieldCheck = "s";
          _restorableDatePickerRouteFuture.present();
        }else{
          fieldCheck = "e";
          _restorableDatePickerRouteFuture.present();
        }
      },
      child: SizedBox(
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Column(
              mainAxisAlignment : MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_month,
                color: Colors.blueGrey,
                  size: 30,
                ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment : MainAxisAlignment.center,
              children: [
                Text(titleText,
                    style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w800
                )),
                Text(dateText,
                    style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w400
               ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
