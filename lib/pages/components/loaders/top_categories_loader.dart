import 'package:flutter/material.dart';

class TopCategoriesLoader extends StatelessWidget {
  const TopCategoriesLoader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: 15),
            child: Column(
              children: [
                Container(
                  width: 63.0,
                  height: 63.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.1)),
                ),
                SizedBox(height: 10),
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 15),
            child: Column(
              children: [
                Container(
                  width: 63.0,
                  height: 63.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.1)),
                ),
                SizedBox(height: 10),
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 15),
            child: Column(
              children: [
                Container(
                  width: 63.0,
                  height: 63.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.1)),
                ),
                SizedBox(height: 10),
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 15),
            child: Column(
              children: [
                Container(
                  width: 63.0,
                  height: 63.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.1)),
                ),
                SizedBox(height: 10),
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 15),
            child: Column(
              children: [
                Container(
                  width: 63.0,
                  height: 63.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.1)),
                ),
                SizedBox(height: 10),
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
