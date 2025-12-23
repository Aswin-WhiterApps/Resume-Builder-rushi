




class SubPackage{
  String key = "rzp_test_4qFqnbgYaejcc6";
  double amount;
  int dur_month;
  // String image ;
  String name= "Apps Ait";
  String currency= "INR";
  // String order_id = "asfdafdfd";
  String package_name;

  SubPackage({required this.amount,required this.package_name,required this.dur_month,
    // required this.image
  });

  Map<String, dynamic> toMap(){
    return{
      "key" : key,
      "amount":amount*100,
      "name" : name,
      // "image" : utf8.fuse(base64).encode(image),
      "currency" : currency,
      "description" : "packageName:$package_name,amount:$amount,subscription_duration:$dur_month months."
    };

  }
}
