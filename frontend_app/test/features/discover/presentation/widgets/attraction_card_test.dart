import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_app/features/discover/domain/entities/attraction.dart';
import 'package:frontend_app/features/discover/presentation/widgets/attraction_card.dart';

void main() {
  const attraction = Attraction(
    id: 'lake-kivu',
    name: 'Lake Kivu',
    description: '',
    category: AttractionCategory.nature,
    latitude: 0,
    longitude: 0,
    rating: 4.7,
    imageUrl: '',
    district: 'Rubavu',
  );

  Widget harness({required VoidCallback onTap}) => MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 180,
        height: 240,
        child: AttractionCard(attraction: attraction, onTap: onTap),
      ),
    ),
  );

  testWidgets('renders the name, rating and district', (tester) async {
    await tester.pumpWidget(harness(onTap: () {}));

    expect(find.text('Lake Kivu'), findsOneWidget);
    expect(find.text('4.7'), findsOneWidget);
    expect(find.text('Rubavu'), findsOneWidget);
  });

  testWidgets('calls onTap when the card is tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(harness(onTap: () => tapped = true));

    await tester.tap(find.byType(AttractionCard));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('lays out without overflow at a narrow width', (tester) async {
    await tester.pumpWidget(harness(onTap: () {}));
    expect(tester.takeException(), isNull);
  });
}
