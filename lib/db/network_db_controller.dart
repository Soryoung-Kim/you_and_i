import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:you_and_i/db/db_helper.dart';
import 'package:you_and_i/db/friend_db_controller.dart';

class Network {
  final String? networkid; //인맥 아이디
  final String? picture; //사진
  final String? name; //이름
  final String? phone; //폰
  final String? company; //폰
  final String? position; //폰
  final String? tel; //폰
  final String? email; //폰
  final String? address; //폰


  String? createdt;

  Network({
    this.networkid,
    this.picture,
    this.name,
    this.phone,
    this.company,
    this.position,
    this.tel,
    this.email,
    this.address,
    this.createdt,
  });

  Map<String, dynamic> toMap() {
    return {
      'networkid': networkid,
      'picture': picture,
      'name': name,
      'phone': phone,
      'company': company,
      'position': position,
      'tel': tel,
      'email': email,
      'address': address,
      'createdt': createdt
    };
  }
}

class NetworkDBController extends GetxController {
  Database? database;

  List<Network> list = <Network>[].obs;
  List<Network> listDiagram = <Network>[].obs;
  RxList<Uint8List> avatarList = <Uint8List>[].obs;

  List<Network> total = <Network>[];

  @override
  void onInit() {
    super.onInit();
    initDB();
  }

  Future<void> initDB() async {
    database = await DbHelper().open();
    await networks();
  }

  void onClose() {
    super.onClose();
    if (database != null) database!.close();
  }

  Future<void> deleteNetwork(String networkId) async {
    await database!.execute('''
      delete from network where networkid = ?
    ''', [networkId]);
    await networks();
  }
  Future<void> deleteNetwork2(String networkId) async {
    await database!.execute('''
      delete from network where networkid = ?
    ''', [networkId]);
  }

  Future<void> deleteNetwork3(String networkId) async {
    await database!.execute('''
      delete from network where networkid = ? AND phone = ?
    ''', [networkId,networkId]);

    await networks();
  }

  Future<void> insertNetwork(Network network) async {


    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd HH:mm');
    String formatted = formatter.format(now);
    network.createdt = formatted;

    //DateTime.now();
    var result = await database!.insert(
      'network',
      network.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // print('insert result $result');

    await database!.execute(" INSERT OR REPLACE INTO network"
        " ( networkid, picture, name, phone, company, position, tel, email, address, createdt) "
        " SELECT ?, ?, ?, ?, ?, ?, ?, ?, ?, ? "
        " WHERE NOT EXISTS"
        "( SELECT networkid FROM network WHERE networkid = ? AND phone = ? )  ",
        [ network.networkid,network.picture,network.name,network.phone, network.company,network.position,
          network.tel,network.email,network.address,network.createdt,network.networkid,network.phone]);


  }

  Future<void> networks() async {
    final List<Map<String, dynamic>> maps = await database!.rawQuery(
        'SELECT id,networkid,picture,name,phone,company,position,tel,email,address,createdt FROM Network A');
    print('===========================================================');
    // print(maps);
    var datas = List.generate(maps.length, (i) {
      return Network(
          networkid: maps[i]['networkid'],
          picture: maps[i]['picture'],
          name: maps[i]['name'],
          phone: maps[i]['phone'],
          company: maps[i]['company'],
          position: maps[i]['position'],
          tel: maps[i]['tel'],
          address: maps[i]['address'],
          createdt: maps[i]['createdt']);
    });
    for(var ele in datas){
      // print('인맥:${ele.toMap()}');
    }

  }
  Future<Network> networkOne(NodeData? one) async {
    final List<Map<String, dynamic>> maps = await database!.rawQuery(
        "SELECT id,networkid,picture,name,phone,company,position,tel,email,address,createdt FROM Network A "
            " WHERE phone = '${one!.id}'  GROUP BY  phone ");
    // print(maps);
    var datas = List.generate(maps.length, (i) {
      return Network(
          networkid: maps[i]['networkid'],
          picture: maps[i]['picture'],
          name: maps[i]['name'],
          phone: maps[i]['phone'],
          company: maps[i]['company'],
          position: maps[i]['position'],
          tel: maps[i]['tel'],
          address: maps[i]['address'],
          createdt: maps[i]['createdt']);
    });
    return datas[0];

  }

  Future<List<Network>?> Diagrm(Network element,List<Network> totalList,depth)async{
    var maps = await database!.rawQuery(
        "SELECT networkid,picture,name,phone FROM Network A WHERE networkid = '${element.phone}' "
            " AND phone != '${element.networkid}' AND phone != '${element.phone}' GROUP BY networkid, phone ");
     print(maps);
    var datas = List.generate(maps.length, (i) {
      return Network(
          networkid: maps[i]['networkid'].toString(),
          picture: maps[i]['picture'].toString(),
          name: maps[i]['name'].toString(),
          phone: maps[i]['phone'].toString(),
          createdt: maps[i]['createdt'].toString());
    });


    datas.removeWhere((element2){

      bool isRemove = true;
      for (var element in totalList) {
        if(element.phone == element2.phone){
          isRemove = false;
          // print('remove false:${element.phone}');
        }
      }
      return isRemove;
    });

    print(datas.length);

    final allContacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: true,
    );

    for (var element2 in datas) {
      EdgeData edge = EdgeData(from: element2.networkid,to:element2.phone,depth: depth);

      map!['edges']!.add(edge);

      NodeData node = NodeData(id: element2.phone,name:element2.name);
      // print('==================================');
      // print(node.name);
      // print('==================================');

      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      // 이름으로 필터링 (부분 포함 검색)
      final matched = allContacts.where(
            (c) =>
                (c.displayName ?? '').contains(element2.name ?? ''),
      );

      if (matched.isEmpty) {
        node.avatar = null;
      } else {
        node.avatar = matched.first.photo; // 썸네일/사진
      }

      map!['nodes']!.add(node);
    }
    total.addAll(datas);
    return datas;

  }

