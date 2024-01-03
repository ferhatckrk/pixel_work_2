// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';
import 'package:grid_work_1/core/extension/extensions.dart';

class Bloc {
  Color blockColor;
  int index;
  double? top;
  double? left;
  Bloc({required this.blockColor, required this.index, this.top, this.left});

  Bloc copyWith({
    Color? blockColor,
    int? index,
    double? top,
    double? left,
  }) {
    return Bloc(
      blockColor: blockColor ?? this.blockColor,
      index: index ?? this.index,
      top: top ?? this.top,
      left: left ?? this.left,
    );
  }
}

class Data {
  static List<Bloc> blocks = [];
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

const int allCount = 10000;
const int crossAxisCount = 80;

//enum Color { red, yellow }

class MyHomePage extends StatefulWidget {
  final Random random = Random();
  // final options = Options(format: Format.hex, colorType: ColorType.green);
  MyHomePage({super.key}) {
    Data.blocks = List<Bloc>.generate(allCount, (index) {
      //  String color = RandomColor.getColor(options);

      return Bloc(
          blockColor: Colors.red /* HexColor.fromHex(color) */, index: index);
    });
  }

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int columnsCount = 0;
  double blocSize = 0;

  late int clickedIndex;
  late Offset clickOffset;
  late int onMoveIndex = 0;
  bool hasSizes = false;
  //late List<BlocType> blocks;
  final ScrollController scrollController = ScrollController();

  ValueNotifier<Offset> glassPosition = ValueNotifier(Offset.zero);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    // blocks = Data.blocks;
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
      Data.blocks[clickedIndex].blockColor = Colors.yellow;
    });
  }

  int onMove(Offset dimension) {
    if (dimension.dx != 0 && dimension.dy != 0) {
      final dx = dimension.dx;
      final dy = dimension.dy + scrollController.offset;
      final tapedRow = (dx / blocSize).floor();
      final tapedColumn = (dy / blocSize).floor();
      onMoveIndex = tapedColumn * crossAxisCount + tapedRow;
      if (onMoveIndex >= 0 && onMoveIndex < allCount) {
        return onMoveIndex;
      }
    }
    return 0;

    // return Data.blocks[onMoveIndex];
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
        },
        onPanUpdate: (DragUpdateDetails details) {
          glassPosition.value = details.localPosition;
        },
        onPanEnd: (details) {
          glassPosition.value = Offset.zero;
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
                  //  blocs: widget.blocks,
                  columnsCount: columnsCount,
                  blocSize: blocSize,
                ),
              ),
            ),
            Positioned(
              left: value.dx - 100,
              top: value.dy - 100,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Data.blocks[onMove(value)].blockColor,
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black,
                        offset: Offset(0, 0),
                      )
                    ]),
                height: 100,
                width: 100,
                child: Text(
                  "x: ${value.dx.toString().split('.').first}\ny: ${value.dy.toString().split('.').first}\n clr:${Data.blocks[onMove(value)].blockColor.value}\n index: ${onMove(value)}",
                  style: const TextStyle(fontSize: 13),
                ),
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
  final double gap = 0.1;
  final Paint painter = Paint()
    ..strokeWidth = 5
    ..style = PaintingStyle.fill;

  final int columnsCount;
  final double blocSize;
  //final List<BlocType> blocs;

  CustomGridView({
    required this.columnsCount,
    required this.blocSize,
    /* required this.blocs */
  });

  @override
  void paint(Canvas canvas, Size size) {
    Data.blocks.asMap().forEach((index, bloc) {
      setColor(bloc.blockColor);

/*       Paint paint2 = Paint()
        ..color = Colors.black
        ..strokeCap = StrokeCap.butt
        ..strokeWidth = 2 // getPixel(1)
        ..style = PaintingStyle.fill; */

      var topPosition = getTop(index);
      var leftPosition = getLeft(index);
      Data.blocks[index] = Data.blocks[index].copyWith(
        top: topPosition,
        left: leftPosition,
      );
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(
                leftPosition, topPosition, blocSize - gap, blocSize - gap,
                // 1.6 - 0.2,
                //  1.6 - 0.2,
              ),
              const Radius.circular(1)),
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

  void setColor(Color blocColor) {
    painter.color = blocColor;
    /*   switch (bloc) {
      case Color.red:
        painter.color = Colors.red;
        break;

      case Color.yellow:
        painter.color = Colors.yellow;
        break;
    } */
  }
}
