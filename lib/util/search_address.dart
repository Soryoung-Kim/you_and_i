import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:you_and_i/util/address.dart';
import 'package:get/get.dart';
import 'package:you_and_i/controller/reg_profile_controller.dart';
class SearchAddress extends StatefulWidget {
  static const String routeName = '/navigator/address_search';

  @override
  SearchAddressState createState() => SearchAddressState();
}
class SearchAddressState extends State<SearchAddress> {
  final searchTec = TextEditingController();
  final scrollController = ScrollController();
  final addressBloc = AddressBloc();

  final  profileController =
  Get.find<RegProfileController>();

  List<Juso> addressList = [];
  String? keyword, errorMessage = "검색어를 입력하세요.";
  int? page;

  @override
  void initState() {
    super.initState();
    addAddressStreamListener();
    addScrollListener();
    addTextEditListener();
    searchTec.text = profileController.addressSearchController.text;

  }

  addAddressStreamListener() {

    addressBloc.address.listen(
          (list) {
        addressList = list;
        setState(() {});
      },
      onError: (error, stacktrace) {
        print("onError: $error");
        print(stacktrace.toString());

        if (error is ErrorModel == false) return;

        ErrorModel errorModel = error;
        if (page == 1) addressList = [];
        if (errorModel.error == -101) page = -1;

        errorMessage = errorModel.message;
        setState(() {});
      },
    );
  }

  addScrollListener() {
    scrollController.addListener(() {
      FocusScope.of(context).requestFocus(new FocusNode());
    });
  }

  addTextEditListener() {
    searchTec.addListener(() async {
      if (keyword == searchTec.text) return;
      keyword = searchTec.text;
      page = 1;
      addressBloc.fetchAddress(keyword!, page!);
    });
  }

  @override
  void dispose() {
    addressBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          elevation: 0,
          centerTitle: true,
          title: Text('주소검색',
            style: TextStyle(color: Colors.black),),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: (){
              Get.back();
            },
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: searchTextField()),
                  cancelWidget(),
                  SizedBox(width: 10)
                ],
              ),
              Expanded(child: listView()),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchTextField() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 20, right: 20),
      height: 50,
      alignment: Alignment.center,
      child: TextField(
        controller: searchTec,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "주소 입력",
          hintStyle: TextStyle(color: Color(0xFFA0A0A0)),
        ),
      ),
    );
  }

  Widget cancelWidget() {
    if (keyword == null || keyword!.isEmpty) return Container();

    return GestureDetector(
      child: Icon(
        Icons.cancel,
        color: Color(0xFFBFBFBF),
        size: 20,
      ),
      onTap: () => searchTec.clear(),
    );
  }

  Widget listView() {
    if (addressList.length == 0) {
      return Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 5,
              color: Color(0xFFEdEdEd),
            ),
            Expanded(
                child: Center(
                  child: Text(errorMessage!,
                    style:  TextStyle(
                    color: Colors.black,
                    // fontWeight: FontWeight.bold,
                    fontSize: 50.sp,
                  ),
                  ),
                ))
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: addressList.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) return Container(height: 15, color: Color(0xFFEdEdEd));
        if (index == addressList.length) addAddressList();

        final address = addressList[index - 1];
        return Column(
          children: [
            listItem(address),
            Container(height: 1, color: Color(0xFFEdEdEd)),
          ],
        );
      },
    );
  }

  Widget listItem(Juso? address) {
    final String roadLast;
    if (address!.buldSlno == '0') {
      roadLast = '';
    } else {
      roadLast = '-' + address.buldSlno.toString();
    }
    final rodaTitle = '${address.rn} ${address.buldMnnm}$roadLast';
    final title = address.bdNm!.isEmpty ? rodaTitle : address.bdNm;

    return Container(
      padding: EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15),
      alignment: Alignment.centerLeft,
      width: double.infinity,
      child: InkWell(
        onTap: (){
          print(address.roadAddr.toString());

          profileController.address(address.roadAddr.toString());
          profileController.addressController.text = address.roadAddr.toString();
          Get.back();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              title!,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 5),
            Text(
              '[지번] '+address.jibunAddr.toString(),
              style: TextStyle(color: Color(0xFFA8A8A8)),
            ),
            Text(
              '[도로명] ' + address.roadAddr.toString(),
              style: TextStyle(color: Color(0xFFA8A8A8)),
            ),
          ],
        ),
      ),



    );
  }

  addAddressList() {
    if (page == -1) return;
    page = page!+1;
    addressBloc.fetchAddress(keyword!, page!);
  }
}
