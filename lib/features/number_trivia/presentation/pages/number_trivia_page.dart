import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdd_clean_arch/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:tdd_clean_arch/features/number_trivia/presentation/bloc/number_trivia_state.dart';
import 'package:tdd_clean_arch/features/number_trivia/presentation/widgets/widgets.dart';
import 'package:tdd_clean_arch/injection_container.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Trivia'),
      ),
      body: SingleChildScrollView(
        child: BlocProvider(
          create: (context) => getIt<NumberTriviaBloc>(),
          child: Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  BlocBuilder<NumberTriviaBloc, NumberTriviaState>(builder: (context, state) {
                    if (state is Empty) {
                      return const MessageDisplay(message: 'Start Searching!');
                    }

                    if (state is Error) {
                      return MessageDisplay(message: state.message);
                    }

                    if (state is Loaded) {
                      return TriviaDisplay(numberTrivia: state.trivia);
                    }

                    if (state is Loading) {
                      return const LoadingWidget();
                    }

                    return const MessageDisplay(
                      message: 'Unexpected behavior',
                    );
                  }),
                  const TriviaControls(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
