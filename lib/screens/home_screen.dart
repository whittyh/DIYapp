// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:diy/constant.dart';
import 'package:diy/widgets/article_card.dart';
import '../models/profilepic.dart';
import 'package:flutter/material.dart';
import 'package:diy/models/article.dart';
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
  // These are globals variables declared/initialized that are needed for the homescreen
  var atClientManager = AtClientManager.getInstance();
  String? atSign = AtClientManager.getInstance().atClient.getCurrentAtSign();
  bool isPicPrivate = false;
  File? articleImage;
  List? images;
  Image img = Image.network(
      "https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/8cc9595364efa0fc-org-1584048843.jpg?resize=980:*");
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

    await atClientManager.atClient.put(atKey, json.encode(picJson));
  }

  /*
  The User has the option to change their profile picture, this function allows the user to select a photo from their gallery and saves the photo
  Pre: None
  Post: Saves selected photo
  */
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
      // Creates the App Bar with Journal as title and background color grey
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
          // Creates a button, when press calls the imagesPicker function
          OutlinedButton(
            onPressed: () => {imagePicker()},
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
          // Display to the screen the users @sign and adds padding of 30 at the bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
            child: Text(
              '${atClientManager.atClient.getCurrentAtSign()}',
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          /*
          FutureBuilder is a widget from the Flutter SDK which allows us to display asyncronous data. 
          This widget requires the "future" parameter. It would be a function that makes API call or 
          fetches data and returns within a Future data type. 
          In our case, the scanYourArticles function fetches all the users article stored within their 
          secondary server (AtSign). 
          */
          FutureBuilder(
            future: scanNamespaceArticles(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              // Check whether user has saved articles in their AtSigns
              if (snapshot.hasData && snapshot.data.isNotEmpty) {
                List<Map<String, dynamic>> results = snapshot.data;
                return Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (BuildContext context, int index) {
                      var articlejson =
                          json.decode(results[index].values.elementAt(0));
                      // Data is returned in json format, so I convert it back to an Article object.
                      var article = Article.fromJson(articlejson);
                      // Each article passed to this Article Card Widget that creates the UI for the article passed.
                      return ArticleCard(article: article);
                    },
                  ),
                );
              }
              return const Text(
                "Please add an Article",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              );
            },
          ),
        ],
      ),
    );
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
        if (val != null) values.add({keyStr!: val});
      }
    }

    return values;
  }

  // This function will retrieve the value of an AtKey. The AtKey is passed as an arguement.
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
