import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:graphview/GraphView.dart' as Grap;

class NetworkPictureController extends GetxController {
  var list = [];
  var nodeMap = {};
  TransformationController transformationController = TransformationController();

  @override
  void onInit() {
    super.onInit();
    initContact();
    //     withThumbnails: false);
  }

  void initPosition(String key, {int retries = 0}) async {
    Future.delayed(const Duration(seconds: 1), () async {

      print('node0x:${nodeMap[key] }');

      if (!nodeMap.containsKey(key)) {
        return;
      }

      final Grap.Node? firstNode = nodeMap[key] as Grap.Node?;
      final position = firstNode?.position;

      if (position == null ||
          !position.dx.isFinite ||
          !position.dy.isFinite) {
        if (retries < 3) {
          initPosition(key, retries: retries + 1);
        }
        return;
      }

      print('node0x:${position.dx}');

      print('node0x:${position.dx}');

      final context = Get.context;

      if (context == null) {
        return;
      }

      final double width = MediaQuery.of(context).size.width / 2;

      if (!width.isFinite || width <= 0) {
        return;
      }

      transformationController.value = Matrix4.identity()
        ..translate(-position.dx + width, 0.0);
      // Matrix4 scrollEnd = Matrix4.identity();

      //
      // transformationController.value = Matrix4.identity()
      // //   ..translate(0, 0);
      // AnimationController animationController =
      // AnimationController(duration: const Duration(seconds: 2), vsync: this);
      //
      // Animation<Matrix4> animation = Matrix4Tween(
      //     begin: transformationController.value, end: Matrix4.identity())
      //     .animate(animationController);
      //
      // transformationController.value = animation.value;
      // transformationController.toScene()
      print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
    });
  }

  Future<void> initContact() async {

    print('연락처 로딩시작*******************************************************************');

    // 권한 요청 (이미 다른 곳에서 처리하면 생략 가능)
    final granted = await FlutterContacts.requestPermission();
    if (!granted) {
      print('연락처 권한 거부');
      return;
    }

    // 연락처 불러오기
    final contacts2 = await FlutterContacts.getContacts(
      withProperties: true, // 전화번호 등 속성 포함
      withPhoto: true,      // 사진 가져오기
    );

    list = contacts2
      .map((e) {
        final phone = e.phones.isNotEmpty ? e.phones.first.number : '';

        return {
          'name': e.displayName,
          'phone': phone,
          'avatar': e.photo, // 또는 e.thumbnail
        };
      })
      .where((e) =>
        !GetUtils.isNullOrBlank(e['name'])! &&
        !GetUtils.isNullOrBlank(e['phone'])!)
      .toList();

    print('연락처 로딩완료*******************************************************************${list.length}');
  }

  Widget getContaniner(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Container(
      width: 50,
      height: 50,
      margin: EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(width: 3, color: secondary),
      ),
      alignment: Alignment.center,
      child: Icon(
        FontAwesomeIcons.userAlt,
        color: primary,
        size: 28,
      ),
    );
  }

  Widget getContaninerImage(BuildContext context, Uint8List avatar) {
    final secondary = Theme.of(context).colorScheme.secondary;
    final primary = Theme.of(context).primaryColor;

    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(width: 3, color: secondary),
        image: DecorationImage(image: MemoryImage(avatar), fit: BoxFit.fill),
      ),
    );
  }

  Widget getPicture(BuildContext context, Uint8List avatar) {
    final primary = Theme.of(context).primaryColor;
    final secondary = Theme.of(context).colorScheme.secondary;
    // print('networkid:${contacts.length}**');

    return GetUtils.isNullOrBlank(avatar)!
        ? getContaniner(context)
        : getContaninerImage(context, avatar);
  }

  Widget getPictureInfo(Uint8List? avatar) {
    return GetUtils.isNullOrBlank(avatar)!
        ? Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color.fromRGBO(125, 125, 125, 1),
            child: const Align(
              alignment: Alignment(0, 0),
              child: Icon(
                Icons.photo_camera_front_outlined,
                size: 125,
                color: Color.fromRGBO(0, 0, 0, 0.3),
              ),
            ),
          )
        : Container(
            width: double.infinity,
            height: double.infinity,
            // margin: EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(50),
              // border: Border.all(width: 3, color: secondary),
              image:
                  DecorationImage(image: MemoryImage(avatar!), fit: BoxFit.fill),
            ),
          );
  }

  Widget getPictureNetwork(String? networkid, String? name, Uint8List? avatar) {
    final primary = Colors.purple[500];
    final secondary = Colors.purple[200];

    return GetUtils.isNullOrBlank(avatar)!
        ? Container(
            // color: Colors.blue,
            width: 200.w,
            height: 230.w,
            child:
            Stack(
              children: [
                Material(
                  elevation: 5.0,
                  shape: const CircleBorder(),
                  child: CircleAvatar(
                    radius: 100.w,
                    child: Container(
                      // height:150.w,
                      // width: 150.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: Container(
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: AssetImage('assets/images/img_profile_user.png')))),
                      // Icon(Icons.account_box_outlined , size: 70,color: Colors.white,),
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(

                      // color: Colors.white,
                      padding: EdgeInsets.fromLTRB(15.w, 15.w, 15.w, 15.w),
                      width: 200.w,
                      height: 75.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // border: Border.all(
                        //     width: 3.0
                        // ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30.0) //     ,
                                //            <--- border radius here
                                ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              spreadRadius: 2),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          name.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 30.sp,
                              color: Colors.black54),
                        ),
                      )),
                )
              ],
            ),
          )
        : Container(
            // color: Colors.blue,
            width: 200.w,
            height: 230.w,
            child: Stack(
              children: [
                Material(
                  elevation: 5.0,
                  shape: const CircleBorder(),
                  child: CircleAvatar(
                    radius: 100.w,
                    child: Container(
                      // height:150.w,
                      // width: 150.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: MemoryImage(avatar!),
                                  fit: BoxFit.fill))),
                      // Icon(Icons.account_box_outlined , size: 70,color: Colors.white,),
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(

                      // color: Colors.white,
                      padding: EdgeInsets.fromLTRB(15.w, 15.w, 15.w, 15.w),
                      width: 200.w,
                      height: 75.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // border: Border.all(
                        //     width: 3.0
                        // ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30.0) //     ,
                                //            <--- border radius here
                                ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              spreadRadius: 2),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          name.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 30.sp,
                              color: Colors.black54),
                        ),
                      )),
                )
              ],
            ),
          );

    // Column(
    //         children: [
    //           Center(
    //             child: Container(
    //               width: 80.w,
    //               height: 80.w,
    //               margin: EdgeInsets.only(right: 15),
    //               decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.circular(50),
    //                 border: Border.all(width: 3, color: Colors.purple),
    //                 image: DecorationImage(
    //                     image: MemoryImage(avatar!), fit: BoxFit.fill),
    //               ),
    //             ),
    //           ),
    //           Text(name!)
    //         ],
    //       );
  }
}
