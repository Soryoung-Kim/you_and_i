import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:you_and_i/db/myinfo_db_controller.dart';

import 'dart:io' as Io;

import 'package:image/image.dart' as Image;

import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:permission_handler/permission_handler.dart';
class RegProfileController extends GetxController {


  var nameController = TextEditingController();
  var phoneController = TextEditingController();

  var companyController = TextEditingController();
  var positionController = TextEditingController();
  var telController = TextEditingController();
  var emailController = TextEditingController();
  var homepageController = TextEditingController();

  var addressSearchController = TextEditingController();
  var addressController = TextEditingController();
  var addressController2 = TextEditingController();
  var memoController = TextEditingController();

  RxString title = ''.obs;

  RxString background = ''.obs;
  RxString name = ''.obs;
  RxString phone = ''.obs;

  RxString company = ''.obs;
  RxString position = ''.obs;
  RxString tel = ''.obs;
  RxString email = ''.obs;
  RxString homepage = ''.obs;
  RxString addressSearch = ''.obs;
  RxString address = ''.obs;
  RxString address2 = ''.obs;
  RxString memo = ''.obs;
  RxString picture = ''.obs;
  RxBool isFirst = true.obs;


  final ImagePicker _picker = ImagePicker();

  final MyInfoDBController controller = Get.find<MyInfoDBController>();


  @override
  void onInit() {
    super.onInit();

    firstCheck();
    print('position : ${name}');
  }

  void firstCheck() async {
    Future.delayed(Duration(milliseconds: 100), () async {
      if (background.value == '') {
        background('d0d0d0');
      }
      final prefs = await SharedPreferences.getInstance();
      final isT = prefs.getBool('isTutorial') ?? false;
      print('asdfasdfasdf:${isT}');
      // 처음 실행 한 유저
      if (!(prefs.getBool('isTutorial') ?? false)) {
        isFirst(true);
        title('프로필을 등록하세요.');
      } else {
        isFirst(false);
        title('프로필 수정');
        nameController.text = controller.name.value;
        phoneController.text = controller.phone.value;
        companyController.text = controller.company.value;
        positionController.text = controller.position.value;
        telController.text = controller.tel.value;
        emailController.text = controller.email.value;
        homepageController.text = controller.homepage.value;

        addressController.text = controller.address.value;
        addressController2.text = controller.address2.value;
        background.value = controller.background.value;
        picture.value = controller.picture.value;

        // Get.offAllNamed('/YouAndIMain');
      }
    });
  }

  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    companyController.dispose();
    telController.dispose();
    emailController.dispose();
    homepageController.dispose();
    addressSearchController.dispose();
    addressController.dispose();
    addressController2.dispose();
    memoController.dispose();

