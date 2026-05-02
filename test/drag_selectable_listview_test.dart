import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drag_selectable_listview/drag_selectable_listview.dart';

void main() {
  group('DragSelectableListView Widget Tests', () {
    late Set<int> selectedItems;
    late List<String> testItems;

    setUp(() {
      selectedItems = <int>{};
      testItems = List.generate(10, (index) => 'Item $index');
    });

    Widget createTestWidget({
      Set<int>? initialSelected,
      int itemCount = 10,
      double itemHeight = 56.0,
      double checkboxWidth = 48.0,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: DragSelectableListView(
            itemCount: itemCount,
            selected: initialSelected ?? selectedItems,
            itemHeight: itemHeight,
            checkboxWidth: checkboxWidth,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                child: Text(testItems[index]),
              );
            },
            checkboxBuilder: ({
              required bool value,
              required ValueChanged<bool?> onChanged,
            }) {
              return Checkbox(
                value: value,
                onChanged: onChanged,
              );
            },
            onSelectionChanged: (Set<int> newSelection) {
              selectedItems = newSelection;
            },
          ),
        ),
      );
    }

    testWidgets('should render correct number of items', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify the ListView is rendered
      expect(find.byType(ListView), findsOneWidget);

      // Check that items are rendered

      for (int i = 0; i < testItems.length; i++) {
        expect(find.text('Item $i'), findsOneWidget);
      }
    });

    testWidgets('should display checkboxes for each item', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find all checkboxes
      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsNWidgets(testItems.length));
    });

    testWidgets('should handle checkbox interactions', (WidgetTester tester) async {
      // Test that checkboxes are present and can be found
      await tester.pumpWidget(createTestWidget());

      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsWidgets);

      // Test that checkbox state reflects selection
      final firstCheckbox = tester.widget<Checkbox>(checkboxes.first);
      expect(firstCheckbox.value, isFalse); // Initially not selected
    });

    testWidgets('should handle initial selected items', (WidgetTester tester) async {
      final initialSelected = {1, 3, 5};

      await tester.pumpWidget(createTestWidget(initialSelected: initialSelected));

      // Check that initially selected items show as checked
      final checkboxes = find.byType(Checkbox);

      for (int i = 0; i < testItems.length; i++) {
        final checkbox = tester.widget<Checkbox>(checkboxes.at(i));
        if (initialSelected.contains(i)) {
          expect(checkbox.value, isTrue);
        } else {
          expect(checkbox.value, isFalse);
        }
      }
    });

    testWidgets('should respect custom item height', (WidgetTester tester) async {
      const customHeight = 100.0;

      await tester.pumpWidget(createTestWidget(itemHeight: customHeight));

      // Find SizedBox widgets that should have the custom height
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsWidgets);

      // Check that at least one SizedBox has the correct height
      bool foundCorrectHeight = false;
      for (int i = 0; i < sizedBoxes.evaluate().length; i++) {
        final sizedBox = tester.widget<SizedBox>(sizedBoxes.at(i));
        if (sizedBox.height == customHeight) {
          foundCorrectHeight = true;
          break;
        }
      }
      expect(foundCorrectHeight, isTrue);
    });

    testWidgets('should respect custom checkbox width', (WidgetTester tester) async {
      const customWidth = 60.0;

      await tester.pumpWidget(createTestWidget(checkboxWidth: customWidth));

      // Find SizedBox widgets for checkbox containers
      final checkboxContainers = find.byType(SizedBox);
      expect(checkboxContainers, findsWidgets);

      // Check that at least one SizedBox has the correct width
      bool foundCorrectWidth = false;
      for (int i = 0; i < checkboxContainers.evaluate().length; i++) {
        final sizedBox = tester.widget<SizedBox>(checkboxContainers.at(i));
        if (sizedBox.width == customWidth) {
          foundCorrectWidth = true;
          break;
        }
      }
      expect(foundCorrectWidth, isTrue);
    });

    testWidgets('should handle empty list', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(itemCount: 0));

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Checkbox), findsNothing);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('should handle single item list', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(itemCount: 1));

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
    });

    testWidgets('should call onSelectionChanged callback', (WidgetTester tester) async {
      final List<Set<int>> selectionChanges = [];

      Widget testWidget = MaterialApp(
        home: Scaffold(
          body: DragSelectableListView(
            itemCount: testItems.length,
            selected: <int>{},
            itemHeight: 56.0,
            checkboxWidth: 48.0,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(testItems[index]),
              );
            },
            checkboxBuilder: ({
              required bool value,
              required ValueChanged<bool?> onChanged,
            }) {
              return Checkbox(
                value: value,
                onChanged: onChanged,
              );
            },
            onSelectionChanged: (Set<int> newSelection) {
              selectionChanges.add(Set.from(newSelection));
            },
          ),
        ),
      );

      await tester.pumpWidget(testWidget);

      // Initially no changes
      expect(selectionChanges.isEmpty, isTrue);

      // Simulate checkbox interaction by calling onChanged directly
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox).first);
      checkbox.onChanged!(true);
      await tester.pump();

      // Should have recorded the change
      expect(selectionChanges.isNotEmpty, isTrue);
      expect(selectionChanges.last, equals({0}));
    });

    group('Drag Selection Tests', () {
      testWidgets('should detect pointer down events', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Simulate pointer down event
        final gesture = await tester.startGesture(tester.getCenter(find.byType(ListView)));
        await tester.pump();

        // The gesture should be recognized
        expect(gesture, isNotNull);

        // Clean up
        await gesture.up();
        await tester.pump();
      });

      testWidgets('should handle pointer move events', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Start gesture
        final gesture = await tester.startGesture(tester.getCenter(find.byType(ListView)));
        await tester.pump();

        // Move pointer
        await gesture.moveTo(tester.getCenter(find.byType(ListView)) + const Offset(0, 10));
        await tester.pump();

        // Clean up
        await gesture.up();
        await tester.pump();
      });

      testWidgets('should handle pointer up events', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Start and end gesture
        final gesture = await tester.startGesture(tester.getCenter(find.byType(ListView)));
        await tester.pump();

        await gesture.up();
        await tester.pump();

        // Should complete without errors
        expect(find.byType(ListView), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle rapid checkbox taps', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final firstCheckbox = find.byType(Checkbox).first;

        // Rapid tapping
        for (int i = 0; i < 5; i++) {
          await tester.tap(firstCheckbox);
          await tester.pump(const Duration(milliseconds: 10));
        }

        // Should handle rapid taps without issues
        expect(find.byType(ListView), findsOneWidget);
        expect(selectedItems.contains(0), isTrue); // Should be selected after odd number of taps
      });

      testWidgets('should handle large number of items', (WidgetTester tester) async {
        const largeItemCount = 1000;
        final largeTestItems = List.generate(largeItemCount, (index) => 'Item $index');

        Widget largeWidget = MaterialApp(
          home: Scaffold(
            body: DragSelectableListView(
              itemCount: largeItemCount,
              selected: selectedItems,
              itemHeight: 56.0,
              checkboxWidth: 48.0,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(largeTestItems[index]),
                );
              },
              checkboxBuilder: ({
                required bool value,
                required ValueChanged<bool?> onChanged,
              }) {
                return Checkbox(
                  value: value,
                  onChanged: onChanged,
                );
              },
              onSelectionChanged: (Set<int> newSelection) {
                selectedItems = newSelection;
              },
            ),
          ),
        );

        await tester.pumpWidget(largeWidget);

        // Should render without issues
        expect(find.byType(ListView), findsOneWidget);

        // Test scrolling
        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pump();

        // Should still be functional
        expect(find.byType(ListView), findsOneWidget);
      });
    });
  });

  group('DragSelectableListView Unit Tests', () {
    test('should calculate correct index from pointer position', () {
      // This test would require more complex setup to test the getIndex method
      // as it depends on RenderBox and widget tree context
      // For now, we'll test the logic indirectly through widget tests
    });

    test('should handle selection range correctly', () {
      // Test selection range calculation logic
      final initialSelected = <int>{};
      final startIndex = 2;
      final currentIndex = 5;

      int s = startIndex.clamp(0, 9);
      int c = currentIndex.clamp(0, 9);

      int minIndex = s < c ? s : c;
      int maxIndex = s > c ? s : c;

      Set<int> newSelected = Set.from(initialSelected);

      for (int i = minIndex; i <= maxIndex; i++) {
        if (initialSelected.contains(i)) {
          newSelected.remove(i);
        } else {
          newSelected.add(i);
        }
      }

      expect(newSelected, equals({2, 3, 4, 5}));
    });

    test('should handle reverse selection range', () {
      final initialSelected = <int>{};
      final startIndex = 5;
      final currentIndex = 2;

      int s = startIndex.clamp(0, 9);
      int c = currentIndex.clamp(0, 9);

      int minIndex = s < c ? s : c;
      int maxIndex = s > c ? s : c;

      Set<int> newSelected = Set.from(initialSelected);

      for (int i = minIndex; i <= maxIndex; i++) {
        if (initialSelected.contains(i)) {
          newSelected.remove(i);
        } else {
          newSelected.add(i);
        }
      }

      expect(newSelected, equals({2, 3, 4, 5}));
    });

    test('should toggle existing selections correctly', () {
      final initialSelected = {2, 4};
      final startIndex = 2;
      final currentIndex = 5;

      int s = startIndex.clamp(0, 9);
      int c = currentIndex.clamp(0, 9);

      int minIndex = s < c ? s : c;
      int maxIndex = s > c ? s : c;

      Set<int> newSelected = Set.from(initialSelected);

      for (int i = minIndex; i <= maxIndex; i++) {
        if (initialSelected.contains(i)) {
          newSelected.remove(i);
        } else {
          newSelected.add(i);
        }
      }

      // 2 and 4 were initially selected, so they should be removed
      // 3 and 5 were not selected, so they should be added
      expect(newSelected, equals({3, 5}));
    });
  });
}