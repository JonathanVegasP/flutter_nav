import 'package:flutter/material.dart';

class PageNotFoundWidget extends StatelessWidget {
  const PageNotFoundWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
      body: Center(
        child: Text(
          '404\nPage Not Found',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            color: const Color(0xFF161616).withOpacity(0.72),
          ),
        ),
      ),
    );
  }
}
