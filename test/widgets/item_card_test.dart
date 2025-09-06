import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linka_type_flutter/ui/widgets/item_card.dart';

void main() {
  group('ItemCard', () {
    testWidgets('отображает заголовок', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(title: 'Тестовая карточка', onTap: () {}),
          ),
        ),
      );

      expect(find.text('Тестовая карточка'), findsOneWidget);
    });

    testWidgets('отображает подзаголовок когда передан', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              title: 'Тестовая карточка',
              subtitle: '5 фраз',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Тестовая карточка'), findsOneWidget);
      expect(find.text('5 фраз'), findsOneWidget);
    });

    testWidgets('отображает иконку когда передана', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              title: 'Тестовая карточка',
              icon: Icons.folder,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.folder), findsOneWidget);
    });

    testWidgets('не отображает иконку когда не передана', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(title: 'Тестовая карточка', onTap: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.folder), findsNothing);
    });

    testWidgets('вызывает onTap при нажатии', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              title: 'Тестовая карточка',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ItemCard));
      expect(tapped, isTrue);
    });

    testWidgets('показывает контекстное меню при долгом нажатии', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              title: 'Тестовая карточка',
              onEdit: () {},
              onDelete: () {},
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(ItemCard));
      await tester.pumpAndSettle();

      expect(find.text('Редактировать'), findsOneWidget);
      expect(find.text('Удалить'), findsOneWidget);
    });

    testWidgets('показывает пункт воспроизведения когда передан onPlay', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              title: 'Тестовая карточка',
              onPlay: () {},
              onEdit: () {},
              onDelete: () {},
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(ItemCard));
      await tester.pumpAndSettle();

      expect(find.text('Воспроизвести'), findsOneWidget);
      expect(find.text('Редактировать'), findsOneWidget);
      expect(find.text('Удалить'), findsOneWidget);
    });

    testWidgets('не показывает контекстное меню когда нет действий', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(title: 'Тестовая карточка', onTap: () {}),
          ),
        ),
      );

      await tester.longPress(find.byType(ItemCard));
      await tester.pumpAndSettle();

      expect(find.text('Редактировать'), findsNothing);
      expect(find.text('Удалить'), findsNothing);
    });

    testWidgets('вызывает onEdit при нажатии на редактировать', (
      WidgetTester tester,
    ) async {
      bool edited = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              title: 'Тестовая карточка',
              onEdit: () => edited = true,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(ItemCard));
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
            body: ItemCard(
              title: 'Тестовая карточка',
              onDelete: () => deleted = true,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(ItemCard));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Удалить'));
      expect(deleted, isTrue);
    });

    testWidgets('вызывает onPlay при нажатии на воспроизвести', (
      WidgetTester tester,
    ) async {
      bool played = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(
              title: 'Тестовая карточка',
              onPlay: () => played = true,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(ItemCard));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Воспроизвести'));
      expect(played, isTrue);
    });

    testWidgets('ограничивает текст заголовка двумя строками', (
      WidgetTester tester,
    ) async {
      const longTitle =
          'Очень длинный заголовок который должен быть ограничен двумя строками и показать многоточие';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ItemCard(title: longTitle, onTap: () {}),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text(longTitle));
      expect(textWidget.maxLines, equals(2));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
    });
  });
}
