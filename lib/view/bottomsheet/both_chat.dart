import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'dart:io';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/model/chat_model.dart';
import 'package:mumbaiclinic/model/question_answers_model.dart';
import 'package:mumbaiclinic/view/button/app_button.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';

enum ActionType { skip, start }

class BotChat extends StatefulWidget {
  final Function onAction;
  final QuestionAnswer questionAnswer;

  BotChat({this.onAction, this.questionAnswer});

  @override
  _BotChatState createState() => _BotChatState();
}

class _BotChatState extends State<BotChat> {
  File _image;
  final picker = ImagePicker();

  final _controller = TextEditingController();
  List<Answer> selectedIds = [];
  int ansId;
  String ansText = '';
  String question='';
  String filePath = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {
        Navigator.pop(context);
      },
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: ColorTheme.buttonColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                child: Center(
                    child: TextView(
                  textAlign: TextAlign.center,
                  text: widget.questionAnswer.question,
                  color: ColorTheme.white,
                  style: AppTextTheme.textTheme14Bold,
                )),
              ),
              const SizedBox(
                height: 20,
              ),
              if (widget.questionAnswer.isPredefinedAnswer)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.5,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: widget.questionAnswer.answers
                        .map((e) => GestureDetector(
                              onTap: () {
                                ansId = e.answerNo;
                                ansText = e.answer;
                                selectedIds.clear();
                                selectedIds.add(e);
                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: ColorTheme.white),
                                  color: selectedIds.contains(e)
                                      ? ColorTheme.white
                                      : Colors.transparent,
                                ),
                                child: Center(
                                  child: TextView(
                                    text: e.answer,
                                    maxLine: 2,
                                    textAlign: TextAlign.center,
                                    color: selectedIds.contains(e)
                                        ? ColorTheme.darkGreen
                                        : ColorTheme.white,
                                    style: AppTextTheme.textTheme12Light,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              if (widget.questionAnswer.isInputText)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: ColorTheme.white,
                  ),
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                    },
                    onChanged: (val) {
                      ansText = val;
                      setState(() {});
                    },
                    style: TextStyle(
                        color: ColorTheme.darkGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(0),
                      hintText: 'Type here..',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: AppButton(
                        text: "Done",
                        color: ColorTheme.white,
                        buttonTextColor: ColorTheme.darkGreen,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: AppTextTheme.textSize14),
                        onClick: () {
                          Navigator.pop(context);
                          FocusScope.of(context).unfocus();
                          widget.onAction(ChatModel(
                            symptomId: widget.questionAnswer.symptomId,
                            questionId: widget.questionAnswer.questionNo,
                            answerId: ansId.toString(),
                            answerText: ansText,
                            questionText: widget.questionAnswer.question,
                            attType: widget.questionAnswer.attType,
                            attchment: filePath,
                          ));
                        },
                      ),
                    ),
                  ),
                  widget.questionAnswer.isImageRequired
                      ? GestureDetector(
                          onTap: () {
                            getImage();
                          },
                          child: Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(6),
                                width: 40,
                                height: 40,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: ColorTheme.white),
                                child: Image.asset(AppAssets.take_pic,width: 20,height: 20,color: ColorTheme.buttonColor,),
                              ),
                             if(filePath!=null&&filePath.isNotEmpty)
                              Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                      color: Colors.redAccent,
                                    ),
                                  ),
                              )
                            ],
                          ),
                        )
                      : Container(),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        filePath = _image.path;
      }
    });
  }
}
