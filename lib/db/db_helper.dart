import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  Future<Database> open() async {
    print(await getDatabasesPath());
    var database = await openDatabase(
        join(await getDatabasesPath(), 'youandi.db'),
        version: 3, onCreate: (Database db, int version) async {
      // 유저 프로필 저장
      await db.execute('''
          CREATE TABLE 
          MyInfo(
            id INTEGER PRIMARY KEY
            ,picture TEXT
            ,background TEXT
            ,name TEXT
            ,phone TEXT
            ,company TEXT
            ,position TEXT
            ,tel TEXT
            ,email TEXT
            ,homepage TEXT
            ,address TEXT
            ,address2 TEXT
            ,memo TEXT);
      ''');
      // var name = await FlutterDeviceFriendlyName.friendlyName;
      var name = '';
      var insertRt = await db.rawInsert('''
        insert into MyInfo(id, name) values(0, ?)
      ''', [name]);
      print('insertRt : $insertRt');
      // // 교환된 친구 정보 저장
      await db.execute('''
          CREATE TABLE
          Friend(
            id TEXT PRIMARY KEY
            ,picture TEXT
            ,background TEXT
            ,name TEXT
            ,phone TEXT
            ,company TEXT
            ,position TEXT
            ,tel TEXT
            ,email TEXT
            ,homepage TEXT
            ,address TEXT
            ,address2 TEXT
            ,memo TEXT
            ,createdt TEXT);
      ''');
      //
      // await db.execute('''
      //     CREATE TABLE
      //     FriendContact(
      //       id INTEGER PRIMARY KEY AUTOINCREMENT
      //       ,friendid TEXT
      //       ,name TEXT
      //       ,phone TEXT
      //       ,createdt TEXT
      //     );
      // ''');
      await db.execute('''
          CREATE TABLE
          Network(
            id INTEGER PRIMARY KEY AUTOINCREMENT
            ,networkid TEXT
            ,picture TEXT
            ,name TEXT
            ,phone TEXT
            ,company TEXT
            ,position TEXT
            ,tel TEXT
            ,email TEXT
            ,address TEXT
            ,createdt TEXT
            ,UNIQUE(networkid,phone)
          );
      ''');
      // await db.execute('''
      //     CREATE TABLE
      //     NetWorkDetail(
      //       id INTEGER PRIMARY KEY AUTOINCREMENT
      //       ,networkid TEXT
      //       ,picture TEXT
      //       ,name TEXT
      //       ,position TEXT
      //       ,phone TEXT
      //       ,tel TEXT
      //       ,email TEXT
      //       ,address TEXT
      //       ,createdt TEXT
      //     );
      // ''');
      await db.execute('''
          CREATE TABLE
          MoreHide(
            id INTEGER PRIMARY KEY AUTOINCREMENT
            ,phone TEXT
          );
      ''');
    });

    return database;
  }
}
