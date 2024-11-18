import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdd_clean_arch/core/error/exceptions.dart';
import 'package:tdd_clean_arch/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdd_clean_arch/features/number_trivia/data/models/index.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_local-data_source_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late MockSharedPreferences sharedPreferences;
  late NumberTriviaLocalDataSourceImpl dataSource;

  setUp(() {
    sharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(sharedPreferences: sharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
      json.decode(fixture('trivia_cached.json')),
    );

    test('should return NumberTrivia from SharedPreferences when there is one in the cache', () async {
      // Arrange
      when(sharedPreferences.getString(cachedNumberTrivia)).thenReturn(fixture('trivia_cached.json'));
      // Act
      final result = await dataSource.getLastNumberTrivia();
      // Assert
      verify(sharedPreferences.getString(cachedNumberTrivia));
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw CacheException when there is no cached value', () async {
      // Arrange
      when(sharedPreferences.getString(cachedNumberTrivia)).thenReturn(null);
      // Act
      call() => dataSource.getLastNumberTrivia();
      // Assert
      expect(call, throwsA(isA<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    const tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'text');

    test('should call SharedPreferences to cache the data', () async {
      // Arrange
      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
      when(sharedPreferences.setString(cachedNumberTrivia, expectedJsonString)).thenAnswer((_) async => true);
      // Act
      await dataSource.cacheNumberTrivia(tNumberTriviaModel);
      // Assert
      verify(sharedPreferences.setString(cachedNumberTrivia, expectedJsonString));
    });
  });
}
