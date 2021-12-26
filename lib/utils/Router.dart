
import 'package:flutter/material.dart';
import 'package:nuniyoekyc/RealScreens/aadhar_kyc_screen.dart';
import 'package:nuniyoekyc/RealScreens/bank_email_pan_validation_screen.dart';
import 'package:nuniyoekyc/RealScreens/commodity_upload_screen.dart';
import 'package:nuniyoekyc/RealScreens/congrats_screen.dart';
import 'package:nuniyoekyc/RealScreens/digilocker_web_view.dart';
import 'package:nuniyoekyc/RealScreens/esign_screen.dart';
import 'package:nuniyoekyc/RealScreens/esign_screen_duplicate.dart';
import 'package:nuniyoekyc/RealScreens/main_application_webview.dart';
import 'package:nuniyoekyc/RealScreens/mobile_validation_screen.dart';
import 'package:nuniyoekyc/RealScreens/options_screen.dart';
import 'package:nuniyoekyc/RealScreens/options_screen_two.dart';
import 'package:nuniyoekyc/RealScreens/personal_details_screen.dart';
import 'package:nuniyoekyc/RealScreens/splash_screen.dart';
import 'package:nuniyoekyc/RealScreens/upload_documents_and_signature.dart';
import 'package:nuniyoekyc/RealScreens/waiting_for_esign_screen.dart';
import 'package:nuniyoekyc/RealScreens/webcam_screen.dart';

/*
0) contact
1) email
2) market segment / Options / market segment
4) digiloc/aadhar kyc
5) personal info /
6) IPV / Webcam screen
7) docupload /
8) esign /
9) application status /
*/

class ScreenRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      //0
      case '/':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      //0
      case 'Mobile':
        return MaterialPageRoute(builder: (_) => MobileValidationLoginScreen());
      //1
      case 'Email':
        return MaterialPageRoute(builder: (_) => BankPanEmailValidationScreen());
      //2
      case 'Account':
        return MaterialPageRoute(builder: (_) => OptionsScreenTwo());
      //3
      case 'Digilocker':
        return MaterialPageRoute(builder: (_) => AadharKYCScreen());
      //4
      case 'Personal':
        return MaterialPageRoute(builder: (_) => PersonalDetailsScreen());
      //5
      case 'IPV':
        return MaterialPageRoute(builder: (_) => WebCamScreen());
      //6
      case 'Document':
        return MaterialPageRoute(builder: (_) => UploadDocumentScreen());
      //7
      case 'Esign':
        return MaterialPageRoute(builder: (_) => EsignScreen());
      //8
      case 'UCC':
        return MaterialPageRoute(builder: (_) => CongratsScreen());
      //EXTRA
      case '/webview':
        return MaterialPageRoute(builder: (_) => BrowserViewX());
      case 'EsignResponse':
        return MaterialPageRoute(builder: (_) => EsignScreenResponse());
      case 'OPEN':
        return MaterialPageRoute(builder: (_) => CommodityDocumentUploadScreen());
      case 'MALAMAL':
        return MaterialPageRoute(builder: (_) => MainApplication_WebView());
    default:
      return MaterialPageRoute(builder: (_) => MobileValidationLoginScreen());
    }
  }
}