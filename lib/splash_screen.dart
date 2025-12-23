
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:you_and_i/splash_permision.dart';
import 'dart:async';

import 'db/db_helper.dart';
import 'package:geolocator/geolocator.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //AudioCache player = AudioCache(prefix: 'assets/sounds/');
  void initState() {
    super.initState();
    load();
  }

  load() async {
    Timer(Duration(milliseconds: 500), () {
      //  player.play('intro.MP3');
    });
    Timer(Duration(seconds: 3), () async {
      var helper = DbHelper();
      await helper.open();
      // Get.put(Tutorial());

      final prefs = await SharedPreferences.getInstance();
      final hasCompletedPermissions =
          prefs.getBool('permissionCompleted') ?? false;

      if (hasCompletedPermissions) {
        final isAgree = prefs.getBool('isAgree') ?? false;
        final isTutorial = prefs.getBool('isTutorial') ?? false;

        if (isTutorial) {
          if (isAgree) {
            Get.offAllNamed('/YouAndIMain');
          } else {
            Get.offAllNamed('/Agree');
          }
        } else {
          Get.offAllNamed('/Tutorial');
        }
        return;
      }

      var status = await Permission.storage.status;
      // var status2 = await Permission.location.status;
      var status3 = await Permission.contacts.status;
      LocationPermission status4 = await Geolocator.checkPermission();

      bool isStatus3 = false;
      if(Platform.isIOS){
        isStatus3 = true;
      }else{
        isStatus3 =status3.isGranted;
      }
      
      print('${status.isGranted},${status3.isGranted},${status4},');
      if (status.isGranted && isStatus3 && status4 != LocationPermission.denied) {

        final prefs = await SharedPreferences.getInstance();

        final isT = prefs.getBool('isAgree') ?? false;
        final isT2 = prefs.getBool('isTutorial') ?? false;

        print('asdfasdfasdf:${isT}');

        print('asdfasdfasdf:${isT2}');
        // 처음 실행 한 유저
        if (prefs.getBool('isTutorial') ?? false) {
          if (prefs.getBool('isAgree') ?? false) {
            Get.offAllNamed('/YouAndIMain');
          }else{
            Get.offAllNamed('/Agree');

          }

        } else {
          Get.offAllNamed('/Tutorial');
        }
      } else {
        Get.offAllNamed('/SplashPermision');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Stack(
        children:[
          Container(
              child: Image(
                image: AssetImage('assets/images/img_splash1.png'),
                // width: 200,
                fit: BoxFit.fill,
              )
          ),
          Center(
            child: Image(
              image: AssetImage('assets/images/img_splash.png'),
              width: 200,
              fit: BoxFit.fill,
            )
          ),
          ]
      )


    );


  }
}
