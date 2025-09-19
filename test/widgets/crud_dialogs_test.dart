import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linka_type_flutter/ui/widgets/crud_dialogs.dart';

void main() {
  group('CrudDialogs', () {
    testWidgets('showTextInputDialog отображает диалог с полем ввода', (
      WidgetTester tester,
    ) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await CrudDialogs.showTextInputDialog(
                    context: context,
                    title: 'Тестовый заголовок',
                    labelText: 'Тестовая метка',
                  );
                },
                child: const Text('Показать диалог'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Показать диалог'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Тестовый заголовок'), findsOneWidget);
      expect(find.text('Тестовая метка'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Отмена'), findsOneWidget);
      expect(find.text('Сохранить'), findsOneWidget);
    });

    testWidgets('showTextInputDialog возвращает null при отмене', (
      WidgetTester tester,
    ) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await CrudDialogs.showTextInputDialog(
                    context: context,
                    title: 'Тестовый заголовок',
                    labelText: 'Тестовая метка',
                  );
                },
                child: const Text('Показать диалог'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Показать диалог'));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Отмена'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(result, isNull);
    });

    testWidgets('showTextInputDialog возвращает текст при сохранении', (
      WidgetTester tester,
    ) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await CrudDialogs.showTextInputDialog(
                    context: context,
                    title: 'Тестовый заголовок',
                    labelText: 'Тестовая метка',
                  );
                },
                child: const Text('Показать диалог'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Показать диалог'));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'Тестовый текст');
      await tester.tap(find.text('Сохранить'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(result, equals('Тестовый текст'));
    });

    testWidgets('showTextInputDialog не сохраняет пустой текст', (
      WidgetTester tester,
    ) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await CrudDialogs.showTextInputDialog(
                    context: context,
                    title: 'Тестовый заголовок',
                    labelText: 'Тестовая метка',
                  );
                },
                child: const Text('Показать диалог'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Показать диалог'));
      await tester.pump(const Duration(milliseconds: 100));

      // Не вводим текст
      await tester.tap(find.text('Сохранить'));
      await tester.pump(const Duration(milliseconds: 100));

      // Диалог должен остаться открытым
      expect(find.text('Тестовый заголовок'), findsOneWidget);
    });

    testWidgets('showTextInputDialog показывает начальное значение', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  await CrudDialogs.showTextInputDialog(
                    context: context,
                    title: 'Тестовый заголовок',
                    labelText: 'Тестовая метка',
                    initialValue: 'Начальное значение',
                  );
                },
                child: const Text('Показать диалог'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Показать диалог'));
      await tester.pump(const Duration(milliseconds: 100));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, equals('Начальное значение'));
    });

    testWidgets('showConfirmDialog отображает диалог подтверждения', (
      WidgetTester tester,
    ) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await CrudDialogs.showConfirmDialog(
                    context: context,
                    title: 'Подтверждение',
                    content: 'Вы уверены?',
                  );
                },
                child: const Text('Показать диалог'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Показать диалог'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Подтверждение'), findsOneWidget);
      expect(find.text('Вы уверены?'), findsOneWidget);
      expect(find.text('Отмена'), findsOneWidget);
      expect(find.text('Удалить'), findsOneWidget);
    });

    testWidgets('showConfirmDialog возвращает false при отмене', (
      WidgetTester tester,
    ) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await CrudDialogs.showConfirmDialog(
                    context: context,
                    title: 'Подтверждение',
                    content: 'Вы уверены?',
                  );
                },
                child: const Text('Показать диалог'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Показать диалог'));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Отмена'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(result, isFalse);
    });

    testWidgets('showConfirmDialog возвращает true при подтверждении', (
      WidgetTester tester,
    ) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await CrudDialogs.showConfirmDialog(
                    context: context,
                    title: 'Подтверждение',
                    content: 'Вы уверены?',
                  );
                },
                child: const Text('Показать диалог'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Показать диалог'));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Удалить'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(result, isTrue);
    });

    testWidgets('showContextMenu отображает контекстное меню', (
      WidgetTester tester,
    ) async {
      bool item1Tapped = false;
      bool item2Tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  CrudDialogs.showContextMenu(
                    context: context,
                    items: [
                      ContextMenuItem(
                        icon: const Icon(Icons.edit),
                        title: 'Редактировать',
                        onTap: () => item1Tapped = true,
                      ),
                      ContextMenuItem(
                        icon: const Icon(Icons.delete),
                        title: 'Удалить',
                        onTap: () => item2Tapped = true,
                      ),
                    ],
                  );
                },
                child: const Text('Показать меню'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Показать меню'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Редактировать'), findsOneWidget);
      expect(find.text('Удалить'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('showContextMenu вызывает onTap при нажатии на элемент', (
      WidgetTester tester,
    ) async {
      bool itemTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  CrudDialogs.showContextMenu(
                    context: context,
                    items: [
                      ContextMenuItem(
                        icon: const Icon(Icons.edit),
                        title: 'Редактировать',
                        onTap: () => itemTapped = true,
                      ),
                    ],
                  );
                },
                child: const Text('Показать меню'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Показать меню'));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Редактировать'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(itemTapped, isTrue);
    });
  });
}
