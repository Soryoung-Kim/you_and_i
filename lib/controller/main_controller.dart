import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:yaml/yaml.dart';
import 'package:you_and_i/db/friend_db_controller.dart';
import 'package:you_and_i/db/more_hide_db_controller.dart';
import 'package:you_and_i/db/network_db_controller.dart';

import '../db/myinfo_db_controller.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io' as Io;
import 'dart:typed_data';
import '../util/webrtc.dart';
import 'package:queue/queue.dart';
import 'package:path/path.dart' as p;

import 'package:flutter_easyloading/flutter_easyloading.dart';

enum ConnectType { RTC, SOCKET }

enum RtcFileType { Profile, Attach }

class FileInfo {
  int size = 0;
  String fileName = '';
  RtcFileType type = RtcFileType.Profile;
  String? sender = '';
  BytesBuilder bytesBuilder = Io.BytesBuilder();

  FileInfo(
      {required this.size,
      required this.fileName,
      required this.type,
      this.sender});

  void clear() {
    bytesBuilder.clear();
  }
}

class MainController extends GetxController {
  RxString appBarTitle = '우리사이'.obs;

  final _rtcCmdReady = 'imready:';
  final _rtcCmdProfile = 'profile:';
  final _rtcCmdProfileImage = 'profileImage:';
  final _rtcCmdContact = 'contact:';
  final _rtcCmdConfirm = 'confirm:';
  final _rtcCmdCancel = 'cancel:';
  final _rtcCmdSendFile = 'sendfile:';
  RxInt mainTabIndex = 0.obs; //바텀 메인네이게이션
  RxInt shareCount = 0.obs; //바텀 메인네이게이션
  RxBool connectButtonPress = false.obs; //커넥트 버튼 눌림여부
  final MyInfoDBController myinfoDbController = Get.find<MyInfoDBController>();
  final FriendDBController friendDbController = Get.find<FriendDBController>();
  final MoreHideDBController moreHideDBController =
      Get.find<MoreHideDBController>();
  final NetworkDBController networkDBController =
  Get.find<NetworkDBController>();


  IO.Socket? _socket;
  String? _url = dotenv.env['MATCHING_SERVER'];
  DataChannelController? _dataChannelController;
  UserType? _rctUserType;
  RxBool dataChannelReady = false.obs;
  RxString externalPath = ''.obs;
  RxString version = ''.obs;

  // StreamSubscription<Position>? _positionStream;
  Position? position;
  RxBool myDataConfirm = false.obs;
  RxBool otherDataConfirm = false.obs;
  RxBool otherCompanyInfo = false.obs;

  RxBool optionCheck = false.obs;

  RxBool isCompanyInfo = false.obs; //회사 정보 공유 체크박스
  Map? _receiveData;

  var _fileQueue = Queue();
  String? _roomId;
  RxString latitude = ''.obs;
  RxString longitude = ''.obs;

  Timer? _notFoundTimer;
  Timer? _messageTimer;

  FileInfo? fileInfo;
  Iterable<Contact>? contacts;
  var myContacts;

  @override
  void onInit() {
    super.onInit();
    _startSocketEvent();
    _preferencesSetting();
    _startFindLocation();
    _init();
    initContacts();


    print('position : ${position}');
  }

  Future<void> _startFindLocation() async {
    position = await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    print('position : ${position}');
    latitude(position!.latitude.toString());
    longitude(position!.longitude.toString());
  }

  _startSocketEvent() {
    _socket = IO.io(
        _url,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableForceNewConnection()
            .build());

    _socket!.onConnect((_) {
      //연결 가능
      // _messageTypeChange(MessageType.ABLE);
      print('connect matching server');

      shareCount(friendDbController.list.length);
    });
    _socket!.onConnectError((error) {
      //에러
      // _messageTypeChange(MessageType.ERROR);
      print(error);
      print('connect error matching server');
    });

    _socket!.onDisconnect((_) {
      print('disconnect matching server');
    });

    _socket!.on('matched', (data) async {
      // if (messageType.value != MessageType.FIND_OK.index) return;

      // _progressDialog.showProgressDialog(Get.context,
      //     textToBeDisplayed: "p2pconnectMsg".tr,
      //     dismissAfter: Duration(seconds: 30));
      await showProgress('연결 중');
      Future.delayed(Duration(seconds: 1), () async {
        await rtcReset(); // 매칭이되면 그전에 연결된것은 초기화하고 다시 가자.
        _roomId = data['room'];
        String type = data['type'];
        print('matched $_roomId , $type');
        _runRTC(_roomId!, type);
      });

    });

    _socket!.on('filere', (data) async {
      print(data);
    });
  }

