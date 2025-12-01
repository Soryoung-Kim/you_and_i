import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:you_and_i/controller/friend_controller.dart';

import 'package:you_and_i/controller/main_controller.dart';
import 'package:you_and_i/controller/more_controller.dart';
import 'package:you_and_i/controller/network_picture_controller.dart';
import 'package:you_and_i/controller/recent_controlloer.dart';
import 'package:you_and_i/db/friend_db_controller.dart';
import 'package:you_and_i/db/network_db_controller.dart';
import 'package:you_and_i/pages/friend/network_detail_diagram.dart';
import 'package:you_and_i/pages/friend/network_detail_info.dart';
import 'package:you_and_i/pages/friend/network_detail_info2.dart';
import 'package:you_and_i/pages/more/more_hide_contect.dart';
import 'package:you_and_i/pages/more/more_webview.dart';
import 'package:you_and_i/pages/more/setting.dart';
import 'package:you_and_i/pages/reg_profile2.dart';
import 'package:you_and_i/pages/reg_profile_all.dart';
import 'package:you_and_i/pages/youandi/share.dart';
import 'package:you_and_i/splash_permision.dart';
import 'package:you_and_i/splash_screen.dart';
import 'agree.dart';
import 'db/more_hide_db_controller.dart';
import 'utils.langs/translations.dart';
import 'pages/tutorial.dart';
import 'package:you_and_i/controller/tutorial_controller.dart';
import 'pages/youandi/youandi_main.dart';
import 'pages/reg_profile.dart';
import 'package:you_and_i/controller/reg_profile_controller.dart';
import 'package:you_and_i/db/myinfo_db_controller.dart';
import 'package:you_and_i/util/search_address.dart';

