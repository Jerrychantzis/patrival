// ignore_for_file: use_super_parameters, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double heightPercentage;
  final BuildContext context;

  const CustomAppBar({Key? key, required this.context, required this.heightPercentage}) : super(key: key);

  @override
  Size get preferredSize {
    return Size.fromHeight(MediaQuery.of(context).size.height * heightPercentage / 100);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: InkWell(
        onTap: () {
          // Navigate to WebViewPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WebViewPage(url: 'https://www.carnivalpatras.gr/')),
          );
        },
        child: Image.asset(
          'lib/pictures/logo_cp_edited.gif',
          height: 150,
          width: double.infinity,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.lightBlue,
      toolbarHeight: MediaQuery.of(context).size.height * heightPercentage / 100,
    );
  }
}


class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
      ),
    );
  }
}
