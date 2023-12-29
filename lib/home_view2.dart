import 'package:flutter/material.dart';
import 'package:grid_paper/grid_paper.dart' as Paper;
import 'package:grid_paper/grid_paper.dart';

class HomeView2 extends StatelessWidget {
  const HomeView2({super.key});

  @override
  Widget build(BuildContext context) {
    return const PaperView();
  }
}

class PaperView extends StatefulWidget {
  const PaperView({
    Key? key,
  }) : super(key: key);

  @override
  State<PaperView> createState() => _PaperViewState();
}

class _PaperViewState extends State<PaperView>
    with SingleTickerProviderStateMixin {
  late final Animation<double> _animation;
  late final AnimationController _animationController;

  _Demo _demoPage = _Demo.gridPaper;

  Offset _panOffset = Offset.zero;
  double _zoomPercent = 1.0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
  }

  void _showDemo(_Demo demo) {
    if (demo == _demoPage) {
      return;
    }

    setState(() {
      _demoPage = demo;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _panOffset -= details.delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: _onPanUpdate,
        child: Stack(
          children: [
            _buildDemo(),
            _buildLabel(),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 50,
                child: RotatedBox(
                  quarterTurns: -1,
                  child: SizedBox(
                    width: 200,
                    child: Slider(
                      value: _zoomPercent,
                      min: 0.1,
                      max: 3.0,
                      thumbColor: Colors.white,
                      activeColor: Colors.white.withOpacity(0.8),
                      inactiveColor: Colors.white.withOpacity(0.5),
                      onChanged: (double value) {
                        setState(() {
                          _zoomPercent = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(onPressed: () {
        if (_Demo.gridPaper == _demoPage) {
          _showDemo(_Demo.dotMatrix);
        } else {
          _showDemo(_Demo.gridPaper);
        }
      }),
    );
  }

  Widget _buildDemo() {
    switch (_demoPage) {
      case _Demo.gridPaper:
        return Paper.GridPaper(
          
          panOffset: _panOffset,
          zoomPercent: _zoomPercent,
          gridUnitSize: 25,
          originAlignment: Alignment.center,
          background: Colors.blueAccent,
          gridColor: Colors.white,
        );
      case _Demo.dotMatrix:
        return DotMatrixPaper(
          panOffset: _panOffset,
          zoomPercent: _zoomPercent,
          gridUnitSize: 25,
          originAlignment: Alignment.center,
          background: const Color(0xFF444444),
          style: const DotMatrixStyle.standard()
              .copyWith(divider: DotMatrixDivider.cross),
        );
    }
  }

  Widget _buildLabel() {
    late final String labelName;
    switch (_demoPage) {
      case _Demo.gridPaper:
        labelName = "Grid Paper";
        break;
      case _Demo.dotMatrix:
        labelName = "Dot Matrix";
        break;
    }

    return Positioned.fill(
      child: Align(
        alignment: Alignment.center,
        child: Transform.translate(
          offset: -_panOffset,
          child: FractionalTranslation(
            translation: const Offset(0.65, -1.2),
            child: Text(
              labelName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _Demo {
  gridPaper,
  dotMatrix,
}
