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

  @override
  void initState() {
    super.initState();
    print("hello from edit");
    var article = widget.article;
    nameController.text = article.name;
    descController.text = article.description!;
    toolsController.text = article.tools!.join(",");
    stepsController.text = article.steps!.join(",");
    selectedDifficulty = article.difficulty != null ? article.difficulty! : "";
    tags = article.tags!.map((t) => t.toString()).toList();
    images = article.images;
    // var datePosted = article.datePosted;
    isArticlePrivate = article.isPrivate;
    isDescPrivate = article.privateFields!['description'];
    isToolsPrivate = article.privateFields!['tools'];
    isStepsPrivate = article.privateFields!['steps'];
  }

  @override
  Widget build(BuildContext context) {
    void createArticle() async {
      if (nameController.text.isNotEmpty) {
        print("Article is being created");
        var privateFields = {
          'description': isDescPrivate,
          'tools': isToolsPrivate,
          'steps': isStepsPrivate,
          // 'difficulty': isDifficultyPrivate
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
            // datePosted: DateTime.now(),
            difficulty: selectedDifficulty == "" ? null : selectedDifficulty,
            isPrivate: isArticlePrivate,
            privateFields: privateFields);

        Map articleJson = article.toJson();

        String? atSign =
            AtClientManager.getInstance().atClient.getCurrentAtSign();

        var metaData = Metadata()..isPublic = true;

        var atKey = AtKey()
          ..key = nameController.text
          //..metadata = metaData
          ..namespace = NAMESPACE
          ..sharedWith = atSign;

        var success =
            await atClientManager.atClient.put(atKey, json.encode(articleJson));
        success ? print("Yay") : print("Boo!");
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
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Editing ${widget.article.name}'),
        centerTitle: true,
        actions: [
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
            Padding(
                padding: const EdgeInsets.all(10),
                child: Tags(
                  // runSpacing: 1,
                  // horizontalScroll: true,

                  // symmetry: true,
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
        style: const TextStyle(color: Colors.white),
        maxLines: isTextArea ? 5 : 1,
        controller: controller,
        decoration: InputDecoration(
          hintText: text,
          hintStyle: const TextStyle(color: Colors.white70),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
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
