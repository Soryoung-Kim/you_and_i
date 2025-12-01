import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart' as G;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:graphview/GraphView.dart';
import 'package:you_and_i/controller/network_picture_controller.dart';
import 'package:you_and_i/db/friend_db_controller.dart';
import 'package:you_and_i/db/myinfo_db_controller.dart';
import 'package:you_and_i/db/network_db_controller.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

class NetworkDetailDiagram extends StatefulWidget {
  // NetworkDetailDiagramPage({Key key}) : super(key: key);

  @override
  NetworkDetailDiagramState createState() => NetworkDetailDiagramState();
}

class NetworkDetailDiagramState extends State<NetworkDetailDiagram> with TickerProviderStateMixin {

  final TextStyle dropdownMenuItem =
      TextStyle(color: Colors.black, fontSize: 18);

  final NetworkDBController networkDBController =
      G.Get.find<NetworkDBController>();
  // NetworkDetail one = Get.arguments[0];
  // Network two = Get.arguments[1];
  final NetworkPictureController _networkPictureController =
      G.Get.find<NetworkPictureController>();
  // static Matrix4 matrix4 = Matrix4(
  //     2, 0, 0, 0,
  //     0, 1, 0, 0,
  //     0, 0, 1, 0,
  //     0, 0, 0, 1
  // );
  // final TransformationController transformationController = TransformationController(matrix4);

