import 'dart:math';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _random = Random();

  double getPixel(double value) {
    FlutterView view = WidgetsBinding.instance.platformDispatcher.views.first;
    return (value / view.devicePixelRatio);
  }

  ValueNotifier<Offset> glassPosition = ValueNotifier(Offset.zero);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: glassPosition,
      builder: (context, value, _) => GestureDetector(
        onTertiaryLongPressDown: (details) {
          glassPosition.value = details.localPosition;
          setState(() {});
        },
        onPanUpdate: (DragUpdateDetails details) {
          glassPosition.value = details.localPosition;
          setState(() {});
        },
        child: RepaintBoundary(
          child: Scaffold(
              body: Stack(
            children: [
              ResponsiveGridList(
                verticalGridSpacing: 0,
                horizontalGridSpacing: 0,
                horizontalGridMargin: 1, // Horizontal space around the grid
                verticalGridMargin: 1, // Vertical space around the grid
                minItemWidth:
                    1, // The minimum item width (can be smaller, if the layout constraints are smaller)
                minItemsPerRow:
                    5, // The minimum items to show in a single row. Takes precedence over minItemWidth
                maxItemsPerRow:
                    1000, // The maximum items to show in a single row. Can be useful on large screens
                listViewBuilderOptions: ListViewBuilderOptions(
                    physics:
                        const NeverScrollableScrollPhysics()), // Options that are getting passed to the ListView.builder() function
                children: List.generate(
                    100000,
                    (index) => Container(
                          width: getPixel(10),
                          height: getPixel(10),
                          decoration: BoxDecoration(
                              color: Color(
                                  (math.Random().nextDouble() * 0xFFFFFF)
                                      .toInt()),
                              border: Border.all(color: Colors.grey)),
                        )), // The list of widgets in the list
              ),
              Positioned(
                left: value.dx - 200,
                top: value.dy - 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const RawMagnifier(
                      decoration: MagnifierDecoration(
                        shape: CircleBorder(
                          side: BorderSide(color: Colors.pink, width: 3),
                        ),
                      ),
                      size: Size(200, 200),
                      magnificationScale: 10,
                    ),
                    Container(
                      height: 1,
                      width: 1,
                      color: Colors.black,
                    )
                  ],
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
