import 'package:flutter/material.dart';

/// A Flutter ListView widget that supports drag-to-select multiple items
/// with customizable selection UI and smooth interaction.
///
/// This widget provides an intuitive way for users to select multiple items
/// by dragging across them, similar to file selection in desktop environments.
/// It supports both individual checkbox selection and range selection via drag gestures.
class DragSelectableListView extends StatefulWidget {
  /// The total number of items in the list.
  final int itemCount;

  /// A builder function that creates widgets for each item in the list.
  ///
  /// The function receives the BuildContext and the item index and should
  /// return a widget to be displayed for that item.
  final IndexedWidgetBuilder itemBuilder;

  /// A callback function that is called when the selection changes.
  ///
  /// The function receives a [Set<int>] containing the indices of all
  /// currently selected items.
  final ValueChanged<Set<int>> onSelectionChanged;
  /// A builder function that creates custom checkbox widgets.
  ///
  /// The function receives a value indicating whether the checkbox is currently
  /// selected and an onChanged callback to handle state changes.
  ///
  /// Example:
  /// ```dart
  /// checkboxBuilder: ({
  ///   required bool value,
  ///   required ValueChanged<bool?> onChanged,
  /// }) {
  ///   return Checkbox(
  ///     value: value,
  ///     onChanged: onChanged,
  ///   );
  /// }
  /// ```
  final Widget Function({
    required bool value,
    required ValueChanged<bool?> onChanged,
  })
  checkboxBuilder;

  /// A set of indices representing currently selected items.
  final Set<int> selected;

  /// The height of each list item in logical pixels.
  ///
  /// This value is used for calculating item positions during drag selection
  /// and should match the actual height of your list items.
  final double itemHeight;

  /// The width allocated for the checkbox area in logical pixels.
  ///
  /// This value determines the horizontal area where drag selection is activated.
  /// Drag gestures within this width from the left edge will trigger selection mode.
  final double checkboxWidth;

  /// Creates a [DragSelectableListView].
  ///
  /// All parameters are required to ensure proper functionality:
  /// - [itemCount]: The total number of items
  /// - [itemBuilder]: Function to build list item widgets
  /// - [selected]: Set of currently selected item indices
  /// - [onSelectionChanged]: Callback for selection changes
  /// - [itemHeight]: Height of each item for drag calculations
  /// - [checkboxWidth]: Width of checkbox area for drag activation
  /// - [checkboxBuilder]: Function to build custom checkbox widgets
  const DragSelectableListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.selected,
    required this.onSelectionChanged,
    required this.itemHeight,
    required this.checkboxWidth,
    required this.checkboxBuilder,
  });

  @override
  State<DragSelectableListView> createState() => _DragSelectableListState();
}


class _DragSelectableListState extends State<DragSelectableListView> {
  final GlobalKey listKey = GlobalKey();
  final ScrollController scrollController = ScrollController();
  late bool isSelecting = false;
  late double startDy = 0;
  late double touchSlop = 8;
  int? startIndex;
  late Set<int> initialSelected = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointMove,
      onPointerUp: _onPointUp,
      child: ListView.builder(
        key: listKey,
        controller: scrollController,
        physics: isSelecting
            ? NeverScrollableScrollPhysics()
            : AlwaysScrollableScrollPhysics(),
        itemCount: widget.itemCount,
        itemExtent: widget.itemHeight,
        itemBuilder: (context, index) {
          return Row(
            children: [
              _buildLeadingWidget(index),
              widget.itemBuilder(context, index),
            ],
          );
        },
      ),
    );
  }

  int getIndex(PointerEvent event) {
    final RenderBox box =
        listKey.currentContext!.findRenderObject() as RenderBox;
    final Offset listTopLeft = box.localToGlobal(Offset.zero);
    final double dy = event.position.dy - listTopLeft.dy;
    final double realDy = dy + scrollController.offset;
    return (realDy / widget.itemHeight).floor();
  }

  void _onPointerDown(PointerDownEvent event) {
    startDy = event.position.dy;
    startIndex = getIndex(event);
    initialSelected = Set.from(widget.selected);
  }

  void _onPointMove(PointerMoveEvent event) {
    double delta = (event.position.dy - startDy).abs();
    if (delta > touchSlop && event.localPosition.dx < widget.checkboxWidth) {
      setState(() {
        isSelecting = true;
      });
    }

    if (!isSelecting || startIndex == null) return;

    int currentIndex = getIndex(event);
    if (currentIndex < 0 || currentIndex >= widget.itemCount) return;
    int s = startIndex!.clamp(0, widget.itemCount - 1);
    int c = currentIndex.clamp(0, widget.itemCount - 1);
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

    widget.onSelectionChanged(newSelected);
  }

  void _onPointUp(_) {
    setState(() {
      isSelecting = false;
    });
  }

  Widget _buildLeadingWidget(int index) {
    return SizedBox(
      width: widget.checkboxWidth,
      child: widget.checkboxBuilder(
        value: widget.selected.contains(index),
        onChanged: (value) {
          Set<int> newSelected = Set.from(widget.selected);
          if (value == true) {
            newSelected.add(index);
          } else {
            newSelected.remove(index);
          }
          widget.onSelectionChanged(newSelected);
        },
      ),
    );
  }
}
