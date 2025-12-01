import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:you_and_i/controller/friend_controller.dart';
import 'dart:async';
import 'package:you_and_i/db/db_helper.dart';

import '../controller/main_controller.dart';

class Friend {
  final String? id; //아이디
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
  final String? address2; //주소
  String? memo; //메모
  int? count; //인맥 카운드
  String? createdt;


  Friend(
      {  this.id,
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
        this.count,
         this.createdt});

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
      'count': count,
      'createdt': createdt
    };
  }
}

class FriendDBController extends GetxController {
  Database? database;
  // final FriendController friendController = Get.find<FriendController>();
  // String _friendlyName;

  // RxString name = ''.obs;
  // RxString position = ''.obs;
  // RxString phone = ''.obs;
  // RxString tel = ''.obs;
  // RxString address = ''.obs;
  // RxString email = ''.obs;
  // RxString memo = ''.obs;

  RxList<Friend> list = <Friend>[].obs;
  RxList<Friend> listRecent = <Friend>[].obs;

  @override
  void onInit() {
    super.onInit();
    initDB();
  }


  Future<void> initDB() async {
    database = await DbHelper().open();
    await friends();
    await friendRecent();
    // friendController.foundUsers!.clear();
    // friendController.foundUsers!.addAll(list);
    // // foundUsers = friendDBController.list;
    // print('foundUsers count :${friendController.foundUsers!.length}');
  }

  void onClose() {
    super.onClose();
    // if (database != null) database!.close();
  }

  Future<void> insertFriend(Friend friend) async {
    // friend.createdt = DateFormat.yMMMd(
    //         '${Get.deviceLocale.languageCode}_${Get.deviceLocale.countryCode}')
    //     .format(DateTime.now());
    final List<Map<String, dynamic>> maps = await database!.rawQuery(""
        " SELECT memo "
        " FROM friend A "
        " WHERE phone = '${friend.phone}' ");
    print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
    print(maps);

    if(maps.length != 0){
      friend.memo = maps[0]['memo'];
    }

    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd HH:mm');
    String formatted = formatter.format(now);
    friend.createdt = formatted;
    // friend.

    //DateTime.now();
    // var result = await database!.insert(
    //   'friend',
    //   friend.toMap(),
    //   conflictAlgorithm: ConflictAlgorithm.replace,
    // );
    // print('insert result $result');

    await database!.execute(" INSERT OR REPLACE INTO friend"
        " (id, picture, background, name, phone, company, position, tel, email, homepage, address, address2, memo, createdt) "
        " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ",
    [friend.id,friend.picture,friend.background,friend.name,friend.phone, friend.company,friend.position,
      friend.tel,friend.email,friend.homepage,friend.address,friend.address2,friend.memo,friend.createdt]);


    await friends();
    await friendRecent();
  }

  Future<void> updateProfileImage(String id, String path) async {
    print('update friend image : $id, $path');

    // await database
    //     .execute('update friend set picture = ? where id = ? ', [path, id]);
    var result = await database!.update('friend', {'picture': path},
        where: 'id= ? ', whereArgs: [id]);
    print('update----result : $result');

    await friends();

    await friendRecent();
  }

  Future<void> updateMemo(String id, String memo) async {
    print('update friend Memo : $id, $memo');

    // await database
    //     .execute('update friend set picture = ? where id = ? ', [path, id]);
    var result = await database!.update('friend', {'memo': memo},
        where: 'id= ? ', whereArgs: [id]);
    print('update----result : $result');

    await friends();

    await friendRecent();
  }

  Future<List<Friend>> friends() async {
    final List<Map<String, dynamic>> maps = await database!.rawQuery(""
        " SELECT id,picture,background,name,phone,company,position,tel,email,homepage,address,address2,memo,createdt, "
        " (SELECT  COUNT(*) FROM Network  WHERE networkid = A.phone) as count "
        " FROM friend A ORDER BY createdt DESC ");

    var datas = List.generate(maps.length, (i) {
      // print(maps[i].toString());
      return Friend(
          id: maps[i]['id'],
          picture: maps[i]['picture'],
          background: maps[i]['background'],
          name: maps[i]['name'],
          phone: maps[i]['phone'],
          company: maps[i]['company'],
          position: maps[i]['position'],
          tel: maps[i]['tel'],
          email: maps[i]['email'],
          homepage: maps[i]['homepage'],
          address: maps[i]['address'],
          address2: maps[i]['address2'],
          memo: maps[i]['memo'],
          createdt: maps[i]['createdt'],
          count: maps[i]['count'],
      );
    });

    list.clear();
    list.addAll(datas);

    Directory? dir;
    if (GetPlatform.isIOS) {
      dir = await getApplicationSupportDirectory();
      List fileList  = dir.path.split('/');
      String tmpString = fileList[6];


      for(Friend friendList in list){
        if(friendList.picture!=''&&friendList.picture!=null&&friendList.picture!='null'){
          fileList = friendList.picture.toString().split('/');
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
          friendList.picture = path;
        }

      }


      // print('path : ${path}');
    }

    return datas;

  }


  Future<List<Friend>> friendRecent() async {
    final List<Map<String, dynamic>> maps = await database!.rawQuery(
        'SELECT id,picture,background,name,phone,company,position,tel,email,homepage,address,address2,createdt FROM friend A '
            ' ORDER BY createdt DESC'
            ' LIMIT 10');


    var datas = List.generate(maps.length, (i) {
      // print(maps[i].toString());
      return Friend(
          id: maps[i]['id'],
          picture: maps[i]['picture'],
          background: maps[i]['background'],
          name: maps[i]['name'],
          phone: maps[i]['phone'],
          company: maps[i]['company'],
          position: maps[i]['position'],
          tel: maps[i]['tel'],
          email: maps[i]['email'],
          homepage: maps[i]['homepage'],
          address: maps[i]['address'],
          address2: maps[i]['address2'],
          memo: maps[i]['memo'],
          createdt: maps[i]['createdt']);
    });

    listRecent.clear();
    listRecent.addAll(datas);

    Directory? dir;
    if (GetPlatform.isIOS) {
      dir = await getApplicationSupportDirectory();
      List fileList  = dir.path.split('/');
      String tmpString = fileList[6];


      for(Friend friendList in listRecent){
        if(friendList.picture!=''&&friendList.picture!=null&&friendList.picture!='null'){
          fileList = friendList.picture.toString().split('/');
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
          friendList.picture = path;
        }

      }


      // print('path : ${path}');
    }
    print('최근 친구 테이블:${listRecent.length}');

    return datas;

  }
  Future<void> deleteFriend(String id) async {
    await database!.execute('''
      delete from friend where id = ?
    ''', [id]);
  }
}

//db에 사진 파일 저장 불러오기
//https://stackoverflow.com/questions/52170790/how-to-save-image-data-to-sqflite-database-in-flutter-for-persistence
