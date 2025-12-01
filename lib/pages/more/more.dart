

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controller/main_controller.dart';

class More extends StatelessWidget {
  const More({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    final MainController mainController = Get.find<MainController>();
    List<String> mainList = [
      '공지사항',
      '이벤트',
      'FAQ',
      '환경설정',
      '약관안내',
      '버전정보  v${mainController.version}',
    ];
    List<String> imageList = [
      'assets/images/notice.png',
      'assets/images/ic_more_01.png',
      'assets/images/ic_more_02.png',

      'assets/images/ic_more_04.png',
      'assets/images/ic_more_06.png',
      'assets/images/ic_more_05.png',
    ];
    return ListView.separated(
      itemCount: mainList.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          onTap: () {
            print(index);
            if(index == 0){
              Get.toNamed('/MoreWebview',
                arguments: ['공지사항','https://woori42.net/notice']);

            }else if(index == 1){
              Get.toNamed('/MoreWebview',
                  arguments: ['이벤트','https://woori42.net/event']);
            }else if(index == 2){
              Get.toNamed('/MoreWebview',
                  arguments: ['FAQ','https://woori42.net/bbs']
              );
            }
            else if(index == 3){
              Get.toNamed('/Setting');
            }
            else if(index == 4){
              Get.toNamed('/MoreWebview',
                  arguments: ['약관안내','https://woori42.net/policy.html']
              );
            }

            // else if(index == 5){
            //   Get.toNamed('/MoreWebview',
            //       arguments: ['버전정보','https://naver.com']
            //   );
            // }

          },
          title: Container(
            alignment: Alignment.centerLeft,
            height: 50,
            child: Row(
              children: [
                SizedBox(
                  width: 30.w,
                ),
                Image(
                  image: AssetImage(imageList[index]),
                  color: Colors.black,
                  width: 70.w,
                  fit: BoxFit.fill,
                ),
                SizedBox(
                  width: 40.w,
                ),
                Text(
                  mainList[index],
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 50.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      }, separatorBuilder: (BuildContext context, int index) { return Divider(thickness: 1); },);
  }
}
