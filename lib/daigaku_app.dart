import 'package:bubble/bubble.dart';
import 'package:firebase_tutorial/pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DaigakuApp extends StatelessWidget {
  const DaigakuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('GDSCAPP'), actions: [
        IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return HomePage();
              }));
            })
      ]),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 154,
                  height: 230,
                  child: Image.asset(
                    'img/tcubird.png',
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Bubble(
                    margin: BubbleEdges.only(top: 10),
                    alignment: Alignment.topLeft,
                    nip: BubbleNip.leftTop,
                    child: Text('今日の天気は○○です。\n今日の図書館は22:00まで。'),
                  ),
                ),
              ],
            ),
            Image.asset(
              'img/tcu_map.png',
              fit: BoxFit.contain,
            ),
            // Row(
            //   children: [
            //     TextButton(
            //       onPressed: () {/* ボタンがタップされた時の処理 */},
            //       child: Text('教室'),
            //     ),
            //     TextButton(
            //       onPressed: () {/* ボタンがタップされた時の処理 */},
            //       child: Text('食堂'),
            //     ),
            //     TextButton(
            //       onPressed: () {/* ボタンがタップされた時の処理 */},
            //       child: Text('図書室'),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
