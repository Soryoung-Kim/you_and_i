import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:you_and_i/controller/reg_profile_controller.dart';
import 'package:you_and_i/db/myinfo_db_controller.dart';

class RegProfile2 extends StatefulWidget {
  @override
  _RegProfile2State createState() => _RegProfile2State();
}

class _RegProfile2State extends State<RegProfile2> {
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
          padding: const EdgeInsets.all(0),
          side: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
          fixedSize: Size(450.w, 120.h),
          shape: const StadiumBorder(),
        ),
        child: const Text('이전'));
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
              !GetUtils.isNullOrBlank(profileController.phoneController.text)!) {
            showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  // title: Text("Delete File"),
                  content: const Text("저장 하시겠습니까??"),
                  actions: [
                    CupertinoDialogAction(
                        child:const Text('취소', style: TextStyle(color: Colors.black38)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    CupertinoDialogAction(
                      child: Text('확인',
                          style: TextStyle(color: Theme.of(context).primaryColor)),
                      onPressed: ()async {

                        Navigator.of(Get.context!).pop();


                        await profileController.dbInsert();
                        if(profileController.isFirst.value){
                          Get.offAllNamed('/YouAndIMain');
                        }else{
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          currentFocus.unfocus();
                          Future.delayed(Duration(seconds: 1), () async {
                            Navigator.of(Get.context!).pop();
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

          padding: const EdgeInsets.all(0),
          // side: BorderSide(
          //   color: Theme.of(context).primaryColor,
          //   width: 2,
          // ),
          fixedSize: Size(450.w, 120.h),
          shape: const StadiumBorder(),
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
          padding: const EdgeInsets.all(0),
          side: const BorderSide(
            color: Colors.grey,
            width: 1,
          ),
          fixedSize: const Size(170, 60),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text('검색', style: TextStyle(fontSize: 50.sp),));
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
            Obx((){
              if(!profileController.isFirst.value){
                return IconButton(onPressed: (){
                  Get.back();
                  Get.back();
                }, icon: const Icon(
                  Icons.close,
                  color: Colors.black,
                ));
              }else{
                return const Text('');
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
                    color: Colors.grey[100],
                  )),
                  Expanded(
                      child: Container(
                    height: 5,
                    color: Colors.black,
                  )),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child:
                  Container(
                    padding: const EdgeInsets.all(25.0),
                    color: Colors.white,
                    child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        const SizedBox(
                          height: 15,
                        ),
                        TextField(
                          controller: profileController.nameController,
                          decoration: const InputDecoration(
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
                        const SizedBox(
                          height: 15,
                        ),
                        TextField(
                          controller: profileController.phoneController,
                          maxLength: 12,
                          decoration: const InputDecoration(
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
                        const SizedBox(
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
                        const SizedBox(
                          height: 15,
                        ),
                        TextField(
                          controller: profileController.companyController,
                          decoration: const InputDecoration(
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
                        const SizedBox(
                          height: 15,
                        ),
                        TextField(
                          controller: profileController.positionController,
                          decoration: const InputDecoration(
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
                        const SizedBox(
                          height: 15,
                        ),
                        TextField(
                          controller: profileController.telController,
                          decoration: const InputDecoration(
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
                        const SizedBox(
                          height: 15,
                        ),
                        TextField(
                          controller: profileController.emailController,
                          decoration: const InputDecoration(
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
                        const SizedBox(
                          height: 15,
                        ),
                        TextField(
                          controller: profileController.homepageController,
                          decoration: const InputDecoration(
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
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Flexible(
                              flex: 8,
                              fit: FlexFit.tight,
                              child: TextField(
                                controller: profileController.addressSearchController,
                                // readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: '주소를 검색하세요.',
                                  labelStyle: TextStyle(color: Colors.grey),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.grey),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.grey),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                ),
                                keyboardType: TextInputType.name,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Flexible(
                              flex: 3,
                              child: searchRenderButton(),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextField(
                          controller: profileController.addressController,
                          readOnly: true,
                          decoration: const InputDecoration(
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
                        const SizedBox(
                          height: 15,
                        ),
                        TextField(
                          controller: profileController.addressController2,
                          decoration: const InputDecoration(
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
        padding: const EdgeInsets.fromLTRB(25,0,25,25),
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
