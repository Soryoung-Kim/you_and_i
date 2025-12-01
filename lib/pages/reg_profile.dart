import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pixel_color_picker/pixel_color_picker.dart';
import 'package:you_and_i/controller/reg_profile_controller.dart';
import 'package:you_and_i/db/myinfo_db_controller.dart';

class RegProfile extends StatefulWidget {
  @override
  _RegProfileState createState() => _RegProfileState();
}

class _RegProfileState extends State<RegProfile> {
  // final MyInfoDBController myInfoController = Get.find<MyInfoDBController>();

  final RegProfileController profileController =
      Get.find<RegProfileController>();

  @override
  void initState() {}

  @override
  void dispose() {
    super.dispose();
  }

  renderButton(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) async {
        switch (value) {
          case 1:
            profileController.openProfileImageSelect(ImageSource.camera);
            break;
          case 2:
            profileController.openProfileImageSelect(ImageSource.gallery);
            break;
        }
      },
      // offset: Offset(0, -30.h),
      child: Container(
        width: 450.w,
        height: 150.h,
        child:
        Stack(
          children: [
            OutlinedButton(
            onPressed: () {
          // tutorialController.index(controller.page);
      },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            textStyle: TextStyle(
              fontSize: 50.sp,
            ),
            padding: EdgeInsets.all(0),
            side: BorderSide(
              color: Colors.grey,
              width: 2,
            ),
            fixedSize: Size(450.w, 150.h),
            shape: StadiumBorder(),
          ),
          child: Text('사진 설정'))
          ,
            Container(
              child:

              Image(
                color: Colors.black.withOpacity(0),
                image: AssetImage(
                    'assets/images/img_profile_bg.png'),
                 width: double.infinity,
                fit: BoxFit.fill,
              ),
            )

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
                Icon(Icons.camera_alt,color: Colors.grey,),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text('사진 촬영'),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: Row(
              children: [
                Icon(Icons.photo_album,color: Colors.grey,),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text('앨범에서 선택'),
                ),
              ],
            ),
          ),
        ];
      },
    );

  }

  backGroundColorRenderButton() {
    return OutlinedButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  // title: Text("Delete File"),
                  content: Form(
                    child: PixelColorPicker(
                      child:Image.asset('assets/images/img_bg_color.png'),
                      onChanged: (color){
                        profileController.changeColorPress(color);

                      },
                    ),
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
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          textStyle: TextStyle(
            fontSize: 50.sp,
          ),
          padding: EdgeInsets.all(0),
          side: BorderSide(
            color: Colors.grey,
            width: 2,
          ),
          fixedSize: Size(450.w, 150.h),
          shape: StadiumBorder(),
        ),
        child: Text('배경색 설정'));
  }

  nextRenderButton() {
    return OutlinedButton(
      onPressed: () {
        //메인 페이지로 이동
        Get.toNamed('/RegProfile2');
        //메인 페이지로 이동
        // Get.offAllNamed('/RegProfile');
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
        textStyle: TextStyle(
          fontSize: 60.sp,
        ),
        padding: EdgeInsets.all(0),
        side: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        fixedSize: Size(360, 65),
        shape: StadiumBorder(),
      ),
      child: Text(
        '다음',
        style: TextStyle(
          color: Colors.white,
          // fontWeight: FontWeight.bold,
          fontSize: 60.sp,
        ),
      ),
    );
  }
  Widget _popupMenu(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) async {
        switch (value) {
          case 1:
            profileController.openProfileImageSelect(ImageSource.camera);
            break;
          case 2:
            profileController.openProfileImageSelect(ImageSource.gallery);
            break;
        }
      },
      // offset: Offset(0, -30.h),
      child: Container(
        width: 230.w,
        height: 70.h,
        child: Material(
          elevation: 0.5,
          color: Theme.of(context).colorScheme.primary,
          child: Icon(
            Icons.camera_alt_outlined,
            color: Theme.of(context).canvasColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: 1,
            child: Row(
              children: [
                Icon(Icons.camera),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text('Camera'),
                ),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 2,
            child: Row(
              children: [
                Icon(Icons.photo_album),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text('Photo'),
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
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          elevation: 0,
          centerTitle: true,
          title: Obx(() => Text(
                profileController.title.value,
                style: const TextStyle(color: Colors.black),
              )),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: true,
          actions: [
            Obx(() {
              if (!profileController.isFirst.value) {
                return IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ));
              } else {
                return Text('');
              }
            }),
          ],
        ),
        body: Container(
          color: Colors.white, //Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: Container(
                    height: 5,
                    color: Colors.black,
                  )),
                  Expanded(
                      child: Container(
                    height: 5,
                    color: Colors.grey[100],
                  )),
                ],
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(25.0),
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(

                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Obx(() => Image(
                              color: Color(int.parse('FF${profileController.background.value}', radix: 16)
                              ),
                              image: const AssetImage('assets/images/img_profile_bg.png'),
                              // width: 1000.w,
                              fit: BoxFit.fill,
                            ))
                            ,

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Obx(() {
                                  if (GetUtils.isNullOrBlank(profileController.picture.value)!) {
                                    return Material(
                                      elevation: 0.0,
                                      shape: const CircleBorder(),
                                      child: CircleAvatar(
                                        radius: 120.w,
                                        child: Container(
                                          // height: 100,
                                          // width: 100,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey,
                                          ),
                                          child:
                                          Container(
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      fit: BoxFit.fill,
                                                      image: AssetImage('assets/images/img_profile_user.png')
                                                  )
                                              )),
                                          // Icon(Icons.account_box_outlined , size: 70,color: Colors.white,),
                                          alignment: Alignment.center,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Material(
                                      elevation: 0.0,
                                      shape: const CircleBorder(),
                                      child: CircleAvatar(
                                        radius: 120.w,
                                        backgroundImage:
                                        FileImage(File(profileController.picture.value)),
                                      ),
                                    );
                                  }
                                }),

                                Image(
                                  image: const AssetImage('assets/images/img_profile_text.png'),
                                  width: 400.w,
                                  fit: BoxFit.fill,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          renderButton(context),
                          backGroundColorRenderButton(),
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Image(
                              image: AssetImage('assets/images/ic_info.png'),
                              width: 25,
                              fit: BoxFit.fill),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            '명함 사진을 등록하셔도 됩니다.',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              // fontWeight: FontWeight.bold,
                              fontSize: 45.sp,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: nextRenderButton(),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}