  Future<void> rtcReset() async {
    otherDataConfirm(false);
    myDataConfirm(false);
    _receiveData = null;
    hideProgress();
    if (_dataChannelController != null) {
      await _dataChannelController!.dispose();
      _dataChannelController = null;
    }
  }

  Future<bool> showProgress(String msg) async {
    await EasyLoading.show(status: msg, maskType: EasyLoadingMaskType.black);
    return true;
  }

  Future<bool> hideProgress() async {
    await EasyLoading.dismiss();
    // await EasyLoading.showToast('연결 되었습니다.');
    return false;
  }

  void _init() async {
    Io.Directory? dir;
    if (GetPlatform.isAndroid) {
      dir = await getExternalStorageDirectory();
    } else {
      dir = await getApplicationSupportDirectory();
    }
    externalPath(dir?.path);

    rootBundle.loadString("pubspec.yaml").then((yamlValue) {
      var yaml = loadYaml(yamlValue);
      version(yaml['version']) ;

      print(version); //pubspec.yaml 파일에 버전값
    });

  }
  /*
  void initContacts() async{
    await showProgress('데이터 로딩 중...');

    Future.delayed(Duration(seconds: 1), () async {
      contacts =
      await ContactsService.getContacts(withThumbnails: false);
      myContacts = contacts!
          .map((e) => {
        'picture' : e.avatar,
        'name': e.displayName,
        'phone': e.phones!.length > 0 ? e.phones!.first.value!.replaceAll('-', '').replaceAll('+82', '0') : '',
        'company':  e.company != null ? e.company : '',
        'tel': e.phones!.length > 1 ? e.phones!.last.value : '',
        'position': e.jobTitle != null ? e.jobTitle : '' ,
        'email': e.emails!.length > 0 ? e.emails!.first.value : '',
        'address': e.postalAddresses!.length > 0 ? '${e.postalAddresses!.first.city } ${e.postalAddresses!.first.country } ${e.postalAddresses!.first.street }'.replaceAll('null ', '')  : '',
      })
          .where((e) =>
      !GetUtils.isNullOrBlank(e['name'])! &&
          !GetUtils.isNullOrBlank(e['phone'])!)
          .toList();


      Future.delayed(Duration(seconds: 1), () async {
        await hideProgress();
      });

    });




  }
   */

  Future<void> initContacts() async {
    await showProgress('데이터 로딩 중...');

    // 권한 요청 (이미 다른 곳에서 하고 있다면 이 부분은 빼셔도 됩니다)
    final granted = await FlutterContacts.requestPermission();
    if (!granted) {
      await hideProgress();
      return;
    }

    Future.delayed(const Duration(seconds: 1), () async {
      // withProperties: true → 전화번호, 이메일, 주소, 회사 등 상세 정보 포함
      // withPhoto: true → 사진/썸네일까지 같이 가져오기 (용량이 크면 false 로 바꾸세요)
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      myContacts = contacts
          .map((e) {
        // 회사/직책
        final org = e.organizations.isNotEmpty ? e.organizations.first : null;
        final company = org?.company ?? '';
        final position = org?.title ?? '';

        // 전화번호들
        final hasPhones = e.phones.isNotEmpty;
        final mainPhone = hasPhones ? e.phones.first.number : '';
        final subPhone = e.phones.length > 1 ? e.phones.last.number : '';

        // 이메일
        final email = e.emails.isNotEmpty ? e.emails.first.address : '';

        // 주소
        final addr = e.addresses.isNotEmpty ? e.addresses.first : null;
        final addressRaw = addr != null
            ? '${addr.city} ${addr.country} ${addr.street}'
            : '';
        final address = addressRaw.replaceAll('null ', '');

        return {
          'picture' : e.photo, // 또는 e.thumbnail
          'name'    : e.displayName,
          'phone'   : mainPhone
              .replaceAll('-', '')
              .replaceAll('+82', '0'),
          'company' : company,
          'tel'     : subPhone,
          'position': position,
          'email'   : email,
          'address' : address,
        };
      })
          .where((e) =>
      !GetUtils.isNullOrBlank(e['name'])! &&
          !GetUtils.isNullOrBlank(e['phone'])!)
          .toList();

      Future.delayed(const Duration(seconds: 1), () async {
        await hideProgress();
      });
    });
  }

