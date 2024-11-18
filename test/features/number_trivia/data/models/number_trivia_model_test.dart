import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_clean_arch/features/number_trivia/data/models/index.dart';
import 'package:tdd_clean_arch/features/number_trivia/domain/entities/index.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const tNumberTriviaModel = NumberTriviaModel(number: 1, text: '1 is a number');
  const tNumberTriviaDoubleModel = NumberTriviaModel(number: 0.5, text: '0.5 is a number');

  test('should be a subclass of NumberTrivia Entity', () async {
    expect(tNumberTriviaModel, isA<NumberTrivia>());
  });

  group('fromJson', () {
    test('should return a valid model when the JSON number is an integer', () async {
      //arrange
      final Map<String, dynamic> jsonmap = json.decode(fixture('trivia.json'));
      //act
      final result = NumberTriviaModel.fromJson(jsonmap);
      //assert
      expect(result, equals(tNumberTriviaModel));
    });

    test('should return a valid model when the JSON number is an double', () async {
      //arrange
      final Map<String, dynamic> jsonmap = json.decode(fixture('trivia_double.json'));
      //act
      final result = NumberTriviaModel.fromJson(jsonmap);
      //assert
      expect(result, equals(tNumberTriviaDoubleModel));
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () async {
      //arrange
      //act
      final result = tNumberTriviaModel.toJson();

      final expectedOutput = {'number': 1, 'text': '1 is a number'};
      expect(result, equals(expectedOutput));
      //assert
    });
  });
}
