import 'package:drag_selectable_listview/drag_selectable_listview.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Demo', home: DragSelectPage());
  }
}

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
      appBar: AppBar(title: Text("demo")),
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
                      borderRadius: BorderRadius.circular(10.0), // 数值越大越圆
                    ),
                    value: value,
                    onChanged: onChanged,
                  ),
                );
              },
              selected: selected,
              onSelectionChanged: (e) {
                setState(() {
                  selected = e;
                });
                print(selected);
              },
            ),
          ),
        ],
      ),
    );
  }
}
