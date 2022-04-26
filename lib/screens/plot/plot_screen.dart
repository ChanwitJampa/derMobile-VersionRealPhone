import 'dart:convert';
import 'dart:io';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:der/entities/site/plot.dart';
import 'package:der/entities/site/trial.dart';
import 'package:der/main.dart';
import 'package:der/screens/select_Image.dart';
import 'package:der/screens/main/signup_screen.dart';
import 'package:der/utils/router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spincircle_bottom_bar/modals.dart';
import 'package:spincircle_bottom_bar/spincircle_bottom_bar.dart';
import 'package:der/model/check_box.dart';
import 'package:der/screens/main/main_screen.dart';
import 'package:der/utils/app_popup_menu.dart';
import 'package:der/utils/constants.dart';

import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;

import 'package:async/async.dart';
import 'package:http/http.dart' as http;

import 'package:der/env.dart';

Box? _UserBox;

class PlotsScreen extends StatefulWidget {
  final String title;
  PlotsScreen({Key? key, required this.title}) : super(key: key);

  @override
  _PlotsScreen createState() => _PlotsScreen(int.parse(this.title));
}

class _PlotsScreen extends State<PlotsScreen> {
  var _image;

  final int title;
  Size? deviceSize;
  List<Widget> plotList = [];
  _PlotsScreen(this.title);

  @override
  void initState() {
    super.initState();
    _UserBox = Hive.box("Users");

    _requestPermisstion();

    List<OnSitePlot> ost =
        _UserBox!.get(userNameNow).onSiteTrials[title].onSitePlots;
    displayPlots(ost);
  }

