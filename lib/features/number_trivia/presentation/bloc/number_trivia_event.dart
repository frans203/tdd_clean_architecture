import 'package:equatable/equatable.dart';

abstract class NumberTriviaEvent extends Equatable {
  @override
  List<Object> get props => [];
}

//events should not convert data, just dispatch events, it should not handle presentation logic
class GetTriviaForConcreteNumber extends NumberTriviaEvent {
  final String numberString;
  //never put logic inside this event classes
  GetTriviaForConcreteNumber({required this.numberString});

  @override
  List<Object> get props => [numberString];
}

class GetTriviaForRandomNumber extends NumberTriviaEvent {}
