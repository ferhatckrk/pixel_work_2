// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BlocType {
  BlockTypes blockColor;
  int index;
  BlocType({
    required this.blockColor,
    required this.index,
  });
}

class HomeView4 extends StatelessWidget {
  const HomeView4({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: MyHomePage(),
        ),
      ),
    );
  }
}

const int redCount = 100000;

const int allCount = 100000;
const int crossAxisCount = 250;

enum BlockTypes { red, yellow }

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key})
      : blocks = List<BlockTypes>.generate(allCount, (index) {
          return BlockTypes.red;
        });

  final List<BlockTypes> blocks;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int columnsCount;
  late double blocSize;

  late int clickedIndex;
  late Offset clickOffset;
  bool hasSizes = false;
  late List<BlockTypes> blocks;
  final ScrollController scrollController = ScrollController();

  ValueNotifier<Offset> glassPosition = ValueNotifier(Offset.zero);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    blocks = widget.blocks;
    super.initState();
  }

  void _afterLayout(_) {
    blocSize = context.size!.width / crossAxisCount;
    columnsCount = (allCount / crossAxisCount).ceil();
    setState(() {
      hasSizes = true;
    });
  }

  void onTapDown(TapDownDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    clickOffset = box.globalToLocal(details.globalPosition);
  }

  void onTap() {
    final dx = clickOffset.dx;
    final dy = clickOffset.dy + scrollController.offset;
    final tapedRow = (dx / blocSize).floor();
    final tapedColumn = (dy / blocSize).floor();
    clickedIndex = tapedColumn * crossAxisCount + tapedRow;

    setState(() {
      blocks[clickedIndex] = BlockTypes.yellow;
    });
  }

  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    print(blocSize);
    return ValueListenableBuilder(
      valueListenable: glassPosition,
      builder: (context, value, _) => GestureDetector(
        onTertiaryLongPressDown: (details) {
          glassPosition.value = details.localPosition;
          isOpen = true;
          setState(() {});
        },
        onPanUpdate: (DragUpdateDetails details) {
          glassPosition.value = details.localPosition;

          setState(() {});
        },
        onPanEnd: (details) {
          glassPosition.value = Offset.zero;

          setState(() {});
        },
        onTapDown: onTapDown,
        onTap: onTap,
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: scrollController,
              child: CustomPaint(
                size: Size(
                  MediaQuery.of(context).size.width,
                  columnsCount * blocSize,
                ),
                painter: CustomGridView(
                  blocs: widget.blocks,
                  columnsCount: columnsCount,
                  blocSize: blocSize,
                ),
              ),
            ),
            Positioned(
              left: value.dx - 50,
              top: value.dy - 50,
              child: Container(
                decoration: const BoxDecoration(color: Colors.red, boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black,
                    offset: Offset(0, 0),
                  )
                ]),
                height: 50,
                width: 50,
              ) /* Stack(
                alignment: Alignment.center,
                children: [
                  const RawMagnifier(
                    decoration: MagnifierDecoration(),
                    size: Size(50, 50),
                    magnificationScale: 30,
                    child: Text("selam"),
                  ),
                  Container(
                    height: 1,
                    width: 1,
                    color: Colors.amber,
                  )
                ],
              ) */
              ,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomGridView extends CustomPainter {
  final double gap = 1;
  final Paint painter = Paint()
    ..strokeWidth = 10
    ..style = PaintingStyle.fill;

  final int columnsCount;
  final double blocSize;
  final List<BlockTypes> blocs;

  CustomGridView(
      {required this.columnsCount,
      required this.blocSize,
      required this.blocs});

  @override
  void paint(Canvas canvas, Size size) {
    blocs.asMap().forEach((index, bloc) {
      setColor(bloc);

      Paint paint2 = Paint()
        ..color = Colors.black
        ..strokeCap = StrokeCap.butt
        ..strokeWidth = 2 // getPixel(1)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(
                getLeft(index),
                getTop(index),
                1.6 - 0.2,
                1.6 - 0.2,
              ),
              const Radius.circular(0)),
          painter);
    });
  }

  double getTop(int index) {
    return (index / crossAxisCount).floor().toDouble() * blocSize;
  }

  double getLeft(int index) {
    return (index % crossAxisCount).floor().toDouble() * blocSize;
  }

  @override
  bool shouldRepaint(CustomGridView oldDelegate) => true;
  @override
  bool shouldRebuildSemantics(CustomGridView oldDelegate) => true;

  void setColor(BlockTypes bloc) {
    switch (bloc) {
      case BlockTypes.red:
        painter.color = Colors.red;
        break;

      case BlockTypes.yellow:
        painter.color = Colors.yellow;
        break;
    }
  }
}
