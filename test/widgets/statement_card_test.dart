import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linka_type_flutter/ui/widgets/statement_card.dart';
import 'package:linka_type_flutter/ui/widgets/item_card.dart';
import 'package:linka_type_flutter/api/models/statement.dart';

void main() {
  group('StatementCard', () {
    late Statement testStatement;

    setUp(() {
      testStatement = Statement(
        id: 'test-id',
        title: 'Тестовая фраза',
        categoryId: 'category-id',
        userId: 'user-id',
      );
    });

    testWidgets('отображает текст фразы', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatementCard(
              statement: testStatement,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Тестовая фраза'), findsOneWidget);
    });

    testWidgets('вызывает onTap при нажатии', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatementCard(
              statement: testStatement,
              onTap: () => tapped = true,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(StatementCard));
      expect(tapped, isTrue);
    });

    testWidgets('вызывает onEdit при нажатии на редактировать', (
      WidgetTester tester,
    ) async {
      bool edited = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatementCard(
              statement: testStatement,
              onTap: () {},
              onEdit: () => edited = true,
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(StatementCard));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Редактировать'));
      expect(edited, isTrue);
    });

    testWidgets('вызывает onDelete при нажатии на удалить', (
      WidgetTester tester,
    ) async {
      bool deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatementCard(
              statement: testStatement,
              onTap: () {},
              onEdit: () {},
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(StatementCard));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Удалить'));
      expect(deleted, isTrue);
    });

    testWidgets('показывает пункт воспроизведения в контекстном меню', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatementCard(
              statement: testStatement,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(StatementCard));
      await tester.pumpAndSettle();

      expect(find.text('Воспроизвести'), findsOneWidget);
      expect(find.text('Редактировать'), findsOneWidget);
      expect(find.text('Удалить'), findsOneWidget);
    });

    testWidgets('вызывает onTap при нажатии на воспроизвести', (
      WidgetTester tester,
    ) async {
      bool played = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatementCard(
              statement: testStatement,
              onTap: () => played = true,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(StatementCard));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Воспроизвести'));
      expect(played, isTrue);
    });

    testWidgets('не отображает иконку', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatementCard(
              statement: testStatement,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // StatementCard не должен показывать иконку
      expect(find.byIcon(Icons.folder), findsNothing);
      expect(find.byIcon(Icons.play_arrow), findsNothing);
    });

    testWidgets('не отображает подзаголовок', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatementCard(
              statement: testStatement,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // StatementCard не должен показывать подзаголовок с количеством фраз
      expect(
        find.textContaining('фраз'),
        findsOneWidget,
      ); // Находит "фраз" в "Тестовая фраза"
      // Но не должен показывать подзаголовок с числом
      expect(find.textContaining(RegExp(r'\d+ фраз')), findsNothing);
    });

    testWidgets('использует ItemCard внутри', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatementCard(
              statement: testStatement,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Проверяем, что StatementCard использует ItemCard
      expect(find.byType(StatementCard), findsOneWidget);
      // ItemCard должен быть найден как дочерний элемент
      expect(find.byType(ItemCard), findsOneWidget);
    });

    testWidgets('передает onTap как onPlay в ItemCard', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatementCard(
              statement: testStatement,
              onTap: () => tapped = true,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Проверяем, что onTap передается как onPlay
      await tester.longPress(find.byType(StatementCard));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Воспроизвести'));
      expect(tapped, isTrue);
    });
  });
}
