import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import 'dart:async';
import 'package:you_and_i/db/db_helper.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
class MoreHide {
  final String phone; //폰


  MoreHide({
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
    };
  }
}

class MoreHideDBController extends GetxController {
  Database? database;

  RxList<MoreHide> list = <MoreHide>[].obs;

  @override
  void onInit() {
    super.onInit();
    initDB();
  }

  Future<void> initDB() async {
    database = await DbHelper().open();
    await moreHides();
  }

  void onClose() {
    super.onClose();
    // if (database != null) database!.close();
  }

  Future<void> moreHides() async {

    String query = 'SELECT DISTINCT phone '
        'FROM MoreHide ' ;
    final List<Map<String, dynamic>> maps = await database!.rawQuery(
        query
    );
    var datas = List.generate(maps.length, (i) {
      return MoreHide(
            phone: maps[i]['phone'],
          );
    });

    list.clear();

    list.addAll(datas);


    print('숨긴 테이블:${list.length}');

  }

  Future<void> insert(MoreHide moreHide) async {
    // friend.createdt = DateFormat.yMMMd(
    //         '${Get.deviceLocale.languageCode}_${Get.deviceLocale.countryCode}')
    //     .format(DateTime.now());


    //DateTime.now();
    var result = await database!.insert(
      'MoreHide',
      moreHide.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('insert result $result');

    await moreHides();
  }

  Future<void> delete(MoreHide moreHide) async {
    // friend.createdt = DateFormat.yMMMd(
    //         '${Get.deviceLocale.languageCode}_${Get.deviceLocale.countryCode}')
    //     .format(DateTime.now());


    //DateTime.now();
    var result = await database!.delete(
      'MoreHide', where: 'phone = ?', whereArgs: [moreHide.phone]
    );
    print('delete result $result');

    await moreHides();
  }

  unSelect() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        //모서리를 둥글게 하기 위해 사용
        borderRadius: BorderRadius.circular(90.0),
        side: BorderSide(color: Colors.grey, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Container(
          width: 270.w,
          height: 100.h,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.check, size: 50.w,
                  color: Colors.grey,

                ),
                SizedBox(width: 25.w,),
                Text(
                  '선택',
                  style: TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.bold,
                    fontSize: 35.sp,
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
  select() {
    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(
        //모서리를 둥글게 하기 위해 사용
        borderRadius: BorderRadius.circular(90.0),
        // side: BorderSide(color: Colors.grey, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Container(
          width: 270.w,
          height: 100.h,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.check, size: 50.w,
                  color: Colors.white,

                ),
                SizedBox(width: 25.w,),
                Text(
                  '선택됨',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 35.sp,
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget HideWidget(String phone)  {
    // friend.createdt = DateFormat.yMMMd(
    //         '${Get.deviceLocale.languageCode}_${Get.deviceLocale.countryCode}')
    //     .format(DateTime.now());


    // await moreHides();

    bool isPhone = false;
    for(var ele in list){
      if(phone == ele.phone){
        isPhone = true;
      }
    }
    if(isPhone){
      return select();
    }else{
      return unSelect();
    }

  }
}

//db에 사진 파일 저장 불러오기
//https://stackoverflow.com/questions/52170790/how-to-save-image-data-to-sqflite-database-in-flutter-for-persistence
