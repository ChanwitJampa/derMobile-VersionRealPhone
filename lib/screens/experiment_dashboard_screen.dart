import 'dart:io';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:der/entities/site/trial.dart';
import 'package:der/screens/main/signup_screen.dart';
import 'package:der/utils/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:der/utils/constants.dart';
import 'package:der/utils/scroll_to_index.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:hive/hive.dart';

import 'dart:math' as math;

Box? _UserBox;
Map<String, double> map1 = {};
Map<String, double> map2 = {};
int countAll = 0;
int countUpload = 0;
int countImage = 0;
int corlor = 0;

class ExperimanetDashBoardScreen extends StatefulWidget {
  _ExperimanetDashBoardScreen createState() => _ExperimanetDashBoardScreen();
}

class _ExperimanetDashBoardScreen extends State<ExperimanetDashBoardScreen> {
  late AutoScrollController controller;

  late List<List<int>> randomList;

  static const maxCount = 100;

  final random = math.Random();

  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();

  final GlobalKey<AnimatedCircularChartState> _chartKey2 =
      new GlobalKey<AnimatedCircularChartState>();

  final _chartSize = const Size(200.0, 200.0);

  late List<CircularStackEntry> data;

  late List<CircularStackEntry> data2;

  void _randomize() {
    setState(() {
      data = _generateRandomData(map1);
      data2 = _generateRandomData(map2);
      _chartKey.currentState!.updateData(data);
      _chartKey2.currentState!.updateData(data2);
    });
  }

  getDataToDisplay() {
    print("getdata to display");
    countAll = 0;
    countUpload = 0;
    countImage = 0;
    List<OnSiteTrial> listOst = _UserBox?.get(userNameNow).onSiteTrials;

    if (listOst.length > 0) {
      for (int i = 0; i < listOst.length; i++) {
        for (int j = 0; j < listOst[i].onSitePlots.length; j++) {
          countAll++;
          if (listOst[i].onSitePlots[j].isUpload == 1) {
            countUpload++;
          }
          if (File(listOst[i].onSitePlots[j].plotImgPath).existsSync()) {
            countImage++;
          }
        }
      }
    } else {
      countAll = -1;
      countUpload = 0;
      countImage = 0;
    }
    map1 = {
      'Upload': (countUpload * 100) / countAll,
      'No-Upload': 100 - ((countUpload * 100) / countAll),
      
    };
    map2 = {
      'Image': (countImage * 100) / countAll,
      'No-Image': 100 - ((countImage * 100) / countAll),
      
    };
  }

  List<CircularStackEntry> _generateRandomData(Map<String, double> map1) {
    int stackCount = 1; //.nextInt(3);

    List<CircularStackEntry> data = List.generate(stackCount, (i) {
      int segCount = random.nextInt(10);
      segCount = segCount == 0 ? 1 : segCount;
      List<CircularSegmentEntry> segments = List.generate(map1.length, (index) {
        String key = map1.keys.elementAt(index);
        Color randomColor;
        if(countAll == -1){
           randomColor = ColorPalette.primary[4];
        }
        else {
           randomColor = ColorPalette.primary[corlor];
        }
        corlor++;
        return new CircularSegmentEntry(map1[key], randomColor, desc: key);
      });
      //   List<CircularSegmentEntry> segments =  List.generate(segCount, (j) {

      //   Color randomColor = ColorPalette.primary.random(random);
      //   return new CircularSegmentEntry(random.nextDouble(), randomColor,desc:"test");
      // });

      return new CircularStackEntry(segments);
    });

    return data;
  }

  @override
  void initState() {
    super.initState();
    _UserBox = Hive.box('Users');
    getDataToDisplay();
    corlor = 0;
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.horizontal);
    randomList = List.generate(maxCount,
        (index) => <int>[index, (1000 * random.nextDouble()).toInt()]);

