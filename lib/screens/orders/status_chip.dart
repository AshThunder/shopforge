import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    Key? key,
    required this.status,
  }) : super(key: key);

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 7, horizontal: 15),
        decoration: BoxDecoration(
            color: status == 'pending'
                ? Color(0xFFEDBA06)
                : status == 'processing' || status == 'on-hold'
                    ? Colors.purple
                    : status == 'completed'
                        ? Colors.green
                        : status == 'cancelled' || status == 'failed'
                            ? Colors.red
                            : status == 'refunded'
                                ? Colors.blue
                                : Colors.black,
            borderRadius: BorderRadius.circular(20)),
        child: Text(
          "${status[0].toString().toUpperCase()}${status.substring(1)}",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ));
  }
}
