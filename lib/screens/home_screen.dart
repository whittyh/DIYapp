// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:diy/models/article.dart';
import 'package:diy/screens/view_article.dart';
import 'package:diy/screens/add_article.dart';
import 'package:diy/widgets/drawer.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? atSign = AtClientManager.getInstance().atClient.getCurrentAtSign();
  var atClientManager = AtClientManager.getInstance();
  // AtClientService? _clientService =
  Future? yourArticles;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: const Center(child: Text('Home             ')),
      ),
      body: Column(
        children: [
          Container(
              alignment: Alignment.topCenter,
              width: 200.0,
              height: 250.0,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(
                          "https://st4.depositphotos.com/20524830/26002/i/1600/depositphotos_260028644-stock-photo-spanner-wrench-white-background.jpg")))),
          Text(
            '${atClientManager.atClient.getCurrentAtSign()}',
            style: const TextStyle(fontSize: 25, color: Colors.white),
          ),
          Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.grey[850]),
                onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddArticle()),
                  )
                },
                child: const Text("Add Article",
                    style: TextStyle(color: Colors.white)),
              )),
          FutureBuilder(
            future: scanYourArticles(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                List<Map<String, dynamic>> results = snapshot.data;
                return Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (BuildContext context, int index) {
                      print(results);
                      // Article article = Article(
                      //     name: "Testing", isPrivate: false, privateFields: {});
                      var articlejson =
                          json.decode(results[index].values.elementAt(0));
                      var article = Article.fromJson(articlejson);
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewArticle(
                                  article: article,
                                ),
                              ),
                            ),
                          },
                          child: Card(
                            elevation: 0,
                            color: Colors.lightBlue[100],
                            child: Text(
                              results[index].keys.elementAt(0),
                              textAlign: TextAlign.center,
                              style: (const TextStyle(
                                  color: Colors.deepPurpleAccent,
                                  fontSize: 26,
                                  height: 1.5)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return const Text("HAS NO DATA");
            },
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> scanYourArticles() async {
    var atClientManager = AtClientManager.getInstance();

    List<AtKey> response =
        await atClientManager.atClient.getAtKeys(sharedWith: atSign);

    List<Map<String, dynamic>> values = [];

    for (AtKey key in response) {
      String? keyStr = key.key;
      if (keyStr != "signing_privatekey") {
        var val = await lookup(key);
        if (val != null) values.add({keyStr!: val});
        // var isDeleted = await atClientManager.atClient.delete(key);
        // isDeleted ? print("Deleted") : print("Not Deleted");
      }
    }

    return values;
  }

  Future<List<Map<String, dynamic>>> scanNamespaceArticles() async {
    var atClientManager = AtClientManager.getInstance();
    String myRegex = '^(?!public).*compactredpanda.*';
    List<AtKey> response =
        await atClientManager.atClient.getAtKeys(regex: myRegex);

    List<Map<String, dynamic>> values = [];

    for (AtKey key in response) {
      String? keyStr = key.key;
      String val = await lookup(key);
      values.add({keyStr!: val});
      // var isDeleted = await atClientManager.atClient.delete(key);
      // isDeleted ? print("Deleted") : print("Not Deleted");
    }

    return values;
  }

  Future<dynamic> lookup(AtKey? atKey) async {
    AtClient client = atClientManager.atClient;
    if (atKey != null) {
      AtValue result = await client.get(atKey);
      return result.value;
    }
    return null;
  }
}
