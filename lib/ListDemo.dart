import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ListDemoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemBuilder: (context, i) {
      return Center(child: Text(i.toString()));
    });
  }
}
