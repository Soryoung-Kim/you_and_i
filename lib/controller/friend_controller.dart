import 'dart:async';
import 'dart:io';

//import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:you_and_i/db/friend_db_controller.dart';
import 'package:you_and_i/db/network_db_controller.dart';
import 'package:you_and_i/main.dart';

import 'main_controller.dart';

class FriendController extends GetxController {
  List? foundUsers = [].obs;
  TextEditingController searchController = TextEditingController();
  TextEditingController memoController = TextEditingController();

  final FriendDBController friendDBController = Get.find<FriendDBController>();
  final NetworkDBController networkDBController =
      Get.find<NetworkDBController>();
  final MainController mainController = Get.find<MainController>();

  @override
  void onInit() {
    super.onInit();
  }

  Widget profileImage(picture) {
    if (GetUtils.isNullOrBlank(picture)!) {
      return Material(
        elevation: 0.0,
        shape: const CircleBorder(),
        child: CircleAvatar(
          radius: 80.w,
          child: Container(
            // height: 100,
            // width: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: Container(
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        image:AssetImage('assets/images/img_profile_user.png')))),
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
            radius: 80.w, backgroundImage: FileImage(File(picture))),
      );
    }
  }


  Widget buttonFriend(phone,index)  {

    return Obx(() {
      // networkDBController.networkCount(phone,friendDBController.list[index]);
      return Text(
        '인맥보기(${friendDBController.list[index].count})',
        style: TextStyle(
          color: Colors.black,
          // fontWeight: FontWeight.bold,
          fontSize: 35.sp,
        ),
      );
    });


  }
  Future<void> onDismissed(phone) async {
    // 삭제
    await networkDBController.deleteNetwork2(phone);
    await friendDBController.deleteFriend(phone);
    friendDBController.friends();
    mainController.shareCount(friendDBController.list.length);
    mainController.appBarTitle('인맥(${mainController.shareCount})');
    // Get.offAndToNamed('/YouAndIMain');
    // Timer(Duration(milliseconds: 500), () {x
    //   //  player.play('intro.MP3');
    //   // friendDBController.friends();
    // });
  }

  void clear() {
    searchController.text = '';
  }

  void onClose() {}

  void moveNetwork(index) async{
    await mainController.showProgress('인맥지도를 그리는 중입니다.\n많을 시 다소 시간이 걸립니다.');
    Future.delayed(const Duration(seconds: 1), () async {
      await networkDBController.networksDiagrm(friendDBController.list[index]);
      print(friendDBController.list[index]);


      Get.toNamed('/NetworkDetailDiagram',arguments: [friendDBController.list[index]]);
      await mainController.hideProgress();
      // Get.toNamed('/NetWorkDetailDiagram',arguments: [_networkDBController.list[index],one]);
    });
  }
}
