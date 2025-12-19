import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:logger/logger.dart';
import 'package:you_and_i/controller/main_controller.dart';
import 'package:you_and_i/pages/friend/friend.dart';
import 'package:you_and_i/pages/more/more.dart';
import 'package:you_and_i/pages/youandi/home.dart';
import 'package:you_and_i/pages/youandi/kakao_webview.dart';


class YouAndIMain extends StatefulWidget {
  @override
  _YouAndIMainState createState() => _YouAndIMainState();
}

class _YouAndIMainState extends State<YouAndIMain> {

  final MainController controller = Get.find<MainController>();
  ShareRenderButton() {
    return OutlinedButton.icon(
      onPressed: () {
        // Respond to button press
        Get.toNamed('/Share');
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
          textStyle: TextStyle(
            fontSize: 30.sp,
          ),
          padding: EdgeInsets.all(0),
          side: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
          // fixedSize: Size(400.w,30.h),
          fixedSize: Size(300.w,20.h),
          shape: StadiumBorder(),
        ),
      icon: Icon(Icons.share, size: 18),
      label: Text("APP공유"),
    );
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        elevation: 0,
        centerTitle: true,
        title:
        Obx(()=>Text(controller.appBarTitle.value,
          style: TextStyle(color: Colors.black),)),
        backgroundColor: Colors.white,
        actions: [
          Padding(padding: EdgeInsets.fromLTRB(0, 35.h, 40.w, 35.h),
              child:
                  Obx((){
                    if(controller.mainTabIndex.value==0){
                      return ShareRenderButton();
                    }else{
                      return Container();
                    }


                  })

          )

        ],

      ),
      bottomNavigationBar: BottomNavigationBar(

        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 35.sp,
        unselectedFontSize: 35.sp,
        iconSize: 25,
        currentIndex: controller.mainTabIndex.value,
        onTap: (int index) {
          setState(() {
            if(index==0){
              controller.appBarTitle('우리사이');
            }else if(index==1){
              controller.appBarTitle('인맥(${controller.shareCount})');
            }else if(index==2){
              controller.appBarTitle('카카오채널');

            }
            else if(index==3){
              controller.appBarTitle('더보기');
            }

            controller.mainTabIndex(index);
          });

        },
        items: [
          BottomNavigationBarItem(
            label: 'Home',
            icon:  ImageIcon(
              AssetImage("assets/images/ic_navi_home.png"),
              size: 90.w,
              // color: Colors.black.withOpacity(0.7),
            ),
          ),
          BottomNavigationBarItem(
            label: '인맥보기',
            icon: ImageIcon(
              AssetImage("assets/images/ic_navi_person.png"),
              size: 90.w,
              // color: Color(0xFF3A5A98),
            ),
          ),
          BottomNavigationBarItem(
            label: '카카오채널',
            icon: ImageIcon(
              AssetImage("assets/images/ic_navi_kakao.png"),
              size: 90.w,
              // color: Color(0xFF3A5A98),
            ),
          ),
          BottomNavigationBarItem(
            label: '더보기',
            icon: ImageIcon(
              AssetImage("assets/images/ic_navi_more.png"),
              size: 90.w,
              // color: Color(0xFF3A5A98),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight),
          child: Center(
            child: Obx(() {
              return _widgetOptions.elementAt(controller.mainTabIndex.value);
            }),
          ),
        ),
      ),
    );
  }

  List _widgetOptions = [
    Home(),
    FriendHome(),
    KakaoWebview(),
    More(),

  ];
}
