import 'package:tdd_clean_arch/features/number_trivia/domain/entities/index.dart';

class NumberTriviaModel extends NumberTrivia {
  const NumberTriviaModel({
    super.number,
    required super.text,
  });

  factory NumberTriviaModel.fromJson(Map<String, dynamic> json) {
    return NumberTriviaModel(text: json['text'], number: (json['number'] as num).toDouble());
  }

  Map<String, Object?> toJson() {
    return {'number': super.number, 'text': super.text};
  }
}
