import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:you_and_i/controller/more_controller.dart';
import 'package:you_and_i/controller/network_picture_controller.dart';

class Setting extends StatelessWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final MoreController controller = Get.find<MoreController>();
    final NetworkPictureController networkPictureController =
        Get.find<NetworkPictureController>();
    List<Widget> mainList = [
      // Text(
      //   'Push 알림',
      //   textAlign: TextAlign.start,
      //   style: TextStyle(
      //     color: Colors.black,
      //     fontWeight: FontWeight.w400,
      //     fontSize: 48.sp,
      //   ),
      // ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '연락처숨김',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 48.sp,
            ),
          ),
           Text(
            '  ${networkPictureController.list.length}명 연락처 등록됨',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w400,
              fontSize: 32.sp,
            ),
          ),
        ],
      ),
    ];
    List<Widget> widgetList = [
      // Obx(() => CupertinoSwitch(
      //     activeColor: Theme.of(context).primaryColor,
      //     trackColor: Colors.grey[400],
      //     thumbColor: Colors.white,
      //     value: controller.isPush.value,
      //     onChanged: (value) {
      //       print(value);
      //       controller.pushSwichChange(value);
      //     })),
      OutlinedButton(
        onPressed: () {
          Get.toNamed('/MoreHideContect');
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          padding: const EdgeInsets.all(1),
          side: const BorderSide(
            color: Colors.grey,
            width: 1,
          ),
          backgroundColor: Colors.white,
          fixedSize: Size(230.w, 80.h),
          shape: const StadiumBorder(),
        ),
        child: Text(
          '수정',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
            fontSize: 43.sp,
          ),
        ),
      ),
    ];

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            '환경설정',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: true,
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              )),
        ),
        body: ListView.separated(
          itemCount: mainList.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              onTap: () {
                print(index);

                if (index == 1) {
                  // Get.toNamed('/Setting');
                }
              },
              title: Container(
                alignment: Alignment.centerLeft,
                height: 50,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(40.w, 0, 40.w, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [mainList[index], widgetList[index]],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(thickness: 1);
          },
        ));
  }
}
