import 'dart:convert';

import 'package:diy/models/article.dart';
import 'package:flutter/material.dart';

class ViewArticle extends StatelessWidget {
  const ViewArticle({Key? key, required this.article}) : super(key: key);
  final Article article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Text(article.difficulty!),
            // Text(article.images![0]),
            (article.images != null
                ? SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Image.memory(
                      base64Decode(article.images![0]),
                      fit: BoxFit.fill,
                    ),
                  )
                : Container()),
            (article.description != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Column(
                      //crossAxisAlignment: CrossAxisAlignment.end,
                      //mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 250,
                          child: Text(article.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  height: 2,
                                  fontSize: 30)),
                        ),
                        SizedBox(
                            width: 250,
                            child: Text(article.description!,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                                textAlign: TextAlign.left)),
                        for (int i = 0; i < article.tools!.length; i++)
                          SizedBox(
                            width: 250,
                            child: Text(article.tools![i],
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20)),
                          ),
                        for (int i = 0; i < article.steps!.length; i++)
                          SizedBox(
                            width: 250,
                            child: Text(article.steps![i],
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20)),
                          ),
                        for (int i = 0; i < article.tags!.length; i++)
                          SizedBox(
                            width: 250,
                            child: Text(article.tags![i],
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20)),
                          )
                      ],
                    ),
                  )
                : Container()),
          ],
        ),
      ),
    );
  }
}
