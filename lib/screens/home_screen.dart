// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:diy/constant.dart';

import '../models/profilepic.dart';
import 'package:flutter/material.dart';
import 'package:diy/models/article.dart';
import 'package:diy/screens/view_article.dart';
import 'package:diy/screens/add_article.dart';
import 'package:diy/widgets/drawer.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var atClientManager = AtClientManager.getInstance();
  String? atSign = AtClientManager.getInstance().atClient.getCurrentAtSign();
  Future? yourArticles;
  bool isPicPrivate = false;
  File? articleImage;
  List? images;
  Image img = Image.network(
      "https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/8cc9595364efa0fc-org-1584048843.jpg?resize=980:*");

  @override
  void initState() {
    super.initState();
  }

  void createProfilePic() async {
    ProfilePic pic = ProfilePic(images: images, isPrivate: isPicPrivate);
    Map picJson = pic.toJson();
    (pic.images == null
        ? img = Image.memory(base64Decode(pic.images![0]))
        : null);
    var metaData = Metadata()..isPublic = true;

    var atKey = AtKey()
      ..key = "profilePic"
      ..metadata = metaData
      ..namespace = NAMESPACE
      ..sharedWith = atSign;

    var success = await atClientManager.atClient
        .put(atKey, json.encode(picJson), isDedicated: true);
    // await atClientManager.atClient.putMeta(atKey);
    success ? print("Yay") : print("Boo!");
  }

  Future imagePicker() async {
    final allImages = await ImagePicker().pickMultiImage();
    try {
      if (allImages == null) return;
      final imagesTemp = allImages
          .map((img) => base64Encode(File(img.path).readAsBytesSync()))
          .toList();
      setState(() => images = imagesTemp);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: const Center(child: Text('Journals             ')),
      ),
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: img,
          ),
          OutlinedButton(
            onPressed: () => {createProfilePic(), imagePicker()},
            style: OutlinedButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.grey[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                )),
            child: const Icon(
              Icons.image,
              color: Colors.blue,
              size: 24.0,
              semanticLabel: 'Select images for your Profile',
            ),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
              child: Text(
                '${atClientManager.atClient.getCurrentAtSign()}',
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
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
                                color: Colors.grey[850],
                                child: Column(children: [
                                  Text(article.name,
                                      textAlign: TextAlign.center,
                                      style: (const TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                          height: 1.5))),
                                  Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(article.description!,
                                          style: const TextStyle(
                                              color: Colors.white))),
                                  (article.difficulty != null
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: RichText(
                                              text:
                                                  TextSpan(children: <TextSpan>[
                                            const TextSpan(
                                                text: "Difficulty: ",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            TextSpan(
                                                text: article.difficulty!,
                                                style: const TextStyle(
                                                    color: Colors.white))
                                          ])))
                                      : Container()),
                                ]))),
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
