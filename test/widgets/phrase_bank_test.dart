import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linka_type_flutter/ui/widgets/phrase_bank.dart';
import 'package:linka_type_flutter/api/models/category.dart';
import 'package:linka_type_flutter/api/models/statement.dart';

void main() {
  group('PhraseBank', () {
    late List<Category> testCategories;
    late List<Statement> testStatements;

    setUp(() {
      testCategories = [
        Category(id: 'cat1', title: 'Категория 1', userId: 'user1'),
        Category(id: 'cat2', title: 'Категория 2', userId: 'user1'),
      ];

      testStatements = [
        Statement(
          id: 'stmt1',
          title: 'Фраза 1',
          categoryId: 'cat1',
          userId: 'user1',
        ),
        Statement(
          id: 'stmt2',
          title: 'Фраза 2',
          categoryId: 'cat1',
          userId: 'user1',
        ),
        Statement(
          id: 'stmt3',
          title: 'Фраза 3',
          categoryId: 'cat2',
          userId: 'user1',
        ),
      ];
    });

    testWidgets(
      'отображает список категорий когда selectedCategory равен null',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PhraseBank(
                categories: testCategories,
                statements: testStatements,
                onSayStatement: (_) {},
                onEditStatement: (_) {},
                onDeleteStatement: (_) {},
                onEditCategory: (_) {},
                onDeleteCategory: (_) {},
                onAddStatement: () {},
                onAddCategory: () {},
                selectedCategory: null,
                onCategorySelected: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('Выберите категорию'), findsOneWidget);
        expect(find.text('Категория 1'), findsOneWidget);
        expect(find.text('Категория 2'), findsOneWidget);
        expect(find.text('2 фраз'), findsOneWidget); // Категория 1
        expect(find.text('1 фраз'), findsOneWidget); // Категория 2
      },
    );

    testWidgets('отображает список фраз когда выбрана категория', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhraseBank(
              categories: testCategories,
              statements: testStatements,
              onSayStatement: (_) {},
              onEditStatement: (_) {},
              onDeleteStatement: (_) {},
              onEditCategory: (_) {},
              onDeleteCategory: (_) {},
              onAddStatement: () {},
              onAddCategory: () {},
              selectedCategory: testCategories[0],
              onCategorySelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Фразы: Категория 1'), findsOneWidget);
      expect(find.text('Фраза 1'), findsOneWidget);
      expect(find.text('Фраза 2'), findsOneWidget);
      expect(find.text('Фраза 3'), findsNothing); // Не должна отображаться
    });

    testWidgets('показывает кнопку добавления категории в режиме категорий', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhraseBank(
              categories: testCategories,
              statements: testStatements,
              onSayStatement: (_) {},
              onEditStatement: (_) {},
              onDeleteStatement: (_) {},
              onEditCategory: (_) {},
              onDeleteCategory: (_) {},
              onAddStatement: () {},
              onAddCategory: () {},
              selectedCategory: null,
              onCategorySelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('показывает кнопку добавления фразы в режиме фраз', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhraseBank(
              categories: testCategories,
              statements: testStatements,
              onSayStatement: (_) {},
              onEditStatement: (_) {},
              onDeleteStatement: (_) {},
              onEditCategory: (_) {},
              onDeleteCategory: (_) {},
              onAddStatement: () {},
              onAddCategory: () {},
              selectedCategory: testCategories[0],
              onCategorySelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('показывает кнопку назад в режиме фраз', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhraseBank(
              categories: testCategories,
              statements: testStatements,
              onSayStatement: (_) {},
              onEditStatement: (_) {},
              onDeleteStatement: (_) {},
              onEditCategory: (_) {},
              onDeleteCategory: (_) {},
              onAddStatement: () {},
              onAddCategory: () {},
              selectedCategory: testCategories[0],
              onCategorySelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('вызывает onCategorySelected при нажатии на кнопку назад', (
      WidgetTester tester,
    ) async {
      Category? selectedCategory;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhraseBank(
              categories: testCategories,
              statements: testStatements,
              onSayStatement: (_) {},
              onEditStatement: (_) {},
              onDeleteStatement: (_) {},
              onEditCategory: (_) {},
              onDeleteCategory: (_) {},
              onAddStatement: () {},
              onAddCategory: () {},
              selectedCategory: testCategories[0],
              onCategorySelected: (category) => selectedCategory = category,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      expect(selectedCategory, isNull);
    });

    testWidgets(
      'вызывает onAddCategory при нажатии на кнопку добавления в режиме категорий',
      (WidgetTester tester) async {
        bool addCategoryCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PhraseBank(
                categories: testCategories,
                statements: testStatements,
                onSayStatement: (_) {},
                onEditStatement: (_) {},
                onDeleteStatement: (_) {},
                onEditCategory: (_) {},
                onDeleteCategory: (_) {},
                onAddStatement: () {},
                onAddCategory: () => addCategoryCalled = true,
                selectedCategory: null,
                onCategorySelected: (_) {},
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.add));
        expect(addCategoryCalled, isTrue);
      },
    );

    testWidgets(
      'вызывает onAddStatement при нажатии на кнопку добавления в режиме фраз',
      (WidgetTester tester) async {
        bool addStatementCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PhraseBank(
                categories: testCategories,
                statements: testStatements,
                onSayStatement: (_) {},
                onEditStatement: (_) {},
                onDeleteStatement: (_) {},
                onEditCategory: (_) {},
                onDeleteCategory: (_) {},
                onAddStatement: () => addStatementCalled = true,
                onAddCategory: () {},
                selectedCategory: testCategories[0],
                onCategorySelected: (_) {},
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.add));
        expect(addStatementCalled, isTrue);
      },
    );

    testWidgets('показывает сообщение об отсутствии категорий', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhraseBank(
              categories: [],
              statements: testStatements,
              onSayStatement: (_) {},
              onEditStatement: (_) {},
              onDeleteStatement: (_) {},
              onEditCategory: (_) {},
              onDeleteCategory: (_) {},
              onAddStatement: () {},
              onAddCategory: () {},
              selectedCategory: null,
              onCategorySelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Нет категорий'), findsOneWidget);
      expect(find.text('Нажмите + чтобы добавить категорию'), findsOneWidget);
    });

    testWidgets('показывает сообщение об отсутствии фраз в категории', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhraseBank(
              categories: testCategories,
              statements: [],
              onSayStatement: (_) {},
              onEditStatement: (_) {},
              onDeleteStatement: (_) {},
              onEditCategory: (_) {},
              onDeleteCategory: (_) {},
              onAddStatement: () {},
              onAddCategory: () {},
              selectedCategory: testCategories[0],
              onCategorySelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Нет фраз в этой категории'), findsOneWidget);
      expect(find.text('Нажмите + чтобы добавить фразу'), findsOneWidget);
    });

    testWidgets('правильно подсчитывает количество фраз в категории', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhraseBank(
              categories: testCategories,
              statements: testStatements,
              onSayStatement: (_) {},
              onEditStatement: (_) {},
              onDeleteStatement: (_) {},
              onEditCategory: (_) {},
              onDeleteCategory: (_) {},
              onAddStatement: () {},
              onAddCategory: () {},
              selectedCategory: null,
              onCategorySelected: (_) {},
            ),
          ),
        ),
      );

      // Категория 1 содержит 2 фразы
      expect(find.text('2 фраз'), findsOneWidget);
      // Категория 2 содержит 1 фразу
      expect(find.text('1 фраз'), findsOneWidget);
    });
  });
}
