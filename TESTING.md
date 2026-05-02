# DragSelectableListView Testing

This document describes the test suite for the DragSelectableListView Flutter component.

## Test Structure

The test suite is located in `test/drag_selectable_listview_test.dart` and includes:

### Widget Tests
- **Basic Rendering Tests**: Verify that the component renders correctly with the expected number of items and checkboxes
- **Configuration Tests**: Test custom dimensions (item height, checkbox width)
- **Initial State Tests**: Verify that initial selection states are properly displayed
- **Empty List Handling**: Ensure the component handles empty lists gracefully
- **Selection Callback Tests**: Verify that onSelectionChanged is called appropriately
- **Pointer Event Tests**: Test drag selection interactions
- **Edge Case Tests**: Handle rapid interactions and large lists

### Unit Tests
- **Selection Logic Tests**: Test the core selection range calculation algorithms
- **Boundary Condition Tests**: Verify handling of edge cases like negative indices

## Running Tests

To run the test suite:

```bash
flutter test
```

To run tests with verbose output:

```bash
flutter test --verbose
```

## Test Coverage

The test suite covers:

✅ Component rendering and layout
✅ Checkbox display and interaction
✅ Custom dimension handling
✅ Initial selection state
✅ Empty and edge cases
✅ Pointer/drag interactions
✅ Selection range calculations
✅ Boundary condition handling

## Key Test Patterns

### Widget Testing
- Uses `WidgetTester` to create and interact with widget trees
- Tests both positive and negative scenarios
- Verifies UI state changes and callback invocations

### Unit Testing
- Tests pure logic functions independently of UI
- Focuses on selection algorithms and range calculations
- Ensures mathematical correctness of selection logic

## Test Dependencies

The tests require:
- `flutter_test` package for widget testing framework
- Standard Flutter testing utilities

## Notes

- Some interactive tests are simplified to focus on callback verification rather than complex gesture simulation
- The test suite prioritizes reliability and maintainability over exhaustive interaction testing
- Edge cases are thoroughly tested to ensure robust behavior