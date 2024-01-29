import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DropDownWithLabel extends HookWidget {
  final String placeholder, currentValue;
  final bool isPassword;
  final List items;
  final Function controller;
  DropDownWithLabel({
    Key? key,
    required this.controller,
    required this.placeholder,
    required this.currentValue,
    required this.items,
    this.isPassword = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final focused = useState(false);
    final myvalue = useState(currentValue.length > 0 ? currentValue : "US");
    final loading = useState(true);
    loadData() async {
      await Future.delayed(Duration(seconds: 1));
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
              style: TextStyle(color: Color(0xFF545454)),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            color: focused.value ? Color(0xFFEFEFE1) : Colors.white,
            border: Border.all(
              color: focused.value
                  ? Color(0xFF0C979F).withOpacity(0.8)
                  : Color(0xFF0C979F).withOpacity(0.1),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              loading.value
                  ? SizedBox(
                      height: 48,
                    )
                  : DropdownButton<String>(
                      underline: SizedBox(),
                      value: myvalue.value,
                      //elevation: 5,
                      style: TextStyle(color: Colors.black),

                      items: items.map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem<String>(
                          value: value['code'],
                          child: Text("${value['name']}"),
                        );
                      }).toList(),
                      hint: Text(
                        "Please choose a langauage",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      onChanged: (value) {
                        print(value);
                        controller(value);
                        myvalue.value = value.toString();
                        // setState(() {
                        //   _chosenValue = value;
                        // });
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
