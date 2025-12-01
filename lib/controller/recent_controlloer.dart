import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:you_and_i/controller/main_controller.dart';
import 'package:you_and_i/db/friend_db_controller.dart';
class RecentController extends GetxController {
  final FriendDBController friendDbController = Get.find<FriendDBController>();
  final MainController mainController = Get.find<MainController>();
  final pageController = PageController(viewportFraction:1 , keepPage: true);
  @override
  void onInit() {
    super.onInit();

  }

  void onClose() {

  }

  Widget profileImageRecent(friend){
    if (GetUtils.isNullOrBlank(
        friend.picture)!) {
      return Material(
        elevation: 5.0,
        shape: CircleBorder(),
        child: CircleAvatar(
          radius: 80.w,
          child: Container(
            // height: 100,
            // width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: Container(
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage(
                            'assets/images/img_profile_user.png')))),
            // Icon(Icons.account_box_outlined , size: 70,color: Colors.white,),
            alignment: Alignment.center,
          ),
        ),
      );
    } else {
      return Material(
        elevation: 5.0,
        shape: CircleBorder(),
        child: CircleAvatar(
          radius: 80.w,
          backgroundImage:
          FileImage(File(friend.picture)),
        ),
      );
    }
  }
  Widget recent(index){
    Friend? friend = friendDbController.listRecent[index];
    // return Container(
    //   color: Colors.red,
    //   width: MediaQuery.of(Get.context).size.width,
    // );

    return Container(
      // color: Colors.red,

      child: Card(
        color: Colors.grey[100],
        shape: RoundedRectangleBorder(
          //모서리를 둥글게 하기 위해 사용
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(40.w,15.h,40.w,15.h),
          child: Container(
            width: double.infinity,
            height: 120.h,
            child:
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      profileImageRecent(friend),
                      SizedBox(
                        width: 40.w,
                      ),
                      Flexible(
                        flex: 1,
                        child: Text(
                          friend.name.toString(),
                          overflow:
                          TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight:
                              FontWeight.bold,
                              fontSize: 45.sp),
                        ),
                      ),
                      SizedBox(
                        width: 30.w,
                      ),
                      Text(
                          friend.phone.toString()
                          // ''
                          ,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 35.sp,
                              letterSpacing: .3)),
                      SizedBox(
                        width: 30.w,
                      ),
                    ],
                  ),
                ),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    //모서리를 둥글게 하기 위해 사용
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: IconButton(
                    icon: Image.asset('assets/images/ic_call.png'),
                    iconSize: 100.w,
                    onPressed: () {
                      // controller.memoAlert(index);
                      launch('tel://${friend.phone}');
                    },
                  ),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget RecentWidgetMain() {
    return Obx((){
      List recentWidget = List.generate(friendDbController.listRecent.length, (index) => recent(index));

      // for (Friend element in friendDbController.list) {
      //   recentWidget.add(recent(element));
      // }
      if (mainController.shareCount == 0) {
        return Card(
          color: Colors.grey[100],
          shape: RoundedRectangleBorder(
            //모서리를 둥글게 하기 위해 사용
            borderRadius: BorderRadius.circular(90.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Container(
              width: double.infinity,
              child: Center(
                child: Text(
                  '최근 내역이 없습니다.',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 45.sp,
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        return
          Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(50.w,0.h,50.w,10.h),
                child: Container(
                  // color: Colors.purple,

                  height: 200.h,
                  child: PageView.builder(

                    controller: pageController,
                    itemCount: recentWidget.length,
                    onPageChanged: (index){


                    },
                    itemBuilder: (_, index) {
                      return recentWidget[index%recentWidget.length];
                    },
                  ),
                ),
              ),
              SizedBox(height: 40.h,),
              Container(
                child: SmoothPageIndicator(

                  controller: pageController,
                  count: recentWidget.length,
                  effect: WormEffect(
                    dotHeight: 12,
                    dotWidth: 12,
                    activeDotColor: Colors.black,

                    // type: WormType.thin,
                    // strokeWidth: 5,
                  ),
                ),
              ),
            ],
          );
      }
    });

  }
}