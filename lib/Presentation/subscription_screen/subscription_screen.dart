import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:resume_builder/Presentation/resources/route_manager.dart';
import 'package:resume_builder/model/subscription_package_model.dart';

import '../../firestore/user_firestore.dart';
import '../../model/model.dart';
import '../resources/assets_manager.dart';
import '../resources/color_manager.dart';
import '../resources/font_manager.dart';
import '../resources/strings_manager.dart';
import '../resources/values_manager.dart';

class SubscriptionView extends StatefulWidget {
  const SubscriptionView({super.key});

  @override
  State<SubscriptionView> createState() => _SubscriptionViewState();
}

class _SubscriptionViewState extends State<SubscriptionView> {
  SubPackage? selectedPackage;
  // final _razorpay = Razorpay();
  String? appsaitLogo;
  @override
  void initState() {
    // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // TODO: implement initState
    super.initState();
  }

  // FireUser().addSubscriptionDetails(subscriptionDetail);
  // Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
  //   SubscriptionDetail subscriptionDetail = SubscriptionDetail(
  //     subStartDate: _getcurrentDate(),
  //     subEndDate: _getEndDate(months: selectedPackage!.dur_month),
  //     paymentId: response.paymentId,
  //     orderId: response.orderId,
  //     signature: response.signature,
  //     duration: selectedPackage!.dur_month,
  //     packageName: selectedPackage!.package_name,
  //     subscribed: true
  //   );
  //   bool result = await FireUser().addSubscriptionDetails(subscriptionDetail);
  //   if(result){
  //     Navigator.of(context).pushReplacementNamed(Routes.splash);
  //   }
  //   print("Payment Success");
  //
  //
  //   // Do something when payment succeeds
  // }
  //
  // void _handlePaymentError(PaymentFailureResponse response) {
  //   const snackBar = SnackBar(
  //     content: Text('Payment Failed, try Again !!'),
  //   );
  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   print("Payment Failed");
  //   // Do something when payment fails
  // }

