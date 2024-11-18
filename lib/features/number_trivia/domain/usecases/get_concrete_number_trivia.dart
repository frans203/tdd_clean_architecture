import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tdd_clean_arch/core/error/failures.dart';
import 'package:tdd_clean_arch/core/usecases/index.dart';
import 'package:tdd_clean_arch/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd_clean_arch/features/number_trivia/domain/repositories/number_trivia_repository.dart';

class GetConcreteNumberTriviaParams extends Equatable {
  final int number;
  const GetConcreteNumberTriviaParams({required this.number});

  @override
  List<Object> get props => [number];
}

class GetConcreteNumberTrivia implements UseCase<NumberTrivia, GetConcreteNumberTriviaParams> {
  final NumberTriviaRepository repository;

  const GetConcreteNumberTrivia({required this.repository});

  @override
  Future<Either<Failure, NumberTrivia>> call(GetConcreteNumberTriviaParams params) async {
    return await repository.getConcreteNumberTrivia(params.number);
  }
}
