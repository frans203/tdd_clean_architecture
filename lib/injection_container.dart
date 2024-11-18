import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdd_clean_arch/core/network/index.dart';
import 'package:tdd_clean_arch/core/util/input_converter.dart';
import 'package:tdd_clean_arch/features/number_trivia/data/datasources/index.dart';
import 'package:tdd_clean_arch/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdd_clean_arch/features/number_trivia/data/repositories/index.dart';
import 'package:tdd_clean_arch/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:tdd_clean_arch/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tdd_clean_arch/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:tdd_clean_arch/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // FEATURES - Number Trivia
  initFeatures();
  // CORE
  initCore();
  // EXTERNAL
  await initExternal();
}

void initFeatures() async {
  // BLOC
  //obs: blocs should not be registered as singletons
  getIt.registerFactory(() => NumberTriviaBloc(
        getConcreteNumberTrivia: getIt<GetConcreteNumberTrivia>(),
        inputConverter: getIt<InputConverter>(),
        getRandomNumberTrivia: getIt<GetRandomNumberTrivia>(),
      ));

  // use cases
  // it makes sense to register useCases as singletons. Since there is no need to create differente instances of it
  // considering that this is immutable
  getIt.registerLazySingleton(
    () => GetConcreteNumberTrivia(
      repository: getIt<NumberTriviaRepository>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetRandomNumberTrivia(
      repository: getIt<NumberTriviaRepository>(),
    ),
  );
  //core
  getIt.registerLazySingleton(() => InputConverter());
  //data source
  getIt.registerLazySingleton<NumberTriviaRemoteDataSource>(
    () => NumberTriviaRemoteDataSourceImpl(
      client: getIt<http.Client>(),
    ),
  );
  getIt.registerLazySingleton<NumberTriviaLocalDataSource>(
    () => NumberTriviaLocalDataSourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );
  //repository
  getIt.registerLazySingleton<NumberTriviaRepository>(
    () => NumberTriviaRepositoryImpl(
      remoteDataSource: getIt<NumberTriviaRemoteDataSource>(),
      localDataSource: getIt<NumberTriviaLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
}

void initCore() async {
  //network info
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(
      connectionChecker: getIt<InternetConnectionChecker>(),
    ),
  );
}

Future<void> initExternal() async {
  //http
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  //shared preferences
  await initSharedPreferences();
  //connection checker
  getIt.registerLazySingleton<InternetConnectionChecker>(() => InternetConnectionChecker());
}

Future<void> initSharedPreferences() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() {
    return sharedPreferences;
  });
}
