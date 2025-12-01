// import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'dart:core';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:you_and_i/controller/tutorial_controller.dart';
class Tutorial extends StatefulWidget {
  @override
  _TutorialState createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> with TickerProviderStateMixin {
  final controller = PageController(viewportFraction: 0.8, keepPage: true);
  final tutorialController = Get.find<TutorialController>();

  @override
  void initState() {

    super.initState();
  }

  renderButton(){
    return OutlinedButton(onPressed: (){

       controller.nextPage(duration: Duration(milliseconds: 500),curve:Curves.ease);

       // tutorialController.index(controller.page);
    },
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).primaryColor,
          textStyle: TextStyle(
            fontSize: 60.sp,
          ),

          padding: EdgeInsets.all(0),
          side: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
          fixedSize: Size(
            350,65
          ),
          shape: StadiumBorder(),
        ),
        child: Text('다음',style: TextStyle(
          fontSize: 50.sp,
        )));
  }
  renderButtonStart()  {
    return OutlinedButton(onPressed: () async{
      //메인 페이지로 이동
      final prefs = await SharedPreferences.getInstance();

      if (prefs.getBool('isAgree') ?? false) {
        Get.offAllNamed('/RegProfile');
      }else{
        Get.offAllNamed('/Agree');

      }
    },
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).primaryColor,
          textStyle: TextStyle(
            fontSize: 60.sp,
          ),

          padding: EdgeInsets.all(0),
          side: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
          backgroundColor: Theme.of(context).primaryColor,
          fixedSize: Size(
              350,65
          ),
          shape: StadiumBorder(),
        ),
        child: Text('서비스 시작하기',
        style:  TextStyle(
          color: Colors.white,
          // fontWeight: FontWeight.bold,
          fontSize: 50.sp,
        ),),);
  }
  @override
  Widget build(BuildContext context) {


    final pages = List.generate(3, (index) {
      // tutorialController.index(index);
      var text = '';
      var imageName ='';
      if(index == 0){
        text = '인맥연결을 쉽게';
        imageName ='assets/images/img_guide_01.png';
      }else if(index == 1){
        text = '꾹 누르면 친구로 등록';
        imageName ='assets/images/img_guide_02.png';
      }else if(index == 2){
        text = '나랑 연결된 인맥은 몇명';
        imageName ='assets/images/img_guide_03.png';
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [


          Center(
              child: Image(
                image: AssetImage(imageName),
                width: 500.h,
                fit: BoxFit.fill,
              )
          ),
          SizedBox(
            height: 100.h,
          ),
          Text(
            text,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 50.sp,
            ),
          )
          ,
        ],
      );
    }

    );
    return Scaffold(

      body: SafeArea(
        child:  Padding(
          padding: EdgeInsets.only(top: 20.h,bottom: 20.h),
          child: Container(

            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Center(

                  child: Text(
                    '우리사이',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 60.sp,
                    ),
                  ),
                )),Expanded(
                  flex: 6,
                  child:

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: [
                          SizedBox(height: 800.h,

                            child:
                            PageView.builder(
                              controller: controller,
                              itemCount: pages.length,
                              onPageChanged: (index){

                                tutorialController.index(index);
                              },
                              itemBuilder: (_, index) {
                                return pages[index % pages.length];
                              },
                            )
                          ),
                          Padding(
                            padding:  EdgeInsets.only(top: 24.h, bottom: 12.h),

                          ),
                          SmoothPageIndicator(

                            controller: controller,
                            count: pages.length,
                            effect: WormEffect(
                              dotHeight: 12,
                              dotWidth: 12,
                              activeDotColor: Colors.black,

                              // type: WormType.thin,
                              // strokeWidth: 5,
                            ),
                          ),
                        ],
                      )
                  ),

                Expanded(child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [

                    Obx((){

                      if(tutorialController.index!=2){
                        return renderButton();
                      }else{
                        return renderButtonStart();
                      }

                    })

                  ],
                ),
                )
              ],
            ),
          ),
        ),
      )

    ) ;


  }


}
