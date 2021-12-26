///Web cam screen - IPV Screen

import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nuniyoekyc/ApiRepository/api_repository.dart';
import 'package:nuniyoekyc/utils/localstorage.dart';
import 'package:nuniyoekyc/widgets/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../globals.dart';


class WebCamScreen extends StatefulWidget {
  const WebCamScreen({Key? key}) : super(key: key);

  @override
  _WebCamScreenState createState() => _WebCamScreenState();
}

class _WebCamScreenState extends State<WebCamScreen> with WidgetsBindingObserver, TickerProviderStateMixin {

  ///Camera
  CameraController? controller;
  XFile? imageFile;
  XFile? videoFile;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  /// Camera

  bool viewOTPContainer = false;

  bool makeStepsVisible = false;

  String RecordingStatus = "Starting Camera...";

  bool showRecordingButton = false;
  bool viewProceedButton = false;

  bool enableProceedBtnRecordingDone = false;
  bool enableProceedBtnOTPMatched = false;

  bool enableRetryBtn = false;

  String ipvOtp = "";

  late FocusNode _IPVOTPTextFieldFocusNode;

  TextEditingController IPVOTPTextEditingController = new TextEditingController();

  int recordForHowManySeconds = 5;

  bool showOTPError = false;

  Image? glassesImage;
  Image? lightBulbImage ;
  Image? faceMaskImage;
  Image? hatImage;


  ScrollController _scrollController = ScrollController();

  bool proceedBtnOnceClicked=false;

  double scrollTo = 200;

  String retryBtnText = "Retry";

  bool linkSend = false;

  void _requestIPVOTPTextFieldFocusNode(){
    setState(() {
      FocusScope.of(context).requestFocus(_IPVOTPTextFieldFocusNode);
    });
  }

  AppLifecycleState? _notification;


  @override
  void initState() {
    super.initState();

    glassesImage = Image.asset('assets/images/reading-eyeglasses.png');
    lightBulbImage = Image.asset('assets/images/bright-lightbulb.png');
    faceMaskImage = Image.asset('assets/images/face-mask.png');
    hatImage = Image.asset('assets/images/hat.png');

    fetchOTP();
    //print("HOla");
    initializeCamera();

    setState(() {});

    _ambiguate(WidgetsBinding.instance)?.addObserver(this);
    if(cameras.isNotEmpty){
      controller = CameraController(cameras[1], ResolutionPreset.max);
      controller!.initialize().then((_) {
        if (!mounted) {
          //print("we came here");
          return;
        }
      });
    }
    else{

    }
    _IPVOTPTextFieldFocusNode = FocusNode();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(glassesImage!.image, context);
    precacheImage(lightBulbImage!.image, context);
    precacheImage(faceMaskImage!.image, context);
    precacheImage(hatImage!.image, context);
  }