Future main() async {
  await DotEnv.dotenv.load(fileName: ".env");
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    KakaoSdk.init(nativeAppKey: 'b8e23f7bb9505fa780fb42448ba73e06',
      // javaScriptAppKey: 'b981b6df6e7339becc62c6525f4c5415',loggingEnabled: false

    );
    runApp(
      MyApp(),
    );
  });
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('width:${ScreenUtil.defaultSize.width}');
    print('height:${ScreenUtil.defaultSize.height}');

    return
      ScreenUtilInit(
        designSize: Size(1080, 1920),
         splitScreenMode: true,
         minTextAdapt: true,
         // allowFontScaling: false,
        builder: (context , child) => GetMaterialApp(
          title: 'You&I',
          translations: Translation(),
          locale: Get.deviceLocale,
          fallbackLocale: Locale('ko', 'KR'),
          theme: ThemeData(
            primarySwatch: Colors.purple,
            // brightness: Brightness.light,
            primaryColor: Color.fromRGBO(78, 11, 157, 1.0),
            canvasColor: Colors.white,
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.purple,
            ).copyWith(
              secondary: Colors.purple[200],
              primary: Colors.purple[700],
            ),
            // fontFamily: 'Montserrat',
          ),
          home: SplashScreen(),
          builder: EasyLoading.init(),
          initialRoute: "/",
          getPages:[
            GetPage(
              name: '/Tutorial',
              page: () => Tutorial(),
              bindings: [
                BindingsBuilder(() {
                  Get.lazyPut<TutorialController>(
                      () => TutorialController());
                }),


              ],
            ),

            GetPage(
              name: '/Share',
              page: () => Share(),
              // bindings: [
              //   BindingsBuilder(() {
              //     Get.lazyPut<TutorialController>(
              //             () => TutorialController());
              //   }),
              //
              // ],
            ),
            GetPage(
              name: '/RegProfile',
              page: () => RegProfile(),
              bindings: [
                BindingsBuilder(() {
                  Get.lazyPut<RegProfileController>(
                          () => RegProfileController());

                }),
                BindingsBuilder(() {
                  Get.put(MyInfoDBController());
                }),




              ],
            ),
            GetPage(
              name: '/RegProfile2',
              page: () => RegProfile2(),
              bindings: [

                //
                // BindingsBuilder(() {
                //   Get.put(MyInfoDBController());
                // }),
                // BindingsBuilder(() {
                //   Get.lazyPut<RegProfileController>(
                //           () => RegProfileController());
                // }),

              ],
            ),GetPage(
              name: '/RegProfileAll',
              page: () => RegProfileAll(),
              bindings: [
                BindingsBuilder(() {
                  Get.lazyPut<RegProfileController>(
                          () => RegProfileController());

                }),
                BindingsBuilder(() {
                  Get.put(MyInfoDBController());
                }),




              ],
            ),
            GetPage(
              name: '/YouAndIMain',
              page: () => YouAndIMain(),
              bindings: [

                BindingsBuilder(() {
                  Get.put(FriendDBController());
                }),
                BindingsBuilder(() {
                  Get.put(NetworkDBController());
                }),
                BindingsBuilder(() {
                  Get.put(MoreHideDBController());
                }),

                BindingsBuilder(() {
                  Get.put(MyInfoDBController());
                }),
                BindingsBuilder(() {
                  Get.put(MainController());
                }),
                BindingsBuilder(() {
                  Get.put(RecentController());
                }),

                BindingsBuilder(() {
                  Get.lazyPut<MoreController>(
                          () => MoreController());
                }),
                BindingsBuilder(() {
                  Get.put(NetworkPictureController());
                }),
                BindingsBuilder(() {
                  Get.put(FriendController());
                }),

              ],
            ),
            GetPage(
              name: '/SearchAddress',
              page: () => SearchAddress(),
              // bindings: [
              //   BindingsBuilder(() {
              //     Get.lazyPut<TutorialController>(
              //             () => TutorialController());
              //   }),
              // ],
            ),
            GetPage(
              name: '/Setting',
              page: () => Setting(),
              bindings: [
                BindingsBuilder(() {
                  Get.lazyPut<MoreController>(
                          () => MoreController());
                }),
              ],
            ),
            GetPage(
              name: '/MoreHideContect',
              page: () => MoreHideContectPage(),
              bindings: [
                // BindingsBuilder(() {
                //   Get.lazyPut<NetworkDetailDiagramDBController>(
                //       () => NetworkDetailDiagramDBController());
                // }),
              ],
            ),
            GetPage(
              name: '/SplashPermision',
              page: () => SplashPermission(),
              bindings: [
                // BindingsBuilder(() {
                //   Get.lazyPut<NetworkDetailDiagramDBController>(
                //       () => NetworkDetailDiagramDBController());
                // }),
              ],
            ),
            GetPage(
              name: '/Agree',
              page: () => Agree(),
              bindings: [
                // BindingsBuilder(() {
                //   Get.lazyPut<NetworkDetailDiagramDBController>(
                //       () => NetworkDetailDiagramDBController());
                // }),
              ],
            ),
            GetPage(
              name: '/NetworkDetailDiagram',
              page: () => NetworkDetailDiagram(),
              bindings: [
                // BindingsBuilder(() {
                //   Get.lazyPut<NetworkDetailDiagramDBController>(
                //       () => NetworkDetailDiagramDBController());
                // }),
              ],
            ),
            GetPage(
              name: '/NetworkDetailInfo',
              page: () => NetworkDetailInfo(),
              // bindings: [
              //   BindingsBuilder(() {
              //     Get.lazyPut<PictureController>(() => PictureController());
              //   }),
              // ],
            ),
            GetPage(
              name: '/NetworkDetailInfo2',
              page: () => NetworkDetailInfo2(),
              // bindings: [
              //   BindingsBuilder(() {
              //     Get.lazyPut<PictureController>(() => PictureController());
              //   }),
              // ],
            ),
            GetPage(
              name: '/MoreWebview',
              page: () => MoreWebview(),
              // bindings: [
              //   BindingsBuilder(() {
              //     Get.lazyPut<PictureController>(() => PictureController());
              //   }),
              // ],
            ),

          ],



        ));
  }
}
