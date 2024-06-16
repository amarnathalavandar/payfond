
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:intl/intl.dart';
import 'package:payfond/Firebase/payment_methods.dart';
import 'package:payfond/helper/app_colors.dart';
import 'package:payfond/paymentGateway/elavon/ccsale.dart';
import 'package:payfond/provider/screenChangeProvider.dart';
import 'package:payfond/widgets/toastWidget.dart';
import 'package:provider/provider.dart';


class CardPayScreen extends StatefulWidget {
  const CardPayScreen({super.key});

  @override
  CardPayScreenState createState() => CardPayScreenState();
}

class CardPayScreenState extends State<CardPayScreen> {


  bool isLoading = false;
  final _auth = FirebaseAuth.instance;

  TextEditingController cardNumber = TextEditingController();
  TextEditingController expiryDate = TextEditingController();
  TextEditingController cardHolderName = TextEditingController();
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  bool useFloatingAnimation = true;

  TextEditingController amountCtrl = TextEditingController();

  final OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.7),
      width: 2.0,
    ),
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
     getCurrentUser();
    super.initState();
    dateFormatConvert(DateTime.now().millisecondsSinceEpoch);
  }

  String dateFormatConvert(int dateValue){
    int epochMilliseconds = dateValue; // Replace this with your epoch timestamp in milliseconds
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epochMilliseconds);
    DateFormat dateFormat = DateFormat("dd/MM/yyyy");
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }

  String tempFBTransactionId = '';

  void createData(String pgUrl, String ssl_merchant_id, String ssl_user_id,String ssl_pin) async {

    try{
    String createRes = await PaymentMethods().fireStoreCreatePayment(tempFBTransactionId: tempFBTransactionId, amount:num.parse(amountCtrl.text), cardNumber: cardNumber.text, userName:loggedInUser!.displayName, cardHolderName:cardHolderName.text, expiryDate: '01/25',
        transactionDate: dateFormatConvert(DateTime.now().millisecondsSinceEpoch), transactionStartTime:  DateTime.now().millisecondsSinceEpoch, userUid:loggedInUser!.uid, payStatus: "Pending");
    if (createRes == "success") {
      ElavonccSale.ccSale(pgUrl, ssl_merchant_id, ssl_user_id, ssl_pin, false, "ccsale", cardNumber.text, expiryDate.text, num.parse(amountCtrl.text)).then((xmlRes){
        updateData(xmlRes);
      });
    }
    }catch(e) {
      print(e.toString());
    }
  }

  void updateData(xmlRes) async{
    Map updateRes = await PaymentMethods().fireStoreUpdatePayment(xxmData: xmlRes, tempFBTransactionId: tempFBTransactionId, transactionEndTime: DateTime.now().millisecondsSinceEpoch);
    if(updateRes["updateRes"] == "Updated Successfully"){
      cardNumber.clear();
      cardHolderName.clear();
      expiryDate.clear();
      amountCtrl.clear();
      setState(() {
        isLoading = false;
      });
      if(updateRes["paymentStatus"] == "Paid"){
        toastMsg(updateRes["successMsg"]);
        setState(() {
          Provider.of<ScreenChangeProvider>(context, listen: false).screenChange("home");
        });
      }
      else{
        if(updateRes["errorCode"]== "5000"){
          errorAlert(updateRes["errorName"], "Credit Card Number Invalid, Please check");
        }
        else if(updateRes["errorCode"]== "5001"){
          errorAlert(updateRes["errorName"], "Exp Date Invalid. Please check");
        }
        else if(updateRes["errorCode"]== "4025"){
          toastMsg(updateRes["Something went wrong!"]);
          setState(() {
            Provider.of<ScreenChangeProvider>(context, listen: false).screenChange("home");
          });
        }
        else{
          toastMsg(updateRes["errorMsg"]);
          setState(() {
            Provider.of<ScreenChangeProvider>(context, listen: false).screenChange("home");
          });
        }

      }
    }
  }

  _onValidate(String pgUrl, String ssl_merchant_id, String ssl_user_id,String ssl_pin) async {
    FocusManager.instance.primaryFocus?.unfocus();
    tempFBTransactionId = DateTime.now().millisecondsSinceEpoch.toString();
    if (formKey.currentState?.validate() ?? false){
      setState(() {
        isLoading = true;
      });
      createData(pgUrl, ssl_merchant_id, ssl_user_id, ssl_pin);
    }

  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('config').doc("elavontest").snapshots(),
        builder: (context,pgSnapshot) {
        return Stack(
          children: [
            Center(
              child: Padding(
                  padding: const EdgeInsets.only(left: 20,right: 20,top: 50),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CreditCardWidget(
                          enableFloatingCard: useFloatingAnimation,
                          glassmorphismConfig: _getGlassmorphismConfig(),
                          cardNumber: cardNumber.text,
                          expiryDate: expiryDate.text,
                          cardHolderName: cardHolderName.text,
                          cvvCode: cvvCode,
                          bankName: '',
                          frontCardBorder: useGlassMorphism
                              ? null
                              : Border.all(color: Colors.grey),
                          backCardBorder: useGlassMorphism
                              ? null
                              : Border.all(color: Colors.grey),
                          showBackView: false,
                          obscureCardNumber: true,
                          obscureCardCvv: true,
                          isHolderNameVisible: true,
                          cardBgColor: AppColors.cardBgColor,
                          backgroundImage: null,
                          isSwipeGestureEnabled: false,
                          onCreditCardWidgetChange:
                              (CreditCardBrand creditCardBrand) {},
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                CreditCardForm(
                                  formKey: formKey,
                                  obscureCvv: true,
                                  obscureNumber: true,
                                  cardNumber: cardNumber.text,
                                  cvvCode: cvvCode,
                                  enableCvv: false,
                                  isHolderNameVisible: true,
                                  isCardNumberVisible: true,
                                  isExpiryDateVisible: true,
                                  cardHolderName: cardHolderName.text,
                                  expiryDate: expiryDate.text,
                                  inputConfiguration: const InputConfiguration(
                                      cardNumberDecoration: InputDecoration(
                                        labelText: 'Card Number',
                                        hintText: 'xxxx xxxx xxxx xxxx',
                                      ),
                                      expiryDateDecoration: InputDecoration(
                                        labelText: 'Expiry Date',
                                        hintText: 'xx/yy',
                                      ),
                                      cvvCodeDecoration: InputDecoration(
                                        labelText: 'CVV',
                                        hintText: 'cvv',
                                      ),
                                      cardHolderDecoration: InputDecoration(
                                        labelText: 'Card Holder',
                                      )),

                                  onCreditCardModelChange: onCreditCardModelChange,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                          width: MediaQuery.of(context).size.width/2,
                                          child: TextField(
                                              controller: amountCtrl,
                                              keyboardType: TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                                              ],
                                              decoration: const InputDecoration(
                                                label: Text('Amount'),
                                              )))),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                    onPressed: (){
                                      if(amountCtrl.text.isNotEmpty){
                                        _onValidate(pgSnapshot.data!["url"],pgSnapshot.data!["ssl_merchant_id"],pgSnapshot.data!["ssl_user_id"],pgSnapshot.data!["ssl_pin"],);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(10),
                                        backgroundColor: Colors.blueGrey,
                                        minimumSize: const Size(150, 50)
                                    ),
                                    child: const Text("Submit",
                                      style: TextStyle(
                                        color: Colors.white
                                      ),
                                    )),
                                const SizedBox(height: 20),

                              ],
                            ),
                          ),
                        ),
                      ])),
            ),
            if(isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.blueGrey,
                ))
          ],
        );
      }
    );
  }

  Glassmorphism? _getGlassmorphismConfig() {
    if (!useGlassMorphism) {
      return null;
    }

    final LinearGradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Colors.grey.withAlpha(50), Colors.grey.withAlpha(50)],
      stops: const <double>[0.3, 0],
    );

    return
      Glassmorphism.defaultConfig();
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber.text = creditCardModel.cardNumber;
      expiryDate.text = creditCardModel.expiryDate;
      cardHolderName.text = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
  errorAlert(String errorTitle, String errorContent){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(errorTitle),
          content: Text(errorContent),
          actions: [
            TextButton(onPressed: (){
              Navigator.pop(context);
              setState(() {
                cardNumber.clear();
                expiryDate.clear();
                cardHolderName.clear();
                //amountCtrl.clear();

                CreditCardModel cardFormObj = CreditCardModel(cardNumber.text, expiryDate.text, cardHolderName.text, cvvCode, isCvvFocused);

                cardFormObj.cardNumber = "";
                cardFormObj.expiryDate = "";
                cardFormObj.cardHolderName = "";

                // Provider.of<ScreenChangeProvider>(context, listen: false).screenChange("home");
              });
            }, child: Text("OK"))
          ],
        )
    );
  }
}

