import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_clean_arch/core/error/failures.dart';
import 'package:tdd_clean_arch/core/util/input_converter.dart';
import 'package:tdd_clean_arch/features/number_trivia/domain/entities/index.dart';
import 'package:tdd_clean_arch/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tdd_clean_arch/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:tdd_clean_arch/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:tdd_clean_arch/features/number_trivia/presentation/bloc/number_trivia_event.dart';
import 'package:tdd_clean_arch/features/number_trivia/presentation/bloc/number_trivia_state.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([GetConcreteNumberTrivia, GetRandomNumberTrivia, InputConverter])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  //since the InputConverter is already tested
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
        getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
        inputConverter: mockInputConverter,
        getRandomNumberTrivia: mockGetRandomNumberTrivia);
  });

  test('initialState should be Empty', () {
    expect(bloc.initialState, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');
    final expectedStream = [
      Error(
        message: invalidInputFailureMessage,
      )
    ];

    void setUpMockInputConverterSuccess() {
      //arrange
      when(mockGetConcreteNumberTrivia(GetConcreteNumberTriviaParams(number: tNumberParsed)))
          .thenAnswer((_) async => const Right(tNumberTrivia));

      when(mockInputConverter.stringToUnsignedInteger(tNumberString)).thenReturn(
        Right(tNumberParsed),
      );
    }

    //remember: a good practice is also to test the calling of some functions. In the following
    // case we are testing the InputConverter class with the method convert for the GetTriviaForConcreteNumber usecase
    test('should call the InputConverter to validate and  convert the string to an unsigned integer', () async {
      //arrange
      setUpMockInputConverterSuccess();
      //act
      bloc.add(GetTriviaForConcreteNumber(numberString: tNumberString));
      //need to await for the call to be executed
      await untilCalled(mockInputConverter.stringToUnsignedInteger(tNumberString));
      //assert
      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
    });

    test('should emit [Error] when the input is invalid', () {
      //arrange
      when(mockInputConverter.stringToUnsignedInteger(tNumberString)).thenReturn(
        Left(InvalidInputFailure()),
      );

      //assert later
      // we need to assert later because while the test is waiting for it to execute, we run the add method
      // in the folowing part
      expectLater(bloc.stream, emitsInOrder(expectedStream));

      //act
      //bloc.add returns void, we need to access bloc.state because of that. Also, in the assert
      //part we need to expect later
      bloc.add(GetTriviaForConcreteNumber(numberString: tNumberString));
    });

    test('should get data from the concrete use case', () async {
      //arrange
      setUpMockInputConverterSuccess();

      //act
      bloc.add(GetTriviaForConcreteNumber(numberString: tNumberString));
      await untilCalled(mockGetConcreteNumberTrivia(GetConcreteNumberTriviaParams(number: tNumberParsed)));
    });

    test('should emit [Loading, Loaded] when data is gotten successfully', () {
      //arrange
      setUpMockInputConverterSuccess();
      //assertLater
      final expectedStates = [
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ];
      expectLater(bloc.stream, emitsInOrder(expectedStates));
      //act
      bloc.add(GetTriviaForConcreteNumber(numberString: tNumberString));
    });

    test('should emit [Loading, Error] when data is gotten successfully', () {
      //arrange
      when(mockInputConverter.stringToUnsignedInteger(tNumberString)).thenReturn(
        Right(tNumberParsed),
      );
      when(mockGetConcreteNumberTrivia(GetConcreteNumberTriviaParams(number: tNumberParsed)))
          .thenAnswer((_) async => Left(ServerFailure()));

      //assertLater
      final expectedStates = [
        Loading(),
        Error(message: serverFailureMessage),
      ];
      expectLater(bloc.stream, emitsInOrder(expectedStates));
      //act
      bloc.add(GetTriviaForConcreteNumber(numberString: tNumberString));
    });
    test('should emit [Loading, Error] when data is gotten successfully and with a proper error message', () {
      //arrange
      when(mockInputConverter.stringToUnsignedInteger(tNumberString)).thenReturn(
        Right(tNumberParsed),
      );
      when(mockGetConcreteNumberTrivia(GetConcreteNumberTriviaParams(number: tNumberParsed)))
          .thenAnswer((_) async => Left(CacheFailure()));

      //assertLater
      final expectedStates = [
        Loading(),
        Error(message: cacheFailureMessage),
      ];
      expectLater(bloc.stream, emitsInOrder(expectedStates));
      //act
      bloc.add(GetTriviaForConcreteNumber(numberString: tNumberString));
    });
  });

  group('GetTriviaForRandomNumber', () {
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');
    final expectedStream = [
      Error(
        message: invalidInputFailureMessage,
      )
    ];

    test('should get the data from the random use case', () async {
      //arrange
      when(mockGetRandomNumberTrivia(NoParams())).thenAnswer((_) async => const Right(tNumberTrivia));
      //act
      bloc.add(GetTriviaForRandomNumber());
      //need to await for the call to be executed
      await untilCalled(mockGetRandomNumberTrivia(NoParams()));
      //assert
      verify(mockGetRandomNumberTrivia(NoParams()));
    });

    test('should emit [Loading, Loaded] when data is gotten successfully', () {
      //arrange
      when(mockGetRandomNumberTrivia(NoParams())).thenAnswer((_) async => const Right(tNumberTrivia));
      //assertLater
      final expectedStates = [
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ];
      expectLater(bloc.stream, emitsInOrder(expectedStates));
      //act
      bloc.add(GetTriviaForRandomNumber());
    });

    test('should emit [Loading, Error] when data is gotten successfully', () {
      //arrange
      when(mockGetRandomNumberTrivia(NoParams())).thenAnswer((_) async => Left(ServerFailure()));

      //assertLater
      final expectedStates = [
        Loading(),
        Error(message: serverFailureMessage),
      ];
      expectLater(bloc.stream, emitsInOrder(expectedStates));
      //act
      bloc.add(GetTriviaForRandomNumber());
    });
    test('should emit [Loading, Error] when data is gotten successfully and with a proper error message', () {
      //arrange
      when(mockGetRandomNumberTrivia(NoParams())).thenAnswer((_) async => Left(CacheFailure()));

      //assertLater
      final expectedStates = [
        Loading(),
        Error(message: cacheFailureMessage),
      ];
      expectLater(bloc.stream, emitsInOrder(expectedStates));
      //act
      bloc.add(GetTriviaForRandomNumber());
    });
  });
}
