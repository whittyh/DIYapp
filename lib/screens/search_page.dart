// ignore_for_file: unnecessary_const
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:diy/widgets/article_card.dart';
import 'package:diy/widgets/drawer.dart';
import 'package:diy/models/article.dart';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  String? atSign = AtClientManager.getInstance().atClient.getCurrentAtSign();
  var atClientManager = AtClientManager.getInstance();
  TextEditingController editingController = TextEditingController();
  List<Map<String, dynamic>> allArticles = [];
  List<Map<String, dynamic>> filteredArticles = [];

  // This is called once at the beginning of the search page
  @override
  void initState() {
    super.initState();
    /* 
      Calls the scanYourArticle function which returns a List of json objects 
      for the articles store within the users AtSign. "then" is used to retreieve the json objects. 
      It waits for the data is be fetched and once its done it initialized the allArticles and filteredArticles variables
      with the articles within the AtSign.  
    */
    scanYourArticles().then((articles) {
      setState(() {
        allArticles = articles;
        filteredArticles = articles;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add a Drawer at the top left of the App Bar, this allows user with option to go back to HomePage or SearchPage
      drawer: const AppDrawer(),
      // Creates an App Bar with following title, and background color of black.
      appBar: AppBar(
        title: const Text('Search Page'),
        backgroundColor: Colors.black,
      ),
      body: Column(children: [
        /*  

        */
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) => _runFilter(value),
            controller: editingController,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFFF2F2F2),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 0.0),
              ),
              labelText: "Search for DIY Articles",
              hintText: "Search",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
            ),
          ),
        ),
        Expanded(
            child: filteredArticles.isEmpty
                // If there is no article found after filter then display text to the screen
                ? const Text(
                    'No results found.',
                  )
                /*
                  If there are articles found then, retrieve the list of articles and display them to the UI using
                  the ArticleCard widget previous made.
                */
                : ListView.builder(
                    itemCount: filteredArticles.length,
                    itemBuilder: (BuildContext context, int index) {
                      /*
                        Data is recieved as a list of Json obejects, convert the indexed json object to a Article object
                      */
                      var article = Article.fromJson(filteredArticles[index]);
                      return ArticleCard(article: article);
                    },
                  )),
      ]),
    );
  }

  // This function is called everytime the text field changes
  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results;
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = allArticles;
    } else {
      // Filter for all articles using the name field
      results = allArticles.where((articles) {
        // we use the toLowerCase() method to make it case-insensitive
        return (articles["name"] as String)
            .toLowerCase()
            .contains(enteredKeyword.toLowerCase());
      }).toList();
    }
    // Refresh the UI
    setState(() {
      filteredArticles = results;
    });
  }

  /*
    This functions fetches data from the users AtSign and it is returned. This function is used in the FutureBuilder.
  */
  Future<List<Map<String, dynamic>>> scanYourArticles() async {
    var atClientManager = AtClientManager.getInstance();

    List<AtKey> response =
        await atClientManager.atClient.getAtKeys(sharedWith: atSign);

    List<Map<String, dynamic>> values = [];

    for (AtKey key in response) {
      String? keyStr = key.key;
      if (keyStr != "signing_privatekey") {
        var val = await lookup(key);
        if (val != null) {
          Map<String, dynamic> data = jsonDecode(val);
          values.add(data);
        }
      }
    }

    return values;
  }

  /*
  This functions fetches data from the users AtSign and it is returned.
  */
  Future<List<Map<String, dynamic>>> scanNamespaceArticles() async {
    var atClientManager = AtClientManager.getInstance();
    String myRegex = '^(?!public).*diy.*';
    List<AtKey> response =
        await atClientManager.atClient.getAtKeys(regex: myRegex);
    List<Map<String, dynamic>> values = [];

    for (AtKey key in response) {
      String? keyStr = key.key;
      String val = await lookup(key);
      values.add(jsonDecode(val));
    }
    return values;
  }

  // This function will retrieve the value of an AtKey. The AtKey is passed as an arguement.
  Future<dynamic> lookup(AtKey? atKey) async {
    AtClient client = atClientManager.atClient;
    if (atKey != null) {
      AtValue result = await client.get(atKey);
      return result.value;
    }
    return null;
  }
}
