// To parse this JSON data, do
//
//     final questionAnswersModel = questionAnswersModelFromJson(jsonString);

import 'dart:convert';

QuestionAnswersModel questionAnswersModelFromJson(String str) => QuestionAnswersModel.fromJson(json.decode(str));

String questionAnswersModelToJson(QuestionAnswersModel data) => json.encode(data.toJson());

class QuestionAnswersModel {
  QuestionAnswersModel({
    this.success,
    this.questionAnswers,
    this.error,
  });

  String success;
  List<QuestionAnswer> questionAnswers;
  String error;

  factory QuestionAnswersModel.fromJson(Map<String, dynamic> json) => QuestionAnswersModel(
    success: json["success"],
    questionAnswers: List<QuestionAnswer>.from(json["payload"].map((x) => QuestionAnswer.fromJson(x))),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "payload": List<dynamic>.from(questionAnswers.map((x) => x.toJson())),
    "error": error,
  };
}

class QuestionAnswer {
  QuestionAnswer({
    this.symptomId,
    this.symptom,
    this.questionNo,
    this.question,
    this.isPredefinedAnswer,
    this.isInputText,
    this.isImageRequired,
    this.attType,
    this.answers,
  });

  int symptomId;
  String symptom;
  int questionNo;
  String question;
  bool isPredefinedAnswer;
  bool isInputText;
  bool isImageRequired;
  String attType;
  List<Answer> answers;

  factory QuestionAnswer.fromJson(Map<String, dynamic> json)  {
    List<Answer> data = [];
    if(json.containsKey("answers")){
      data=List<Answer>.from(json["answers"].map((x) => Answer.fromJson(x)));
    }
    return QuestionAnswer(
    symptomId: json["symptom_id"],
    symptom: json["symptom"],
    questionNo: json["question_no"],
    question: json["question"],
    isPredefinedAnswer: json["is_predefined_answer"],
    isInputText: json["is_input_text"],
    isImageRequired: json["is_image_required"],
    attType: json["att_type"],
    answers: data,
  );

  }

  Map<String, dynamic> toJson() => {
    "symptom_id": symptomId,
    "symptom": symptom,
    "question_no": questionNo,
    "question": question,
    "is_predefined_answer": isPredefinedAnswer,
    "is_input_text": isInputText,
    "is_image_required": isImageRequired,
    "att_type": attType,
    "answers": List<dynamic>.from(answers.map((x) => x.toJson())),
  };
}

class Answer {
  Answer({
    this.questionNo,
    this.answerNo,
    this.answer,
  });

  int questionNo;
  int answerNo;
  String answer;

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
    questionNo: json["question_no"],
    answerNo: json["answer_no"],
    answer: json["answer"],
  );

  Map<String, dynamic> toJson() => {
    "question_no": questionNo,
    "answer_no": answerNo,
    "answer": answer,
  };
}
