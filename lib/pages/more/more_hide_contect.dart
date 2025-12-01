import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:you_and_i/controller/network_picture_controller.dart';
import 'package:you_and_i/db/friend_db_controller.dart';
import 'package:you_and_i/db/more_hide_db_controller.dart';

class MoreHideContectPage extends StatefulWidget {
  @override
  _MoreHideContectPageState createState() => _MoreHideContectPageState();
}

class _MoreHideContectPageState extends State<MoreHideContectPage> {
  final TextStyle dropdownMenuItem =
      TextStyle(color: Colors.black, fontSize: 18);

  final NetworkPictureController _networkPictureController =
      Get.find<NetworkPictureController>();
  final MoreHideDBController _moreHideDBController =
      Get.find<MoreHideDBController>();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '연락처 숨김',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              Container(
                  // padding: EdgeInsets.only(top: 10.h),
                  height: MediaQuery.of(context).size.height,
                  // height: double.infinity,
                  width: double.infinity,
                  child: ListView.builder(
                      itemCount: _networkPictureController.list.length,
                      itemBuilder: (BuildContext context, int index) {
                        return buildList(context, index);
                      })),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildList(BuildContext context, int index) {
    return InkWell(
      onTap: () async {
        // 터치 시 숨김
        await _moreHideDBController.moreHides();
        bool isPhone = false;
        for (var ele in _moreHideDBController.list.value) {
          if (_networkPictureController.list[index]['phone'] == ele.phone) {
            isPhone = true;
          }
        }
        if (isPhone) {
          //delete
          await _moreHideDBController.delete(new MoreHide(
              phone: _networkPictureController.list[index]['phone']));
        } else {
          //insert
          await _moreHideDBController.insert(new MoreHide(
              phone: _networkPictureController.list[index]['phone']));
        }
        for (var ele in _moreHideDBController.list.value) {
          print(ele.phone);
        }
      },
      child: Column(
        children: [
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.white,
              ),
              width: double.infinity,
              height: 180.h,
              // margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 10.w),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // _networkPictureController.getPicture(context,'01071934621')
                      // )
                      // ,
                      // ,
                      Expanded(
                        child:
                         Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(

                              width: 60.w,
                            ),
                            Flexible(
                              flex: 1,
                              child: Text(
                              _networkPictureController.list[index]['name'],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 45.sp),
                            ),),
                            SizedBox(

                              width: 30.w,
                            ),


                            Text(
                                _networkPictureController.list[index]['phone']
                                // ''
                                ,

                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 30.sp,
                                    letterSpacing: .3)),
                            SizedBox(

                              width: 50.w,
                            ),



                            // Row(
                            //   children: <Widget>[
                            //     Icon(
                            //       Icons.date_range,
                            //       color: secondary,
                            //       size: 20,
                            //     ),
                            //     SizedBox(
                            //       width: 5,
                            //     ),
                            //     // Text(_networkDBController.list[index].createdt,
                            //     //     style: TextStyle(
                            //     //         color: primary, fontSize: 13, letterSpacing: .3)),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                      Container(
                          alignment: Alignment.centerRight,
                          child: Obx(() {
                            return _moreHideDBController.HideWidget(
                                _networkPictureController.list[index]['phone']);
                          }))
                      ,
                      SizedBox(

                        width: 30.w,
                      ),
                    ],
                  ),


                ],
              )),
          Divider(
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

// class _FriendPageState extends State<FriendPage> {

// }
