import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethods{
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<String> fireStoreCreatePayment({
    required tempFBTransactionId,
    required num amount,
    required cardNumber,
    required userName,
    required cardHolderName,
    required expiryDate,
    required transactionDate,
    required transactionStartTime,
    required userUid,
    required payStatus
  })async{
    String res = "Some error Occurred";
   try{
     print('tempFBTransactionId--->$tempFBTransactionId');
     _fireStore.collection('transaction').doc(tempFBTransactionId).set({
       "amount": amount,
       "cardNumber" : cardNumber,
       "cardName" : "TEST",
       "userName" : userName,
       "cardHolder" : cardHolderName,
       "cardExpireDate" : expiryDate,
       "transactionDate" : transactionDate,
       "transactionStartTime": transactionStartTime,
       "transactionEndTime" : "",
       "transactionType" : "",
       "transactionId" : "",
       "uid" : userUid,
       "paymentStatus" : payStatus,
       "remarks" : {}
     });
     res = "success";
   }catch(e){
     return e.toString();
   }
   return res;
  }

  Future<Map> fireStoreUpdatePayment({
    required xxmData,
    required tempFBTransactionId,
    required transactionEndTime,
  })async {
    await Future.delayed(const Duration(seconds: 2));
    Map res = {};
    try {
      _fireStore.collection('transaction').doc(tempFBTransactionId).update({
        "transactionEndTime": transactionEndTime,
        "paymentStatus":"Paid"
      });
      res = {
        "updateRes":"Updated Successfully",
        "successMsg": "Paid Successfully",
        "paymentStatus": "Paid",
      };

     /* if(xxmData['pay_status'] == "Paid"){
        _fireStore.collection('transaction').doc(tempFBTransactionId).update({
          "amount": xxmData['ssl_amount'],
          "cardName": xxmData['ssl_card_short_description'],
          "transactionEndTime": transactionEndTime,
          "transactionType": xxmData['ssl_transaction_type'],
          "transactionId": xxmData['ssl_txn_id'],
          "paymentStatus": xxmData['pay_status']
        });
        res = {
          "updateRes":"Updated Successfully",
          "successMsg": "Paid Successfully",
          "paymentStatus": xxmData['pay_status'],
        };
      }else{
        _fireStore.collection('transaction').doc(tempFBTransactionId).update({
          "paymentStatus": xxmData['pay_status'],
          "transactionEndTime": transactionEndTime,
          "remarks" : {
            "errorCode": xxmData['ssl_errorCode'],
            "errorName": xxmData['ssl_errorName'],
            "errorMsg": xxmData['ssl_errorMsg']
          }
        });
        res = {
          "updateRes":"Updated Successfully",
          "errorName": xxmData['ssl_errorName'],
          "errorMsg": xxmData['ssl_errorMsg'],
          "errorCode": xxmData['ssl_errorCode'],
          "paymentStatus": xxmData['pay_status'],
        };
      }*/

    }
    catch (e) {
      res = res = {
        "updateRes":"Update Failed",
      };
      // Fluttertoast.showToast(
      //     msg: "$e",
      //     toastLength: Toast.LENGTH_LONG,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.grey,
      //     textColor: Colors.white,
      //     fontSize: 16.0
      // );
    }
    return res;
  }

}