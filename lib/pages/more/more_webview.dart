import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:you_and_i/controller/more_controller.dart';
import 'package:you_and_i/controller/network_picture_controller.dart';

class MoreWebview extends StatelessWidget {
  String? title = Get.arguments[0];
  String? url = Get.arguments[1];
  @override
  Widget build(BuildContext context) {

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url ?? ''));


    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          elevation: 0,
          centerTitle: true,
          title: Text(
            title.toString(),
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: true,
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              )),
        ),
        body: WebViewWidget(
          controller: controller,
        )
    );
  }
}
