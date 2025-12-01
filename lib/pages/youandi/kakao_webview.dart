import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:you_and_i/controller/more_controller.dart';
import 'package:you_and_i/controller/network_picture_controller.dart';

import '../../controller/main_controller.dart';


class KakaoWebview extends StatefulWidget {
  const KakaoWebview({Key? key}) : super(key: key);

  @override
  State<KakaoWebview> createState() => _KakaoWebviewState();
}

class _KakaoWebviewState extends State<KakaoWebview> {
  String? url = 'https://pf.kakao.com/_SfRRxj';

  final MainController mainController = Get.find<MainController>();
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    // if (Platform.isAndroid) WebView.platform = AndroidWebView();


    // initKako();
  }
  // Uri? uri;
  // Channels? relations;
  // void initKako() async{
    // try {
    //   OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
    //   print('카카오톡으로 로그인 성공 ${token.accessToken}');
    // } catch (error) {
    //   print('카카오톡으로 로그인 실패 $error');
    // }



  // }
  // _launchURL(url) async {
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

//   void kakaPlusConnect() async{
//     print('#####################kakaPlusConnect###########################');
//     uri = await TalkApi.instance.addChannelUrl('_LbDxnxb');
//     try {
//       relations = await TalkApi.instance.channels();
//       print('채널 관계 확인 성공'
//           '\n${relations!.channels}');
//     } catch (error) {
//       print('채널 관계 확인 실패 $error');
//     }
//
//
//     // 연결 페이지 URL을 브라우저에서 열기
//     print('#####################kakaPlusConnect###########################');
//
//     try {
//       await launchBrowserTab(uri!);
//     } catch (error) {
//       print('카카오톡 채널 추가 실패 $error');
//     }
//   }
//
//   void kakaPlusChat() async{
//
//     print('#######################kakaPlusChat#########################');
//     Uri url = await TalkApi.instance.channelChatUrl('_LbDxnxb');
//     print('#######################kakaPlusChat#########################$url');
// // 디바이스 브라우저 열기
//     try {
//       await launchBrowserTab(url);
//     } catch (error) {
//       print('카카오톡 채널 채팅 실패 $error');
//     }
//   }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        Container(
          child: OutlinedButton(
              onPressed: () async{
                // kakaPlusChat();
                await launch(url!, forceWebView: false, forceSafariVC: false);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.yellow,
                textStyle: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.bold
                ),
                padding: EdgeInsets.all(5),
                side: BorderSide(
                  color: Colors.black,
                  width: 1,
                ),
                fixedSize: Size(700.w, 130.h),
                shape: StadiumBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/ic_navi_kakao.png'),
                    width: 100.w,
                    fit: BoxFit.fill,
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Text('우리사이 카카오 채널',style:TextStyle(fontSize: 45.sp)),
                ],
              )),
        ),
        SizedBox(height: 40.h,),
        Text('1:1 채팅으로 문의 가능합니다.',style:TextStyle(fontSize: 45.sp)),
      ],
    );

    //   WebView(
    //     initialUrl: url.toString(),
    //     javascriptMode: JavascriptMode.unrestricted,
    //
    //     navigationDelegate: (NavigationRequest request) {
    //       print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@${request.url}');
    //
    //       if (request.url.contains("/friend")) {
    //
    //         kakaPlusConnect();
    //         return NavigationDecision.prevent;
    //       } else if (request.url.contains("intent://plusfriend/talk/chat/")) {
    //         kakaPlusChat();
    //         return NavigationDecision.prevent;
    //       }
    //
    //       // else if (request.url.contains("com.kakao.talk")) {
    //       //   _launchURL(request.url);
    //       //   return NavigationDecision.prevent;
    //       // } else if (request.url.contains("chat")) {
    //       //   _launchURL(request.url);
    //       //   return NavigationDecision.prevent;
    //       // }
    //       return NavigationDecision.navigate;
    //     },
    //   )
    // ;
  }
}
