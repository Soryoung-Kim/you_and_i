import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';

import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';


class SplashPermission extends StatefulWidget {
  @override
  _SplashPermissionState createState() => _SplashPermissionState();
}

class _SplashPermissionState extends State<SplashPermission> {
//  AudioCache player = AudioCache(prefix: 'assets/sounds/');
  void initState() {
    super.initState();
  }

  Future<bool> requestPermission() async {

    final contactGranted = await _contactPermision();
    final storageGranted = await _storagePermision();
    final locationGranted = await _locationPermision();

    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainRoot()));
    //await _storagePermision();
    //await _contactPermision();
    //await _locationPermision();

    // final prefs = await SharedPreferences.getInstance();
    // if (!(prefs.getBool('isFirst') ?? false)) {
    //   Get.offAllNamed('/Tutorial');
    // }else{
    //   Get.offAllNamed('/YouAndI');
    //
    // }

    return contactGranted && storageGranted && locationGranted;
  }

  Future<bool> _locationPermision() async {
    var status = await Permission.location.request();
    if (status.isDenied) {
      return Future.error('Location permissions are denied ');
    }

    if (status.isGranted) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          //return Future.error('Location permissions are denied');
          permission = await Geolocator.requestPermission();
        }
        return permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse;
      }

      return _handleDenied(status, '위치 접근 권한을 허용해주세요.');
    }

  Future<bool> _contactPermision() async {
    var status = await Permission.contacts.request();

    if (status.isGranted) {
        return true;
    }

      return _handleDenied(status, '연락처 접근 권한을 허용해주세요.');
  }

  Future<bool> _askPermissions(String routeName) async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      return true;
    } else {
      return _handleDenied(permissionStatus, '연락처 접근 권한을 허용해주세요.');
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  Future<bool> _storagePermision() async {
    // 기본 저장소 권한 요청
    var status = await Permission.storage.request();

    if (status.isGranted) {
      return true;
    }

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final int androidVersion = androidInfo.version.sdkInt ?? 0;

      if (androidVersion >= 33) {
        if (await Permission.photos.status.isDenied ||
            await Permission.videos.status.isDenied) {
          Map<Permission, PermissionStatus> statuses = await [
            Permission.photos,
            Permission.videos,
          ].request();

          if (statuses[Permission.photos] == PermissionStatus.granted ||
              statuses[Permission.videos] == PermissionStatus.granted) {
            return true;
          } else {
            PermissionStatus representativeStatus  = await Permission.photos.request();
            return _handleDenied(representativeStatus , '저장소 권한을 허용해주세요.');
          }
        }
      }
    }

    return _handleDenied(status, '저장소 권한을 허용해주세요.');
  }

  bool _handleDenied(PermissionStatus status, String message) {
    final shouldShowSettingsCTA =
        status.isPermanentlyDenied || status.isDenied || status.isRestricted;

    if (status.isPermanentlyDenied) {
      Get.snackbar('권한 필요', '$message\n설정에서 권한을 변경해주세요.',
          mainButton: TextButton(
            onPressed: openAppSettings,
            child: const Text('설정 열기'),
          ));
      openAppSettings();
    } else if (status.isDenied || status.isRestricted || status.isLimited) {
      Get.snackbar('권한 필요', message,
          mainButton: shouldShowSettingsCTA
              ? TextButton(
            onPressed: openAppSettings,
            child: const Text('설정 열기'),
          )
              : null);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.all(0),
            color: Colors.white,
            child:

               Align(
                alignment: FractionalOffset.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  height: 120.h,
                  child: TextButton(
                    child: Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 60.sp,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor, // foreground
                    ),
                    onPressed: () async {
                      final granted = await requestPermission();
                      if (!granted) {
                        return;
                      }

                      final prefs = await SharedPreferences.getInstance();
                      final isT = prefs.getBool('isTutorial') ?? false;
                      print('asdfasdfasdf:${isT}');
                      // 처음 실행 한 유저
                      if (prefs.getBool('isTutorial') ?? false) {
                        Get.offAllNamed('/YouAndIMain');
                      } else {

                        Get.offAllNamed('/Tutorial');
                      }


                    },
                  ),

              ),
            ),
            // decoration: BoxDecoration(color: Colors.black,),
          ),
          Column(
            children: [
              SizedBox(
                height: 80,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      '우리사이를 사용을 위한\n접근 권한 안내',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 70.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
              SizedBox(
                height: 30,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      '필수 접근 권한',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 55.sp,
                      ),
                    ),
                  ]),
              SizedBox(
                height: 10,
              ),
              ListTile(
                dense: true,
                contentPadding:
                EdgeInsets.symmetric(vertical: 0.0, horizontal: 20),
                leading: Icon(
                  Icons.gps_fixed,
                  color: Theme.of(context).primaryColor,
                  size: 50.h,
                ),
                title: Align(
                  alignment: Alignment(-1.0, 0),
                  child: Text(
                    '위치',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 50.sp,
                    ),
                  ),
                ),
                subtitle: Align(
                  alignment: Alignment(-1.0, 0),
                  child: Text(
                    '현 위치로 매칭',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 43.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                dense: true,
                contentPadding:
                EdgeInsets.symmetric(vertical: 0.0, horizontal: 20),
                leading: Icon(
                  Icons.perm_contact_cal,
                  color: Theme.of(context).primaryColor,
                  size: 50.h,
                ),
                title: Align(
                  alignment: Alignment(-1.0, 0),
                  child: Text(
                    '주소록',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 50.sp,
                    ),
                  ),
                ),
                subtitle: Align(
                  alignment: Alignment(-1.0, 0),
                  child: Text(
                    '주소록 매칭 및 교환',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 43.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                dense: true,
                contentPadding:
                EdgeInsets.symmetric(vertical: 0.0, horizontal: 20),
                leading: Icon(
                  Icons.sd_storage,
                  color: Theme.of(context).primaryColor,
                  size: 50.h,
                ),
                title: Align(
                  alignment: Alignment(-1.0, 0),
                  child: Text(
                    '저장소',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 50.sp,
                    ),
                  ),
                ),
                subtitle: Align(
                  alignment: Alignment(-1.0, 0),
                  child: Text(
                    '로컬 데이터 저장',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 43.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      '선택 접근 권한',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 55.sp,
                      ),
                    ),
                  ]),
              SizedBox(
                height: 10,
              ),
              ListTile(
                dense: true,
                contentPadding:
                EdgeInsets.symmetric(vertical: 0.0, horizontal: 20),
                leading: Icon(
                  Icons.camera_alt,
                  color: Theme.of(context).primaryColor,
                  size: 50.h,
                ),
                title: Align(
                  alignment: Alignment(-1.0, 0),
                  child: Text(
                    '카메라',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 50.sp,
                    ),
                  ),
                ),
                subtitle: Align(
                  alignment: Alignment(-1.0, 0),
                  child: Text(
                    '프로필 사진 촬영',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 43.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
