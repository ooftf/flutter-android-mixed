import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
class ListDemoWidget extends StatelessWidget {
  final _items  = <WordPair>[];
  final _favorite = new Set<WordPair>();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemBuilder: (context, position) {

      return new ListTile(title: new Text(_items[position].asPascalCase,style: _biggerFont));
    });
  }
}
