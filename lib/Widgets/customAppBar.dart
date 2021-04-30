
import 'package:ecommerce/notifiers/cartitemcounter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class MyAppBar extends StatelessWidget with PreferredSizeWidget {
  final PreferredSizeWidget bottom;
  final Widget leading;
  MyAppBar({this.bottom, this.leading});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      centerTitle: true,
      title: Text("SEARCH_TSWANA"),
      bottom: bottom,
      leading: leading,
      backgroundColor: Colors.blueGrey,
    );
  }


  // Adding 80 because height of bottom SearchBox container is 80
  @override
  // TODO: implement preferredSize
  Size get preferredSize => bottom==null?Size(56,AppBar().preferredSize.height):Size(56, 80+AppBar().preferredSize.height);
}
