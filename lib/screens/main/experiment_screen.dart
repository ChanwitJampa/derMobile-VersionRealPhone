import 'dart:io';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:der/entities/site/plot.dart';

import 'package:der/entities/site/trial.dart';
import 'package:flutter/material.dart';
import 'package:der/screens/plot/plot_screen.dart';
import 'package:der/utils/constants.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import 'package:der/entities/site/trial.dart';
import 'package:der/entities/trial.dart';

import 'package:der/screens/main/signup_screen.dart';

import 'package:der/screens/main/main_screen.dart';
import 'package:http/http.dart' as Http;
import 'dart:convert';
import 'package:der/entities/objectlist.dart';
import 'package:der/entities/trial.dart';

import 'package:der/env.dart';

final _formKey = GlobalKey<FormState>();

class ExperimentScreen extends StatefulWidget {
  _ExperimentScreen createState() => _ExperimentScreen();
}

Box? _UserBox;

List<double> listPercent = [];
List<double> listPercent2 = [];

double allPercentI = 0;
double allPercentU = 0;

List<Widget> makeExperiments = [];
bool _isConnectionSuccessful = false;

class _ExperimentScreen extends State<ExperimentScreen> {
  List<OnSiteTrial>? ost;
  initState() {
    super.initState();

    _UserBox = Hive.box("Users");

    fetchTrialsOnSever().then((e) => {
          calculatePercent(_UserBox?.get(userNameNow).onSiteTrials),
          loadAllTrials(_UserBox?.get(userNameNow).onSiteTrials, listPercent,
              listPercent2)
        });
  }

