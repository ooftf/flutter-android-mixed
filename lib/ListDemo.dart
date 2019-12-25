import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ListDemoWidget extends StatelessWidget {
  final _items = <WordPair>[];
  final _favorite = new Set<WordPair>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    _items.addAll(generateWordPairs().take(50));
    return MaterialApp(
        title: "ListDemo",
        theme: ThemeData(primarySwatch: Colors.blue),
        home: new Scaffold(
          appBar: _buildTitle(),
          body: _buildList(),
        ));
  }

  Widget _buildTitle() {
    return AppBar(title: new Center(child: Text("ListDemoo")));
  }

  Widget _buildList() {
    return ListView.builder(
      itemBuilder: (context, position) {
        return _buildItem(position);
      },
      itemCount: _items.length,
      padding: const EdgeInsets.all(16.0),
    );
  }

  Widget _buildItem(int position) {
    final text = _items[position];
    final isSelected = _favorite.contains(text);
    return ListTile(
      title: new Text(
        text.asPascalCase,
        textDirection: TextDirection.ltr,
        style: _biggerFont,
      ),
      trailing: new Icon(isSelected ? Icons.favorite : Icons.favorite_border),
      onLongPress: (){_favorite.add(text);},
    );
  }
}