  _requestPermisstion() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();
  }

  final allChecked = CheckBoxModal(title: 'All Checked');

  final plotItems = [
    CheckBoxModal(title: 'CheckBox 1'),
    CheckBoxModal(title: 'CheckBox 2'),
    CheckBoxModal(title: 'CheckBox 3'),
  ];
  bool isLoading = false;

  Future _loadData() async {
    //await new Future.delayed(new Duration(seconds: 2));
    //print("testtest");
    //print("load more");
    // update data and loading status
    setState(() {
      plotItems.addAll([CheckBoxModal(title: 'Item1')]);
      //print('items: '+ items.toString());
      isLoading = false;
    });
  }

  Widget listAllPlot() {
    return Expanded(
        child: NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!isLoading &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _loadData();
          // start loading data
          setState(() {
            isLoading = true;
          });
        }
        return isLoading;
      },
      child: ListView(
        children: [
          ListTile(
            onTap: () => onAllClicked(allChecked),
            leading: Checkbox(
                value: allChecked.value,
                onChanged: (value) => onAllClicked(allChecked)),
            title: Text(
              allChecked.title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(),
          ...plotItems.map((item) => ListTile(
                onTap: () => onItemClicked(item),
                leading: Checkbox(
                  value: item.value,
                  onChanged: (value) => onItemClicked(item),
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
        ],
      ),
    ));
  }

  imagepathLoader(String feedImage) {
    Image image;

    if (File(feedImage).existsSync()) {
      return new RotationTransition(
        turns: new AlwaysStoppedAnimation(0 / 360),
        child: new Image.file(
          File(feedImage),
          // child: new Image.asset(
          //   feedImage,
          height: 500,
          width: 700,
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.all(50.0),
        height: 300,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            image: DecorationImage(
                image: AssetImage("assets/images/img_not.png"),
                fit: BoxFit.cover)),
      );
    }
  }

  Widget makePlot(
      {isLock,
      plotID,
      userImage = "assets/images/unknown_user.png",
      feedTime,
      feedText,
      feedImage}) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage(userImage), fit: BoxFit.cover)),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        plotID,
                        style: TextStyle(
                            color: Colors.grey[900],
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        feedTime,
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    ],
                  )
                ],
              ),
              InkWell(
                child: Container(
                  height: 30,
                  width: 30,
                  margin:
                      EdgeInsets.only(top: 0, right: 10, left: 0, bottom: 0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: AssetImage(
                              'assets/images/arrow_curved_forward_right.png'),
                          fit: BoxFit.cover)),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(ASSESSMENT_ROUTE);
                },
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Center(
              child: Text(
            feedText,
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[800],
              height: 1.5,
              letterSpacing: .7,
            ),
          )),
          SizedBox(
            height: 10,
          ),
          feedImage != "null"
              ? imagepathLoader(feedImage)
              // Container(
              //     height: 200,
              //     decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(10),
              //         image: DecorationImage(
              //             image: AssetImage(feedImage), fit: BoxFit.cover)),
              //   )
              : Container(
                  margin: const EdgeInsets.all(50.0),
                  height: 300,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                          image: AssetImage("assets/images/img_not.png"),
                          fit: BoxFit.cover)),
                ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  if (isLock == "Open") ...[
                    makeLock(isLock: false),
                  ] else ...[
                    makeLock(isLock: true)
                  ]

                  /*
                  makeLike(),
                  Transform.translate(
                      offset: Offset(-5, 0),
                      child: makeLove()
                  ),
                  SizedBox(width: 5,),
                  Text("2.5K", style: TextStyle(fontSize: 15, color: Colors.grey[800]),)
                  */
                ],
              ),
              //Text("400 Comments", style: TextStyle(fontSize: 13, color: Colors.grey[800]),)
            ],
          ),
          SizedBox(
            height: 20,
          ),
          //SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              makeCameraButton(plotID),
              makeGallryButton(plotID),
              if (isLock == "Open") ...[makeShareButton(plotID)]
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            height: 3,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget makeLock({required bool isLock}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
          color: (isLock) ? Colors.red : Colors.blue,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white)),
      child: Center(
        child: Icon((isLock) ? Icons.lock : Icons.thumb_up,
            size: 15, color: Colors.white),
      ),
    );
  }

  Widget makeLike() {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white)),
      child: Center(
        child: Icon(Icons.thumb_up, size: 12, color: Colors.white),
      ),
    );
  }

  Widget makeLove() {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white)),
      child: Center(
        child: Icon(Icons.lock, size: 12, color: Colors.white),
      ),
    );
  }

  final picker = ImagePicker();
  _upload(File imageFile, String plotID, int index) async {
    // open a bytestream
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    // get file length
    var length = await imageFile.length();

    // string to uri
    var uri = Uri.parse("$LOCAL_SERVER_IP_URL/api/plot/upload");

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);

    // multipart that takes file
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: p.basename(imageFile.path));

    // add file to multipart
    request.files.add(multipartFile);
    request.fields['plot'] = plotID.toString();
    request.fields['username'] = userNameNow.toString();
    String token = _UserBox!.get(userNameNow).token;
    request.headers.addAll({"Authorization": "Bearer ${token}"});
    // send
    var response = await request.send();
    print(response.statusCode);

    if (response.statusCode == 200) {
      _UserBox?.get(userNameNow)
          .onSiteTrials[title]
          .onSitePlots[index]
          .isUpload = 1;
      // print(_UserBox?.get(userNameNow).onSiteTrials[title].onSitePlots[index].isUpload);

      // _UserBox?.get(userNameNow).save();

    } else {
      //ALERTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT

    }
    _UserBox?.get(userNameNow).save();
    print(_UserBox?.get(userNameNow)
        .onSiteTrials[title]
        .onSitePlots[index]
        .isUpload);

    // listen for response
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
  }

  _getImage(ImageSource imageSource, String plotId) async {
    final _imageFile = await picker.pickImage(
      source: imageSource,
      maxWidth: 1000,
      maxHeight: 1000,
      //imageQuality: quality,
    );

//if user doesn't take any image, just return.
    if (_imageFile == null) {
      // print("null");
      return;
    }
    setState(
      () {
        //print("not null");
        _image = _imageFile;
        isSelected = true;
        saveExperiment(_image, plotId);
        //_imageFileList = pickedFile;
//Rebuild UI with the selected image.
        //print('$_image');
        //_image = File(pickedFile.path);
      },
    );
  }

  bool isSelected = false;

  Widget makeCameraButton(String plotId) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.camera,
              color: Colors.blue,
              size: 20,
            ),
            SizedBox(
              width: 10,
            ),
            Container(
              child: InkWell(
                child: Container(
                  child: Text(
                    //iconcamera
                    "Camera",
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
                onTap: () {
                  _getImage(ImageSource.camera, plotId);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Directory>?>? _externalStorageDirectories;

  Future<void> saveExperiment(XFile impath, String plotId) async {
    Directory? directory;
    String testpath = "";

    await GallerySaver.saveImage(impath.path);

    final _filename = p.basename(impath.path);
    directory = await getExternalStorageDirectory();

    print("tempPath3 = " + directory!.path);
    print("FileName = " + _filename);

    int count1 = 0;

    if (count1 == 0) {
      galleryPath = "";
      for (int i = 0; i < directory.path.length; i++) {
        print(directory.path[i]);

        galleryPath = galleryPath + directory.path[i];

        if (directory.path[i] == "0") {
          break;
          count1 = 1;
        }
      }
    }

    galleryPath = galleryPath + "/Pictures/";
    testpath = galleryPath + _filename;

    print("galleryPath = " + galleryPath);
    print("imgPath = " + testpath);

    print(impath.path);
    _image = null;

    _UserBox = Hive.box("Users");
    List<OnSiteTrial> ost = _UserBox?.get(userNameNow).onSiteTrials;
    int i = 0, j = 0;
    for (i = 0; i < ost.length; i++) {
      for (j = 0; j < ost[i].onSitePlots.length; j++) {
        // print("${plotId}" +
        //     ost[i].onSitePlots[j].pltId.toString() +
        //     "    ${plotId == ost[i].onSitePlots[j].pltId.toString()}");
        if (plotId == ost[i].onSitePlots[j].pltId.toString()) {
          _UserBox?.get(userNameNow)
              .onSiteTrials[i]
              .onSitePlots[j]
              .plotImgPath = testpath;
          _UserBox?.get(userNameNow).save();
          // print("this is save now ----------------------- " +
          //     _UserBox?.get(userNameNow)
          //         .onSiteTrials[i]
          //         .onSitePlots[j]
          //         .plotImgPath);
        }
      }
    }
    setState(() {
      OnSiteTrial onSiteTrial = _UserBox?.get(userNameNow).onSiteTrials[title];
      plotList.clear();
      onSiteTrial.onSitePlots.forEach((e) {
        String isStatus = "";
        if (e.plotStatus == "Open") {
          isStatus = "Open";
        }
        plotList.addAll([
          makePlot(
            isLock: isStatus,
            plotID: e.pltId.toString(),
            feedTime: (new DateTime.fromMillisecondsSinceEpoch(e.uploadDate))
                .toString(),
            feedText:
                // "Status : ${e.plotStatus}   repNO : ${e.repNo} barcode : ${e.barcode} uploaded : ${e.isUpload} "   ,
                "Status : ${e.plotStatus}   repNO : ${e.repNo} barcode : ${e.barcode} uploaded : ${e.isUpload} ",
            feedImage: e.plotImgPath,
          )
        ]);
      });
    });

    // Navigator.of(context).pushNamed(PLOT_ROUTE);
  }

  Widget makeGallryButton(String plotID) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.photo,
              color: Colors.blue,
              size: 20,
            ),
            SizedBox(
              width: 5,
            ),
            Container(
              child: InkWell(
                child: Container(
                  child: Text(
                    "Gallery",
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
                onTap: () {
                  _getImage(ImageSource.gallery, plotID);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget makeShareButton(String plotId) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.upload, color: Colors.blue, size: 20),
            SizedBox(
              width: 5,
            ),
            Container(
              child: InkWell(
                child: Container(
                  child: Text(
                    //iconupload
                    "Upload",
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Upload Plot'),
                          content: Text('Confirm to upload this plot'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                List<OnSitePlot> ost =
                                    _UserBox?.get(userNameNow)
                                        .onSiteTrials[title]
                                        .onSitePlots;
                                int lenght = ost.length;
                                print("upload plot iD is" +
                                    plotId.toString() +
                                    " length :" +
                                    lenght.toString());
                                String filePath = "";
                                for (int i = 0; i < lenght; i++) {
                                  print("${ost[i].pltId} +++ ${plotId}");
                                  if (ost[i].pltId.toString() ==
                                      plotId.toString()) {
                                    filePath = ost[i].plotImgPath;

                                    _upload(File(filePath), plotId, i);

                                    _UserBox?.get(userNameNow)
                                        .onSiteTrials[title]
                                        .onSitePlots[i]
                                        .isUpload = 1;

                                    print("${filePath}" +
                                        " plot id : " +
                                        plotId +
                                        " UPLOAD " +
                                        " : ${_UserBox?.get(userNameNow).onSiteTrials[title].onSitePlots[i].isUpload}");

                                    break;
                                  }
                                }
                                Navigator.pop(context);
                              },
                              child: Text('Upload'),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myController = TextEditingController();
    void dispose() {
      // Clean up the controller when the widget is disposed.
      myController.dispose();
      super.dispose();
    }

    deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                // color: Colors.blue,
                color: Color(0xFF398AE5),

                height: 120,
                padding:
                    EdgeInsets.only(top: 50, right: 20, left: 20, bottom: 10),
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
                          await serchPlots(text);
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
                          hintText:
                              "Search plot in ${_UserBox!.get(userNameNow).onSiteTrials[title].trialId} ",
                          suffixIcon: InkWell(
                            child: const Icon(
                              Icons.qr_code,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              Navigator.of(context).pushNamed(SCAN_QR_ROUTE);
                            },
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              Positioned(
                right: -10.0,
                top: 100.0,
                child: Container(
                  height: 50,
                  child: Column(
                    //height: 10,
                    children: [
                      AppPopupMenu(
                        icon: Icon(
                          Icons.filter_list,
                          size: 20,
                        ),
                        items: [
                          'all',
                          'have picture',
                          'not have picture on phone'
                        ],
                        onSelected: (value) {
                          //print(value);

                          int i = 0;
                          List<OnSitePlot> ost = [];
                          ost.addAll(_UserBox!
                              .get(userNameNow)
                              .onSiteTrials[title]
                              .onSitePlots);

                          if (value == "all") {
                            displayPlots(ost);
                          } else if (value == 'have picture') {
                            // String isStatus = "";
                            plotList.clear();
                            //print("length ost is : ${ost.length}");
                            for (int j = 0; j < ost.length; j++) {
                              //print("${ost[j].plotImgPath}");
                              if (ost[j].plotImgPath != "null") {
                                if (!(File(ost[j].plotImgPath).existsSync())) {
                                  _UserBox?.get(userNameNow)
                                      .onSiteTrials[title]
                                      .onSitePlots[j]
                                      .plotImgPath = "null";
                                  ost.removeAt(j);
                                  j--;
                                }
                              } else {
                                // = null
                                ost.removeAt(j);
                                j--;
                              }
                            }
                            displayPlots(ost);
                          } else if (value == 'not have picture on phone') {
                            plotList.clear();
                            String isStatus = "";
                            plotList.clear();

                            for (int j = 0; j < ost.length; j++) {
                              print("${ost[j].plotImgPath}");
                              if (ost[j].plotImgPath != "null") {
                                //มี path
                                if (!(File(ost[j].plotImgPath).existsSync())) {
                                  //มี path แต่ รูปเอามาแสดงไม่ได้
                                  _UserBox?.get(userNameNow)
                                      .onSiteTrials[title]
                                      .onSitePlots[j]
                                      .plotImgPath = "null";
                                  _UserBox?.get(userNameNow).save();
                                } else {
                                  // มี path มีรูป
                                  ost.removeAt(j);
                                  j--;
                                }
                              }
                            }
                            displayPlots(ost);
                          }
                        },
                        offset: const Offset(0, 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: EdgeInsets.all(10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
              child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Column(
                children: plotList,
              ),
            ),
          )),
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
        onTap: (int i) => Navigator.of(context).pushReplacementNamed('$i'),
      ),
    );
  }

  onAllClicked(CheckBoxModal item) {
    final newValue = !item.value;
    setState(() {
      allChecked.value = !allChecked.value;
      plotItems.forEach((element) {
        element.value = newValue;
      });
    });
  }

  onItemClicked(CheckBoxModal item) {
    setState(() {
      item.value = !item.value;
    });
  }

  serchPlots(String text) async {
    List<OnSitePlot> osp = [];
    List<OnSitePlot> ospAll = [];
    ospAll.addAll(_UserBox!.get(userNameNow).onSiteTrials[title].onSitePlots);
    // print(
    //     "First text field: $text  length osp is : ${osp.length} test : ${osp[0].pltId.toString().contains("333333")}");
    String namePlot;
    for (int i = 0; i < ospAll.length; i++) {
      if (ospAll[i].pltId.toString().contains(text.toString()) ||
          ospAll[i].barcode.toString().contains(text.toString())) {
        osp.add(ospAll[i]);
      }
    }

    await displayPlots(osp);
  }

  displayPlots(List<OnSitePlot> ost) {
    // print("Path");
    // for(int i = 0 ; i< _UserBox?.get(userNameNow)
    //                                     .onSiteTrials[title]
    //                                     .onSitePlots.length ; i++){
    //         print(ost[i].plotImgPath);
    //                                     }

    setState(() {
      _UserBox = Hive.box("Users");
      int i = 0;
      String isStatus = "";
      plotList.clear();
      ost.forEach((e) {
        isStatus = "";
        if (e.plotStatus == "Open") {
          isStatus = "Open";
        }
        plotList.addAll([
          makePlot(
            isLock: isStatus,
            plotID: e.pltId.toString(),
            feedTime: (new DateTime.fromMillisecondsSinceEpoch(e.uploadDate))
                .toString(),
            feedText:
                "${e.barcode} Status : ${e.plotStatus}   repNO : ${e.repNo}  uploaded : ${e.isUpload} ",
            feedImage: e.plotImgPath,
          )
        ]);
      });
    });
  }
}
