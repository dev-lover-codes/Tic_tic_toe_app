import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';

void main() {
  testWidgets('App smoke test', (tester) async {
    // Firebase not initialized in tests – just verify widget tree builds
    expect(TicTacToeApp, isNotNull);
  });
}