  Friend one = G.Get.arguments[0];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
        appBar: AppBar(

          toolbarHeight: 70,
          elevation: 0,
          centerTitle: true,
          title: Text(
            '${one.name}님 인맥보기 (${one.count})',
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor:  const Color(0xfff9f9f9),
          automaticallyImplyLeading: true,
          leading: IconButton(
              onPressed: () {
                G.Get.back();
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              )),
        ),
        backgroundColor: const Color(0xfff9f9f9),
        body: Column(
          children: [

            Image(
                image: const AssetImage('assets/images/depth.png'),
                width: 1050.w,
                fit: BoxFit.fill),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child:
              // ZoomOverlay(
              //   minScale: 0.5, // Optional
              //   maxScale: 3.0, // Optional
              //   twoTouchOnly: false, // Defaults to false
              //   child:

                InteractiveViewer(
                    // onInteractionStart: (ScaleStartDetails scaleStartDetails) {
                    //   // print('Interaction Start - Focal point: ${scaleStartDetails.focalPoint}'
                    //   //     ', Local focal point: ${scaleStartDetails.localFocalPoint}'
                    //   // );
                    //   // print('node0x:${graph.nodes.first.position.distanceSquared.w},node0y:${graph.nodes.first.position.dy},');
                    //
                    // },
                    // onInteractionEnd: (ScaleEndDetails scaleEndDetails) {
                    //   print('Interaction End - Velocity: ${scaleEndDetails.velocity}');
                    // },
                    // onInteractionUpdate: (ScaleUpdateDetails scaleUpdateDetails) {
                    //   print('Interaction Update - Focal point: ${scaleUpdateDetails.focalPoint}'
                    //       ', Local focal point: ${scaleUpdateDetails.localFocalPoint}'
                    //       ', Scale: ${scaleUpdateDetails.scale}'
                    //       ', Horizontal scale: ${scaleUpdateDetails.horizontalScale}'
                    //       ', Vertical scale: ${scaleUpdateDetails.verticalScale}'
                    //       ', Rotation: ${scaleUpdateDetails.rotation}'
                    //   );
                    // },
                    constrained: false,
                    transformationController: _networkPictureController.transformationController,
                    boundaryMargin: EdgeInsets.fromLTRB(200.w,100.w,200.w,400.w),
                    minScale:  0.01,
                    maxScale: 1,
                    child:

                    GraphView(

                      graph: graph,
                      algorithm: SugiyamaAlgorithm(builder),
                      // algorithm: builder,
                      animated: true,
                      paint: (Paint()
                        ..color = Colors.green
                        ..strokeWidth = 3)..style = PaintingStyle.stroke
                        ..strokeCap = StrokeCap.round
                        ..strokeJoin  = StrokeJoin.round
                      ,
                      builder: (Node node) {
                        // I can decide what widget should be shown here based on the id
                        var a = ' ';
                        return getNodeText(null);
                      },
                    )
                // )
              ),


            ),
          ],
        ));
  }

  // int n = 8;
  // Random r = Random();

  Widget getNodeText(NodeData? node) {
    return InkWell(
      onTap: ()async{
        // print('index = $i');
        if(node!.id == one.phone){
          G.Get.toNamed('/NetworkDetailInfo',
              arguments: [one,node.avatar]);
        }else{

          Network network = await networkDBController.networkOne(node);
          G.Get.toNamed('/NetworkDetailInfo2',
              arguments: [network,node]);
        }

      },

        child:
        Container(
            padding: EdgeInsets.all(0),
            child:
            // Text("$node.name"),
                _networkPictureController.getPictureNetwork(node!.id, node.name, node.avatar)
            )
    );
  }

  // final Graph graph = Graph();
  // var builder;

  final Graph graph = Graph();
  SugiyamaConfiguration builder = SugiyamaConfiguration();
    // ..bendPointShape = CurvedBendPointShape(curveLength: 20);


  @override
  void initState() {



    for (NodeData ele in networkDBController.map!['nodes']!.toList()) {
      // print('2');

      _networkPictureController.nodeMap[ele.id] = Node(getNodeText(ele));
      // graph.addNode(nodeMap[ele.id]);
      // print('@@@@@@@@@@@@@@@@ ${ele.id}');

    }
    // print('4');

    // print(nodeMap);
    for (EdgeData ele in networkDBController.map!['edges']!.toList()) {
      var color = 0xffE8004B;
      if(ele.depth == 1){
        color = 0xffE8004B;
      }else if(ele.depth == 2){
        color = 0xff482A84;
      }else if(ele.depth == 3){
        color = 0xffE66D24;
      }else if(ele.depth == 4){
        color = 0xff316BB5;
      }else if(ele.depth == 5){
        color = 0xffF6B510;
      }else if(ele.depth == 6){
        color = 0xffEC4C87;
      }else if(ele.depth == 7){
        color = 0xff8DC333;
      }else{
        color = 0xff8DC333;
      }
      // print('5');
      // print('@@@@@@@@@@@@@@@@@@@@@@@@@${nodeMap[ele.from]},${nodeMap[ele.to]},');
      graph.addEdge(_networkPictureController.nodeMap[ele.from], _networkPictureController.nodeMap[ele.to],
          paint: Paint()..color = Color(color)..strokeWidth = 2);
      // print('6');
    }

    // graph.addEdge(nodeMap['01027981801'], nodeMap['01025221240'],
    //     paint: Paint()..color = Colors.green..strokeWidth = 3);
    // graph.addEdge(nodeMap['01027981801'], nodeMap['01089254862'],
    //     paint: Paint()..color = Colors.green..strokeWidth = 3);

    // graph.addEdge(nodeMap[ele.from], nodeMap[ele.to],
    //     paint: Paint()..color = Color(color)..strokeWidth = 3);
    ////**********************************************************************TODO
    //
    // final a = Node( rectangleWidget('a'));  //using deprecated mechanism of directly placing the widget here
    // final b = Node( rectangleWidget('b'));  //using deprecated mechanism of directly placing the widget here
    // final c = Node( rectangleWidget('c'));  //using deprecated mechanism of directly placing the widget here
    // final d = Node( rectangleWidget('d'));  //using deprecated mechanism of directly placing the widget here
    // final e = Node( rectangleWidget('e'));  //using deprecated mechanism of directly placing the widget here
    // final f = Node(rectangleWidget('f'));  //using deprecated mechanism of directly placing the widget here
    // final g = Node(rectangleWidget('g'));  //using deprecated mechanism of directly placing the widget here
    // final h = Node(rectangleWidget('h'));  //using deprecated mechanism of directly placing the widget here
    //
    // graph.addEdge(a, b);
    // graph.addEdge(a, d);
    // graph.addEdge(c, e);
    // graph.addEdge(d, f);
    // graph.addEdge(f, c);
    // graph.addEdge(g, c);
    // graph.addEdge(h, g);
    //
    // graph.addEdge(a, h);
    // graph.addEdge(a, g);
    // graph.addEdge(h, b,
    //     paint: Paint()..color = Colors.blue
    //     ..strokeCap = StrokeCap.round
    //     ..strokeJoin = StrokeJoin.round
    // );
    // graph.addEdge(c, a);
    // graph.addEdge(a, e);

    // builder = FruchtermanReingoldAlgorithm(
    //     iterations: DEFAULT_ITERATIONS,
    //     repulsionRate: 0.5,
    //   repulsionPercentage: 0.4,
    //   attractionRate: 0.15,
    //   attractionPercentage: 0.15
    // );
    // builder = FruchtermanReingoldAlgorithm(
    //     iterations: DEFAULT_ITERATIONS,
    //     repulsionRate: 0.5,
    //     repulsionPercentage: 0.4,
    //     attractionRate: 0.15,
    //     attractionPercentage: 0.15
    // );
    builder
      ..nodeSeparation = (20)
      ..levelSeparation = (networkDBController.map!['nodes']!.length*5)
      ..orientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM;


    _networkPictureController.initPosition(one.phone.toString());
  }
}

