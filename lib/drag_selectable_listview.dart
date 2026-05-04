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

  /// The minimum drag distance in pixels required to activate selection mode.
  ///
  /// This threshold prevents accidental selection from minor touch movements.
  /// Default value is 8.0 pixels.
  final double touchSlop;

  /// Creates a [DragSelectableListView].
  ///
  /// All parameters except [touchSlop] are required to ensure proper functionality:
  /// - [itemCount]: The total number of items
  /// - [itemBuilder]: Function to build list item widgets
  /// - [selected]: Set of currently selected item indices
  /// - [onSelectionChanged]: Callback for selection changes
  /// - [itemHeight]: Height of each item for drag calculations
  /// - [checkboxWidth]: Width of checkbox area for drag activation
  /// - [checkboxBuilder]: Function to build custom checkbox widgets
  /// - [touchSlop]: Minimum drag distance to activate selection (optional, defaults to 8.0)
  const DragSelectableListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.selected,
    required this.onSelectionChanged,
    required this.itemHeight,
    required this.checkboxWidth,
    required this.checkboxBuilder,
    this.touchSlop = 8.0,
  });

  @override
  State<DragSelectableListView> createState() => _DragSelectableListState();
}

/// State class for [DragSelectableListView] that manages drag selection behavior.
///
/// This class handles the core logic for drag-to-select functionality including:
/// - Tracking drag gestures and calculating affected item ranges
/// - Managing selection state during drag operations
/// - Controlling scroll behavior during active selection
/// - Building the list UI with integrated checkbox controls
class _DragSelectableListState extends State<DragSelectableListView> {

  /// Controller for managing list view scrolling behavior.
  /// Used to calculate item positions and disable scrolling during drag selection.
  final ScrollController scrollController = ScrollController();

  /// Global key for accessing the ListView's render object.
  /// Used to calculate item positions relative to screen coordinates during drag operations.
  final GlobalKey listviewKey = GlobalKey();

  /// Flag indicating whether a drag selection operation is currently active.
  /// When true, scrolling is disabled and drag gestures affect item selection.
  bool isSelecting = false;

  /// The initial Y-coordinate of the drag gesture when selection started.
  /// Used to calculate drag distance and determine when to activate selection mode.
  double startDy = 0;

  /// Minimum drag distance in pixels required to activate selection mode.
  /// This value is now configurable via the widget's touchSlop parameter.
  /// Prevents accidental selection from minor touch movements.
  late double touchSlop;

  /// Snapshot of selected items at the start of a drag operation.
  /// Used as the base state for range selection - items between start and current
  /// positions are toggled relative to this initial selection.
  Set<int> initialSelected = {};

  /// The index of the list item where the drag selection operation started.
  /// Used in conjunction with current position to determine the selection range.
  int? startIndex;

  @override
  void initState() {
    super.initState();
    touchSlop = widget.touchSlop;
  }

  /// Disposes the scroll controller to prevent memory leaks.
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
        key: listviewKey,
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
              Expanded(child: widget.itemBuilder(context, index)),
            ],
          );
        },
      ),
    );
  }

  /// Calculates the list item index corresponding to a pointer event position.
  ///
  /// This method converts screen coordinates to list item indices by:
  /// 1. Converting the event position to local coordinates relative to the ListView
  /// 2. Adjusting for current scroll offset
  /// 3. Dividing by item height to get the item index
  ///
  /// Returns the zero-based index of the item at the given position.
  int getIndex(PointerEvent event) {
    final RenderBox box =
        listviewKey.currentContext!.findRenderObject() as RenderBox;
    final Offset listTopLeft = box.localToGlobal(Offset.zero);
    final double dy = event.position.dy - listTopLeft.dy;
    final double realDy = dy + scrollController.offset;
    return (realDy / widget.itemHeight).floor();
  }

  /// Handles the start of a pointer/touch interaction.
  ///
  /// Records the initial position and selection state for potential drag selection.
  /// This method is called for all touch interactions, but drag selection only
  /// activates after sufficient movement within the checkbox area.
  void _onPointerDown(PointerDownEvent event) {
    startDy = event.position.dy;
    startIndex = getIndex(event);
    initialSelected = Set.from(widget.selected);
  }

  /// Handles pointer movement during drag operations.
  ///
  /// This method performs two main functions:
  /// 1. Activates drag selection mode when movement exceeds the touch slop threshold
  ///    and occurs within the checkbox area
  /// 2. Updates selection state for items within the drag range, toggling each
  ///    item relative to the initial selection state
  ///
  /// The selection logic creates a range selection where all items between the
  /// start and current positions are toggled (selected if not in initial selection,
  /// deselected if in initial selection).
  void _onPointMove(PointerMoveEvent event) {
    // Activate selection mode if drag distance exceeds threshold and is within checkbox area
    double delta = (event.position.dy - startDy).abs();
    if (delta > touchSlop && event.localPosition.dx < widget.checkboxWidth) {
      setState(() {
        isSelecting = true;
      });
    }

    // Skip processing if not in selection mode or no valid start position
    if (!isSelecting || startIndex == null) return;

    // Calculate current item index and validate bounds
    int currentIndex = getIndex(event);
    if (currentIndex < 0 || currentIndex >= widget.itemCount) return;

    // Determine selection range bounds
    int s = startIndex!.clamp(0, widget.itemCount - 1);
    int c = currentIndex.clamp(0, widget.itemCount - 1);
    int minIndex = s < c ? s : c;
    int maxIndex = s > c ? s : c;

    // Toggle selection for all items in the range
    Set<int> newSelected = Set.from(initialSelected);
    for (int i = minIndex; i <= maxIndex; i++) {
      if (initialSelected.contains(i)) {
        newSelected.remove(i);
      } else {
        newSelected.add(i);
      }
    }

    // Notify parent widget of selection changes
    widget.onSelectionChanged(newSelected);
  }

  /// Handles the end of a pointer interaction.
  ///
  /// Deactivates drag selection mode and re-enables normal scrolling behavior.
  /// Called when the user lifts their finger or completes a drag gesture.
  void _onPointUp(_) {
    setState(() {
      isSelecting = false;
    });
  }

  /// Builds the leading widget (checkbox area) for each list item.
  ///
  /// Creates a fixed-width container with a checkbox that allows individual
  /// item selection. The checkbox appearance is determined by the user-provided
  /// [checkboxBuilder] function.
  ///
  /// The onChanged callback handles individual item selection/deselection
  /// outside of drag selection mode.
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
