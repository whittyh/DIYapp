// ignore_for_file: non_constant_identifier_names, avoid_print

import 'dart:io';
import 'dart:convert';

import 'package:diy/widgets/drawer.dart';
import 'package:flutter/material.dart';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';

import 'package:diy/constant.dart';
import '../models/article.dart';
import 'home_screen.dart';

class EditArticle extends StatefulWidget {
  const EditArticle({Key? key, required this.article}) : super(key: key);
  final Article article;

  @override
  State<EditArticle> createState() => _EditArticleState();
}

class _EditArticleState extends State<EditArticle> {
  // This is globals variables declared/initialized used throght this screen
  var atClientManager = AtClientManager.getInstance();
  var dropDownItems = ["", "Easy", "Medium", "Hard"];
  bool isArticlePrivate = false;
  bool isDescPrivate = false;
  bool isToolsPrivate = false;
  bool isStepsPrivate = false;
  bool isTagsPrivate = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController toolsController = TextEditingController();
  TextEditingController stepsController = TextEditingController();
  TextEditingController tagsController = TextEditingController();
  String? selectedDifficulty;
  File? articleImage;
  List? images;
  List<String> tags = [];

  // This is called once at the beginning of the search screen
  @override
  void initState() {
    super.initState();
    var article = widget.article;
    /* 
      This screen is only accessable through the view article screen. 
      The edit article screen is required to recieve as argument the Article object.
      In the InitState function, I autofill all the fields that were previous filled when the 
      user created the article.
    */
    nameController.text = article.name;
    descController.text = article.description!;
    toolsController.text = article.tools!.join(",");
    stepsController.text = article.steps!.join(",");
    selectedDifficulty = article.difficulty != null ? article.difficulty! : "";
    tags = article.tags!.map((t) => t.toString()).toList();
    images = article.images;
    isArticlePrivate = article.isPrivate;
    isDescPrivate = article.privateFields!['description'];
    isToolsPrivate = article.privateFields!['tools'];
    isStepsPrivate = article.privateFields!['steps'];
  }

