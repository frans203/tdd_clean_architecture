import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_clean_arch/core/network/index.dart';

import 'network_info_test.mocks.dart';

@GenerateMocks([InternetConnectionChecker])
void main() {
  late NetworkInfoImpl networkInfo;
  late MockInternetConnectionChecker mockInternetConnectionChecker;

  setUp(() {
    mockInternetConnectionChecker = MockInternetConnectionChecker();
    networkInfo = NetworkInfoImpl(connectionChecker: mockInternetConnectionChecker);
  });

  group('isConnected', () {
    test('should forward the call to InternetConnectionChecker.hasConnection', () async {
      const tHasConnectionFuture = true;
      //arrange
      when(mockInternetConnectionChecker.hasConnection).thenAnswer((_) async => tHasConnectionFuture);
      //act
      final result = await networkInfo.isConnected;
      //assert
      verify(mockInternetConnectionChecker.hasConnection);
      expect(result, tHasConnectionFuture);
    });
  });

  group('isNotConnected', () {
    test('should block the call to InternetConnectionChecker.hasConnection', () async {
      const tHasConnectionFuture = false;
      //arrange
      when(mockInternetConnectionChecker.hasConnection).thenAnswer((_) async => tHasConnectionFuture);
      //act
      final result = await networkInfo.isConnected;
      //assert
      verify(mockInternetConnectionChecker.hasConnection);
      expect(result, tHasConnectionFuture);
    });
  });
}