    data = _generateRandomData(map1);
    data2 = _generateRandomData(map2);
  }

  Widget _wrapScrollTag({required int index, required Widget child}) =>
      AutoScrollTag(
        key: ValueKey(index),
        controller: controller,
        index: index,
        child: child,
        highlightColor: Colors.black.withOpacity(0.1),
      );

  Widget _getRow(int index, double height) {
    return _wrapScrollTag(
      index: index,
      child: InkWell(
        onTap: () {
          setState(() {
            counter = index;
          });
        },
        child: Container(
          width: 300,
          padding: EdgeInsets.all(8),
          alignment: Alignment.topCenter,
          height: height,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.lightBlue, width: 4),
              borderRadius: BorderRadius.circular(12)),
          child: Text('index: $index, height: $height'),
        ),
      ),
    );
  }

  int _currentItem = 0;

  Widget makeDoughnutProgress({double? inProgress, double? finished}) {
    int fin = (finished! * 100).round();

    return Stack(children: <Widget>[
      //SizedBox(width: 10,),
      CircularProgressIndicator(
        value: 1,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
      ),
      Positioned(right: 6, bottom: 10, child: Text('$fin' + ' ')),

      CircularProgressIndicator(
        value: inProgress,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrangeAccent),
      ),
      CircularProgressIndicator(
        value: finished,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
      ),
    ]);
  }

  Widget makeExperiment(
      {experimentID,
      userImage = "assets/images/unknown_user.jpg",
      feedTime,
      feedText,
      feedImage}) {
    return GestureDetector(
      onTap: () {
        //Navigator.pushNamedAndRemoveUntil(context, PLOT_ROUTE, (route) => false,arguments: experimentID);
        //Navigator.of(context).pushNamed('$i')
        // Navigator.pushReplacementNamed(context, PLOT_ROUTE,(Route<dynamic> route) => false,arguments: experimentID);
        Navigator.pushNamed(context, PLOT_ROUTE, arguments: experimentID);
        //Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PlotsScreen(title: experimentID)));
      },
      child: Container(
        //margin: EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    /*Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: AssetImage(userImage),
                                  fit: BoxFit.cover
                              )
                          ),
                        ),*/
                    //SizedBox(width: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          experimentID,
                          style: TextStyle(
                              color: Colors.grey[900],
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          feedTime,
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ],
                    )
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    size: 30,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {},
                )
              ],
            ),
            //SizedBox(height: 20,),
            Text(
              feedText,
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[800],
                  height: 1.5,
                  letterSpacing: .7),
            ),
            //SizedBox(height: 20,),

            Stack(
              children: [
                makeDoughnutProgress(inProgress: 0.6, finished: 0.6),
                feedImage != ''
                    ? Container(
                        height: 90,
                        child: Stack(
                          children: [Container()],
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                                image: AssetImage(feedImage),
                                fit: BoxFit.cover)),
                      )
                    : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget makeExperimentDatail() {
    return Container();
  }

  Widget makePieChart() {
    return Container(
      width: 400,
      height: 600,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 600,
            height: 300,
            decoration:
                BoxDecoration(border: Border.all(color: Colors.blueAccent)),
            //color: Colors.black54.withOpacity(0.5),

            child: Stack(
              children: [
                Positioned(
                    top: 70.0,
                    right: 175,
                    child: InkWell(
                        child: AnimatedCircularChart(
                          key: _chartKey,
                          size: _chartSize,
                          initialChartData: data,
                          holeLabel: countAll==-1? "0 / 0 ":"${countUpload} / ${countAll}",
                           labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                          //edgeStyle: SegmentEdgeStyle.round,
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),

                          chartType: CircularChartType.Radial,
                          width: 15,
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed(UNMATCH_PLOT_ROUTE);
                        })
                        ),
                Positioned(
                    top: 10.0,
                    left: 15,
                    child: Text(
                      "Upload",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ],
            ),
          ),
          Container(
              width: 600,
              height: 300,
              child: Stack(
                children: [
                  Positioned(
                      top: 70.0,
                      right: 175,
                      child: AnimatedCircularChart(
                        key: _chartKey2,
                        size: _chartSize,
                        holeLabel: countAll==-1? "0 / 0 ":"${countImage} / ${countAll}",
                        //edgeStyle: SegmentEdgeStyle.round,
                        initialChartData: data2,
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),

                        chartType: CircularChartType.Radial,
                        width: 15,
                      )),
                  Positioned(
                      top: 10.0,
                      left: 15,
                      child: Text(
                        "Image",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.blue[600],
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ],
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            color: Colors.blue,
          ),
          // Container(
          //   height: 200,
          //   width: 600,
          //   //color: Colors.blue,
          //   child: ListView.builder(
          //     itemCount: 5,
          //     itemBuilder: (context, index) {
          //       return VisibilityDetector(
          //           key: Key(index.toString()),
          //           onVisibilityChanged: (VisibilityInfo info) {
          //             if (info.visibleFraction == 1)
          //               setState(() {
          //                 _currentItem = index;
          //                 print(_currentItem);
          //                 _randomize();
          //               });
          //           },
          //           child: Padding(
          //             padding: EdgeInsets.all(2),
          //             child: Container(
          //               //color: Colors.blue,
          //               decoration: BoxDecoration(
          //                   //color: Colors.blue[200],
          //                   borderRadius: BorderRadius.circular(10),
          //                   gradient: LinearGradient(
          //                       begin: Alignment.bottomRight,
          //                       colors: [
          //                         Colors.black.withOpacity(.9),
          //                         Colors.black.withOpacity(.1),
          //                       ])),
          //               width: 350,
          //               height: 100,
          //               //margin: const EdgeInsets.symmetric(horizontal: 1.0),
          //               child: makeExperiment(
          //                   experimentID: '54155',
          //                   //userImage: 'assets/images/aiony-haust.jpg',
          //                   feedTime: '1 hr ago',
          //                   feedText:
          //                       'All the Lorem Ipsum.',
          //                   feedImage: 'assets/images/corn.png'),
          //             ),
          //           )
          //           );
          //     },
          //     scrollDirection: Axis.horizontal,
          //   ),

          //   /*ListView(
          //         controller: controller,

          //         scrollDirection: Axis.horizontal,

          //         children: randomList.map<Widget>((data) {
          //           return Padding(
          //             padding: EdgeInsets.all(8),

          //             child: _getRow(data[0], math.max(data[1].toDouble(), 50.0)),
          //           );
          //         }).toList(),

          //       ),*/
          // ),
          Container(
            height: 3,
            color: Colors.grey[300],
          ),
          Padding(
            padding: EdgeInsets.all(2),
            child: Container(
              //color: Colors.red,
              height: 600,
              width: 600,
              //color: Colors.red,

              //  child: Expanded(

              child: makePieChart(),
              /*Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 50,
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  Stack(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Plot',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(
                            width: 50,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 20),
                            width: 300,
                            height: 20,
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              child: LinearProgressIndicator(
                                value: 0.7,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.green),
                                backgroundColor: Color(0xffD6D6D6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(left: 200, bottom: 22, child: Text('70/100')),
                    ],
                  ),
                  Stack(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Uploaded',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(
                            width: 0,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 20),
                            width: 300,
                            height: 20,
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              child: LinearProgressIndicator(
                                value: 0.7,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.green),
                                backgroundColor: Color(0xffD6D6D6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(left: 200, bottom: 22, child: Text('70/100')),
                    ],
                  ),
                  Stack(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Approved',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(
                            width: 0,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 20),
                            width: 300,
                            height: 20,
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              child: LinearProgressIndicator(
                                value: 0.7,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.green),
                                backgroundColor: Color(0xffD6D6D6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(left: 200, bottom: 22, child: Text('70/100')),
                    ],
                  ),
                ],
              ),*/

              //   ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        backgroundColor: Color(0xFF398AE5),
        items: [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.download, title: 'Download'),
          TabItem(icon: Icons.qr_code, title: 'Scan'),
          TabItem(icon: Icons.art_track, title: 'Experiment'),
          TabItem(icon: Icons.bar_chart, title: 'Report'),
        ],
        initialActiveIndex: 0,
        onTap: (int i) => Navigator.of(context).pushReplacementNamed('$i'),
      ),
    );
  }

  int counter = -1;
  Future _scrollToIndex() async {
    setState(() {
      counter++;

      if (counter >= maxCount) counter = 0;
    });

    await controller.scrollToIndex(counter,
        preferPosition: AutoScrollPosition.begin);
    controller.highlight(counter);
  }
}

fetchHiveBox() async {
  _UserBox = Hive.box('Users');
}
