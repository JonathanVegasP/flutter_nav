import 'package:flutter/material.dart';

import '../nav_data.dart';
import '../nav_page.dart';

class UnknownPage<T> extends NavPage<T> {
  UnknownPage()
      : super(
          name: 'Page Not Found',
          restorationId: '/404',
          arguments: navData(uri: Uri.parse('/404'), pathParams: const {}),
          child: Scaffold(
            backgroundColor: const Color(0xFFF2F2F2),
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
          ),
        );
}
