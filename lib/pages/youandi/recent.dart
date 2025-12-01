
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:you_and_i/controller/recent_controlloer.dart';


class Recent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final RecentController controller = Get.find<RecentController>();


    return controller.RecentWidgetMain();
  }
}
