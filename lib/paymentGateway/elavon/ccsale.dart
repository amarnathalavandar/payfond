
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
class ElavonccSale {
  static Future<Map<String, String?>>ccSale(String pgUrl,String sslMerchantId, String sslUserId, String sslPin,bool sslTestMode, String sslTransactionType,String sslCardNumber,String sslExpDate,num sslAmount,) async {
   /* var url = Uri.parse(pgUrl);
    var header = {'Content-Type': 'application/x-www-form-urlencoded'};
    var body = "xmldata=<txn><ssl_merchant_id>$sslMerchantId</ssl_merchant_id><ssl_user_id>$sslUserId</ssl_user_id><ssl_pin>$sslPin</ssl_pin><ssl_test_mode>$sslTestMode</ssl_test_mode><ssl_transaction_type>$sslTransactionType</ssl_transaction_type><ssl_card_number>$sslCardNumber</ssl_card_number><ssl_exp_date>$sslExpDate</ssl_exp_date><ssl_amount>$sslAmount</ssl_amount></txn>";
    var response = await http.post(url,body: body,headers: header);*/
    Map<String,String?> tempMap = {};
    /*if(response.statusCode == 200){
      try{
        final document = xml.XmlDocument.parse(response.body);
        final txn = document.findElements('txn');
        String? ssl_txn_id;
        String? ssl_amount;
        String? ssl_txn_time;
        String? ssl_card_short_description;
        String? ssl_transaction_type;
        for (final data in txn) {
          ssl_txn_id = data.findElements('ssl_txn_id').first.innerText;
          ssl_amount = data.findElements('ssl_amount').first.innerText;
          ssl_txn_time = data.findElements('ssl_txn_time').first.innerText;
          ssl_card_short_description = data.findElements('ssl_card_short_description').first.innerText;
          ssl_transaction_type = data.findElements('ssl_transaction_type').first.innerText;
        }
          tempMap = {
          "ssl_txn_id": ssl_txn_id,
          "ssl_amount" : ssl_amount,
          "ssl_txn_time" : ssl_txn_time,
          "ssl_card_short_description" : ssl_card_short_description,
          "ssl_transaction_type" : ssl_transaction_type,
          "pay_status" : "Paid"
        };
      }catch(e){
        final document = xml.XmlDocument.parse(response.body);
        final txn = document.findElements('txn');
        String? errorCode;
        String? errorName;
        String? errorMsg;
        for (final data in txn) {
           errorCode = data.findElements('errorCode').first.innerText;
           errorName = data.findElements('errorName').first.innerText;
           errorMsg = data.findElements('errorMessage').first.innerText;
        }
        tempMap = {
          "ssl_errorCode": errorCode,
          "ssl_errorName": errorName,
          "ssl_errorMsg": errorMsg,
          "pay_status" : "Failed"
        };

      }
      
    }*/
    tempMap = {
      "ssl_errorCode": "test",
      "ssl_errorName": "test",
      "ssl_errorMsg": "test",
      "pay_status" : "Failed"
    };
    return tempMap;
  }


}