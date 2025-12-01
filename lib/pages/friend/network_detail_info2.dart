import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:you_and_i/controller/network_picture_controller.dart';
import 'package:you_and_i/db/friend_db_controller.dart';

import '../../db/network_db_controller.dart';


class NetworkDetailInfo2 extends StatefulWidget {
  // NetworkDetailInfo({Key key}) : super(key: key);

  @override
  _NetworkDetailInfo2State createState() => _NetworkDetailInfo2State();
}

class _NetworkDetailInfo2State extends State<NetworkDetailInfo2> {

  Future<bool> _onBackPressed() async {
    return Future<bool>.value(true);
  }
  final NetworkPictureController _networkPictureController = Get.find<NetworkPictureController>();
  // final PictureController _pictureController = Get.find<PictureController>();

  Network one = Get.arguments[0];

  NodeData? two = Get.arguments[1];


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          // iconTheme: IconThemeData(color: Theme.of(context).accentColor),
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              )),
        ),
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(

                height: 250,
                child: Stack(
                  children: [
                    Container(
                        height: double.infinity,
                        width: double.infinity,
                  child:
                  // _pictureController.getPicture(one.picture),)
                  _networkPictureController.getPictureInfo(two!.avatar),)
                    // Align(
                    //   alignment: Alignment(0, 0.8),
                    //   child: MaterialButton(
                    //       minWidth: 0,
                    //       elevation: 0.5,
                    //       color: Theme.of(context).buttonColor,
                    //       child: Icon(
                    //         Icons.camera_alt_outlined,
                    //         color: Theme.of(context).canvasColor,
                    //       ),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(20.0),
                    //       ),
                    //       onPressed: () {
                    //         // profileController.openProfileImageSelect();
                    //       }),
                    // ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      enabled: false,
                      controller: TextEditingController()..text = one.name.toString().replaceAll('null', ' '),
                      decoration: InputDecoration(

                        labelText: '이름',
                      ),
                      style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 50.sp,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Stack(children: [
                      TextField(
                        enabled: false,
                        controller: TextEditingController()..text = one.phone.toString().replaceAll('null', ' '),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '휴대폰',
                        ),
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          fontSize: 50.sp,
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Card(
                            color: Colors.green,
                            shape: RoundedRectangleBorder(

                              //모서리를 둥글게 하기 위해 사용
                              borderRadius: BorderRadius.circular(50.0),

                            ),
                            child: IconButton(
                              icon: Image.asset('assets/images/ic_call.png', color: Colors.white,
                              ),
                              iconSize: 100.w,
                              onPressed: () {
                                // controller.memoAlert(index);
                                launch('tel://${one.phone}');
                              },
                            ),
                          ),
                          // Container(
                          //   alignment: Alignment.centerRight,
                          //   child: IconButton(
                          //       icon: Icon(FontAwesomeIcons.sms,size: 40,color: Theme.of(context).buttonColor,),
                          //       onPressed: () {
                          //         launch('sms://${one.phone}');
                          //       }
                          //   ),
                          // ),
                        ],
                      ),
                    ],),
                    const SizedBox(height: 10.0),
                    TextField(
                      enabled: false,
                      controller: TextEditingController()..text = one.company.toString().replaceAll('null', ' '),
                      decoration: InputDecoration(
                        labelText: '회사',
                      ),
                      style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 50.sp,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextField(
                      enabled: false,
                      controller: TextEditingController()..text = one.position.toString().replaceAll('null', ' '),
                      decoration: InputDecoration(
                        labelText: '직급',
                      ),
                      style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 50.sp,
                      ),
                    ),
                    const SizedBox(height: 10.0),

                    TextField(
                      enabled: false,
                      controller: TextEditingController()..text = one.tel.toString().replaceAll('null', ' '),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '전화',
                      ),
                      style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 50.sp,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextField(
                      enabled: false,
                      controller: TextEditingController()..text = one.email.toString().replaceAll('null', ' '),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: '이메일',
                      ),
                      style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 50.sp,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      enabled: false,
                      maxLines: null,
                      controller: TextEditingController()..text = one.address.toString().replaceAll('null', ' '),
                      decoration: InputDecoration(
                        labelText: '주소',
                      ),
                      style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 50.sp,
                      ),
                    ),

                    const SizedBox(height: 10.0),


                    // const SizedBox(height: 20.0),
                    // MaterialButton(
                    //   child: Text('youAndIProfileSave'.tr),
                    //   color: Theme.of(context).buttonColor,
                    //   onPressed: () {},
                    //   textColor: Colors.white,
                    //   padding: const EdgeInsets.all(16.0),
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(30.0),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
