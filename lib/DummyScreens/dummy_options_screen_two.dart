import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuniyoekyc/ApiRepository/api_repository.dart';
import 'package:nuniyoekyc/DummyScreens/dummy_webcam_screen.dart';
import 'package:nuniyoekyc/widgets/widgets.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../globals.dart';

class DummyOptionsScreenTwo extends StatefulWidget {
  const DummyOptionsScreenTwo({Key? key}) : super(key: key);


  @override
  _DummyOptionsScreenTwoState createState() => _DummyOptionsScreenTwoState();
}

class _DummyOptionsScreenTwoState extends State<DummyOptionsScreenTwo> {

  String total= "0";

  bool checkedValue  = false;

  String? _groupValue;

  String amount="";

  bool enablePaymentButton = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child:Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: WidgetHelper().NuniyoAppBar(),
      body: SingleChildScrollView(
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.0,),
                    Row(
                      children: [
                        SizedBox(width: 10.0,),
                        Text("Select Brokerage Plan",textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 22.0,letterSpacing: .5,fontWeight: FontWeight.bold)),),
                        //Text(" ₹ $total",textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 22.0,letterSpacing: .5,fontWeight: FontWeight.bold)),),
                      ],
                    ),
                   Padding(
                      padding: const EdgeInsets.fromLTRB(8.0,10,0,0),
                      child: Container(height: 5, width: 35,
                        decoration: BoxDecoration(
                            color: primaryColorOfApp,
                            borderRadius: BorderRadius.all(Radius.circular(20))
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0,),
                  ],
                ),
                SizedBox(height: 24.0,),
                Container(
                  height: _groupValue=="platinum"?210:100,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: primaryColorOfApp,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex:1,
                              child: Radio(
                              value: "platinum",
                              groupValue: _groupValue,
                              onChanged: (String? value) {
                                setState(() {
                                  _groupValue = value;
                                  total = "1250";
                                  //print(_groupValue);
                                });
                              },
                            ),),
                            Expanded(
                              flex:5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Platinum",textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 22.0,letterSpacing: .5,fontWeight: FontWeight.bold)),),
                              ),
                            ),
                            Text("₹1,250",textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 22.0,letterSpacing: .5,fontWeight: FontWeight.bold)),)
                          ],
                        ),
                        Visibility(child: Padding(
                            padding: const EdgeInsets.fromLTRB(8.0,0.0,0.0,0.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("1) Upfront Margin", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                    Text("₹100,000", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child:Text("2) Intraday", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                    Text("0.01%", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child:Text("3) Delivery", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                    Text("0.10%", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child:Text("4) Options/Lot", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                    Text("₹10", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child:Text("5) Currency/Lot", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                    Text("₹5", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                  ],
                                ),
                              ],
                            )
                        ),visible: _groupValue=="platinum",)
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.0,),
                Container(
                  height: _groupValue=="gold"?210:100,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: primaryColorOfApp,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex:1,
                              child: Radio(
                                value: "gold",
                                groupValue: _groupValue,
                                onChanged: (String? value) {
                                  setState(() {
                                    _groupValue = value;
                                    total = "550";
                                    //print(_groupValue);
                                  });
                                },
                              ),),
                            Expanded(
                              flex:5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Gold",textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 22.0,letterSpacing: .5,fontWeight: FontWeight.bold)),),
                              ),
                            ),
                            Text("₹550",textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 22.0,letterSpacing: .5,fontWeight: FontWeight.bold)),)
                          ],
                        ),
                        Visibility(visible: _groupValue=="gold",child: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0,0.0,0.0,0.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("1) Upfront Margin", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                  Text("₹25,000", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child:Text("2) Intraday", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                  Text("0.03%", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child:Text("3) Delivery", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                  Text("0.30%", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child:Text("4) Options/Lot", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                  Text("₹30", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child:Text("3) Currency/Lot", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                  Text("₹10", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                ],
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.0,),
                Container(
                  height: _groupValue=="silver"?210:100,
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: primaryColorOfApp,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex:1,
                              child: Radio(
                                value: "silver",
                                groupValue: _groupValue,
                                onChanged: (String? value) {
                                  setState(() {
                                    _groupValue = value;
                                    total = "300";
                                    //print(_groupValue);
                                  });
                                },
                              ),),
                            Expanded(
                              flex:5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Silver",textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 22.0,letterSpacing: .5,fontWeight: FontWeight.bold)),),
                              ),
                            ),
                            Text("₹300",textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 22.0,letterSpacing: .5,fontWeight: FontWeight.bold)),)
                          ],
                        ),
                        Visibility(visible: _groupValue=="silver",child: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0,0.0,0.0,0.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("1) Upfront Margin", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                  Text("₹5,000", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child:Text("2) Intraday", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                  Text("0.05%", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child:Text("3) Delivery", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                  Text("0.50%", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child:Text("4) Options/Lot", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                  Text("₹50", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child:Text("3) Currency/Lot", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5)))),
                                  Text("₹20", style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 12.0,letterSpacing: .5))),
                                ],
                              ),
                            ],
                          ),
                        ),)
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.0,),
                Divider(
                  height: 20,
                  thickness: 2,
                  indent: 20,
                  endIndent: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Total",textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(color:primaryColorOfApp,fontSize: 22.0,letterSpacing: .5,fontWeight: FontWeight.bold))),
                    Text("₹ $total",textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(color:primaryColorOfApp,fontSize: 22.0,letterSpacing: .5,fontWeight: FontWeight.bold))),
                  ],
                ),
                Divider(
                  height: 20,
                  thickness: 2,
                  indent: 20,
                  endIndent: 20,
                ),
                SizedBox(height: 30,),
                Container(
                  color: Colors.transparent,
                  width: MediaQuery.of(context).size.width,
                  height: 75,
                  child: FlatButton(
                    disabledTextColor: Colors.blue,
                    disabledColor: secondaryColorOfApp,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    onPressed: ()  {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => DummyWebCamScreen()),
                      );

                      //Navigator.pushNamed(context, 'Digilocker');
                    },
                    color: primaryColorOfApp,
                    child: enablePaymentButton?Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "Please Wait",
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                        ),
                        SizedBox(width:20,),
                        CircularProgressIndicator(color: Colors.white,),
                      ],
                    ):Text(
                        "Proceed",
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4.0,10.0,0.0,0.0),
                  child: Text("* You can create F&O and Commodity account after equity account opening is completed." ,textAlign:TextAlign.left, style:GoogleFonts.openSans(textStyle: TextStyle(height:2,color: Colors.black,fontSize: 10.0,letterSpacing: .5)),),
                ),
              ],
            ),
          ),
        ),
      ),)
    );
  }

  Future<bool> _onWillPop() {
    return Future.value(false);
  }

}
