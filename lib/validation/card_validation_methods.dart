

class PaymentCardValidation {

   static String? cardNumberValidation(String? cardNumber){
    int cardNo = int.parse(cardNumber!);
    if(cardNo is! int){
        return 'Field should be 16 digit number';
    }else if(cardNumber.length<16){
        return 'Please enter a 16 digit number';
    }else{
      return null;
    }
  }


}


