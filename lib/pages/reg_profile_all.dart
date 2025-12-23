import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pixel_color_picker/pixel_color_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:you_and_i/controller/reg_profile_controller.dart';
import 'package:you_and_i/db/myinfo_db_controller.dart';

class RegProfileAll extends StatefulWidget {
  @override
  _RegProfileAllState createState() => _RegProfileAllState();
}

class _RegProfileAllState extends State<RegProfileAll> {
  final MyInfoDBController myInfoController = Get.find<MyInfoDBController>();

  final RegProfileController profileController =
      Get.find<RegProfileController>();

  @override
  void initState() {
    // myInfoController.initDB();
  }

  @override
  void dispose() {
    super.dispose();
  }

  backRenderButton() {
    return OutlinedButton(
        onPressed: () {
          Get.back();

          // tutorialController.index(controller.page);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).primaryColor,
          textStyle: TextStyle(
            fontSize: 50.sp,
          ),
          padding: EdgeInsets.all(0),
          side: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
          fixedSize: Size(450.w, 120.h),
          shape: StadiumBorder(),
        ),
        child: Text('취소'));
  }

  saveRenderButton() {
    return OutlinedButton(
        onPressed: () {
          if (GetUtils.isNullOrBlank(profileController.nameController.text)!) {
            Get.snackbar(
              '필수정보',
              '이름을 입력해주세요.',
              backgroundColor: Colors.black.withAlpha(150),
              colorText: Colors.white,
            );
          }
          if (GetUtils.isNullOrBlank(profileController.phoneController.text)!) {
            Get.snackbar(
              '필수정보',
              '핸드폰 번호를 입력해주세요',
              backgroundColor: Colors.black.withAlpha(150),
              colorText: Colors.white,
            );
          }

          if (!GetUtils.isNullOrBlank(profileController.nameController.text)! &&
              !GetUtils.isNullOrBlank(
                  profileController.phoneController.text)!) {
            showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  // title: Text("Delete File"),
                  content: Text("저장 하시겠습니까??"),
                  actions: [
                    CupertinoDialogAction(
                        child:
                            Text('취소', style: TextStyle(color: Colors.black38)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    CupertinoDialogAction(
                      child: Text('확인',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor)),
                      onPressed: () async {
                        Navigator.of(Get.context!).pop();

                        await profileController.dbInsert();
                        if (profileController.isFirst.value) {
                          Get.offAllNamed('/YouAndIMain');
                        } else {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          currentFocus.unfocus();
                          Future.delayed(Duration(seconds: 1), () async {
                            Navigator.of(Get.context!).pop();
                          });
                        }
                      },
                    )
                  ],
                );
              },
            );
          }
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          textStyle: TextStyle(
            fontSize: 50.sp,
          ),

          padding: EdgeInsets.all(0),
          // side: BorderSide(
          //   color: Theme.of(context).primaryColor,
          //   width: 2,
          // ),
          fixedSize: Size(450.w, 120.h),
          shape: StadiumBorder(),
        ),
        child: Text('저장'));
  }

  searchRenderButton() {
    return OutlinedButton(
        onPressed: () {
          //메인 페이지로 이동
          Get.toNamed('/SearchAddress');
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          textStyle: TextStyle(
            fontSize: 50.sp,
          ),
          padding: EdgeInsets.all(0),
          side: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
          fixedSize: Size(170, 60),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          '검색',
          style: TextStyle(fontSize: 50.sp),
        ));
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
        height: 130.h,
        child: Stack(
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
                child: Text('사진 설정')),
            Container(
              child: Image(
                color: Colors.black.withOpacity(0),
                image: AssetImage('assets/images/img_profile_bg.png'),
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            )
          ],
        ),
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: 1,
            child: Row(
              children: [
                Icon(
                  Icons.camera_alt,
                  color: Colors.grey,
                ),
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
                Icon(
                  Icons.photo_album,
                  color: Colors.grey,
                ),
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
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.6,
                        minHeight: 320.h,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PixelColorPicker(
                              child: Image.asset(
                                'assets/images/img_bg_color.png',
                                fit: BoxFit.contain,
                              ),
                              onChanged: (color) {
                                profileController.changeColorPress(color);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    CupertinoDialogAction(
                      child: Text('확인',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor)),
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
          fixedSize: Size(450.w, 130.h),
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
          color: Theme.of(context).colorScheme.secondary,
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
          PopupMenuItem(
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
          PopupMenuItem(
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
              style: TextStyle(color: Colors.black),
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
                  icon: Icon(
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
            // Row(
            //   children: [
            //     Expanded(
            //         child: Container(
            //       height: 5,
            //       color: Colors.grey[100],
            //     )),
            //     Expanded(
            //         child: Container(
            //       height: 5,
            //       color: Colors.grey[100],
            //     )),
            //   ],
            // ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.fromLTRB(80.w, 0.w, 80.w, 80.w),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Obx(() => Image(
                                color: Color(int.parse(
                                    'FF${profileController.background.value}',
                                    radix: 16)),
                                image: AssetImage(
                                    'assets/images/img_profile_bg.png'),
                                // width: 1000.w,
                                fit: BoxFit.fill,
                              )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Obx(() {
                                if (GetUtils.isNullOrBlank(
                                    profileController.picture.value)!) {
                                  return Material(
                                    elevation: 0.0,
                                    shape: CircleBorder(),
                                    child: CircleAvatar(
                                      radius: 120.w,
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
                                                    image: AssetImage('assets/images/img_profile_user.png')
                                                )
                                            )
                                        ),
                                        // Icon(Icons.account_box_outlined , size: 70,color: Colors.white,),
                                        alignment: Alignment.center,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Material(
                                    elevation: 0.0,
                                    shape: CircleBorder(),
                                    child: CircleAvatar(
                                      radius: 120.w,
                                      backgroundImage: FileImage(File(
                                          profileController.picture.value)),
                                    ),
                                  );
                                }
                              }),
                              Image(
                                image: AssetImage('assets/images/img_profile_text.png'),
                                width: 400.w,
                                fit: BoxFit.fill,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          renderButton(context),
                          backGroundColorRenderButton(),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          Text(
                            '● ',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              // fontWeight: FontWeight.bold,
                              fontSize: 50.sp,
                            ),
                          ),
                          Text(
                            '필수정보',
                            style: TextStyle(
                              color: Colors.black,
                              // fontWeight: FontWeight.bold,
                              fontSize: 50.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: profileController.nameController,
                        decoration: InputDecoration(
                          labelText: '이름을 입력하세요.',
                          labelStyle: TextStyle(color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        keyboardType: TextInputType.name,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: profileController.phoneController,
                        maxLength: 12,
                        decoration: InputDecoration(
                          labelText: "휴대폰번호를 입력하세요.('-'은 넣지마세요)",
                          labelStyle: TextStyle(color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          Text(
                            '● ',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              // fontWeight: FontWeight.bold,
                              fontSize: 50.sp,
                            ),
                          ),
                          Text(
                            '직장정보',
                            style: TextStyle(
                              color: Colors.black,
                              // fontWeight: FontWeight.bold,
                              fontSize: 50.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: profileController.companyController,
                        decoration: InputDecoration(
                          labelText: '직장명을 입력하세요.',
                          labelStyle: TextStyle(color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: profileController.positionController,
                        decoration: InputDecoration(
                          labelText: '직책을 입력하세요',
                          labelStyle: TextStyle(color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        keyboardType: TextInputType.name,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: profileController.telController,
                        decoration: InputDecoration(
                          labelText: '회사연락처를 입력하세요.',
                          labelStyle: TextStyle(color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: profileController.emailController,
                        decoration: InputDecoration(
                          labelText: '이메일을 입력하세요.',
                          labelStyle: TextStyle(color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: profileController.homepageController,
                        decoration: InputDecoration(
                          labelText: '홈페이지를 입력하세요.',
                          labelStyle: TextStyle(color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Flexible(
                            flex: 8,
                            fit: FlexFit.tight,
                            child: TextField(
                              controller:
                                  profileController.addressSearchController,
                              // readOnly: true,
                              decoration: InputDecoration(
                                labelText: '주소를 검색하세요.',
                                labelStyle: TextStyle(color: Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.grey),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide:
                                      BorderSide(width: 1, color: Colors.grey),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                ),
                              ),
                              keyboardType: TextInputType.name,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Flexible(
                            flex: 3,
                            child: searchRenderButton(),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: profileController.addressController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: '기본 주소',
                          labelStyle: TextStyle(color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        keyboardType: TextInputType.name,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextField(
                        controller: profileController.addressController2,
                        decoration: InputDecoration(
                          labelText: '상세주소',
                          labelStyle: TextStyle(color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(width: 1, color: Colors.grey),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        keyboardType: TextInputType.name,
                      ),
                      SizedBox(
                        height: 200.h,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.fromLTRB(25, 0, 25, 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            backRenderButton(),
            saveRenderButton(),
          ],
        ),
      ),
    );
  }
}
