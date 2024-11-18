import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdd_clean_arch/core/error/failures.dart';
import 'package:tdd_clean_arch/core/util/input_converter.dart';
import 'package:tdd_clean_arch/features/number_trivia/domain/entities/index.dart';
import 'package:tdd_clean_arch/features/number_trivia/domain/usecases/index.dart';
import 'package:tdd_clean_arch/features/number_trivia/presentation/bloc/number_trivia_event.dart';
import 'package:tdd_clean_arch/features/number_trivia/presentation/bloc/number_trivia_state.dart';

const String serverFailureMessage = 'Server Failure';
const String cacheFailureMessage = "Cache Failure";
const String invalidInputFailureMessage = 'Invalid input - The number must be a positive integer or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.inputConverter,
    required this.getRandomNumberTrivia,
  }) : super(Empty()) {
    on<GetTriviaForConcreteNumber>(_onGetConcreteNumberTrivia);
    on<GetTriviaForRandomNumber>(_onGetRandomNumberTrivia);
  }

  NumberTriviaState get initialState => Empty();

  void _onGetConcreteNumberTrivia(GetTriviaForConcreteNumber event, Emitter<NumberTriviaState> emit) async {
    final inputEither = inputConverter.stringToUnsignedInteger(event.numberString);

    await inputEither.fold((failure) async {
      emit(Error(message: invalidInputFailureMessage));
    }, (integer) async {
      emit(Loading());

      // Await the result of getConcreteNumberTrivia
      final failureOrTrivia = await getConcreteNumberTrivia(GetConcreteNumberTriviaParams(number: integer));

      // Ensure the next state is emitted after the async operation
      _eitherLoadedOrErrorState(failureOrTrivia, emit);
    });
  }

  void _onGetRandomNumberTrivia(GetTriviaForRandomNumber event, Emitter<NumberTriviaState> emit) async {
    final failureOrTrivia = await getRandomNumberTrivia(NoParams());
    emit(Loading());
    _eitherLoadedOrErrorState(failureOrTrivia, emit);
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return serverFailureMessage;
    }

    if (failure is CacheFailure) {
      return cacheFailureMessage;
    }

    return 'Unexpected error';
  }

  void _eitherLoadedOrErrorState(Either<Failure, NumberTrivia> failureOrTrivia, Emitter<NumberTriviaState> emit) {
    failureOrTrivia.fold((failure) {
      emit(Error(message: _mapFailureToMessage(failure)));
    }, (trivia) {
      emit(Loaded(trivia: trivia));
    });
  }
}
