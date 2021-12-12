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

class AddArticle extends StatefulWidget {
  const AddArticle({Key? key}) : super(key: key);

  @override
  State<AddArticle> createState() => _AddArticleState();
}

class _AddArticleState extends State<AddArticle> {
  var atClientManager = AtClientManager.getInstance();
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
  var dropDownItems = ["", "Easy", "Medium", "Hard"];
  String selectedDifficulty = "";
  File? articleImage;
  List? images;
  List<String> tags = [];

  void createArticle() async {
    print("Article is being created");
    var privateFields = {
      'description': isDescPrivate,
      'tools': isToolsPrivate,
      'steps': isStepsPrivate,
      // 'difficulty': isDifficultyPrivate
    };
    List<String> tools = toolsController.text.split(",");
    List<String> steps = stepsController.text.split(",");
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

    String? atSign = AtClientManager.getInstance().atClient.getCurrentAtSign();

    // Map metaJson = Metadata().toJson();
    // metaJson['isPublic'] = true;
    // metaJson['ttr'] = 1;
    // Metadata metadata = Metadata.fromJson(metaJson);

    // Metadata metadata = Metadata();
    // metadata.isPublic = !isArticlePrivate;
    // metadata.isCached = !isArticlePrivate;
    // metadata.isHidden = false;S
    // metadata.ttr = 1;

    var metaData = Metadata()..isPublic = true;

    var atKey = AtKey()
      ..key = nameController.text
      //..metadata = metaData
      ..namespace = NAMESPACE
      ..sharedWith = atSign;

    var success = await atClientManager.atClient
        .put(atKey, json.encode(articleJson), isDedicated: true);
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
        title: const Text('Add Article'),
        actions: [
          Switch(
              value: isArticlePrivate,
              onChanged: (bool val) {
                setState(() {
                  isArticlePrivate = val;
                });
              })
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
                      }),
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
                      }),
                ],
              ),
            ),
            DropdownButton(
              value: selectedDifficulty,
              items:
                  dropDownItems.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? val) {
                setState(() => selectedDifficulty = val!);
              },
            ),
            OutlinedButton(
              onPressed: () => imagePicker(),
              child: const Icon(
                Icons.image,
                color: Colors.blueGrey,
                size: 24.0,
                semanticLabel: 'Select images for your article',
              ),
            ),
            Tags(
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
                width: 400,
                inputDecoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                ),
                hintText: "Enter article's tags",
                onSubmitted: (String? str) {
                  setState(() => tags.add(str!));
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => createArticle(),
              child: const Text("Create Article"),
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
        maxLines: isTextArea ? 5 : 1,
        controller: controller,
        decoration: InputDecoration(
          hintText: text,
          border: const OutlineInputBorder(
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
