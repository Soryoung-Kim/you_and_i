import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';
import 'package:you_and_i/controller/main_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:you_and_i/db/myinfo_db_controller.dart';
import 'package:you_and_i/pages/youandi/recent.dart';

import 'package:im_animations/im_animations.dart';

class Home extends StatelessWidget {
  final MainController mainController = Get.find<MainController>();
  final MyInfoDBController controller = Get.find<MyInfoDBController>();

  companyInputRenderButton() {
    return OutlinedButton(
        onPressed: () {
          Get.toNamed('/RegProfileAll');
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: TextStyle(
            fontSize: 40.sp,
            fontWeight: FontWeight.bold
          ),
          padding: EdgeInsets.all(5),
          side: BorderSide(
            color: Colors.white,
            width: 1,
          ),
          fixedSize: Size(430.w, 110.h),
          shape: StadiumBorder(),
        ),
          child: Text('직장정보 입력하기'));
  }
  renderButton(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) async {
        switch (value) {
          case 1:
             Get.toNamed('/RegProfileAll');
            break;
          case 2:
            Share.share('우리사이에서 프로필을 공유했습니다.\n\n\n${controller.name}(${controller.phone})\n${controller.company} | ${controller.position}\n'
                '${controller.tel}\n${controller.email}\n${controller.homepage}\n${controller.address}  ${controller.address2}', subject: '${controller.name}님 프로필 공유');
            break;
        }
      },
      // offset: Offset(0, -30.h),
      child: Container(
        // width: 450.w,
        // height: 150.h,
        child:
        Stack(
          children: [
            Image(
              image: AssetImage('assets/images/ic_more.png'),
              width: 100.w,
              fit: BoxFit.fill,
            ),

          ],
        )
        ,
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: 1,
            child: Row(
              children: [
                Image(
                  image: AssetImage(
                      'assets/images/ic_edit.png'),
                  width: 50.w,
                  fit: BoxFit.fill,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text('수정'),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: Row(
              children: [
                Image(
                  image: AssetImage(
                      'assets/images/ic_share_gray.png'),
                  width: 50.w,
                  fit: BoxFit.fill,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text('공유'),
                ),
              ],
            ),
          ),
        ];
      },
    );

  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(40.w, 8.h, 40.w, 30.h),
              child: Card(
                  color: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    //모서리를 둥글게 하기 위해 사용
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  // elevation: 4.0, //그림자 깊이
                  child: Padding(
                    padding: EdgeInsets.all(13),
                    child: Row(
                      children: [
                        Image(
                          image: AssetImage(
                              'assets/images/ic_group_user_icon.png'),
                          width: 50.w,
                          fit: BoxFit.fill,
                        ),
                        Text(
                          '  우리사이에서 ',
                          style: TextStyle(
                            color: Colors.black,
                            // fontWeight: FontWeight.bold,
                            fontSize: 35.sp,
                          ),
                        ),
                        Obx(()=>Text(
                          '${mainController.shareCount.value}명',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 35.sp,
                          ),
                        )),
                        Text(
                          '과',
                          style: TextStyle(
                            color: Colors.black,
                            // fontWeight: FontWeight.bold,
                            fontSize: 35.sp,
                          ),
                        ),
                        Text(
                          ' 인맥을 공유',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 35.sp,
                          ),
                        ),
                        Text(
                          '했습니다.',
                          style: TextStyle(
                            color: Colors.black,
                            // fontWeight: FontWeight.bold,
                            fontSize: 35.sp,
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          ),
          Obx(() => Container(
                padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                color: Color(
                    int.parse('FF${controller.background.value}', radix: 16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 40.h,
                        ),
                        Obx(() {
                          if (GetUtils.isNullOrBlank(
                              controller.picture.value)!) {
                            return Material(
                              elevation: 5.0,
                              shape: CircleBorder(),
                              child: CircleAvatar(
                                radius: 100.w,
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
                                radius: 100.w,
                                backgroundImage:
                                    FileImage(File(controller.picture.value)),
                              ),
                            );
                          }
                        }),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 25.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Obx(() => Text(
                                  controller.name.value,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 55.sp,
                                  ),
                                )),
                            SizedBox(width: 10),
                            Obx(() => Text(
                                  controller.phone.value,
                                  style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 35.sp,
                                  ),
                                )),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Obx((){
                          if(controller.isCompanyButtonShow.value){
                            return

                              Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 20.h,),
                                companyInputRenderButton(),
                              ],
                            ) ;

                          }else{
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.company.value + ' | '+ controller.position.value,
                                      style: TextStyle(
                                        color: Colors.white,
                                        // fontWeight: FontWeight.bold,
                                        fontSize: 35.sp,
                                      ),
                                    ),
                                    // Text(
                                    //   ' | ',
                                    //   style: TextStyle(
                                    //     color: Colors.grey,
                                    //     // fontWeight: FontWeight.bold,
                                    //     fontSize: 35.sp,
                                    //     fontWeight: FontWeight.bold,
                                    //   ),
                                    // ),
                                    // Text(
                                    //   controller.position.value,
                                    //   style: TextStyle(
                                    //     color: Colors.white,
                                    //     // fontWeight: FontWeight.bold,
                                    //     fontSize: 35.sp,
                                    //   ),
                                    // ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  controller.tel.value,
                                  style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 35.sp,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  controller.email.value,
                                  style: TextStyle(
                                    color: Colors.white,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 35.sp,
                                  ),
                                ),
                                SizedBox(height: 8.h)
                              ],
                            );
                          }

                        })

                        ,
                      ],
                    ),
                    renderButton(context),
                  ],
                ),
              )),
          Expanded(
            child: Obx(() => Container(
                  width: double.infinity,
                  color: Color(
                      int.parse('FF${controller.background.value}', radix: 16)),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.white, width: double.infinity),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40)),
                        ),
                      ),

                      Container(
                        width: double.infinity,
                        // color: Colors.red,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(30, 30, 30, 10),
                              child: Text(
                                '최근 공유 내역',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 45.sp,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Recent(),
                            SizedBox(height: 25.h),
                            Expanded(
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    print('onTap');
                                    Get.snackbar(
                                      '안내',
                                      '연결될때까지 좀 더 눌러주세요.',
                                      backgroundColor: Colors.green.withAlpha(200),
                                      colorText: Colors.white,
                                    );
                                  },
                                  onLongPress: () {
                                    print('start ');
                                    mainController.collisionPress();
                                  },
                                  onLongPressUp: () {
                                    print('stop ');
                                    mainController.collisionOut();

                                  },
                                  child: Obx(() {
                                    if (mainController
                                        .connectButtonPress.value) {
                                      return ColorSonar(
                                        innerWaveColor: Colors.deepPurple,
                                        middleWaveColor:
                                            Colors.deepPurple.withOpacity(0.5),
                                        outerWaveColor:
                                            Colors.deepPurple.withOpacity(0.2),
                                        // wavesDisabled: true,
                                        // waveMotion: WaveMotion.synced,
                                        contentAreaRadius: 250.0.w,
                                        waveFall: 10.0,
                                        // waveMotionEffect: Curves.elasticIn,
                                        waveMotion: WaveMotion.synced,
                                        duration: Duration(seconds: 2),
                                        child: CircleAvatar(
                                          radius: 250.0.w,
                                          backgroundImage: AssetImage(
                                              'assets/images/bt_connet_s.png'),
                                        ),
                                      );
                                    } else {
                                      return Container(
                                        child: CircleAvatar(
                                          radius: 250.0.w,
                                          backgroundImage: AssetImage(
                                              'assets/images/bt_connet_n.png'),
                                        ),
                                      );
                                    }
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