  Widget makeDoughnutProgress({double? inProgress, double? finished}) {
    int fin = (finished! * 100).round();

    return Stack(children: <Widget>[
      CircularProgressIndicator(
        value: 1,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
      ),
      Positioned(right: 6, top: 10, child: Text('$fin' + ' ')),
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

  findPathExist(List<OnSitePlot> osp) {
    int i = 0;
    int length = 0;

    for (i; i < osp.length; i++) {
      if (File(osp[i].plotImgPath).existsSync()) {
        length++;
      }
    }

    print("Length: $length");
    return length;
  }

  imagepathLoader(List<OnSitePlot> osp) {
    Image image;

    int lenght = osp.length;
    // print("lenght = " + lenght.toString());
    int i = 0;
    int j = 0;
    int k = 0;

    List<String> pathList = [];

    for (i; i < osp.length; i++) {
      // print('image path: ' + osp[i].plotImgPath + " i  = " + i.toString());

      if (File(osp[i].plotImgPath).existsSync()) {
        // return new RotationTransition(
        //   turns: new AlwaysStoppedAnimation(0 / 360),
        //   child: new Image.file(
        //     File(osp[i].plotImgPath),
        //     // child: new Image.asset(
        //     //   feedImage,
        //     height: 500,
        //     width: 700,
        //   ),
        // );
        // print('image path is: ' + osp[i].plotImgPath + " i  = " + i.toString());

        j = i;
        // i = lenght;
        k++;
        // print("END");
        pathList.add(osp[j].plotImgPath.toString());
      } else {
        // print("Continue");
        continue;
      }
    }

    if (k == 0) {
      // return "assets/images/img_not.png";
      return "null";
    } else {
      print(pathList);
      return pathList;
    }

    // if (File(feedImage).existsSync()) {
    //   return new RotationTransition(
    //     turns: new AlwaysStoppedAnimation(0 / 360),
    //     child: new Image.file(
    //       File(feedImage),
    //       // child: new Image.asset(
    //       //   feedImage,
    //       height: 500,
    //       width: 700,
    //     ),
    //   );
    // } else {
    //   return Container(
    //     margin: const EdgeInsets.all(50.0),
    //     height: 300,
    //     decoration: BoxDecoration(
    //         borderRadius: BorderRadius.circular(5),
    //         image: DecorationImage(
    //             image: AssetImage("assets/images/img_not.png"),
    //             fit: BoxFit.cover)),
    //   );
    // }
  }

  Widget displayTrial(int plotSize, List<String> feedImage) {
    if (plotSize == 1) {
      return Container(
        child: new Image.file(
          File(feedImage[0]),
          // child: new Image.asset(
          //   feedImage,
          height: 500,
          width: 700,
        ),
      );
    } else if (plotSize == 2) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: new Image.file(
                File(feedImage[0]),
                // child: new Image.asset(
                //   feedImage,
                height: 300,
                width: 250,
              ),
            ),
            Container(
              child: new Image.file(
                File(feedImage[1]),
                // child: new Image.asset(
                //   feedImage,
                height: 300,
                width: 230,
              ),
            )
          ],
        ),
      );
    } else if (plotSize == 3) {
      return Container(
        width: 600,
        height: 300,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 270,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  // image: AssetImage('images/moth.JPG'),
                  image: FileImage(File(feedImage[0])),
                  fit: BoxFit.fitWidth,
                ),
                //shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 270,
              height: 300,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            // image:AssetImage('images/Mozilla_Thunderbird_logo.png'),
                            image: FileImage(File(feedImage[1])),
                            fit: BoxFit.fitWidth,
                          ),
                          shape: BoxShape.rectangle,
                        ),
                      ),
                      Stack(
                        children: [
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                // image: AssetImage('images/moth.JPG'),
                                image: FileImage(File(feedImage[2])),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      // Container(
      //   child: Row(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Container(
      //   child: new Image.file(
      //               File(feedImage[0]),
      //               // child: new Image.asset(
      //               //   feedImage,
      //               height: 300,
      //               width: 250,
      //             ),
      // ),
      // Container(
      //   child: Column(
      //     children: [
      //       Container(
      //         child: new Image.file(
      //               File(feedImage[1]),
      //               // child: new Image.asset(
      //               //   feedImage,
      //               height: 150,
      //               width: 130,
      //             ),
      //       ),
      //       SizedBox(height: 2,),
      //       Container(
      //     child: new Image.file(
      //               File(feedImage[2]),
      //               // child: new Image.asset(
      //               //   feedImage,
      //               height: 150,
      //               width: 130,
      //             ),
      //       )
      //     ],
      //   )),],

      //   ),
      // );

    } else if (plotSize == 4) {
      return Container(
        width: 600,
        height: 300,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 270,
              height: 300,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            // image:AssetImage('images/Mozilla_Thunderbird_logo.png'),
                            image: FileImage(File(feedImage[0])),
                            fit: BoxFit.fitWidth,
                          ),
                          shape: BoxShape.rectangle,
                        ),
                      ),
                      Stack(
                        children: [
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                // image: AssetImage('images/moth.JPG'),
                                image: FileImage(File(feedImage[1])),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 270,
              height: 300,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            // image:AssetImage('images/Mozilla_Thunderbird_logo.png'),
                            image: FileImage(File(feedImage[2])),
                            fit: BoxFit.fitWidth,
                          ),
                          shape: BoxShape.rectangle,
                        ),
                      ),
                      Stack(
                        children: [
                          Container(
                            height: 150,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                // image: AssetImage('images/moth.JPG'),
                                image: FileImage(File(feedImage[3])),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (plotSize == 5) {
      return Container(
          width: 600,
          height: 300,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
                child: Container(
                  width: 600,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Color(0xFFEEEEEE),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: 275,
                            height: 150,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(feedImage[0])),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                          Container(
                            width: 275,
                            height: 150,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(feedImage[1])),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            width: 184,
                            height: 150,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(feedImage[2])),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                          Container(
                            width: 183,
                            height: 150,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(feedImage[3])),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                          Container(
                            width: 183,
                            height: 150,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(feedImage[4])),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ));
    }

    return Container(
        width: 600,
        height: 300,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
              child: Container(
                width: 600,
                height: 300,
                decoration: BoxDecoration(
                  color: Color(0xFFEEEEEE),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: 275,
                          height: 150,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(File(feedImage[0])),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                        Container(
                          width: 275,
                          height: 150,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(File(feedImage[1])),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: 184,
                          height: 150,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(File(feedImage[2])),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                        Container(
                          width: 183,
                          height: 150,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(File(feedImage[3])),
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                        Stack(children: [
                          Container(
                            width: 183,
                            height: 150,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(feedImage[4])),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                          Container(
                            height: 150,
                            color: Colors.black87
                          ),
                          Positioned(
                            bottom: 48.0,
                            left: 90.0,
                            child: Container(
                              color: Colors.transparent,
                              child: Text(
                                "+",
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 40, color: Colors.white),
                              ),
                            ),
                          )
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));

  }

  Widget makeExperiment(
      {index,
      experimentID,
      userImage = "assets/images/unknown_user.jpg",
      feedTime,
      feedText,
      feedImage,
      finishPercent = 0.5,
      inprogressPercent = 0.9,
      percentText,
      percentText2,
      trialLenght}) {
    return GestureDetector(
      onTap: () {
        //Navigator.pushNamedAndRemoveUntil(context, PLOT_ROUTE, (route) => false,arguments: experimentID);
        //Navigator.of(context).pushNamed('$i')
        // Navigator.pushReplacementNamed(context, PLOT_ROUTE,(Route<dynamic> route) => false,arguments: experimentID);
        //print("Test 1 :" + experimentID);
        //print("testtest: " + context.toString());
        Navigator.pushNamed(context, PLOT_ROUTE, arguments: index);

        //Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PlotsScreen(title: experimentID)));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
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
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          experimentID,
                          style: TextStyle(
                              color: Colors.grey[900],
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          feedTime,
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    )
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: 30,
                    color: Colors.red[900],
                    // color: Colors.grey[600],
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Delete trial'),
                            content: Text('Confirm to delete this trial'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () async {
                                  //--------------------------------delete trial-------------------------------------
                                  // print(index);

                                  await deletePictureOnTrialByIndex(index);
                                  _UserBox!
                                      .get(userNameNow)
                                      .onSiteTrials
                                      .removeAt(index);

                                  listPercent.removeAt(index);
                                  listPercent2.removeAt(index);

                                  _UserBox!.get(userNameNow).save();

                                  loadAllTrials(
                                      _UserBox?.get(userNameNow).onSiteTrials,
                                      listPercent,
                                      listPercent2);

                                  Navigator.pop(context);
                                },
                                child: Text('Delete'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancle'),
                              )
                            ],
                          );
                        });
                  },
                )
              ],
            ),
            SizedBox(
              height: 0,
            ),
            Text(
              feedText,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[800],
                  height: 1.5,
                  letterSpacing: .7),
            ),
            SizedBox(
              height: 20,
            ),
            Stack(
              children: [
                feedImage != "null"
                    ? RotationTransition(
                        turns: new AlwaysStoppedAnimation(0 / 360),
                        child: displayTrial(trialLenght, feedImage),
                      )
                    : Container(
                        margin: const EdgeInsets.all(50.0),
                        height: 300,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            image: DecorationImage(
                                image: AssetImage("assets/images/img_not.png"),
                                fit: BoxFit.cover)),
                      )
                // feedImage != ''
                //     ? Container(
                //         height: 300,
                //         child: Stack(
                //           children: [Container()],
                //         ),
                //         decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(10),
                //             image: DecorationImage(
                //                 image: AssetImage(feedImage),
                //                 fit: BoxFit.cover)),
                //       )
                //     : Container(),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      makeDoughnutProgress(
                          inProgress: inprogressPercent,
                          finished: finishPercent),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            percentText,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                                height: 1.5,
                                letterSpacing: .7),
                          ),
                          Text(
                            percentText2,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                                height: 1.5,
                                letterSpacing: .7),
                          )
                        ],
                      ),
                    ]),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                //makeCameraButton(),
                //makeGallryButton(),
                //makeShareButton(),
              ],
            ),
            Container(
              height: 10,
              color: Colors.grey[300],
            )
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                // color: Colors.blue,
                color: Color(0xFF398AE5),
                height: 100,
                padding:
                    EdgeInsets.only(top: 40, right: 20, left: 20, bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.grey[200]),
                      child: TextField(
                        autofocus: false,
                        // serch by barcode or plot id
                        onChanged: (text) async {
                          await serchTrials(text);
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[600],
                          ),
                          border: InputBorder.none,
                          hintStyle:
                              TextStyle(color: Colors.grey[600], fontSize: 20),
                          hintText: "Search Trials",
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              Container(
                height: 3,
                color: Colors.grey[300],
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Column(
                      children: makeExperiments,
                    ),
                  ),
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
              TabItem(icon: Icons.art_track, title: 'Trials'),
              TabItem(icon: Icons.bar_chart, title: 'Report'),
            ],
            initialActiveIndex: 3,
            onTap: (int i) => Navigator.of(context).pushNamed('$i'),
          ),
        ));
  }

  serchTrials(String text) async {
    List<double> listPercentDisplay = [];
    List<double> listPercentDisplay2 = [];

    listPercentDisplay.clear();
    listPercentDisplay2.clear();

    List<OnSiteTrial> ost = [];
    List<OnSiteTrial> ostAll = [];
    ostAll.addAll(_UserBox!.get(userNameNow).onSiteTrials);

    String nameTrial;
    for (int i = 0; i < ostAll.length; i++) {
      if (ostAll[i].trialId.toString().contains(text.toString())) {
        ost.add(ostAll[i]);

        listPercentDisplay.add(listPercent[i]);
        listPercentDisplay2.add(listPercent2[i]);

        print("----------------------");
      } else {}
    }

    await loadAllTrials(ost, listPercentDisplay, listPercentDisplay2);
  }

  int numPlot = 0;
  int numImg = 0;

  double percentPath = 0.00;
  int numUploaded = 0;

  double percentUpload = 0.00;
  int nPlot = 0;

  double imgAllPlot = 0;
  double uploadAllPlot = 0;

  calculatePercent(ost) {
    listPercent.clear();
    listPercent2.clear();

    setState(() {
      List<OnSiteTrial> ListTrial = _UserBox?.get(userNameNow).onSiteTrials;

      for (int i = 0; i < ListTrial.length; i++) {
        numPlot = 0;
        numImg = 0;
        numUploaded = 0;
        // print("Trial = " + (i + 1).toString());

        for (int j = 0; j < ListTrial[i].onSitePlots.length; j++) {
          // print("trial[i] = " +(i+1).toString() +" plot[j] = " + (j+1).toString() +" path : " + ListTrial[i].onSitePlots[j].plotImgPath);
          numPlot++;

          if (ListTrial[i].onSitePlots[j].plotImgPath != "null") {
            if (File(ListTrial[i].onSitePlots[j].plotImgPath).existsSync()) {
              numImg++;
              imgAllPlot++;
            }
          }
          if (ListTrial[i].onSitePlots[j].isUpload == 1) {
            numUploaded++;
            uploadAllPlot++;
          }
          // print("numplot :" + numPlot.toString() + " numImg :" + numImg.toString());
          // print("numplot :" + numPlot.toString() + " numupload :" + numUploaded.toString());
          //print("Plot ID : " + ListTrial[i].onSitePlots[j].pltId.toString() + " isUpload : " + ListTrial[i].onSitePlots[j].isUpload.toString());

          nPlot++;
        }
        percentPath = numImg.toDouble() / numPlot.toDouble();

        percentUpload = numUploaded.toDouble() / numPlot.toDouble();

        listPercent.add(percentPath);
        listPercent2.add(percentUpload);

        // print("percent Trial " + (i+1).toString() + " : " + percentPath.toString() + "%");
      }

      print(listPercent);
      print(listPercent2);

      // print(nPlot);
      // print(imgAllPlot);
      // print(uploadAllPlot);

      allPercentI = imgAllPlot.toDouble() / nPlot.toDouble();
      print("All Image Percent : " + allPercentI.toString());

      allPercentU = uploadAllPlot.toDouble() / nPlot.toDouble();
      print("All Upload Percent : " + allPercentU.toString());
    });
  }

  loadAllTrials(
      List<OnSiteTrial> ost, List<double> listP1, List<double> listP2) {
    //print("load All");
    //print(ost.length);

    // int i = 0;
    setState(() {
      int i = 0;
      makeExperiments.clear();

      ost.forEach((e) {
        makeExperiments.addAll([
          makeExperiment(
            index: i,
            experimentID: e.trialId,
            userImage: 'assets/images/aiony-haust.jpg',
            feedTime: 'last update ' +
                (new DateTime.fromMillisecondsSinceEpoch(e.lastUpdate))
                    .toString(),
            // feedText: '  index : ${i}  plots = ${e.onSitePlots.length}',
            feedText: '  ${e.onSitePlots.length} plot',
            // feedImage: 'assets/images/corn.png',
            feedImage: imagepathLoader(e.onSitePlots),
            inprogressPercent: listP1[i],
            finishPercent: listP2[i],
            // percentText: 'inprogress: 90 % finished: 50 %')
            percentText: "have photo: " + (listP1[i] * 100).toString() + "%",
            percentText2: "Uploaded: " + (listP2[i] * 100).toString() + "%",
            trialLenght: findPathExist(e.onSitePlots),
          )
        ]);
        i++;
        // i++;
      });
    });
  }

  fetchTrialsOnSever() async {
    String token = _UserBox!.get(userNameNow).token;
    List<Trial> trials = [];
    await _tryConnection();

    if (_isConnectionSuccessful) {
      String url = "$LOCAL_SERVER_IP_URL/api/trial/user/trials";

      var response = await Http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${token}'
        },
      );
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        trials = ObjectList<Trial>.fromJson(
            jsonDecode(response.body), (body) => Trial.fromJson(body)).list;

        // print(trials.length);
        List<OnSiteTrial> trialsUser = _UserBox?.get(userNameNow).onSiteTrials;

        //update trials on phone
        for (int i = 0; i < trials.length; i++) {
          for (int j = 0; j < trialsUser.length; j++) {
            if (trials[i].trialId == trialsUser[j].trialId) {
              if (trials[i].lastUpdate > trialsUser[j].lastUpdate) {
                OnSiteTrial trial = createOnSiteTrialsWithTrials(trials[i]);
                _UserBox?.get(userNameNow).onSiteTrials[j] =
                    compareAndUpdateTrial(trial, trialsUser[j]);
                print("Update Trials ${j}: ${trials[i].trialId}");
                break;
              }
            }
          }
        }
        _UserBox?.get(userNameNow).save();
      }
    }
    await compareUnmatchPlotAndUpdate();
  }

  deletePictureOnTrialByIndex(int index) async {
    print(
        "delete : ${index}  ${_UserBox?.get(userNameNow).onSiteTrials.length}");
    List<OnSitePlot> osp =
        _UserBox?.get(userNameNow).onSiteTrials[index].onSitePlots;
    for (int i = 0; i < osp.length; i++) {
      String path = _UserBox?.get(userNameNow)
          .onSiteTrials[index]
          .onSitePlots[i]
          .plotImgPath;
      print("path : ${path}");
      if (path != "null") {
        print("delete");
        await deleteFile(File('${path}'));
      }
    }
  }

  Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print(e);
    }
  }

  compareUnmatchPlotAndUpdate() async {
    List<OnSitePlot> ospUnmatch = _UserBox?.get(userNameNow).unMatchPlots;
    List<OnSiteTrial> ostPhone = _UserBox?.get(userNameNow).onSiteTrials;
    print("---------update unmatchplot---------");
    // print(" unmatch : " +
    //     ospUnmatch.length.toString() +
    //     "trial :" +
    //     ostPhone.length.toString());
    for (int i = 0; i < ospUnmatch.length; i++) {
      for (int j = 0; j < ostPhone.length; j++) {
        for (int k = 0; k < ostPhone[j].onSitePlots.length; k++) {
          // print(ostPhone[j].onSitePlots.length.toString() + " -=-");
          print(ospUnmatch[i].barcode +
              " || " +
              ostPhone[j].onSitePlots[k].barcode +
              "    " +
              (ospUnmatch[i].barcode == ostPhone[j].onSitePlots[k].barcode)
                  .toString());
          if (ospUnmatch[i].barcode == ostPhone[j].onSitePlots[k].barcode) {
            _UserBox?.get(userNameNow)
                .onSiteTrials[j]
                .onSitePlots[k]
                .plotImgPath = ospUnmatch[i].plotImgPath;
            _UserBox?.get(userNameNow).unMatchPlots.removeAt(i);
            _UserBox?.get(userNameNow).save();
            if (i == ospUnmatch.length) {
              return;
            }
            break;
          }
        }
      }
    }
  }

  OnSiteTrial compareAndUpdateTrial(
      OnSiteTrial trialsOnSever, OnSiteTrial trialOnPhone) {
    //
    List<OnSitePlot> ospUnmatch = _UserBox?.get(userNameNow).unMatchPlots;
    for (int i = 0; i < trialOnPhone.onSitePlots.length; i++) {
      for (int j = 0; j < trialsOnSever.onSitePlots.length; j++) {
        if (trialOnPhone.onSitePlots[i].pltId ==
            trialsOnSever.onSitePlots[j].pltId) {
          trialsOnSever.onSitePlots[j].plotImgPath =
              trialOnPhone.onSitePlots[i].plotImgPath;
          trialsOnSever.onSitePlots[j].isUpload =
              trialOnPhone.onSitePlots[i].isUpload;
        }
      }
    }
    return trialsOnSever;
  }

  Future<void> _tryConnection() async {
    try {
      final response = await InternetAddress.lookup('www.google.com');

      setState(() {
        _isConnectionSuccessful = response.isNotEmpty;
      });
    } on SocketException catch (e) {
      setState(() {
        _isConnectionSuccessful = false;
      });
    }
  }

  OnSiteTrial createOnSiteTrialsWithTrials(Trial trial) {
    List<OnSitePlot> osps = [];
    OnSiteTrial ost = OnSiteTrial(
        trial.trialId,
        trial.aliasName,
        trial.trialActive,
        trial.trialStatus,
        trial.createDate,
        trial.lastUpdate,
        osps);
    if (trial.plots.isNotEmpty) {
      trial.plots.forEach((e) {
        osps.add(OnSitePlot(
            e.plotId,
            e.barcode,
            e.repNo,
            e.abbrc,
            e.entno,
            e.notet,
            e.plotImgPath,
            e.plotImgPathS,
            e.plotImgBoxPath,
            e.plotImgBoxPathS,
            e.uploadDate,
            e.eartnA,
            e.dlernA,
            e.dlerpA,
            e.drwapA,
            e.eartnM,
            e.dlernM,
            e.dlerpM,
            e.drwapM,
            e.approveDate,
            e.plotProgress,
            e.plotStatus,
            e.plotActive,
            0));
      });
    }
    return ost;
  }
}
