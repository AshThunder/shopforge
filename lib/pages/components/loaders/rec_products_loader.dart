import 'package:flutter/material.dart';

class RecProductsLoader extends StatelessWidget {
  const RecProductsLoader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        EachLoader(),
        EachLoader(),
        EachLoader(),
        EachLoader(),
        EachLoader(),
        EachLoader(),
      ],
    );
  }
}

class EachLoader extends StatelessWidget {
  const EachLoader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 125,
      margin: EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: 125,
              height: 133,
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.all(Radius.circular(2.0)))),
          SizedBox(height: 10),
          Container(
            width: 120,
            height: 12,
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
          ),
          SizedBox(height: 10),
          Container(
            width: 60,
            height: 11,
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
          ),
        ],
      ),
    );
  }
}
