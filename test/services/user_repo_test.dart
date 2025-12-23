import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:resume_builder/services/user_repo.dart';

// Import the generated mock file (we will generate this next)
import 'user_repo_test.mocks.dart';

// Annotation to generate the MockClient class
@GenerateMocks([http.Client])
void main() {
  // Define variables for the mock and the class under test
  late MockClient mockClient;
  late UserRepository userRepository;

  // setUp runs before every test
  setUp(() {
    mockClient = MockClient();
    userRepository = UserRepository(client: mockClient);
  });

  group('UserRepository Tests', () {
    test('fetchUser returns a User if the http call completes successfully',
        () async {
      // ARRANGEMENT
      // Stub the client.get method to return a successful response (200 OK)
      // when calls to any URI are made which matches the pattern
      when(mockClient.get(any)).thenAnswer((_) async => http.Response(
          '{"id": 1, "name": "John Doe", "email": "john@example.com"}', 200));

      // ACT
      final user = await userRepository.fetchUser(1);

      // ASSERTION
      expect(user, isNotNull);
      expect(user?.name, 'John Doe');
      expect(user?.email, 'john@example.com');

      // Verify that the get request was called exactly once
      verify(mockClient
              .get(Uri.parse('https://jsonplaceholder.typicode.com/users/1')))
          .called(1);
    });

    test(
        'fetchUser throws an exception if the http call completes with an error',
        () {
      // ARRANGEMENT
      // Stub the client.get method to return a 404 Not Found response
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      // ACT & ASSERTION
      // Expect the function call to throw an Exception
      expect(userRepository.fetchUser(1), throwsException);
    });
  });
}
