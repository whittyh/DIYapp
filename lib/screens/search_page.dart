import 'dart:async';

import 'package:diy/widgets/drawer.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  SearchPageState createState() => SearchPageState();
}

Icon customIcon = const Icon(Icons.search);
Widget customSearchBar = const Text('Search DIY Journals');

class SearchPageState extends State<SearchPage> {
  TextEditingController editingController = TextEditingController();
  //final List<String> entries = <String>['A', 'B', 'C', 'D',
  //'E','F','G', 'H', 'I', 'J', 'K', 'L','M','N','O','P',
  //'Q','R', 'S', 'T', 'U','V','W','X','Y','Z'];
  final duplicateItems = List<String>.generate(100, (i) => "Item $i");
  var items = <String>[];

  @override
  void initState() {
    items.addAll(duplicateItems);
    super.initState();
  }

  void filterSearchResults(String query) {
    List<String> dummySearchList = <String>[];
    dummySearchList.addAll(duplicateItems);
    if (query.isNotEmpty) {
      List<String> dummyListData = <String>[];
      dummySearchList.forEach((item) {
        if (item.contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(duplicateItems);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: const Text('Search Page'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                filterSearchResults(value);
              },
              controller: editingController,
              decoration: const InputDecoration(
                  labelText: "Search for DIY Articles",
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: "Search",
                  fillColor: Color.fromRGBO(200, 200, 200, 0),
                  hintStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 50,
                  color: Colors.grey[900],
                  child: Center(
                      child: Text(
                    'Entry ${items[index]}',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  )),
                );
              },
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
    );
  }
}