  @override
  void dispose() {
  
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _screenHeight = MediaQuery.of(context).size.height;
    double _screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushReplacementNamed(Routes.homescreen);
        return Future(() => true);
      },
      child: Scaffold(
        // appBar: AppBar(
        //   forceMaterialTransparency: true,
        //    toolbarOpacity: 0,
        //   bottomOpacity: 0,
        //   foregroundColor: Colors.transparent,
        //   backgroundColor: Colors.transparent,
        //   systemOverlayStyle: SystemUiOverlayStyle(
        //     statusBarColor: ColorManager.white,
        //     statusBarBrightness: Brightness.dark,
        //     statusBarIconBrightness: Brightness.dark,
        //   ),
        // ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.p20),
          height: _screenHeight,
          width: _screenWidth,
          decoration: BoxDecoration(color: ColorManager.splashBackColor),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 30,
                ),
                Text(
                  AppStrings.appBarTitle,
                  style: TextStyle(
                      color: ColorManager.secondary,
                      fontSize: 30,
                      fontWeight: FontWeight.w300,
                      fontFamily: FontFamily.emblema),
                ),
                Container(
                    height: 300,
                    width: _screenWidth,
                    child: Image.asset(
                      ImageAssets.subLogo,
                      height: 300,
                      width: _screenWidth,
                      fit: BoxFit.contain,
                    )),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Upgrade to Premium",
                  style: TextStyle(
                      color: ColorManager.promo1BgColor,
                      fontSize: 30,
                      fontWeight: FontWeight.w300,
                      fontFamily: FontFamily.outfit),
                ),
                Container(
                  height: 250,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: packagesList(),
                  ),
                ),
            
                ElevatedButton(
                  onPressed: () => _checkout(subPackage: selectedPackage),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.promo1BgColor),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: Text(
                      "Get Started",
                      textScaleFactor: 1.5,
                      style: TextStyle(
                          color: Colors.white, fontFamily: FontFamily.outfit),
                    ),
                  ),
                ),
                Text(
                  AppStrings.subscriptionScreenText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: ColorManager.promo1BgColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      fontFamily: FontFamily.outfit),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkout({required SubPackage? subPackage}) async {
    if (subPackage != null) {
      // _razorpay.open(subPackage.toMap());
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => UsePaypal(
              // sandboxMode: true,
              clientId:
                  "AUAdndslY5O1St2I6LMOr-_jo7iUY_xvDoo49-csJEcGDdwh8W2XOxrB23DqeWnzyewunljyflIW5-u8",
              secretKey:
                  "EIKsJQrtkbxo7dF-WSGhmbY8mMgCtuSWoMUSUEQ-VKmTyRbcGVWK71mFLP4JYuizh-6kSdDEioF3SYhA",
              returnURL: "https://samplesite.com/return",
              cancelURL: "https://samplesite.com/cancel",
              transactions: [
                {
                  "amount": {
                    "total": selectedPackage!.amount,
                    "currency": "USD",
                    "details": {
                      "subtotal": selectedPackage!.amount,
                      "shipping": '0',
                      "shipping_discount": 0
                    }
                  },
                  "description": "The payment transaction description.",
                  "payment_options": {
                    "allowed_payment_method": "INSTANT_FUNDING_SOURCE"
                  },
                  "item_list": {
                    "items": [
                      {
                        "name": "A demo product",
                        "quantity": 1,
                        "price": selectedPackage!.amount,
                        "currency": "USD"
                      }
                    ],

                    // shipping address is not required though
                    // "shipping_address": {
                    //   "recipient_name": "Jane Foster",
                    //   "line1": "Travis County",
                    //   "line2": "",
                    //   "city": "Austin",
                    //   "country_code": "US",
                    //   "postal_code": "73301",
                    //   "phone": "+00000000",
                    //   "state": "Texas"
                    // },
                  }
                }
              ],
              note: "Contact us for any questions on your order.",
              onSuccess: (Map response) {
                _updateDetails(response);

                print("Payment Success");

                print("onSuccess: $response");
              },
              onError: (error) {
                print("onError: $error");
              },
              onCancel: (params) {
                print('cancelled: $params');
              }),
        ),
      );
    }
  }

  Future<void> _updateDetails(Map response) async {
    SubscriptionDetail subscriptionDetail = SubscriptionDetail(
        subStartDate: _getcurrentDate(),
        subEndDate: _getEndDate(months: selectedPackage!.dur_month),
        paymentId: response['paymentId'],
        payerId: response['payer_id'],
        currency: response['currency'],
        duration: selectedPackage!.dur_month,
        packageName: selectedPackage!.package_name,
        subscribed: true);
    bool result = await FireUser().addSubscriptionDetails(subscriptionDetail);
    // if(mounted){
    if (result) {
      await Navigator.of(context).pushReplacementNamed(Routes.splash);
    }
    // }
  }

  // Future<void> getAppsAitLogo() async {
  //   ByteData bytes = await rootBundle.load(ImageAssets.appsAitLogo);
  //   var buffer = bytes.buffer;
  //   String m = base64.encode(Uint8List.view(buffer));
  //   appsaitLogo = m;
  // }
  List<Widget> packagesList() => [
        _getSubscrptionPack(
            subPackage:
                SubPackage(amount: 17, package_name: "Diamond", dur_month: 12)),
        _getSubscrptionPack(
            subPackage:
                SubPackage(amount: 4, package_name: "Gold", dur_month: 3)),
        _getSubscrptionPack(
            subPackage:
                SubPackage(amount: 2, package_name: "Basic", dur_month: 1)),
      ];

  Widget _getSubscrptionPack({required SubPackage subPackage}) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedPackage = subPackage;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        height: 150,
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          border: selectedPackage?.package_name == subPackage.package_name
              ? Border.all(
                  color: ColorManager.selectedPackageBorderColor,
                  width: 5,
                  strokeAlign: BorderSide.strokeAlignOutside)
              : Border.all(color: Colors.transparent, width: 0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                  horizontal: AppPadding.p8, vertical: AppPadding.p8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: ColorManager.promo1BgColor),
              child: Center(
                child: Text(
                  "${subPackage.package_name}",
                  style: TextStyle(
                      color: ColorManager.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      fontFamily: FontFamily.outfit),
                ),
              ),
            ),
            Text(
              "${subPackage.dur_month}",
              style: TextStyle(
                color: ColorManager.promo1BgColor,
                fontSize: 50,
                fontWeight: FontWeight.bold,
                // fontFamily: FontFamily.outfit
              ),
            ),
            Text(
              "months\n \$ ${subPackage.amount}",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorManager.promo1BgColor,

                // fontSize: 50,
                fontWeight: FontWeight.w300,
                // fontFamily: FontFamily.outfit
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: AppPadding.p8),
                  child: SvgPicture.asset(
                    ImageAssets.subCrown,
                    height: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getcurrentDate() {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);

    print(formattedDate);
    return formattedDate;
  }

  String _getEndDate({required int months}) {
    var endDate = Jiffy.now().add(months: months);
    String formattedDate = endDate.format(pattern: "yyyy-MM-dd");
    return formattedDate;
  }
}