    controller.initDB();
    super.onClose();
  }

  void textFieldlatestValue() {
    print("Name Text field: ${nameController.text}");
    // dbInsert();
  }

  Future<void> _storagePermision() async {
    var status = await Permission.storage.request();
    if (status.isDenied) {
      return Future.error('Storage permissions are denied ');
    }
  }

  Future<void> _cameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isDenied) {
      return Future.error('Camera permissions are denied ');
    }
  }

  void openProfileImageSelect(ImageSource source) async {
    //await _storagePermision();

    if (source == ImageSource.camera) {
      await _cameraPermission();
    }

    try {
      final pickedFile = await _picker.getImage(
          source: source, maxWidth: 500, maxHeight: 1000);

      var resizeImage = Image.decodeImage(await pickedFile!.readAsBytes());


      var ext = p.extension(pickedFile.path);

      var baseName = p.basename(pickedFile.path);

      Io.Directory? saveDir;
      if (GetPlatform.isAndroid) {
        saveDir = await getExternalStorageDirectory();
      } else {
        saveDir = await getApplicationSupportDirectory();
      }
      var saveFile = Io.File('${saveDir!.path}/$baseName');

      List<int>? binary;

      if (ext == '.png') {
        binary = Image.encodePng(resizeImage!);
      } else if (ext == '.jpg' || ext == '.jpeg') {
        binary = Image.encodeJpg(resizeImage!);
      }
      saveFile.writeAsBytes(binary!);

      // print('save file: ${saveFile.path}');
      // print('save file size: ${image.getBytes().length}');
      // var exists = await saveFile.exists();
      // print('save file exists: $exists');
      picture(saveFile.path);
      await controller.updateProfileImage(saveFile.path);
    } catch (e) {
      print(e);
    }

    // var result = await FilePicker.platform
    //     .pickFiles(type: FileType.image, allowMultiple: false);
    // if (result != null && result.count > 0) {
    //   _progressDialog.showProgressDialog(Get.context);
    //   var file = result.files[0];
    //   // print('select file : ${file.path}');
    //   var image = Image.decodeImage(Io.File(file.path).readAsBytesSync());
    //   // print('select file size : ${image.getBytes().length}');

    //   var resizeImage = Image.copyResize(image, width: 500);
    //   Io.Directory saveDir;
    //   if (GetPlatform.isAndroid) {
    //     saveDir = await getExternalStorageDirectory();
    //   } else {
    //     saveDir = await getApplicationDocumentsDirectory();
    //   }
    //   var saveFile = Io.File('${saveDir.path}/${file.name}');

    //   List<int> binary;
    //   if (file.extension == 'png') {
    //     binary = Image.encodePng(resizeImage);
    //   } else if (file.extension == 'jpg' || file.extension == 'jpeg') {
    //     binary = Image.encodeJpg(resizeImage);
    //   }
    //   saveFile.writeAsBytes(binary);

    //   // print('save file: ${saveFile.path}');
    //   // print('save file size: ${image.getBytes().length}');
    //   // var exists = await saveFile.exists();
    //   // print('save file exists: $exists');

    //   await controller.updateProfileImage(saveFile.path);
    //   picture(saveFile.path);

    //   _progressDialog.dismissProgressDialog(Get.context);
    // }
  }

  Future<void> dbInsert() async {
    final fido = MyInfo(
        id: 0,
        name: nameController.text,
        background: background.value,
        picture: picture.value,
        company: companyController.text,
        position: positionController.text,
        phone: phoneController.text,
        tel: telController.text,
        email: emailController.text,
        homepage: homepageController.text,
        address: addressController.text,
        address2: addressController2.text,
        memo: memoController.text);

    await controller.insertMyInfo(fido);
  }

  Color fromHex() {
    print(background.value.length);
    final buffer = StringBuffer();
    if (background.value.length == 6 || background.value.length == 7) buffer
        .write('ff');
    buffer.write(background.value.replaceFirst('0xff', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }


  void changeColorPress(color) {
    print('changeColorPress');

    final palette = [
      'd0d0d0',
      '676767',
      '383838',
      'd5e5f2',
      '168edb',
      '005d9c',
      'd7dcf5',
      '4c5dd3',
      '202e7f',
      'e5dcfa',
      '643db0',
      '412979',
      'ebd7f0',
      '943fab',
      '632275',
      'f2dfe5',
      'f2dfe5',
      'd7457b'
    ];

    Color? resolvedColor;

    if (color is Color) {
      resolvedColor = color;
    } else {
      var converted = color.toString().replaceAll('0xff', '');
      converted = converted.replaceAll('(', '');
      converted = converted.replaceAll(')', '');
      converted = converted.replaceAll('Color', '');
      converted = converted.toLowerCase();

      if (converted.length == 6) {
        resolvedColor = Color(int.parse('0xff$converted'));
      }
    }

    if (resolvedColor == null) {
      return;
    }

    final normalizedHex = resolvedColor.value.toRadixString(16).substring(2);
    if (palette.contains(normalizedHex)) {
      background(normalizedHex);
      return;
    }

    String? nearestHex;
    int? nearestDistance;

    for (final hex in palette) {
      final paletteColor = Color(int.parse('0xff$hex'));
      final distance = _colorDistance(resolvedColor!, paletteColor);

      if (nearestDistance == null || distance < nearestDistance) {
        nearestDistance = distance;
        nearestHex = hex;
      }

      if (nearestHex != null) {
        background(nearestHex);
      }
    }
  }

  int _colorDistance(Color a, Color b) {
    final rDiff = (a.r * 255.0).round().clamp(0, 255) -
        (b.r * 255.0).round().clamp(0, 255);
    ;
    final gDiff = (a.g * 255.0).round().clamp(0, 255) -
        (b.g * 255.0).round().clamp(0, 255);
    final bDiff = (a.b * 255.0).round().clamp(0, 255) -
        (b.b * 255.0).round().clamp(0, 255);

    return rDiff * rDiff + gDiff * gDiff + bDiff * bDiff;
  }

}