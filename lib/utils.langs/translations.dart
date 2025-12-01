import 'package:get/get.dart';
import 'package:you_and_i/utils.langs/en.dart';
import 'package:you_and_i/utils.langs/ko.dart';


class Translation extends Translations{
  @override
  // TODO: implement keys
  Map<String, Map<String, String>> get keys => {
    'en' : en,
    'ko' : ko
  };

}