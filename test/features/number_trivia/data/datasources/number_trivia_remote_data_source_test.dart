import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_clean_arch/core/error/exceptions.dart';
import 'package:tdd_clean_arch/features/number_trivia/data/datasources/index.dart';
import 'package:tdd_clean_arch/features/number_trivia/data/models/index.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_remote_data_source_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockHttpClient;
  late NumberTriviaRemoteDataSourceImpl dataSource;

  setUp(() {
    mockHttpClient = MockClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  const tNumber = 1;
  const numbersApiUrl = 'numbersapi.com';
  final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

  void setUpMockHttpClientSuccess200() {
    when(
      mockHttpClient.get(
        Uri.http('numbersapi.com', '/$tNumber', {'json': ''}),
      ),
    ).thenAnswer(
      (_) async => http.Response(fixture('trivia.json'), 200),
    );
  }

  void setUpMockHttpClientFailure404() {
    when(mockHttpClient.get(
      Uri.http('numbersapi.com', '/$tNumber', {'json': ''}),
    )).thenAnswer(
      (_) async => http.Response('Something went wrong', 404),
    );
  }

  void setUpMockHttpClientSuccess200Random() {
    when(mockHttpClient.get(
      Uri.http('numbersapi.com', '/random', {'json': ''}),
    )).thenAnswer(
      (_) async => http.Response(fixture('trivia.json'), 200),
    );
  }

  void setUpMockHttpClientFailure404Random() {
    when(mockHttpClient.get(
      Uri.http(numbersApiUrl, '/random', {'json': ''}),
    )).thenAnswer(
      (_) async => http.Response('Something went wrong', 404),
    );
  }

  //create groups for each method
  group('getConcreteNumberTrivia', () {
    test("should perform a GET request on a URL with number being the endpoint and with application/json header", () {
      //arrange
      setUpMockHttpClientSuccess200();
      //act
      dataSource.getConcreteNumberTrivia(tNumber);

      //assert
      verify(
        mockHttpClient.get(
          Uri.http('numbersapi.com', '/$tNumber', {'json': ''}),
        ),
      );
    });
    //take a look and see that the tests take care of small parts of the implementation each time
    //we create them. First the action itself, then exception, for example.

    //test the small amount of functionality the tests can
    test('should return NumberTrivia when the response code is 200 (success)', () async {
      //arrange
      setUpMockHttpClientSuccess200();
      //act
      final result = await dataSource.getConcreteNumberTrivia(tNumber);

      //assert
      expect(result, tNumberTriviaModel);
    });

    test('should throw a ServerException when the status code is 404 or other', () {
      setUpMockHttpClientFailure404();

      final call = dataSource.getConcreteNumberTrivia;

      expect(() async => await call(tNumber), throwsA(isA<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    test("should perform a GET request on a URL with number being the endpoint and with application/json header", () {
      //arrange
      setUpMockHttpClientSuccess200Random();
      //act
      dataSource.getRandomNumberTrivia();

      //assert
      verify(
        mockHttpClient.get(
          Uri.http('numbersapi.com', '/random', {'json': ''}),
        ),
      );
    });
    //take a look and see that the tests take care of small parts of the implementation each time
    //we create them. First the action itself, then exception, for example.

    //test the small amount of functionality the tests can
    test('should return NumberTrivia when the response code is 200 (success)', () async {
      //arrange
      setUpMockHttpClientSuccess200Random();
      //act
      final result = await dataSource.getRandomNumberTrivia();

      //assert
      expect(result, tNumberTriviaModel);
    });

    test('should throw a ServerException when the status code is 404 or other', () async {
      setUpMockHttpClientFailure404Random();

      final call = dataSource.getRandomNumberTrivia;

      expect(() async => await call(), throwsA(isA<ServerException>()));
    });
  });
}
