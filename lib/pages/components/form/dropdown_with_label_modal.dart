import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shopforge/config/app.dart';
import 'package:shopforge/pages/components/shop/close_widget.dart';
import 'package:shopforge/utils/Providers.dart';

class DropDownWithLabelModal extends HookWidget {
  final String placeholder, currentValue;
  final List items;
  final Function controller;
  DropDownWithLabelModal({
    Key? key,
    required this.controller,
    required this.placeholder,
    required this.currentValue,
    required this.items,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final focused = useState(false);
    final loading = useState(true);
    final myvalue = useState(currentValue.length > 0 ? currentValue : "US");

    loadData() async {
      await Future.delayed(Duration(milliseconds: 500));
      loading.value = false;
    }

    useEffect(() {
      loadData();
    }, const []);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 4),
            Text(
              "$placeholder",
              style: TextStyle(
                  color:
                      color.state == 'dark' ? darkModeText : Color(0xFF545454)),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.only(left: 16, right: 16),
          decoration: BoxDecoration(
            color: focused.value
                ? color.state == 'dark'
                    ? primaryText.withOpacity(0.5)
                    : Color(0xFFEFEFE1)
                : color.state == 'dark'
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white,
            border: Border.all(
              color: focused.value
                  ? Color(0xFF0C979F).withOpacity(0.8)
                  : color.state == 'dark'
                      ? Color(0xFF4B464B)
                      : Color(0xFF0C979F).withOpacity(0.1),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: InkWell(
            onTap: () => showMaterialModalBottomSheet(
              backgroundColor: Colors.transparent,
              barrierColor: Colors.black.withOpacity(0.5),
              context: context,
              builder: (context) => DropDownData(
                  items: items,
                  controller: controller,
                  currentValue: currentValue,
                  myvalue: myvalue),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${this.items.firstWhere((element) => element['code'] == myvalue.value)['name']}",
                    style: TextStyle(
                      color: color.state == 'dark' ? Colors.white : primaryText,
                    ),
                  ),
                  SvgPicture.asset(
                    iconsPath + 'chevron-down.svg',
                    color: color.state == 'dark' ? Colors.white : primaryText,
                    width: 24,
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DropDownData extends HookWidget {
  final List items;
  final Function controller;
  final String currentValue;
  final ValueNotifier myvalue;
  const DropDownData({
    Key? key,
    required this.items,
    required this.controller,
    required this.currentValue,
    required this.myvalue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = useProvider(colorProvider);
    final loading = useState(true);

    loadData() async {
      await Future.delayed(Duration(seconds: 1));
      loading.value = false;
    }

    useEffect(() {
      loadData();
    }, const []);
    return Container(
        padding: EdgeInsets.symmetric(vertical: 25),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
            color: color.state == 'dark' ? primaryText : Colors.white,
            borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pick a country",
                  style: TextStyle(
                      color: color.state == 'dark' ? Colors.white : primaryText,
                      fontWeight: FontWeight.w600),
                ),
                CloseWidget(),
              ],
            ),
          ),
          SizedBox(height: 25),
          Expanded(
            child: SingleChildScrollView(
              child: loading.value
                  ? Container(
                      margin: EdgeInsets.only(top: 40),
                      child: SpinKitFadingCube(
                        color: colorPrimary,
                        size: 20.0,
                      ),
                    )
                  : Column(
                      children: [
                        ...items.map((item) => Material(
                              color: color.state == 'dark'
                                  ? primaryText
                                  : Colors.white12,
                              child: InkWell(
                                onTap: () => {
                                  controller(item['code']),
                                  myvalue.value = item['code'],
                                  Navigator.pop(context)
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 25),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        myvalue.value == item['code']
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off_outlined,
                                        color: myvalue.value == item['code']
                                            ? colorPrimary
                                            : color.state == 'dark'
                                                ? darkModeTextHigh
                                                : primaryText,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                          child: Text(
                                        "${item['name']}",
                                        style: TextStyle(
                                            color: color.state == 'dark'
                                                ? darkModeTextHigh
                                                : primaryText),
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                            ))
                      ],
                    ),
            ),
          )
        ]));
  }
}
