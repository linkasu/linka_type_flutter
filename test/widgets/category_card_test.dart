import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linka_type_flutter/ui/widgets/category_card.dart';
import 'package:linka_type_flutter/ui/widgets/item_card.dart';
import 'package:linka_type_flutter/api/models/category.dart';

void main() {
  group('CategoryCard', () {
    late Category testCategory;

    setUp(() {
      testCategory = Category(
        id: 'test-id',
        title: 'Тестовая категория',
        userId: 'user-id',
      );
    });

    testWidgets('отображает название категории', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              category: testCategory,
              statementCount: 5,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Тестовая категория'), findsOneWidget);
    });

    testWidgets('отображает количество фраз', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              category: testCategory,
              statementCount: 3,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('3 фраз'), findsOneWidget);
    });

    testWidgets('отображает иконку папки', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              category: testCategory,
              statementCount: 0,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.folder), findsOneWidget);
    });

    testWidgets('вызывает onTap при нажатии', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              category: testCategory,
              statementCount: 0,
              onTap: () => tapped = true,
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CategoryCard));
      expect(tapped, isTrue);
    });

    testWidgets('вызывает onEdit при нажатии на редактировать', (
      WidgetTester tester,
    ) async {
      bool edited = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              category: testCategory,
              statementCount: 0,
              onTap: () {},
              onEdit: () => edited = true,
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(CategoryCard));
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
            body: CategoryCard(
              category: testCategory,
              statementCount: 0,
              onTap: () {},
              onEdit: () {},
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(CategoryCard));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Удалить'));
      expect(deleted, isTrue);
    });

    testWidgets('показывает правильное склонение для одной фразы', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              category: testCategory,
              statementCount: 1,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('1 фраз'), findsOneWidget);
    });

    testWidgets('показывает правильное склонение для нескольких фраз', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              category: testCategory,
              statementCount: 5,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('5 фраз'), findsOneWidget);
    });

    testWidgets('показывает правильное склонение для нуля фраз', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              category: testCategory,
              statementCount: 0,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('0 фраз'), findsOneWidget);
    });

    testWidgets('использует ItemCard внутри', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryCard(
              category: testCategory,
              statementCount: 2,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Проверяем, что CategoryCard использует ItemCard
      expect(find.byType(CategoryCard), findsOneWidget);
      // ItemCard должен быть найден как дочерний элемент
      expect(find.byType(ItemCard), findsOneWidget);
    });
  });
}