  @override
  void dispose() {
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<bool> _onWillPop() {
    initializeCamera();
    setState(() {});
    return Future.value(false);
  }

  // This function is triggered when the user presses the back-to-top button
  void _scrollToTop() {
    _scrollController.animateTo(scrollTo, duration: Duration(milliseconds: 500), curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: WidgetHelper().NuniyoAppBar(),
      body: SingleChildScrollView(
        controller: _scrollController,
        //physics: const NeverScrollableScrollPhysics(),
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
                        Expanded(child:Text("Front Cam Verification (IPV)",textAlign:TextAlign.left,
                          style:GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black,fontSize: 20.0,letterSpacing: .5,fontWeight: FontWeight.bold)),)),
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
                //Container(
                  //child: imageFile==null?null:Image.file(File(imageFile!.path)),
                //),
                Visibility(visible:makeStepsVisible,child: Text("1.Click on Capture button to get the OTP on screen.\n\n2.Once you see the OTP the recording will start.\n\n3.Enter the OTP in the textbox below capture button.\n\n4.Once you enter the OTP recording will stop and it will get verified.\n",style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 16),
                ),),),
                SizedBox(height: 20,),
                ///Video Camera
                Expanded(
                  child: Center(child:
                  Container(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Center(
                          child: _cameraPreviewWidget(),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        //shape: BoxShape.circle,
                        border: Border.all(
                          color:
                          controller != null && controller!.value.isRecordingVideo
                              ? Colors.green
                              : Colors.grey,
                          width: 3.0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),

                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      //_thumbnailWidget(),
                      Expanded(flex:1,child:Visibility(visible: viewOTPContainer,
                        child:Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 75.0,
                            width: MediaQuery.of(context).size.width/2,
                            decoration: new BoxDecoration(
                              boxShadow: [ //background color of box
                                BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 5.0, // soften the shadow
                                  spreadRadius: 2.0, //extend the shadow
                                )
                              ],
                            ),
                            child: Container(
                              height: 80,
                              color: Colors.black12,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Center(
                                  child: Text("$ipvOtp",style: GoogleFonts.openSans(
                                    textStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold, letterSpacing: .5,fontSize: 24),
                                  ),),
                                ),
                              ),
                            ),
                          ),
                        ),)),
                      SizedBox(width: 10,),
                      ///Card Box
                      Visibility(visible: viewOTPContainer,child:Expanded(
                          flex: 1,
                          child: Container(
                            height: 80,
                            child: TextField(
                              onChanged: (value) async {
                                if(value.length==6){
                                  bool isOtpCorrect = await ApiRepository().VerifyIPVOTP(value);
                                  if(isOtpCorrect){
                                    showOTPError = false;
                                    showRecordingButton = true;
                                    enableProceedBtnOTPMatched = true;
                                    setState(() {
                                    });
                                  }
                                  else{
                                    showOTPError = true;
                                    showRecordingButton = false;
                                    enableProceedBtnOTPMatched = false;
                                    setState(() {});
                                  }
                                }
                              },
                              maxLength: 6,
                              cursorColor: primaryColorOfApp,
                              style: GoogleFonts.openSans(textStyle: TextStyle(color: Colors.black, letterSpacing: 0.5,fontSize: 14,fontWeight: FontWeight.bold)),
                              focusNode: _IPVOTPTextFieldFocusNode,
                              keyboardType: TextInputType.number,
                              controller: IPVOTPTextEditingController,
                              onTap: _requestIPVOTPTextFieldFocusNode,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(25.0,40.0,0.0,40.0),
                                  counter: Offstage(),
                                  errorText: showOTPError?"Enter a valid OTP":null,
                                  labelText: _IPVOTPTextFieldFocusNode.hasFocus ? 'Enter IPV OTP here' : 'Enter IPV OTP Here',
                                  labelStyle: GoogleFonts.openSans(textStyle:TextStyle(fontSize: 14,letterSpacing: 0.5,
                                    color: _IPVOTPTextFieldFocusNode.hasFocus ?primaryColorOfApp : Colors.grey,
                                  ))
                              ),
                            ),
                          ))),


                      //Center(child:Text("$ipvOtp",style: GoogleFonts.openSans(textStyle: TextStyle(color: primaryColorOfApp, letterSpacing: 0.5,fontSize: 40,fontWeight: FontWeight.bold)),)),

                    ],
                  ),
                ),

                Visibility(visible: viewOTPContainer,child:GestureDetector(child:Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: primaryColorOfApp,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8))
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: FlatButton(
                    disabledTextColor: Colors.grey,
                    disabledColor: secondaryColorOfApp,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    onPressed:(){print("Do Nothing");},
                    color: Colors.transparent,
                    child: Text(
                        "$RecordingStatus",
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(color:primaryColorOfApp, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                    ),
                  ),
                ),)),
                SizedBox(height: 10,),
                Visibility(visible: viewProceedButton,child:Container(
                  color: Colors.transparent,
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: FlatButton(
                    disabledTextColor: Colors.blue,
                    disabledColor: secondaryColorOfApp,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    onPressed:enableProceedBtnRecordingDone&&enableProceedBtnOTPMatched?() async {
                      //print("Uploading Video");
                      enableProceedBtnRecordingDone = false;
                      proceedBtnOnceClicked = true;
                      setState(() {});
                      //List<int> byteFormatOfVideoFile = await videoFile!.readAsBytes();
                      final file = File(videoFile!.path);
                      //print("Aapka File :"+videoFile!.path);
                      int sizeInBytes = file.lengthSync();
                      double sizeInMb = sizeInBytes / (1024 * 1024);
                      //print("AAPKA FILE SIZE HAI :"+sizeInMb.toString());

                      final thumbnailFile = await VideoCompress.getFileThumbnail(
                          videoFile!.path,
                          quality: 50, // default(100)
                          position: -1 // default(-1)
                      );

                      final MediaInfo? info = await VideoCompress.compressVideo(
                        videoFile!.path,
                        quality: VideoQuality.LowQuality,
                        deleteOrigin: false,
                        includeAudio: true,
                      );

                      int sizeInBytes2 = thumbnailFile.lengthSync();
                      double sizeInMb2 = sizeInBytes / (1024 * 1024);
                      //print("AAPKA FILE SIZE HAI :"+sizeInMb2.toString());

                      List<int> byteFormatOfVideoFile = await thumbnailFile.readAsBytes();
                      //print(imageFile);
                      String fileExtension = imageFile!.path.split('/').last;
                      //print("Image From IPV Video"+fileExtension);
                      List<int> byteFormatOfImageFile = await imageFile!.readAsBytes();
                      await ApiRepository().Video_Upload_DIO(info!.file);
                      await ApiRepository().VIPV_Selfie_Upload(byteFormatOfImageFile,fileExtension);
                      await ApiRepository().UpdateStage_Id();
                      //Once Tap Disable this button.
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String stage_id = prefs.getString(STAGE_KEY);
                      //print("Let\'s go To");
                      //print(stage_id);
                      Navigator.pushReplacementNamed(context, stage_id);
                    }:null,
                    color: primaryColorOfApp,
                    child: proceedBtnOnceClicked?Row(
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
                )),
                SizedBox(height: 20,),
                //Retry Button
                Visibility(visible: enableRetryBtn,child:Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    child: Text("$retryBtnText",textAlign: TextAlign.center,style: GoogleFonts.openSans(textStyle: TextStyle(decoration: TextDecoration.underline,fontSize: 18,fontWeight: FontWeight.bold,color:enableRetryBtn?primaryColorOfApp:Colors.transparent, letterSpacing: .5),),),
                    onPressed: enableRetryBtn?() {
                      RetryButtonPressed();
                    }:null),
                )),
                SizedBox(height: 10,),
                Align(
                  alignment: Alignment.center,
                  child:!linkSend?Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text:"If Your Mobile Camera is not working ,",
                          style: GoogleFonts.openSans(textStyle:TextStyle(color: Colors.grey,letterSpacing: .5,fontSize: 16),
                          ),),
                        TextSpan(text:" click here",recognizer: TapGestureRecognizer()
                      ..onTap = () async { await ApiRepository().Send_IPV_URL();linkSend = true;setState(() {

                      });},
                          style: GoogleFonts.openSans(textStyle: TextStyle(decoration: TextDecoration.underline,color: primaryColorOfApp,letterSpacing: .5,fontSize: 16),
                        ),),
                        TextSpan(text:" to Continue the Registration Process.",
                          style: GoogleFonts.openSans(textStyle:TextStyle(color: Colors.grey,letterSpacing: .5,fontSize: 16),
                          ),),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ):Text(" Link has been sent to you via SMS , Please Check Messages",textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(textStyle:TextStyle(color: Colors.grey,letterSpacing: .5,fontSize: 16),
                    ),),
                ),
              ],
            ),
          ),
        ),
      ),
    ), onWillPop: _onWillPop);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    setState(() { _notification = state;});
    //print("APP KA STAGE HAI :"+_notification.toString());

    if (Platform.isIOS) {
      exit(0);
    } else {
      SystemNavigator.pop();
    }


    if(state == AppLifecycleState.paused){
      controller?.dispose();
    }

    if(state == AppLifecycleState.resumed||state == AppLifecycleState.detached){
      //print("aapka app resumed ya detached  hogaya hai!");
      //Reload the whole page
      //print("Naya Screen Load Krta hu");
      controller?.dispose();
      Navigator.pushReplacementNamed(context, "IPV");
      controller?.dispose();
      viewOTPContainer=true;
      //print("Naya Screen load kar chuka");
    }

    // App state changed before we got the chance to initialize.
    if (controller == null || !controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
      //print("aapka app inactive hogaya hai!");
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        viewOTPContainer = true;
        controller = CameraController(cameras[1], ResolutionPreset.max);
      }
    }
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return //Icon Information
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 580.0,
            padding: EdgeInsets.all(10),
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            child: Container(
              height: 80,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Recording Instructions",style: GoogleFonts.openSans(fontSize: 20,
                          textStyle: TextStyle(color: Colors.black,fontWeight: FontWeight.bold ,letterSpacing: .5,fontSize: 16),
                        ),),
                        SizedBox(height: 30,),
                        Row(
                          children: [
                            Expanded(child:Container(
                              //color: Colors.black12,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Center(child: SizedBox(height:50 ,width:50 ,child: lightBulbImage)),
                                  SizedBox(height: 10,),
                                  Stack(
                                    children: [
                                      Align(alignment:Alignment.bottomCenter,child:Container(color: Colors.white,
                                          width: MediaQuery.of(context).size.width,
                                          height: 50,
                                          child: Center(child:Padding(padding: EdgeInsets.only(top: 20),child:Text("Bright Light",textAlign: TextAlign.center,style: GoogleFonts.openSans(
                                            textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 10),
                                          ),),))),),
                                      Align(alignment:Alignment.topCenter,child:Padding(padding: EdgeInsets.only(bottom: 0),child:Icon(Icons.check_circle,color: Colors.green,),),)
                                    ],
                                  )
                                ],
                              ),
                            )),
                            SizedBox(width: 10,),
                            Expanded(child:Container(
                              //color: Colors.black12,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Center(child: SizedBox(height:50 ,width:50 ,child: glassesImage,)),
                                  SizedBox(height: 10,),
                                  Stack(
                                    children: [
                                      Align(alignment:Alignment.bottomCenter,child:Container(color: Colors.white,
                                          width: MediaQuery.of(context).size.width,
                                          height: 50,
                                          child: Center(child:Padding(padding: EdgeInsets.only(top: 20),child:Text("No Glasses",textAlign: TextAlign.center,style: GoogleFonts.openSans(
                                            textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 10),
                                          ),),))),),
                                      Align(alignment:Alignment.topCenter,child:Padding(padding: EdgeInsets.only(bottom: 0),child:Icon(CupertinoIcons.clear_circled_solid,color: Colors.red,),),)
                                    ],
                                  )
                                ],
                              ),
                            )),
                            SizedBox(width: 10,),
                            Expanded(child:Container(
                              //color: Colors.black12,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Center(child: SizedBox(height:50 ,width:50 ,child: hatImage)),
                                  SizedBox(height: 10,),
                                  Stack(
                                    children: [
                                      Align(alignment:Alignment.bottomCenter,child:Container(color: Colors.white,
                                          width: MediaQuery.of(context).size.width,
                                          height: 50,
                                          child: Center(child:Padding(padding: EdgeInsets.only(top: 20),child:Text("No Hat",textAlign: TextAlign.center,style: GoogleFonts.openSans(
                                            textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 10),
                                          ),),))),),
                                      Align(alignment:Alignment.topCenter,child:Padding(padding: EdgeInsets.only(bottom: 0),child:Icon(CupertinoIcons.clear_circled_solid,color: Colors.red,),),)

                                    ],
                                  )
                                ],
                              ),
                            )),
                            SizedBox(width: 10,),
                            Expanded(child:Container(
                              //color: Colors.black12,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Center(child: SizedBox(height:50 ,width:50 ,child:faceMaskImage)),
                                  SizedBox(height: 10,),
                                  Stack(
                                    children: [
                                      Align(alignment:Alignment.bottomCenter,child:Container(color: Colors.white,
                                          width: MediaQuery.of(context).size.width,
                                          height: 50,
                                          child: Center(child:Padding(padding: EdgeInsets.only(top: 20),child:Text("No Mask",textAlign: TextAlign.center,style: GoogleFonts.openSans(
                                            textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 10),
                                          ),),))),),
                                      Align(alignment:Alignment.topCenter,child:Padding(padding: EdgeInsets.only(bottom: 0),child:Icon(CupertinoIcons.clear_circled_solid,color: Colors.red,),),)
                                    ],
                                  )
                                ],
                              ),
                            )),
                          ],
                        ),
                        SizedBox(height: 30,),
                        Text("1.Click on Capture button to get the OTP on screen.\n\n2.Once you see the OTP the recording will start.\n\n3.Enter the OTP in the textbox below capture button.\n\n4.Once you enter the OTP recording will stop and it will get verified.\n",style: GoogleFonts.openSans(
                          textStyle: TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 15),
                        ),),
                        Container(
                          color: Colors.transparent,
                          width: MediaQuery.of(context).size.width,
                          height: 60,
                          child: FlatButton(
                            disabledTextColor: Colors.blue,
                            disabledColor: secondaryColorOfApp,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            onPressed: () async {
                              await onCaptureButtonPressed();
                            },
                            color: primaryColorOfApp,
                            child: Text(
                                "Capture",
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 16,fontWeight: FontWeight.bold),)
                            ),
                          ),
                        ),
                      ],
                    )
                ),
              ),
            ),
          ),
        );
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: Container(
          height: 290,
          width: 200,
          child:CameraPreview(
            controller!,
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onScaleStart: _handleScaleStart,
                    onScaleUpdate: _handleScaleUpdate,
                    onTapDown: (details) => onViewFinderTap(details, constraints),
                  );
                }),
          ),),
      );
    }
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  /// Display the thumbnail of the captured image or video.
  Widget _thumbnailWidget() {
    final VideoPlayerController? localVideoController = videoController;
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            localVideoController == null && imageFile == null
                ? Container()
                : SizedBox(
              child: (localVideoController == null)
                  ? Image.file(File(imageFile!.path))
                  : Container(
                child: Center(
                  child: AspectRatio(
                      aspectRatio:
                      localVideoController.value.size != null
                          ? localVideoController
                          .value.aspectRatio
                          : 1.0,
                      child: VideoPlayer(localVideoController)),
                ),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.pink)),
              ),
              width: 64.0,
              height: 64.0,
            ),
          ],
        ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
    final CameraController? cameraController = controller;
    return Container();
  }

  Future<void> onVideoRecordButtonPressed() async {
    await Future.delayed(const Duration(seconds: 2), (){});
    startVideoRecording().then((_) async {
      if (mounted) {
        setState(() {});
        //print("Recording Started");
        RecordingStatus = "Recording Started";
        setState(() {

        });
        for(int i=recordForHowManySeconds;i>=0;i--){
          await Future.delayed(Duration(seconds: 1), () {
            RecordingStatus = "$i Seconds Remaining";
            setState(() {});
          });
        }
        onStopButtonPressed();
        //print("DONE WAITING");
        RecordingStatus = "Recording Completed";
        setState(() {});
      }
    });
  }

  Future<void> onStopButtonPressed() async {
    stopVideoRecording().then((file) {
      if (mounted) setState(() {});
      if (file != null) {
        //print('Video recorded to ${file.path}');
        showInSnackBar('Video recorded to ${file.path}');
        videoFile = file;
        //_startVideoPlayer();
      }
    });

    await Future.delayed(const Duration(seconds: 2), (){});
    RecordingStatus = "Taking Selfie!";
    setState(() {});
    takePicture().then((XFile? file) async {
      //print("Picture Lene Jaa raha hu");
      if (mounted) {
        //print("Camera Mounted Hai Picture Lene Ke Liye");
        setState(() {
          imageFile = file;
          //print("Photo Hogayi");
          //print(imageFile!.name);
          videoController?.dispose();
          videoController = null;
        });
        if (file != null){
          print("Picture Saved To : ${file.path}");
          showInSnackBar('Picture saved to ${file.path}');
          if(enableProceedBtnOTPMatched){
            RecordingStatus = "Click On Proceed!";
            retryBtnText = "Retry ?";
            enableRetryBtn = true;
            viewProceedButton = true;
            viewOTPContainer = false;
            enableProceedBtnRecordingDone = true;
          }
          else{
            showOTPError = true;
            retryBtnText = "Wrong Captcha , Try Again";
            viewOTPContainer=false;
            enableRetryBtn = true;
          }

          setState(() {

          });
        }
        else{
          print('UNABLE TO CAPTURE PHOTO. So , Retrying!');
          showInSnackBar('UNABLE TO CAPTURE PHOTO. So , Retrying!');
          imageFile = await takePicture();

          videoController?.dispose();
          videoController = null;
          print('Picture saved to ${imageFile!.path}');
          showInSnackBar('Picture saved to ${imageFile!.path}');
          scrollTo = 300;
          _scrollToTop();
          showRecordingButton = false;
          enableRetryBtn = true;
          RecordingStatus = "RECORDING COMPLETED";
          enableProceedBtnRecordingDone = true;
          setState(() {});
        }
      }
    });
  }

  /*Future<void> _startVideoPlayer() async {
    if (videoFile == null) {
      return;
    }

    final VideoPlayerController vController =
    VideoPlayerController.file(File(videoFile!.path));
    videoPlayerListener = () {
      if (videoController != null && videoController!.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController!.removeListener(videoPlayerListener!);
      }
    };
    vController.addListener(videoPlayerListener!);
    await vController.setLooping(true);
    await vController.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imageFile = null;
        videoController = vController;
      });
    }
    await vController.play();
  }*/

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    //logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> manageSteps() async {
    String currentRouteName = '/webcamscreen';
    await StoreLocal().StoreRouteNameToLocalStorage(currentRouteName);
    String routeName = await StoreLocal().getRouteNameFromLocalStorage();
    //print("YOU ARE ON THIS STEP : "+routeName);
  }


  Future<void> initializeCamera() async {
    // Fetch the available cameras before initializing the app.
    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await availableCameras();
    } on CameraException catch (e) {
    }
  }

  initializeRecorder() {
    controller = CameraController(cameras[1], ResolutionPreset.max);
    controller!.initialize().then((_) {
      if (!mounted) {
        //print("we came here");
        return;
      }
      else{
        //If you want to change the orientation of webcam
        //controller!.lockCaptureOrientation(DeviceOrientation.landscapeLeft);
        _onWillPop();
      }
    });
  }

  void fetchOTP() async {
    //print("IPV OTP METHODS");
    String result = await ApiRepository().IPVOTP();
    Map valueMap = jsonDecode(result);
    //print(valueMap);
    ipvOtp = valueMap["res_Output"][0]["result_Description"];
    recordForHowManySeconds = valueMap["res_Output"][0]["result_Id"];
    _requestIPVOTPTextFieldFocusNode();
    _scrollToTop();
    setState(() {});
  }


  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void RetryButtonPressed() {
    viewOTPContainer = true;
    viewProceedButton = false;
    enableRetryBtn = false;
    showOTPError = false;
    ipvOtp = "";
    showRecordingButton = false;
    proceedBtnOnceClicked = false;
    setState(() {});
    fetchOTP();
    enableProceedBtnRecordingDone = false;
    enableProceedBtnOTPMatched = false;
    IPVOTPTextEditingController.clear();
    setState(() {

    });
    RecordingStatus = "Starting Recording...";
    //showRecordingButton = true;
    onVideoRecordButtonPressed();
    _onWillPop();
  }

  Future<void> onCaptureButtonPressed() async {

    if (await Permission.camera.request().isGranted  && await Permission.microphone.request().isGranted) {
      print("Permitted to use Camera");
      initializeRecorder();
      enableRetryBtn = false;
      ipvOtp = "";
      showRecordingButton = false;
      proceedBtnOnceClicked = false;
      fetchOTP();
      onVideoRecordButtonPressed();
      viewOTPContainer = true;
      _requestIPVOTPTextFieldFocusNode();
      _scrollToTop();
      setState(() {});
    }
    else{
      print("Not Permitted to use Camera/Microphone");
    }
  }
}

List<CameraDescription> cameras = [];


/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
// TODO(ianh): Remove this once we roll stable in late 2021.
T? _ambiguate<T>(T? value) => value;