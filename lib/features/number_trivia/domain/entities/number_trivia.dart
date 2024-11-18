import 'package:equatable/equatable.dart';

class NumberTrivia extends Equatable {
  final String text;
  final double? number;

  const NumberTrivia({required this.text, this.number});

  @override
  List<Object?> get props => [text, number];
}
