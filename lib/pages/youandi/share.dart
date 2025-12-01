import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:share/share.dart' as pubshare;
import 'package:url_launcher/url_launcher.dart';
class Share extends StatelessWidget {
  const Share({Key? key}) : super(key: key);

  static const _shareUrl = '\n\n\nhttps://woori42.net/guide.html';
  static const _title = '우리사이엔 뭔가있다. ''우리사이'' 앱 공유!';
  @override
  Widget build(BuildContext context) {



    sms() async {

      if (Platform.isAndroid) {
        const uri = 'sms:?body='+_title+_shareUrl;
        await launch(uri);
      } else if (Platform.isIOS) {
        // iOS
        const uri = 'sms:&body='+_title+_shareUrl;
        await launch(uri);
      }
    }
    QrAlert(){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text("QR코드",style: TextStyle(
                // color: Theme.of(context).primaryColor,
                // fontWeight: FontWeight.bold,
                  fontSize: 50.sp)),
              content: Form(
                  child:  Column(
                    children: [
                      SizedBox(height: 30.h,),
                      Image.asset('assets/images/share_qr_image.png', width: 800.w,),
                      SizedBox(height: 30.h,),
                      Text('QR코드를 스캔하세요',style: TextStyle(
                        // color: Theme.of(context).primaryColor,
                        // fontWeight: FontWeight.bold,
                        fontSize: 50.sp,
                      ))
                    ],
                  )
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text('확인',
                      style: TextStyle(color: Theme.of(context).primaryColor)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );

          });
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '공유',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        leading:
          IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ))
        ,
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(55.w, 0, 55.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: (){
                    sms();
                  },
                  child:  Card(

                    color: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      //모서리를 둥글게 하기 위해 사용
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Container(
                        width: 280.w,
                        height: 280.w,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Center(
                              child: Image.asset('assets/images/ic_share_sms.png', width: 200.w,),
                            ),
                      Text('SMS',style: TextStyle(
                        // color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 45.sp,
                      )),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                ,

                GestureDetector(
                  onTap: (){
                    pubshare.Share.share(_shareUrl, subject: _title);
                  },
                  child:  Card(

                    color: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      //모서리를 둥글게 하기 위해 사용
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Container(
                        width: 280.w,
                        height: 280.w,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Center(
                              child: Image.asset('assets/images/ic_share_social.png', width: 200.w,),
                            ),
                            Text('소셜미디어',style: TextStyle(
                              // color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 45.sp,
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                ,
              ],
            ),
            SizedBox(height: 15.h,),
            GestureDetector(
              onTap: (){
                QrAlert();

              },
              child:  Card(

                color: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  //모서리를 둥글게 하기 위해 사용
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Container(
                    width: 280.w,
                    height: 280.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: Image.asset('assets/images/ic_share_qrcode.png', width: 200.w,),
                        ),
                        Text('QR코드',style: TextStyle(
                          // color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 45.sp,
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
