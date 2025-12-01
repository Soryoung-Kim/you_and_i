import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
class MoreController extends GetxController {
  // RxInt index = 0.obs;
  RxBool isPush  = true.obs;
  @override
  void onInit() {
    super.onInit();

  }

  void onClose() {

  }
  void pushSwichChange(value){
    isPush(value);
  }
}