import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

Future<Uint8List?> createImageFromWidget(
  Widget widget, {
  required Size size,
  Duration? wait,
  double devicePixelRatio = 1,
}) async {
  final ViewConfiguration viewConfiguration = ViewConfiguration(
    devicePixelRatio: devicePixelRatio,
    size: size,
  );

  final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

  final RenderPositionedBox renderPositionedBox = RenderPositionedBox(
    alignment: Alignment.center,
    child: repaintBoundary,
  );

  final renderView = RenderView(
    // ignore: deprecated_member_use
    view: ui.window,
    child: renderPositionedBox,
    configuration: viewConfiguration,
  );

  final pipelineOwner = PipelineOwner();
  final buildOwner = BuildOwner(focusManager: FocusManager());

  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

  final widgetRender = RenderObjectToWidgetAdapter<RenderBox>(
    container: repaintBoundary,
    debugShortDescription: "Generated",
    child: widget,
  );

  final rootElement = widgetRender.attachToRenderTree(buildOwner);

  buildOwner.buildScope(rootElement);
  if (wait != null) {
    await Future.delayed(wait);
  }
  buildOwner.finalizeTree();

  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();
  pipelineOwner.flushSemantics();

  final image = await repaintBoundary.toImage(pixelRatio: devicePixelRatio);

  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  return byteData?.buffer.asUint8List();
}

// Future<Uint8List?> createImageFromWidget(
//   Widget widget, {
//   Duration? wait,
//   Size? logicalSize,
//   Size? imageSize,
// }) async {
//   final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

//   logicalSize ??= ui.window.physicalSize / ui.window.devicePixelRatio;
//   imageSize ??= ui.window.physicalSize;

//   final RenderView renderView = RenderView(
//     view: ui.window,
//     child: RenderPositionedBox(
//       alignment: Alignment.center,
//       child: repaintBoundary,
//     ),
//     configuration: ViewConfiguration(size: logicalSize, devicePixelRatio: 1),
//   );

//   final PipelineOwner pipelineOwner = PipelineOwner();
//   final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

//   pipelineOwner.rootNode = renderView;
//   renderView.prepareInitialFrame();

//   final RenderObjectToWidgetElement<RenderBox> rootElement =
//       RenderObjectToWidgetAdapter<RenderBox>(
//     container: repaintBoundary,
//     child: Directionality(
//       textDirection: TextDirection.ltr,
//       child: widget,
//     ),
//   ).attachToRenderTree(buildOwner);

//   buildOwner.buildScope(rootElement);

//   if (wait != null) {
//     await Future<void>.delayed(wait);
//   }

//   buildOwner.buildScope(rootElement);
//   buildOwner.finalizeTree();

//   pipelineOwner.flushLayout();
//   pipelineOwner.flushCompositingBits();
//   pipelineOwner.flushPaint();

//   final ui.Image image = await repaintBoundary.toImage(
//     pixelRatio: imageSize.width / logicalSize.width,
//   );
//   final ByteData? byteData = await image.toByteData(
//     format: ui.ImageByteFormat.png,
//   );

//   return byteData?.buffer.asUint8List();
// }
