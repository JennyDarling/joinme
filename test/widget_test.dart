import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:joinme/main.dart';
import 'package:joinme/providers/room_provider.dart';

void main() {
  testWidgets('JoinMe smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RoomProvider()),
        ],
        child: const JoinMeApp(),
      ),
    );

    expect(find.text('JoinMe'), findsOneWidget);
    expect(find.text('Create a Room'), findsOneWidget);
    expect(find.text('Join a Room'), findsOneWidget);
  });
}