  void _preferencesSetting() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setBool('isTutorial', true);

    // 처음 실행 한 유저
    if (!(prefs.getBool('isFirst') ?? false)) {
      prefs.setBool('isCompanyInfo', isCompanyInfo.value);
      prefs.setBool('isFirst', true);
    } else {
      isCompanyInfo(prefs.getBool('isCompanyInfo'));
    }
  }

  Future<void> _receiveContact(Map<String, dynamic> data) async {
    // await showProgress('인맥 매칭 중...');



    final logger = Logger();

    // logger.d(myContacts);
    // List<Map> insertData = [];
    var senderPhone = data['myinfo']['phone'];
    var senderName = data['myinfo']['name'];

    //  기존 데이터 삭제
    await networkDBController.deleteNetwork(senderPhone);


    var contactData = data['contacts'];
    //
    print(contactData);
    for (var data in contactData) {
      var filter = myContacts.where((element) =>
      element['phone'] == data['phone'].replaceAll('-', '').replaceAll('+82', '0') );
      if (filter.length > 0) {
        // insertData.add(data);
        var matchData = filter.first;
        // print('matchData, $matchData');


        await networkDBController.insertNetwork(Network(
          networkid: senderPhone,
          picture: matchData['picture'].toString(),
          name:  matchData['name'].toString(),
          phone:  matchData['phone'].toString(),
          company:  matchData['company'].toString(),
          position:  matchData['position'].toString(),
          tel:  matchData['tel'].toString(),
          email:  matchData['email'].toString(),
          address:  matchData['address'].toString()
        ));
      }
    }

    await networkDBController.deleteNetwork3(senderPhone);


    shareCount(friendDbController.list.length);

    await networkDBController.networks();
    await friendDbController.friends();
    await friendDbController.friendRecent();
    await hideProgress();
    Future.delayed(const Duration(seconds: 1), () async {
      Get.snackbar(
        '알림',
        '인맥이 공유에 성공하였습니다.',
        backgroundColor: Colors.black.withAlpha(150),
        colorText: Colors.white,
      );
    });


  }

  void _runRTC(final String roomId, String type) {
    _rctUserType = type == 'a' ? UserType.broadcaster : UserType.watcher;
    _dataChannelController = DataChannelController(_rctUserType!, roomId);
    _dataChannelController!.onLog = (text) => print('rtc log : $text');

    var peerSocket = _dataChannelController!.socket;

    // Future.delayed(Duration(seconds: 5), () {
    peerSocketInit(roomId, peerSocket);

    // });
    return;
    _dataChannelController!.onDataChannelConnected = (dataChannel) async {
      await hideProgress();
      print('data channel connected!');
      if (_rctUserType == UserType.watcher) {
        _dataChannelController!.sendMessage(_rtcCmdReady);
        // dataChannelReady(true);
        _sendProfile();
      }
      _dataChannelController!.sendMessage('hi!!!!! bang ga bang ga. ');
    };

    _dataChannelController!.onTimeout = (peerSocket, room) async {
      peerSocketInit(room, peerSocket);
      print('onTimeout!');
    };
    _dataChannelController!.onMessage = (dataChannelMessage) async {
      print('dataChannelMessage');
      // if (dataChannelMessage.text.startsWith('pattern')
      if (!dataChannelMessage.isBinary) {
        print('on message ${dataChannelMessage.text}');
        if (dataChannelMessage.text == _rtcCmdReady) {
          // var body = dataChannelMessage.text.split(_rtcCmdReady)[1];
          // if (tabIndex.value != int.parse(body)) return; // 공유 타입이 같을때 작동
          // 데이터 채널 준비
          _sendProfile();
        } else if (dataChannelMessage.text.startsWith(_rtcCmdProfile)) {
          // 상태방 프로필 정보 수신.
          print(dataChannelMessage.text);
          var body = dataChannelMessage.text.split(_rtcCmdProfile)[1];
          _receiveData = jsonDecode(body);
          // _messageTypeChange(MessageType.SUCCESS);
          _asyncConfirmDialog(Get.context!,
              name: _receiveData!['name'], phone: _receiveData!['phone']);
        } else if (dataChannelMessage.text == _rtcCmdConfirm) {
          otherDataConfirm(true);
          _dataConfirmCheck();
        } else if (dataChannelMessage.text.startsWith(_rtcCmdCancel)) {
          // _messageTypeChange(MessageType.ABLE);
          otherDataConfirm(false);
        } else if (dataChannelMessage.text.startsWith(_rtcCmdProfileImage)) {
          var datas = dataChannelMessage.text.split(':');
          await _receiveFileInfo(
              datas[2], int.parse(datas[3]), RtcFileType.Profile,
              sender: datas[1]);
        } else if (dataChannelMessage.text.startsWith(_rtcCmdSendFile)) {
          var body = dataChannelMessage.text.split(_rtcCmdSendFile)[1];
          var data = json.decode(body);
          await _receiveFileInfo(
              data['filename'], data['size'], RtcFileType.Attach);
        } else if (dataChannelMessage.text.startsWith(_rtcCmdContact)) {
          // if (!isChip[2].value) return; // 상대방이 데이터를 보냈더라도 내 설정이 꺼져있으면 작동안함.TODO
          var body = dataChannelMessage.text.split(_rtcCmdContact)[1];
          var data = json.decode(body);
          print(data);
          await _receiveContact(data);
        }
      } else {
        if (fileInfo == null) return;
        print('get binary! ${dataChannelMessage.binary.length}');
        fileInfo!.bytesBuilder.add(dataChannelMessage.binary);
        if (fileInfo!.size == fileInfo!.bytesBuilder.length) {
          // await _fileCompleteSave();
        }
      }
    };

    // Future.delayed(Duration(seconds: 5), () {
    //   print(
    //       'check : fail proc~ ${_roomId != roomId}, ${_dataChannelController.isChannelConnected}   if false, false run!');
    //   if (_roomId != roomId) return;
    //   if (_dataChannelController.isChannelConnected) return;

    //   print('fail proc run!!!!!!');

    //   _dataChannelController.clearCallback();

    //   var peerSocket = _dataChannelController.socket;
    //   peerSocketInit(roomId, peerSocket);
    // });
  }

  void _dataConfirmCheck({IO.Socket? peerSocket, String? room}) async {


  print(
        '_dataConfirmCheck : ${myDataConfirm.value}, ${otherDataConfirm.value},${otherCompanyInfo}');
    if (myDataConfirm.value && otherDataConfirm.value) {

      if (!otherCompanyInfo.value) {
        _receiveData!['company'] = '';
        _receiveData!['position'] = '';
        _receiveData!['tel'] = '';
        _receiveData!['email'] = '';
        _receiveData!['homepage'] = '';
        _receiveData!['address'] = '';
        _receiveData!['address2'] = '';
      }
      await friendDbController.insertFriend(Friend(
          id: _receiveData!['phone'],
          picture: _receiveData!['picture'],
          background: _receiveData!['background'],
          name: _receiveData!['name'],
          phone: _receiveData!['phone'],
          company: _receiveData!['company'],
          position: _receiveData!['position'],
          tel: _receiveData!['tel'],
          email: _receiveData!['email'],
          homepage: _receiveData!['homepage'],
          address: _receiveData!['address'],
          address2: _receiveData!['address2'],
          memo: _receiveData!['memo']));

      await _sendExtraProfile(peerSocket: peerSocket, room: room);

      shareCount(friendDbController.list.length);
      // _messageTypeChange(MessageType.ABLE);
    }
  }
  Future<void> contactNetwork(IO.Socket? peerSocket, String? room) async{
    // await showProgress('인맥 찾는 중..');
    var myinfo = (await myinfoDbController.myInfo())[0];
    print("*********************3******************************");

    // Iterable<Contact> contacts =
    //     await ContactsService.getContacts(withThumbnails: false);
    print("*********************4******************************");
    var list = contacts!
        .map((e) => {
              'name': e.displayName,
              'phone': e.phones!.length > 0 ? e.phones!.first.number : ''
            })
        .where((e) =>
            !GetUtils.isNullOrBlank(e['name'])! &&
            !GetUtils.isNullOrBlank(e['phone'])!)
        .toList();
    //연락처 숨김 list에서 삭제
    Logger().e(list);
    print("********************* 연락처 숨김 기능  ******************************");
    await moreHideDBController.moreHides();
    for (var ele in moreHideDBController.list.value) {
      print("*********************${ele.toMap()}******************************");
      list.removeWhere((element) =>
          element['phone'].toString().replaceAll('-', '').replaceAll('+82', '0') ==
          ele.phone.replaceAll('-', '').replaceAll('+82', '0'));
    }
    print("*********************6******************************");
    var sendData = {
      'room':room,
      'myinfo': {'name': myinfo.name, 'phone': myinfo.phone},
      'contacts': list,

    };
    print("*********************7******************************${sendData}");
    print(peerSocket!.active);
    if (peerSocket != null) {
      print(peerSocket.active);
      peerSocket.emit('data-contact', sendData);
    }

    print("*********************8******************************");

    print("*********************9******************************");

    // await hideProgress();
  }
  //TODO 데이터 전송~~~
  Future<void> _sendExtraProfile({IO.Socket? peerSocket, String? room}) async {
    try {
      await showProgress('프로필 전송 중..');
      Future.delayed(Duration(seconds: 1), () async {
        print("*********************1******************************");
        await contactNetwork(peerSocket, room);

        var myinfo = (await myinfoDbController.myInfo())[0];
        print('@@@@@@@@@@@@@@@@@'
            ''+myinfo.picture.toString());
        var file = Io.File(myinfo.picture.toString());
        var fileExists = await file.exists();
        int fileSize = 0;
        const int chunkSize = 1024 * 100;
        Uint8List? binary;

        print("*********************2******************************:${fileExists}");
        if (fileExists) {
          binary = await file.readAsBytes();
          fileSize = binary.length;
          // var loopCnt = (fileSize / chunkSize).ceil();
          // porgressCounter += loopCnt;
        }

        if (fileExists) {
          var fileName = '${myinfo.phone}${p.extension(file.path)}';
          print(fileName);
          if (peerSocket == null) {
            _dataChannelController!.sendMessage(
                '$_rtcCmdProfileImage${myinfo.phone}:$fileName:$fileSize');
          }

          int currenIndex = 0;
          print("*********************9******************************");
          do {
            var sendData = {};
            if (peerSocket != null && currenIndex == 0) {
              sendData['fileName'] = fileName;
              sendData['fileSize'] = fileSize;
              sendData['sender'] = myinfo.phone;
              sendData['type'] = RtcFileType.Profile.index;
            }
            var end = min(fileSize, currenIndex + chunkSize);
            var chunk = binary!.sublist(currenIndex, end);

            print('total $fileSize , start $currenIndex, end $end');
            currenIndex = end;
            if (peerSocket != null) {
              sendData['room'] = room;
              sendData['binary'] = chunk;
              peerSocket.emit('data-binary', sendData);


            }
            print("*********************10******************************");


            // counter++;
            // _pd.update(value: counter);
          } while (currenIndex < fileSize);
          print("*********************11******************************");
        }
      });



    } catch (e) {
      print("*********************12******************************");
      Get.snackbar(
        '전송이 되지 않았습니다. 다시 시도해주세요',
        e.toString(),
        backgroundColor: Colors.black.withAlpha(150),
        colorText: Colors.white,
      );
      print("*********************13******************************");
    } finally {
      print("*********************14******************************");


      print("*********************15******************************");

    }
  }

  Future<void> _receiveFileInfo(String fileName, int size, RtcFileType type,
      {String? sender = ''}) async {
    // if (_progressDialog.isDismissed) {
    //   _progressDialog.showProgressDialog(Get.context,
    //       textToBeDisplayed: "p2pDataSendMsg".tr,
    //       dismissAfter: Duration(seconds: 30));
    // }

    // var body = dataChannelMessage.text.split(_rtcCmdSendFile)[1];
    // var data = json.decode(body);
    // print(data);

    print('!!!!!!!!!!!!!!!!!!!!!!!!!!! fileName: $fileName, size: $size, type: ${type.toString()}');

    fileInfo =
        FileInfo(sender: sender, fileName: fileName, size: size, type: type);
    Io.Directory? dir;
    if (GetPlatform.isAndroid) {
      dir = await getExternalStorageDirectory();
    } else {
      dir = await getApplicationSupportDirectory();
    }
    var saveFile = Io.File('${dir!.path}/${fileInfo!.fileName}');
    print('saveFile : ${saveFile.path}');
    if (await saveFile.exists()) {
      saveFile.deleteSync();
    }
  }

  void _sendProfile({IO.Socket? peerSocket, String? room}) async {
    // if (_dataLock) return;
    // _dataLock = true;
    var myinfo = (await myinfoDbController.myInfo())[0];

    var sendData = myinfo.toMap();

    // if (!isCompanyInfo.value) {
    //   sendData['company'] = '';
    //   sendData['position'] = '';
    //   sendData['tel'] = '';
    //   sendData['email'] = '';
    //   sendData['homepage'] = '';
    //   sendData['address'] = '';
    //   sendData['address2'] = '';
    //   sendData['company'] = '';
    // }

    if (peerSocket != null) {

      sendData['room'] = room;
      peerSocket.emit('data-profile', sendData);
    }
    // else {
    //   var strJson = jsonEncode(sendData);
    //   _dataChannelController!.sendMessage('$_rtcCmdProfile$strJson');
    // }
    // _dataLock = false;
  }

  Future<void> _asyncConfirmDialog(BuildContext context,
      {String? phone,
      String? name,
      IO.Socket? peerSocket,
      String? room}) async {
    // _progressDialog.dismissProgressDialog(context);
    // await hideProgress();

    if (_notFoundTimer != null) _notFoundTimer!.cancel();
    // _messageTypeChange(MessageType.FIND_OK);

    return showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            // title: Text("Delete File"),
            title: Text("연결하기"),
            content: Column(
              children: [
                SizedBox(
                  height: 60.h,
                ),
                Row(
                  children: [
                    Text(name!,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 40.sp,
                        )),
                    Text('님이 맞으세요?',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 40.sp,
                        )),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                Card(
                  color: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    //모서리를 둥글게 하기 위해 사용
                    borderRadius: BorderRadius.circular(90.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Container(
                      width: double.infinity,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 40.sp,
                              ),
                            ),
                            Text(
                              '   ${phone}',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 30.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40.h,
                ),
                Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                            value: isCompanyInfo.value,
                            onChanged: (value) {
                              isCompanyInfo(value);
                            }),
                        Text('직장정보도 함께 전송\n하시려면 체크하세요.',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 30.sp,
                            )),
                      ],
                    ))
              ],
            ),
            actions: [
              CupertinoDialogAction(
                  child: Text('취소', style: TextStyle(color: Colors.black38)),
                  onPressed: () {
                    peerSocket!.emit('data-cancel', room);

                    myDataConfirm(false);
                    Navigator.of(context).pop();
                    connectButtonPress(false);
                  }),
              CupertinoDialogAction(
                child: Text('확인',
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                onPressed: () {
                  if (peerSocket != null) {
                    var sendData = {
                      'room' : room,
                      'info' : isCompanyInfo.value.toString()
                    };
                    peerSocket.emit('data-confirm', sendData);
                  }

                  Navigator.of(context).pop();

                  myDataConfirm(true);
                  connectButtonPress(false);
                  _dataConfirmCheck(peerSocket: peerSocket, room: room);
                },
              )
            ],
          );
        });
  }


  Future<void> _fileCompleteSave(peerSocket,room) async {
    if (fileInfo!.size == fileInfo!.bytesBuilder.length) {
      // 데이터 수신완료
      Io.Directory? dir;
      if (GetPlatform.isAndroid) {
        dir = await getExternalStorageDirectory();
      } else {
        dir = await getApplicationSupportDirectory();
      }
      var saveFile = Io.File('${dir!.path}/${fileInfo!.fileName}');
      await saveFile.writeAsBytes(fileInfo!.bytesBuilder.toBytes());
      if (fileInfo!.type == RtcFileType.Profile) {
        // 프로필일 경우 디비 업데이트
        await friendDbController.updateProfileImage(
            fileInfo!.sender.toString(), saveFile.path);
      }
      print('${fileInfo!.sender.toString()} saveFile.path : ${saveFile.path}');
      fileInfo!.clear();
      fileInfo = null;

      print('파일전송 완료');

      // await hideProgress();


    }
    // contactNetwork(peerSocket, room);
  }

  void peerSocketInit(room, peerSocket) {
    _dataChannelController!.stopRtc();
    print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!socket");
    peerSocket.on('data-allready', (data) async {
      Future.delayed(Duration(seconds: 1), () async {
        print('p socket : data-allready -> $room,   $data');
        _sendProfile(peerSocket: peerSocket, room: room);
        await hideProgress();
      });
    });
    peerSocket.on('data-profile', (data) {
      print('p socket : data-profile -> $room');
      print(data);
      Vibration.vibrate(duration: 1000);
      _receiveData = data;
      _asyncConfirmDialog(Get.context!,
          name: data['name'],
          phone: data['phone'],
          peerSocket: peerSocket,
          room: room);
    });
    peerSocket.on('data-cancel', (_) {
      otherDataConfirm(false);
      Get.snackbar(
        '알림', '상대방이 공유를 취소하였습니다.',
        backgroundColor: Colors.black.withAlpha(150),
        colorText: Colors.white,
      );
      // _messageTypeChange(MessageType.ABLE);
    });

    peerSocket.on('data-confirm', (data){

      // Logger().e(data);
      print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ${data['info']}');

      if(data['info'] == 'true'){
        otherCompanyInfo(true);
      }else{
        otherCompanyInfo(false);
      }
      otherDataConfirm(true);
      _dataConfirmCheck(peerSocket: peerSocket, room: data['room']);
    });
    peerSocket.on('data-contact', (data) {
      print('data-contack*************************');
      _receiveContact(data);
    });

    peerSocket.on('data-binary', (data) async {
      print('11111111111111');
      print(data['fileName']);
      _fileQueue.add(() async {
        print(data['fileName']);
        print('222222222222');
        if (data['fileName'] != null) {
          print(data);
          print('34343434343434');
          var fileName = data['fileName'];
          var fileSize = data['fileSize'];
          var type = data['type'];
          var dataType = type == RtcFileType.Profile.index
              ? RtcFileType.Profile
              : RtcFileType.Attach;
          var sender = data['sender'] == null ? '' : data['sender'];
          print('33333333333');
          await _receiveFileInfo(fileName, fileSize, dataType, sender: sender);
          print('44444444444444');
        }
        print(data['binary']);

        fileInfo!.bytesBuilder.add(data['binary']);
        print(
            'receive file ${fileInfo!.size} / ${fileInfo!.bytesBuilder.length}');
        if (fileInfo!.size == fileInfo!.bytesBuilder.length) {
          print('55555555555555');
          await _fileCompleteSave(peerSocket,room);
        }
      });
    });

    peerSocket.emit('data-ready', room);
  }

  void collisionOut() async {
    connectButtonPress(false);
    // await rtcReset();
    Vibration.vibrate(duration: 100);
  }

  void collisionPress() {
    connectButtonPress(true);
    var sendData = {
      'pitch': 1,
      'roll': 1,
      'latitude': latitude.value,
      'longitude': longitude.value,
      'type': 0
    };
    //서버 전송
    _socket!.emit('collision', sendData);
    Vibration.vibrate(duration: 100);
  }


}
