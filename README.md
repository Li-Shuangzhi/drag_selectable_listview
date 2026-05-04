# Drag Selectable ListView

A Flutter ListView that supports drag-to-select multiple items with customizable selection UI and smooth interaction.

## Features

✨ **Drag Selection**: Select multiple items by dragging across them\
🎨 **Customizable UI**: Custom checkbox builders and item layouts\
📱 **Lazy Loading**: Uses ListView.builder for efficient rendering\
🎯 **Flexible Selection**: Support for both tap and drag selection modes\
🔧 **Easy Integration**: Simple API that works with existing ListView patterns

## Demo

![Demo GIF](./demo.gif)

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  drag_selectable_listview: ^1.0.1
```

Then run:

```bash
flutter pub get
```


## Complete Example

Here's a complete working example showing how to use DragSelectableListView:

```dart
class DragSelectPage extends StatefulWidget {
  const DragSelectPage({super.key});

  @override
  State<DragSelectPage> createState() => _DragSelectPageState();
}

class _DragSelectPageState extends State<DragSelectPage> {
  Set<int> selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            color: Colors.blueAccent,
            padding: EdgeInsets.all(8),
            child: Text(
              'selected: ${selected.toList().join(', ')}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: DragSelectableListView(
              itemCount: 60,
              itemHeight: 40,
              checkboxWidth: 40,
              touchSlop: 8.0,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    print(index);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text("Item $index")],
                        ),
                      ),
                      Divider(height: 1),
                    ],
                  ),
                );
              },
              checkboxBuilder:
                  ({
                required bool value,
                required ValueChanged<bool?> onChanged,
              }) {
                return Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    value: value,
                    onChanged: onChanged,
                  ),
                );
              },
              selected: selected,
              onSelectionChanged: (e) {
                //!! need setSate and selected = e
                setState(() {
                  selected = e;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## API Reference

### Properties

- **itemCount** (int): Total number of items in the list
- **itemBuilder** (IndexedWidgetBuilder): Builder function for list items
- **selected** (Set<int>): Set of currently selected item indices
- **onSelectionChanged** (ValueChanged<Set<int>>): Callback when selection changes
- **checkboxBuilder** (Function): Builder for custom checkbox widgets
- **itemHeight** (double): Height of each list item
- **checkboxWidth** (double): Width allocated for checkbox area
- **touchSlop** (double, optional): Minimum drag distance to activate selection mode (defaults to 8.0)

### Selection Behavior

- **Tap Selection**: Tap individual checkboxes to toggle selection
- **Drag Selection**: Press and drag across items to select/deselect ranges
  - **Important**: Drag selection only activates when gesture starts within checkbox area (defined by `checkboxWidth`)
  - Gestures starting outside checkbox area trigger normal list scrolling
- **Selection Toggle**: Drag selection toggles items (selected ↔ deselected)
- **Visual Feedback**: Selection changes are immediately reflected in the UI

## Testing

This package includes comprehensive tests covering:

- Widget rendering and layout
- Selection state management
- Drag gesture handling
- Custom UI components
- Edge cases and boundary conditions

Run tests with:

```bash
flutter test
```

### Bug Reports

Please file bug reports with:
- Clear description of the issue
- Steps to reproduce
- Expected vs actual behavior
- Flutter version and device information

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you have any questions or need help, please open an issue on GitHub.

---

Made with ❤️ by the Flutter community