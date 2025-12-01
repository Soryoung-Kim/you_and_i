
import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'dart:async';
import 'package:you_and_i/db/db_helper.dart';

class MyInfo {
  final int? id; //아이디
  String? picture; //사진
  final String? background; //배경
  final String? name; //이름
  final String? phone; //휴대폰
  final String? company; //회사
  final String? position; //직급
  final String? tel; //전화
  final String? email; //이메일
  final String? homepage; //홈페이지
  final String? address; //주소
  final String? address2; //주소2
  final String? memo; //메모

  MyInfo(
      {this.id,
        this.picture,
        this.background,
        this.name,
        this.phone,
        this.company,
        this.position,
        this.tel,
        this.email,
        this.homepage,
        this.address,
        this.address2,
        this.memo,
      });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'picture': picture,
      'background': background,
      'name': name,
      'phone': phone,
      'company': company,
      'position': position,
      'tel': tel,
      'email': email,
      'homepage': homepage,
      'address': address,
      'address2': address2,
      'memo': memo,
    };
  }
}

class MyInfoDBController extends GetxController {
  static Database? database;
  // String _friendlyName;

  RxString picture = ''.obs;
  RxString background = ''.obs;
  RxString name = ''.obs;
  RxString phone = ''.obs;
  RxString company = ''.obs;
  RxString position = ''.obs;
  RxString tel = ''.obs;
  RxString email = ''.obs;
  RxString homepage = ''.obs;
  RxString address = ''.obs;
  RxString address2 = ''.obs;
  RxString memo = ''.obs;

  RxBool isCompanyButtonShow = false.obs;
  // bool isPictureUpdate = false;
  @override
  void onInit() {
    super.onInit();
    initDB();
  }

  void onClose() {
    super.onClose();
    // if (database != null) {
    //   database!.close();
    // } (database != null) {
    //   database!.close();
    // }
  }

  Future<void> initDB() async {
    database = await DbHelper().open();
    // 디비 생성할때 무조건 하나 만듬. dbHelper
    var myinfos = await myInfo();
    var myInfoData = myinfos[0];
    print('----myinfo---');
    print(myInfoData.toMap());


    picture(myInfoData.picture);
    background(myInfoData.background);
    name(myInfoData.name);
    phone(myInfoData.phone);
    company(myInfoData.company);
    position(myInfoData.position);
    tel(myInfoData.tel);
    email(myInfoData.email);
    homepage(myInfoData.homepage);
    address(myInfoData.address);
    address2(myInfoData.address2);
    memo(myInfoData.memo);


    if((myInfoData.company==null || myInfoData.company=='') &&
        (myInfoData.position==null || myInfoData.position=='') &&
        (myInfoData.tel==null || myInfoData.tel=='') &&
        (myInfoData.email==null || myInfoData.email=='') ){
      isCompanyButtonShow(true);
    }else{
      isCompanyButtonShow(false);
    }
    print('isCompanyButtonShow:${isCompanyButtonShow}');

    // Future.delayed(Duration(seconds: 2), () {
    //   if (phone.value.isEmpty) {
    //     Get.toNamed('/YouAndIProfile');
    //   }
    // });
  }

  Future<void> insertMyInfo(MyInfo myInfo) async {
    print(myInfo.toMap());
    await database!.insert(
      'myInfo',
      myInfo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // myInfo();
  }

  Future<void> updateProfileImage(String path) async {
    var result = await database!.update('myInfo', {'picture': path},
        where: 'id= ? ', whereArgs: [0]);
    print('update----result : $result');
    if (result > 0) {
      picture(path);
      // isPictureUpdate = true;
    }
  }

  Future<List<MyInfo>> myInfo() async {
    // 모든 Dog를 얻기 위해 테이블에 질의합니다.
    final List<Map<String, dynamic>> maps = await database!.query('myInfo');

    // List<Map<String, dynamic>를 List<Dog>으로 변환합니다.

    var list = List.generate(maps.length, (i) {
      return MyInfo(
        id: maps[i]['id'],
        picture: maps[i]['picture'],
        background: GetUtils.isNullOrBlank(maps[i]['background'])!
            ? null
            : maps[i]['background'],
        name: GetUtils.isNullOrBlank(maps[i]['name'])! ? null : maps[i]['name'],
        phone:
        GetUtils.isNullOrBlank(maps[i]['phone'])! ? null : maps[i]['phone'].toString(),
        company: GetUtils.isNullOrBlank(maps[i]['company'])! ? null : maps[i]['company'],
        position: GetUtils.isNullOrBlank(maps[i]['position'])!
            ? null
            : maps[i]['position'],
        tel: GetUtils.isNullOrBlank(maps[i]['tel'])! ? null : maps[i]['tel'].toString(),
        email:
        GetUtils.isNullOrBlank(maps[i]['email'])! ? null : maps[i]['email'],
        homepage:
        GetUtils.isNullOrBlank(maps[i]['homepage'])! ? null : maps[i]['homepage'],
        address: GetUtils.isNullOrBlank(maps[i]['address'])!
            ? null
            : maps[i]['address'],
        address2: GetUtils.isNullOrBlank(maps[i]['address2'])!
            ? null
            : maps[i]['address2'],
        memo: GetUtils.isNullOrBlank(maps[i]['memo'])! ? null : maps[i]['memo'],
      );
    });

    Directory? dir;
    if (GetPlatform.isIOS) {
      dir = await getApplicationSupportDirectory();
      List fileList  = dir.path.split('/');
      String tmpString = fileList[6];
      print(list[0].picture);
      if(list[0].picture!=''&&list[0].picture!=null&&list[0].picture!='null'){
        fileList = list[0].picture.toString().split('/');
        fileList[6] = tmpString;
        String path = '';
        int i=0;
        for(String ele in fileList){
          if(i == 0){
            path = path + '$ele';
          }else{
            path = path + '/$ele';
          }
          i++;
        }
        list[0].picture = path;
      }

      // print('path : ${path}');
    }



    return list;
  }
}

//db에 사진 파일 저장 불러오기
//https://stackoverflow.com/questions/52170790/how-to-save-image-data-to-sqflite-database-in-flutter-for-persistence
