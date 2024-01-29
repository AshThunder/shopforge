import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shopforge/pages/components/form/botton_widget.dart';

import 'config/app.dart';
import 'pages/dashboard.dart';

class Onboarding extends HookWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CarouselController _controller = CarouselController();
    final _current = useState(0);
    List images = [
      {
        "title": "Shopping just made easy",
        "body": "We make you enjoy a shopping experience you truly deserve",
        "url": "assets/images/home.jpg"
      },
      {
        "title": "Shopping just made easy",
        "body": "We make you enjoy a shopping experience you truly deserve",
        "url": "assets/images/home1.jpeg"
      },
      {
        "title": "Shopping just made easy",
        "body": "We make you enjoy a shopping experience you truly deserve",
        "url": "assets/images/home2.jpeg"
      }
    ];

    startShopping() async {
      var box = await Hive.openBox('appBox');
      box.put('boarded', 'yes');
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Dashboard()),
          (Route<dynamic> route) => false);
    }

    final List<Widget> imageSliders = images
        .map((each) => Container(
              color: colorPrimary,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Image.asset(
                      "${each['url']}",
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  Positioned(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black, Colors.black.withOpacity(0)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      padding: EdgeInsets.only(bottom: 160.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "${each['title']}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            '${each['body']}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFBDBDBD),
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ))
        .toList();
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CarouselSlider(
                  items: imageSliders,
                  carouselController: _controller,
                  options: CarouselOptions(
                      autoPlay: true,
                      height: MediaQuery.of(context).size.height,
                      viewportFraction: 1,
                      onPageChanged: (index, reason) {
                        _current.value = index;
                      }),
                ),
                Positioned(
                  bottom: 40,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: images.asMap().entries.map((entry) {
                            return GestureDetector(
                              onTap: () => _controller.animateToPage(entry.key),
                              child: Container(
                                width:
                                    _current.value == entry.key ? 30.0 : 12.0,
                                height: 12.0,
                                margin: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: _current.value == entry.key
                                            ? colorPrimary
                                            : Color(0xFFBDBDBD),
                                        width: 1.5),
                                    //shape: BoxShape.circle,
                                    borderRadius: BorderRadius.circular(6),
                                    color: _current.value == entry.key
                                        ? colorPrimary
                                        : Colors.transparent),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ButtonWidget(
                              action: () => startShopping(),
                              text: "Start Shopping",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
