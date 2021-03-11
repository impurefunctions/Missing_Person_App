import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF78909C),
        title: Text("About"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "STOCKiT",
                style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
              ),
            ),
            Text("Version 1.0.0"),

            Padding(
              padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
            ),
            Divider(
              height: 20.0,
              color: Colors.grey,
            ),
            Container(
              padding: const EdgeInsets.only(left: 8.0),
              alignment: Alignment.topLeft,
              child: Text(
                "About StockIt",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(

              "STOCKiT assits the farmers and the small businesses that are involved in meat industries to upload the information and compare with others."),  ),
            Container(
              padding: const EdgeInsets.only(left: 8.0),
              alignment: Alignment.topLeft,
              child: Text(
                "Privacy & Policy",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "STOCKiT enables you to trade amongst other farmers and small businesses within the safety and convenience in your area. We make it safer easier and cheaper to trade your products at your comfort. For example,  you can compare the prices of the items that are available on STOCKiT from different butcheries. It takes meer seconds to upload a items and meer seconds to find the available items you need on the platform."),
            )
          ],
        ),
      ),
    );
  }
}