  @override
  Widget build(BuildContext context) {
    /*Once users has enter all information he/she wants stored, this function gathers all
   the information and creates a Article object and converts it to json format. 
   Then, json format is stored within the users AtSign
   */
    void createArticle() async {
      // All fields are optional except the Article name field. If that field is empty
      // Then a SnackBar widget will appear at the bottom, notifying user to fill in the field.
      if (nameController.text.isNotEmpty) {
        print("Article is being created");
        var privateFields = {
          'description': isDescPrivate,
          'tools': isToolsPrivate,
          'steps': isStepsPrivate,
        };
        List<String> tools = toolsController.text == ""
            ? []
            : toolsController.text.split(",").map((s) => s.trim()).toList();
        List<String> steps = stepsController.text == ""
            ? []
            : stepsController.text.split(",").map((s) => s.trim()).toList();
        Article article = Article(
            name: nameController.text,
            description: descController.text,
            tools: tools,
            steps: steps,
            images: images,
            tags: tags,
            difficulty: selectedDifficulty == "" ? null : selectedDifficulty,
            isPrivate: isArticlePrivate,
            privateFields: privateFields);

        Map articleJson = article.toJson();

        String? atSign =
            AtClientManager.getInstance().atClient.getCurrentAtSign();

        var metaData = Metadata()..isPublic = true;

        var atKey = AtKey()
          ..key = nameController.text
          ..namespace = NAMESPACE
          ..sharedWith = atSign;
        // Store the article in the secondary sever
        var success =
            await atClientManager.atClient.put(atKey, json.encode(articleJson));
        // If the article was succesfully store then navigate back to the Home Screen
        if (success) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        final snackBar = SnackBar(
          content: const Text(
            'Article Name field is empty',
            style: TextStyle(color: Colors.redAccent),
          ),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {},
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    /*
    The User has the option add pictures of their DIY project, 
    this function allows the user to select a photo from their gallery and saves the photo
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
        print('error');
        print(e);
      }
    }

    return Scaffold(
      // Add a Drawer at the top left of the App Bar, this allows user with option to go back to HomePage or SearchPage
      drawer: const AppDrawer(),
      // Creates an App Bar with following title, and background color of black.
      appBar: AppBar(
        title: Text('Editing ${widget.article.name}'),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          // Add a Switch  where user can select if the entire article is public/private
          Switch(
            value: isArticlePrivate,
            onChanged: (bool val) {
              setState(() {
                isArticlePrivate = val;
              });
            },
            activeColor: Colors.white,
            activeTrackColor: Colors.grey[500],
            inactiveThumbColor: Colors.lightBlue,
            inactiveTrackColor: Colors.blue[100],
          )
        ],
      ),
      // Allows for the screen to be scrollable
      body: SingleChildScrollView(
          child: Container(
        color: Colors.grey[850],
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: const Text(
                  "NOTE: Information is public by default!\nToggle privacy on for all or part of your article",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                  textAlign: TextAlign.center),
            ),
            // Add Padding of 10 around and Creates TextField by calling the custom
            // widget TextFieldWidget for the article name fiel
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  TextFieldWidget(
                    controller: nameController,
                    text: "Enter Article name",
                  ),
                ],
              ),
            ),
            /*
                Adds Padding of 10 all around and Creates TextField by calling the custom
                widget TextFieldWidget for the article description field. Adds a Switch 
                where user has the option to make the description field public / private
              */
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  TextFieldWidget(
                    controller: descController,
                    isTextArea: true,
                    text: "Enter Article description",
                  ),
                  Switch(
                    value: isDescPrivate,
                    onChanged: (bool val) {
                      setState(() {
                        isDescPrivate = val;
                      });
                    },
                    activeColor: Colors.white,
                    activeTrackColor: Colors.grey[500],
                    inactiveThumbColor: Colors.lightBlue,
                    inactiveTrackColor: Colors.blue[100],
                  ),
                ],
              ),
            ),
            /*
                Adds Padding of 10 all around and Creates TextField by calling the custom
                widget TextFieldWidget for the article tools field. Adds a Switch 
                where user has the option to make the tools field public / private
            */
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  TextFieldWidget(
                    controller: toolsController,
                    isTextArea: true,
                    text: "Enter tool nessesary (seperated by ,)",
                  ),
                  Switch(
                    value: isToolsPrivate,
                    onChanged: (bool val) {
                      setState(() {
                        isToolsPrivate = val;
                      });
                    },
                    activeColor: Colors.white,
                    activeTrackColor: Colors.grey[500],
                    inactiveThumbColor: Colors.lightBlue,
                    inactiveTrackColor: Colors.blue[100],
                  ),
                ],
              ),
            ),
            /*
                Adds Padding of 10 all around and Creates TextField by calling the custom
                widget TextFieldWidget for the article steps field. Adds a Switch 
                where user has the option to make the steps field public / private
              */
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  TextFieldWidget(
                    controller: stepsController,
                    isTextArea: true,
                    text: "Enter steps to complete",
                  ),
                  Switch(
                    value: isStepsPrivate,
                    onChanged: (bool val) {
                      setState(() {
                        isStepsPrivate = val;
                      });
                    },
                    activeColor: Colors.white,
                    activeTrackColor: Colors.grey[500],
                    inactiveThumbColor: Colors.lightBlue,
                    inactiveTrackColor: Colors.blue[100],
                  ),
                ],
              ),
            ),
            /*
                Adds a drop down ment where user has the option of selecting the difficulty of the DIY project.
              */
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(10)),
              child: DropdownButton(
                dropdownColor: Colors.black,
                borderRadius: BorderRadius.circular(20),
                style: const TextStyle(color: Colors.white),
                value: selectedDifficulty,
                items:
                    dropDownItems.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Center(
                        child: Text(value,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center)),
                  );
                }).toList(),
                onChanged: (String? val) {
                  setState(() => selectedDifficulty = val!);
                },
              ),
            ),
            /*
                Creates a Button where when pressed, it calls the imagePicker function that allows 
                user to select an image from gallary.
            */
            OutlinedButton(
              onPressed: () => imagePicker(),
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
                semanticLabel: 'Select images for your article',
              ),
            ),
            /*
                Using a third-party widget, this allows users to enter relevent tags about their Article. 
                These tags can be used for the search functionally which would filter all articles with specific tag(s).
              */
            Padding(
                padding: const EdgeInsets.all(10),
                child: Tags(
                  itemCount: tags.length,
                  itemBuilder: (int index) {
                    final item = tags[index];
                    return ItemTags(
                      key: Key(index.toString()),
                      index: index,
                      title: item,
                      removeButton: ItemTagsRemoveButton(onRemoved: () {
                        setState(() => tags.removeAt(index));
                        return true;
                      }),
                    );
                  },
                  textField: TagsTextField(
                    textStyle:
                        const TextStyle(fontSize: 14, color: Colors.white),
                    width: 400,
                    inputDecoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          bottomLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          bottomLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                        ),
                      ),
                    ),
                    hintText: "Enter article's tags",
                    hintTextColor: Colors.white,
                    onSubmitted: (String? str) {
                      setState(() => tags.add(str!));
                    },
                  ),
                )),
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.grey[700]),
              onPressed: () => createArticle(),
              child: const Text("Update Article"),
            ),
          ],
        ),
      )),
    );
  }
}

/* This is a custom widget that Creates a TextField and applies the following styles to it
   This widget is used various time.
*/
class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({
    Key? key,
    required this.controller,
    required this.text,
    this.isTextArea = false,
  }) : super(key: key);

  final TextEditingController controller;
  final bool isTextArea;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        // Styles
        style: const TextStyle(color: Colors.white),
        maxLines: isTextArea ? 5 : 1,
        controller: controller,
        decoration: InputDecoration(
          hintText: text,
          hintStyle: const TextStyle(color: Colors.white70),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            // Makes all corners of the TextField circular
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              bottomLeft: Radius.circular(25),
              topRight: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              bottomLeft: Radius.circular(25),
              topRight: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
        ),
      ),
    );
  }
}
