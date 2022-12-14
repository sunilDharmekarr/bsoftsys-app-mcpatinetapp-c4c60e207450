import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/model/chat_model.dart';
import 'package:mumbaiclinic/model/doc_by_specialization.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';

class ChatScreen extends StatefulWidget {
  final List<ChatModel> _chatModel;
  final Doctor doctor;
  final Key key;

  ChatScreen(this._chatModel, this.doctor, this.key) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatModel> _list = [];
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _list.clear();
    _list.addAll(widget._chatModel);
  }

  _scarollTo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    _scarollTo();
    return Container(
      padding: const EdgeInsets.all(6),
      child: Column(
        children: <Widget>[

          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              controller: _scroll,
              reverse: false,
              shrinkWrap: true,
              itemBuilder: (cntx, index) {
                ChatModel chat = _list[index];
                return Column(
                  children: [
                    if(chat.questionText!=null&&chat.questionText.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(6),
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage(
                                      '${widget.doctor.photopath}'),
                                )),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              margin: const EdgeInsets.fromLTRB(4, 4, 50, 4),
                              decoration: BoxDecoration(
                                color: ColorTheme.lightGreenOpacity,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(0),
                                ),
                              ),
                              child: TextView(
                                text: chat.questionText,
                                style: AppTextTheme.textTheme12Light,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    if(chat.answerText!=null&&chat.answerText.isNotEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (chat.attchment != null && chat.attchment.isNotEmpty)
                            Container(
                              height: 120,
                              width: 120,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.file(
                                  File(chat.attchment),
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 6),
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: ColorTheme.buttonColor,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                topLeft: Radius.circular(10),
                                bottomRight: Radius.circular(0),
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                            child: TextView(
                              text: chat.answerText,
                              style: AppTextTheme.textTheme12Light,
                              color: ColorTheme.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
              itemCount: _list.length,
            ),
          )
        ],
      ),
    );
  }
}