  Map<String,List>? map;
  Future<void> networksDiagrm(Friend? one) async {
    Uint8List bytes = Uint8List(0);
    map = {'nodes': [], 'edges': []};

    // 친구 본인 사진
    if (one != null && one.picture != null && one.picture.toString().isNotEmpty) {
      var file = File(one.picture.toString());
      bytes = file.readAsBytesSync();
    }
    NodeData root = NodeData(id: one!.phone, name: one.name, avatar: bytes);
    map!['nodes']!.add(root);

    // 🔐 연락처 권한 (다른 곳에서 이미 요청했다면 생략해도 됨)
    final granted = await FlutterContacts.requestPermission();
    if (!granted) {
      // 권한 없으면 아바타 없이 그래프만 그리도록
      print('연락처 권한이 없어 아바타를 불러오지 않습니다.');
    }

    // ✅ 연락처 전체 한 번만 로드 (권한 있을 때만)
    List<Contact> allContacts = [];
    if (granted) {
      allContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
    }

    // 1depth 데이터 select
    List<Map<String, dynamic>> maps = await database!.rawQuery(
      "SELECT networkid,picture,name,phone,createdt "
          "FROM Network A "
          "WHERE networkid = '${one.phone}' AND phone != '${one.phone}' "
          "GROUP BY networkid, phone ",
    );

    var datas = List.generate(maps.length, (i) {
      return Network(
        networkid: maps[i]['networkid'],
        picture: maps[i]['picture'],
        name: maps[i]['name'],
        phone: maps[i]['phone'],
        createdt: maps[i]['createdt'],
      );
    });

    total.clear();
    total.addAll(datas);

    for (var element in datas) {
      NodeData node = NodeData(id: element.phone, name: element.name);
      EdgeData edge =
      EdgeData(from: element.networkid, to: element.phone, depth: 1);

      // 🧭 flutter_contacts로 이름 매칭해서 아바타 찾기
      if (granted) {
        final searchName = (element.name ?? '').trim().toLowerCase();

        final matched = allContacts.where(
              (c) => (c.displayName ?? '').toLowerCase().contains(searchName),
        );

        if (matched.isEmpty) {
          node.avatar = null;
        } else {
          node.avatar = matched.first.photo; // 또는 matched.first.thumbnail
        }
      } else {
        node.avatar = null;
      }

      map!['nodes']!.add(node);
      map!['edges']!.add(edge);

      int depth = 2;

      // 2depth 데이터 구현
      List<Network>? remindList = await Diagrm(element, total, depth);

      while (remindList!.length > 0) {
        print('############# count : ${remindList.length}');
        print('############# depth : $depth');

        for (var element2 in remindList) {
          print('############# depth : ${element2.phone}');
          remindList = await Diagrm(element2, total, depth);
        }

        depth++;
      }
    }
  }

  // Future<void> networkCount(phone,Friend friend) async {
  //   final List<Map<String, dynamic>> maps = await database!.rawQuery(
  //       "SELECT COUNT(*) as count FROM Network A "
  //           " WHERE networkid = '${phone}'  ");
  //   var datas = List.generate(maps.length, (i) {
  //     return maps[i]['count'];
  //   });
  //   // friend.count = datas[0];
  //   friend.count= datas[0];
  //   print(friend.count);
  //
  //
  // }
}

class NodeData {
  String? id;
  String? name;
  Uint8List? avatar;


  NodeData({this.id,this.name,this.avatar});
}

class EdgeData {
  String? from;
  String? to;
  int? depth;


  EdgeData({this.from,this.to,this.depth});
}

//db에 사진 파일 저장 불러오기
//https://stackoverflow.com/questions/52170790/how-to-save-image-data-to-sqflite-database-in-flutter-for-persistence
