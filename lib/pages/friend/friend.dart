import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:you_and_i/controller/friend_controller.dart';
import 'package:you_and_i/db/friend_db_controller.dart';
import 'package:you_and_i/db/network_db_controller.dart';


import '../../controller/main_controller.dart';

class FriendHome extends StatefulWidget {
  const FriendHome({Key? key}) : super(key: key);

  @override
  State<FriendHome> createState() => _FriendState();
}

class _FriendState extends State<FriendHome> {
  final FriendController controller = Get.find<FriendController>();

  final FriendDBController friendDBController = Get.find<FriendDBController>();

  final MainController mainController = Get.find<MainController>();
  List? foundUsers;
  final NetworkDBController networkDBController =
  Get.find<NetworkDBController>();

  @override
  initState() {
    // at the beginning, all users are shown
    foundUsers = friendDBController.list;
    // print(friendDBController.list[0].toMap());
    super.initState();
  }

  void runFilter(String enteredKeyword) {
    List results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = friendDBController.list;
    } else {
      results = friendDBController.list
          .where((list) =>
              list.name!.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      foundUsers = results;
    });
  }

  void memoAlert(index) async {
    Friend? friend = friendDBController.list[index];
    controller.memoController.text =  friend.memo.toString().replaceAll('null', '');

    showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("메모",
                style: TextStyle(
                  // color: Theme.of(context).primaryColor,
                  // fontWeight: FontWeight.bold,
                    fontSize: 50.sp)),
            content: Form(
                child: Column(
                  children: [
                    SizedBox(
                      height: 30.h,
                    ),
                    TextFormField(
                      controller: controller.memoController,
                      minLines: 2,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: '메모를 작성하세요.',
                        hintStyle: TextStyle(
                            color: Colors.grey
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                  ],
                )),
            actions: [
              CupertinoDialogAction(
                child: Text('취소', style: TextStyle(color: Colors.grey[600])),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text('저장',
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                onPressed: () {
                  friendDBController.updateMemo(friend.id.toString(), controller.memoController.text);
                  Navigator.of(context).pop();

                  friendDBController.friends();

                  setState(() async{
                    // foundUsers!.remove(friend);
                    // foundUsers!.add(friend);
                    // phoneSave(index);
                    // Get.offAllNamed('/YouAndIMain');
                    controller.searchController.text = '  ';
                    runFilter(controller.searchController.text);
                    Future.delayed(const Duration(milliseconds: 200), () {
                      controller.searchController.text = '';
                      runFilter(controller.searchController.text);

                    });



                    await mainController.hideProgress();
                  });

                  Get.snackbar(
                    '알림',
                    '${friend.name}님에 대한 메모가 저장되었습니다.',
                    backgroundColor: Colors.black.withAlpha(150),
                    colorText: Colors.white,
                  );

                },
              )
            ],
          );
        });
  }
  memoRenderButton(int index) {
    Friend friend = friendDBController.list[index];
    Color color = Colors.grey;

    if(friend.memo == '' ||friend.memo == 'null'||friend.memo == null){
      color = Colors.grey;
    }else{
      color = Theme.of(context).primaryColor;
    }
    // friend.memo =

    return
      InkWell(
        onTap: (){
          memoAlert(index);
        },
        child: Card(

            color: color,
            shape: RoundedRectangleBorder(
              //모서리를 둥글게 하기 위해 사용
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Image.asset('assets/images/ic_memo.png',color: Colors.white,
              width: 90.w,
            )

        ),
      );



  }

  // icon: Image.asset('path/the_image.png'),
  // iconSize: 50,1

  void onDismissed(index) {
    print(foundUsers![index].phone);


    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          // title: Text("Delete File"),
          content: const Text("삭제 하시겠습니까??"),
          actions: [
            CupertinoDialogAction(
                child:const Text('취소', style: TextStyle(color: Colors.black38)),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            CupertinoDialogAction(
              child: Text('확인',
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: ()async {

                print(index);
                print(foundUsers!.length);
                controller.onDismissed(foundUsers![index].phone);
                setState(() {
                  foundUsers!.remove(foundUsers![index]);
                  print(foundUsers!.length);
                });
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
  Widget phoneSave(index){

    Friend friend = friendDBController.list[index];

    var filter = mainController.myContacts!.where((element) =>
    element['phone'] == friend.phone!.replaceAll('-', '').replaceAll('+82', '0') );
    print('filter. : ${filter}');
    print('filter.length : ${filter.length}');




    if (filter.length == 0) {
      return OutlinedButton(
        onPressed: () async{
          showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                // title: Text("Delete File"),
                content: Text("${friend.name}님을 휴대폰에 \n저장 하시겠습니까??"),
                actions: [
                  CupertinoDialogAction(
                      child:const Text('취소', style: TextStyle(color: Colors.black38)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                  CupertinoDialogAction(
                    child: Text('확인',
                        style: TextStyle(color: Theme.of(context).primaryColor)),
                    onPressed: ()async {

                      Navigator.of(context).pop();


                      await mainController.showProgress('휴대폰 저장 중');
                      Future.delayed(const Duration(milliseconds: 1000), ()  async {
                        final newContact = Contact()
                        // 이름
                          ..name = Name(first: friend.name ?? '')
                          ..displayName = friend.name ?? ''
                        // 전화번호들
                          ..phones = [
                            if ((friend.phone ?? '').isNotEmpty)
                              Phone(friend.phone!, label: PhoneLabel.mobile),
                            if ((friend.tel ?? '').isNotEmpty)
                              Phone(friend.tel!, label: PhoneLabel.work),
                          ]
                        // 회사/직책
                          ..organizations = [
                            Organization(
                              company: friend.company ?? '',
                              title: friend.position ?? '',
                            ),
                          ]
                        // 이메일
                          ..emails = [
                            if ((friend.email ?? '').isNotEmpty)
                              Email(friend.email!, label: EmailLabel.work),
                          ]
                        // 주소
                          ..addresses = [
                            if ((friend.address ?? '').isNotEmpty ||
                                (friend.address2 ?? '').isNotEmpty)
                              Address(
                                '${friend.address ?? ''} ${friend.address2 ?? ''}',
                                city: friend.address ?? '',
                                street: friend.address2 ?? '',
                              ),
                          ];

                          // if (await Permission.contacts.status.isGranted) {
                          await newContact.insert();

                          // 필요하다면 전체 연락처 다시 로딩
                          final contacts = await FlutterContacts.getContacts(
                            withProperties: true,
                            withPhoto: true,
                          );
                          print("Contact added successfully. count = ${contacts.length}");

                          mainController.initContacts();

                          Get.snackbar(
                            '알림','휴대폰에 저장되었습니다.',
                            backgroundColor: Colors.black.withAlpha(150),
                            colorText: Colors.white,
                          );

                          friendDBController.friends();

                          Future.delayed(const Duration(milliseconds: 3000), ()  async {
                            setState(() async{
                              // foundUsers!.remove(friend);
                              // foundUsers!.add(friend);
                              // phoneSave(index);
                              // Get.offAllNamed('/YouAndIMain');
                              controller.searchController.text = '  ';
                              runFilter(controller.searchController.text);
                              Future.delayed(const Duration(milliseconds: 200), () {
                                controller.searchController.text = '';
                                runFilter(controller.searchController.text);

                              });

                              await mainController.hideProgress();
                            });



                          });

                        // }
                        // else{
                        //   PermissionStatus permission = await Permission.contacts.status;
                        //   print('권한이 없습니다.');
                        // }
                        await mainController.hideProgress();

                      });


                    },
                  )
                ],
              );
            },
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          padding: const EdgeInsets.all(1),
          side: BorderSide(
            color: Theme.of(Get.context!).primaryColor,
            width: 1,
          ),
          backgroundColor: Colors.white,
          fixedSize: Size(410.w, 90.h),
          shape: const StadiumBorder(),
        ),
        child:  Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          crossAxisAlignment:
          CrossAxisAlignment.center,
          children: [
            Image(
              image: const AssetImage('assets/images/ic_save.png'),
              width: 70.w,
              fit: BoxFit.fill,
            ),
            SizedBox(
              width: 25.w,
            ),
            Text(
              '휴대폰저장',
              style: TextStyle(
                color: Theme.of(Get.context!).primaryColor,
                // fontWeight: FontWeight.bold,
                fontSize: 40.sp,
              ),
            ),
          ],
        ),
      );
    }else{
      return OutlinedButton(
        onPressed: () {
          Get.snackbar(
            '알림','이미 저장된 번호입니다.',
            backgroundColor: Colors.black.withAlpha(150),
            colorText: Colors.white,
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          padding: const EdgeInsets.all(1),
          side: const BorderSide(
            color:  Colors.white70,
            width: 1,
          ),
          backgroundColor: Colors.grey[300],
          fixedSize: Size(410.w, 90.h),
          shape: const StadiumBorder(),
        ),
        child:  Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          crossAxisAlignment:
          CrossAxisAlignment.center,
          children: [
            Image(
              image: const AssetImage('assets/images/ic_save_check.png'),
              width: 70.w,
              fit: BoxFit.fill,
            ),
            SizedBox(
              width: 25.w,
            ),
            Text(
              '저장완료',
              style: TextStyle(
                color: Colors.black,
                // fontWeight: FontWeight.bold,
                fontSize: 35.sp,
              ),
            ),
          ],
        ),
      );
    }

  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(50.w, 20.h, 50.w, 0.h),
      child: Column(
        children: [
          SizedBox(
            height: 10.h,
          ),
          TextField(
            controller: controller.searchController,
            onChanged: (value) => runFilter(value),
            decoration: InputDecoration(
              labelStyle: const TextStyle(color: Colors.grey),
              labelText: '이름으로 검색하세요',
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.black,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                color: Colors.black,
                onPressed: () {
                  runFilter('');
                  controller.clear();
                },
              ),
              focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  )),
              enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  )),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Expanded(
            child: foundUsers!.isNotEmpty
                ? ListView.builder(
                    itemCount: foundUsers!.length,
                    itemBuilder: (context, index) {
                      return Slidable(
                        key: Key(foundUsers![index].phone),
                        endActionPane: ActionPane(
                            motion: const StretchMotion(),
                            extentRatio: 0.2,
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  print('tap delect');
                                  onDismissed(index);
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: '삭제', // [변경됨] caption 대신 label 사용
                              ),
                            ]),
                          child:
                          InkWell(
                            onTap: (){
                              Uint8List? avatar = new Uint8List(0);
                              if(friendDBController.list[index].picture.toString()!= null && friendDBController.list[index].picture.toString()!=''){
                                var file = File(friendDBController.list[index].picture.toString());
                                 avatar = file.readAsBytesSync() as Uint8List;

                              }
                              Get.toNamed('/NetworkDetailInfo',
                                  arguments: [friendDBController.list[index],avatar]);
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                //모서리를 둥글게 하기 위해 사용
                                borderRadius:
                                BorderRadius.circular(20.0),

                              ),
                              // key: ValueKey(foundUsers![index]["id"]),
                              color: Colors.grey[100],
                              elevation: 0,
                              margin: EdgeInsets.symmetric(vertical: 18.h),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        50.w, 30.h, 50.w, 20.h),
                                    child: Container(
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: [
                                                controller.profileImage(foundUsers![index]
                                                    .picture),
                                                SizedBox(
                                                  width: 60.w,
                                                ),
                                                Flexible(
                                                  flex: 1,
                                                  child: Text(
                                                    foundUsers![index].name,
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 40.sp),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 30.w,
                                                ),
                                                Text(
                                                    foundUsers![index].phone
                                                    // ''
                                                    ,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 30.sp,
                                                        letterSpacing: .3)),
                                                SizedBox(
                                                  width: 40.w,
                                                ),
                                              ],
                                            ),
                                          ),
                                          memoRenderButton(index),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        50.w, 0.h, 50.w, 20.h),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        phoneSave(index),

                                        OutlinedButton(
                                          onPressed: ()  {
                                            controller.moveNetwork(index);

                                          },
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.all(1),
                                            side: const BorderSide(
                                              color: Colors.grey,
                                              width: 1,
                                            ),
                                            backgroundColor: Colors.white,
                                            fixedSize: Size(410.w, 90.h),
                                            shape: StadiumBorder(),
                                          ),
                                          child:  Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              Image(
                                                image: const AssetImage('assets/images/ic_person.png'),
                                                width: 70.w,
                                                fit: BoxFit.fill,
                                              ),
                                              SizedBox(
                                                width: 25.w,
                                              ),
                                              controller.buttonFriend(foundUsers![index].phone,index),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                      );
                    },
                  )
                : Text(
                    '\n\n\n\n\n\n\n인맥이 없습니다.',
                    style: TextStyle(fontSize: 50.sp),
                  ),
          ),
        ],
      ),
    );
  }
}
