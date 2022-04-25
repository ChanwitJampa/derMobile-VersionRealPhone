import 'package:flutter/material.dart';

import 'components/custom-button.dart';
import 'app-scale.dart';

class Utils {



  static getButton(
      {required String text,
      required VoidCallback onPressed,
      double width: 0.75,
      double height: 0.055,
      Color? color,
      double fontScale : 0.019,
      Color? bgColor,
      Widget? icon,
      OutlinedBorder? shape,
      bool mini : false}) {
    return !mini ?
      CustomSigInButton(
        text: text,
        onPressed: onPressed,
        width: width,
        height: height,
        color: color,
        fontScale: fontScale,
        bgColor: bgColor,
        icon: icon,
        shape: shape,)
    :CustomSigInButton.mini(
      text: text,
      onPressed: onPressed,
      width: width,
      height: height,
      color: color,
      fontScale: fontScale,
      bgColor: bgColor,
      icon: icon,
      shape: shape,);
  }

  static getAppBar(BuildContext context, {bool canGoBack = false}) {
    AppScale scale = AppScale(context);

    return AppBar(
      title: Text('Single Sign-On'),
      toolbarHeight: scale.ofHeight(0.076),
      leading: canGoBack
          ? new IconButton(
              icon: new Icon(Icons.arrow_back, size: scale.ofHeight(0.033)),
              onPressed: () => Navigator.pop(context))
          : null,
      // elevation: 0,
      centerTitle: true,
    );
  }
}
