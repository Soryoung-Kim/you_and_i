
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';


class Agree extends StatefulWidget {
  @override
  _AgreeState createState() => _AgreeState();
}

class _AgreeState extends State<Agree> {
//  AudioCache player = AudioCache(prefix: 'assets/sounds/');
  void initState() {
    super.initState();
  }

  Future<void> requestAgree() async {
    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainRoot()));

    // final prefs = await SharedPreferences.getInstance();
    // if (!(prefs.getBool('isFirst') ?? false)) {
    //   Get.offAllNamed('/Tutorial');
    // }else{
    //   Get.offAllNamed('/YouAndI');
    //
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(0),
            color: Colors.white,
            child:Align(
                alignment: FractionalOffset.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  height: 120.h,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20.h),
                    child :TextButton(
                      child: Text(
                        '동의하고 시작하기',
                        style: TextStyle(
                          fontSize: 60.sp,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor, // foreground
                      ),
                      onPressed: () async {
                        await requestAgree();

                        final prefs = await SharedPreferences.getInstance();
                        prefs.setBool('isAgree', true);

                        Get.offAllNamed('/RegProfile');
                      },
                    ),
                  )
              ),
            ),
            // decoration: BoxDecoration(color: Colors.black,),
          ),
          Column(
            children: [
              const SizedBox(
                height: 80,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      '이용약관에 동의하고\n지금바로 시작하기',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 70.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]),
              const SizedBox(
                height: 30,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      '서비스 이용약관(필수)',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 55.sp,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton(
                      child: Text(
                        '자세히 보기',
                        style: TextStyle(
                          fontSize: 60.sp,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor, // foreground
                      ),
                      onPressed: () async {
                        Get.toNamed('/MoreWebview',
                            arguments: ['약관안내','https://woori42.net/policy.html']
                        );

                      },
                    ),
                  ]),

            ],
          ),
        ],
      ),
    );
  }
}
