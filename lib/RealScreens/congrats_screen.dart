///Congrats Screen

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuniyoekyc/ApiRepository/api_repository.dart';
import 'package:nuniyoekyc/RealScreens/options_screen_two.dart';
import 'package:nuniyoekyc/utils/localstorage.dart';
import 'package:nuniyoekyc/widgets/widgets.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../globals.dart';
import '../nuniyo_custom_icons.dart';
import 'main_application_webview.dart';

class CongratsScreen extends StatefulWidget {
  const CongratsScreen({Key? key}) : super(key: key);

  @override
  _CongratsScreenState createState() => _CongratsScreenState();
}

class _CongratsScreenState extends State<CongratsScreen> {

  String emailAddress = "Loading..";
  String userName = "Loading..";

  bool isLoading = false;

  Image? congratsImage;

  File? pdfFile;

  bool viewForm = false;

  Uint8List? pdfInBytesFormat;

  bool hasDownloadedPdfSuccessfully = false;

  static const platform = const MethodChannel("razorpay_flutter");

  late Razorpay _razorpay;

  String total= "0";

  String amount="";

  bool enableDownloadPDFButton = true;
  bool enableViewPDFButton = true;

  @override
  void initState() {
    super.initState();
    congratsImage = Image.asset("assets/images/congratulations.png");
    //manageSteps();
    WidgetsBinding.instance!.addPostFrameCallback((_) => sendEmail());
    WidgetsBinding.instance!.addPostFrameCallback((_) => fetchInitialData());
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> fetchInitialData() async {

    Map valueMap = await ApiRepository().Get_User_Details();

    emailAddress = valueMap["res_Output"][0]["email_Id"];
    userName = valueMap["res_Output"][0]["mobile_No"];

    isLoading = true;
    setState(() {});
  }

  Future<void> downloadPDFFromServer() async {

    try{
      pdfInBytesFormat = await ApiRepository().Download_Application_Pdf();
    }
    catch(e){
      print(e);
      print("No Response From Download Application PDF! PDF Was Not Downloaded");
    }

    //Lets make a file and show it inside it
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path = '$dir/example.pdf';
    final File file = File(path);

    pdfFile = await file.writeAsBytes(pdfInBytesFormat!);
    setState(() {});

    print("PDF DOWNLOADED SUCCESSFULLYYYYYYYYY");

    hasDownloadedPdfSuccessfully = true;

    setState(() {});
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(congratsImage!.image, context);
  }


  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      // navigation bar color
      statusBarColor: secondaryColorOfApp, // status bar color
    ));
    return WillPopScope(child: !isLoading?Scaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                  "Please Wait....",textAlign:TextAlign.center,
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
              ),
              SizedBox(height: 20,),
              CircularProgressIndicator(color: primaryColorOfApp,),
            ],),
    )):Scaffold(
      floatingActionButton: viewForm?new FloatingActionButton(
          elevation: 0.0,
          child: new Icon(Icons.arrow_back_sharp),
          backgroundColor: primaryColorOfApp,
          onPressed: (){
            viewForm=false;
            setState(() {});
          }
      ):null,
      resizeToAvoidBottomInset: true,
      appBar: WidgetHelper().NuniyoAppBar(),
      body: !viewForm?SingleChildScrollView(
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidgetHelper().DetailsTitle('Congratulations !'),
                Center(child: SvgPicture.asset(
                    "assets/images/congrats.svg",
                    semanticsLabel: 'Acme Logo'
                )),
                SizedBox(height: 20,),
                Text("Your application is complete . After verification , you will recieve your login credentials on your e-mail.",textAlign:TextAlign.center,style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16),
                ),),
                SizedBox(height: 20,),
                Container(
                  height: 250.0,
                  width: MediaQuery.of(context).size.width,
                  decoration: new BoxDecoration(
                    boxShadow: [ //background color of box
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5.0, // soften the shadow
                        spreadRadius: 2.0, //extend the shadow
                      )
                    ],
                  ),
                  child: Container(
                    height: 80,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0,30.0,0.0,0.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            UserDetailsContainer(),
                            SizedBox(height: 20,),
                            Container(
                              color: Colors.transparent,
                              height: 60,
                              width: MediaQuery.of(context).size.width,
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => MainApplication_WebView()),
                                  );
                                },
                                color: primaryColorOfApp,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "Make Your First Trade :",textAlign:TextAlign.center,
                                        style: GoogleFonts.openSans(
                                          textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                                    ),
                                    Icon(Icons.arrow_right,color: Colors.white,size: 40.0,),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.transparent,
                      height: 60,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, 'OPEN');
                        },
                        color: primaryColorOfApp,
                        child: Text(
                            "Open F&O & Currency Account",textAlign: TextAlign.center,
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      color: Colors.transparent,
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        onPressed: () {},
                        color: primaryColorOfApp,
                        child: Text(
                            "Add a Nominee",textAlign:TextAlign.center,
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      color: Colors.transparent,
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        onPressed: !enableViewPDFButton?null:() async {
                          enableViewPDFButton = false;
                          setState(() {});
                          await downloadPDFFromServer();
                          viewForm = !viewForm;
                          enableViewPDFButton = true;
                          setState(() {});
                        },
                        color: primaryColorOfApp,
                        disabledTextColor: Colors.blue,
                        disabledColor: secondaryColorOfApp,
                        child: !enableViewPDFButton?Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                "Fetching PDF",
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                            ),
                            SizedBox(width:20,),
                            CircularProgressIndicator(color: Colors.white,),
                          ],
                        ):Text(
                            "View Form",textAlign:TextAlign.center,
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      color: Colors.transparent,
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        onPressed: !enableDownloadPDFButton?null:() async {
                          //First Save Mangal Keshav Document Here...In a Local Storage!
                          enableDownloadPDFButton = false;
                          setState(() {});
                          await downloadPDFFromServer();
                          // the downloads folder path
                          Directory tempDir = await DownloadsPathProvider.downloadsDirectory;
                          String tempPath = tempDir.path;
                          var rng = new Random();
                          String newFileName="/mangalkeshav";
                          for (var i = 0; i < 10; i++) {
                            //print(rng.nextInt(100));
                            newFileName+=rng.nextInt(100).toString();
                          }
                          newFileName = newFileName+".pdf";
                          var filePath = tempPath + newFileName;

                          //Lets make a file and show it inside it
                          final File file = File(filePath);

                          if(pdfInBytesFormat==null){
                            fetchInitialData();
                          }

                          pdfFile = await file.writeAsBytes(pdfInBytesFormat!);
                          enableDownloadPDFButton = true;

                          setState(() {
                          });

                          //Then Show SnackBar
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.black,
                          content: Row(
                            children: [
                              Icon(hasDownloadedPdfSuccessfully?Icons.check_circle:Icons.error,color: hasDownloadedPdfSuccessfully?Colors.green:Colors.red,),
                              TextButton(child:Text(hasDownloadedPdfSuccessfully?"Download Completed : Tap to Open":"Failed to Download Form! , Please Retry",style: TextStyle(color: Colors.white, letterSpacing: 0.5),) ,onPressed: () async {
                                ///Open Downloaded Mangal Keshav PDF Here
                                ///Now to Open this File
                                final _result = await OpenFile.open(filePath);
                                //print(_result.message);
                              },),
                            ],
                          )
                          ),
                          );
                        },
                        color: primaryColorOfApp,
                        disabledTextColor: Colors.blue,
                        disabledColor: secondaryColorOfApp,
                        child: !enableDownloadPDFButton?Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                "Downloading PDF",
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                            ),
                            SizedBox(width:20,),
                            CircularProgressIndicator(color: Colors.white,),
                          ],
                        ):Text(
                            "Download Form",textAlign:TextAlign.center,
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Visibility(visible: viewForm,child:Container(
                      height: MediaQuery.of(context).size.height/6,
                      width: MediaQuery.of(context).size.width/3,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(0))
                      ),
                      child:pdfFile==null?Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                                "Please Wait ....",textAlign:TextAlign.center,
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                            ),
                            SizedBox(height: 20,),
                            CircularProgressIndicator(color: primaryColorOfApp,),
                          ],
                        ),
                      ):SfPdfViewer.file(pdfFile!),
                    )),
                    SizedBox(height: 20,),
                    Container(
                      height: 80,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColorOfApp),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        onPressed: () {},
                        child:
                        Row(
                          children: [
                            Icon(NuniyoCustomIcons.mobile_number_black,size: 30.0,color: primaryColorOfApp),
                            Flexible(
                              child: Text(
                                  "Get an App Download Link On Mobile",textAlign:TextAlign.center,
                                  style: GoogleFonts.openSans(
                                    textStyle: TextStyle(color: primaryColorOfApp, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              ],
            ),
          ),
        ),
      ):SfPdfViewer.file(pdfFile!),
    ), onWillPop: _onWillPop);
  }

  Future<bool> _onWillPop() {
    return Future.value(false);
  }

  Future<void> sendEmail() async {
    await ApiRepository().Welcome_Email();
    setState(() {});
  }


  UserDetailsContainer(){
    return Column(
      children: [
        Row(children: [
          Text(
              "Username  : ",textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
          ),
          Text(
              "$userName",textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16),)
          ),
        ],),
        Row(children: [
          Flexible(child:Text(
              "Email Id      : ",textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
          )),
          Flexible(child:Align(alignment: Alignment.bottomLeft,child:FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
              "$emailAddress",textAlign: TextAlign.left,maxLines: 1,
              style: GoogleFonts.openSans(
                textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16),)
          )))),
        ],),
        Row(children: [
          Text(
              "Margin        : ",textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text:" ₹ 0.00  ",
                  style: GoogleFonts.openSans(textStyle:TextStyle(color: Colors.black,letterSpacing: .5,fontSize: 16),
                  ),),
                TextSpan(text:"Add Margin",recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    print("sdxhs");
                    openCheckout();
                  },
                  style: GoogleFonts.openSans(textStyle: TextStyle(decoration: TextDecoration.underline,color: primaryColorOfApp,letterSpacing: .5,fontSize: 16),
                  ),),
              ],
            ),
            textAlign: TextAlign.center,
          )
        ],),
      ],
    );
  }

  UserDetails() {
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Username  :",textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
            ),
            Text(
                "Email Id  :",textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
            ),
            Text(
                "Margin  :",textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "$userName",textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16),)
            ),
            Text(
                "$emailAddress",textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.black, letterSpacing: .5),)
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "Rs.0.00",textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16),)
                ),
                SizedBox(width: 10,),
                Text(
                    "Add Funds",textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(decoration: TextDecoration.underline,color: primaryColorOfApp, letterSpacing: .5,fontSize: 16),)
                ),

              ],
            ),
          ],
        ),
      ],
    );
  }

  void openCheckout() async {
    setState(() {

    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phoneNumber= prefs.getString(MOBILE_NUMBER_KEY);
    String emailID = prefs.getString('EMAIL_ID');

    amount = (int.parse(total)*100).toString();
    //String amount = "100";
    var options = {
      'key': 'rzp_live_q8gUCOxfHIbCkb',
      //'key': 'rzp_test_dojmbldJSpz91g',
      //'amount': amount,
      'amount': "100",
      //"order_id":"$orderID",
      'name': 'TecXLabs',
      'description': 'Stock Trading',
      'prefill': {'contact': '$phoneNumber', 'email': '$emailID'},
    };

    /*if(orderID==null||orderID==""){
      options = {
        'key': 'rzp_live_q8gUCOxfHIbCkb',
        //'key': 'rzp_test_dojmbldJSpz91g',
        //'amount': amount,
        'amount': "100",
        //"order_id":"$orderID",
        'name': 'TecXLabs',
        'description': 'Stock Trading',
        'prefill': {'contact': '$phoneNumber', 'email': '$emailID'},
      };
    }*/

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {

    });
    Fluttertoast.showToast(msg: "SUCCESS: " + response.paymentId!, toastLength: Toast.LENGTH_SHORT);
    //print("Razor Payment Success SIGNATURE"+response.signature.toString());
    //print("Razor Payment Success ORDER ID"+response.signature.toString());
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {

    });
    Fluttertoast.showToast(msg: "ERROR: " + response.code.toString() + " - " + response.message!, toastLength: Toast.LENGTH_SHORT);
    //print("Payment Error");
    //print(response.code.toString());
    //print(response.message.toString());
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "EXTERNAL_WALLET: " + response.walletName!, toastLength: Toast.LENGTH_SHORT);
  }
}
