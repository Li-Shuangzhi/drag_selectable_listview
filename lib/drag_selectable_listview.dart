import 'package:flutter/material.dart';

class DragSelectableList extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ValueChanged<Set<int>> onSelectionChanged;
  final Widget Function({
  required bool value,
  required ValueChanged<bool?> onChanged,
  })
  checkboxBuilder;

  final Set<int> selected;
  final double itemHeight;
  final double checkboxWidth;

  const DragSelectableList({
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
  _DragSelectableListState createState() => _DragSelectableListState();
}

class _DragSelectableListState extends State<DragSelectableList> {
  final GlobalKey listKey = GlobalKey();
  final ScrollController scrollController = ScrollController();
  late bool isSelecting;
  late double startDy;
  late double touchSlop;
  int? startIndex;
  late Set<int> initialSelected;


  @override
  void initState() {
    super.initState();
    isSelecting = false;
    startDy = 0;
    touchSlop = 4;
    initialSelected = {};
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
        itemBuilder: (context, index) {
          return SizedBox(
            height: widget.itemHeight,
            child: Row(
              children: [
                _buildLeadingWidget(index),
                widget.itemBuilder(context, index),
              ],
            ),
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
      isSelecting = true;
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
    isSelecting = false;
  }

  Widget _buildLeadingWidget(int index) {
    return SizedBox(
      width: widget.checkboxWidth,
      child: widget.checkboxBuilder(
        value: widget.selected.contains(index),
        onChanged: (value) {
          if (value == true) {
            widget.selected.add(index);
          } else {
            widget.selected.remove(index);
          }
          widget.onSelectionChanged(widget.selected);
        },
      ),
    );
  }
}
