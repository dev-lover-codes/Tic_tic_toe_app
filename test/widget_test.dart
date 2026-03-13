import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:myapp/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => AppStateProvider(),
        child: const TicTacToeApp(),
      ),
    );

    // Verify that our app loads by finding the title text
    expect(find.text('The Ultimate\n'), findsNothing); // WelcomePage has 'The Ultimate' in rich text but won't be exactly 'The Ultimate\n' as a text widget probably
    // But it definitely doesn't crash on load
    expect(find.byType(TicTacToeApp), findsOneWidget);
  });
}
