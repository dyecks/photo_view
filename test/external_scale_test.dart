import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_view/photo_view.dart';

void main() {
  const double initialScale = 1.0;
  const double externalScale = 2.5;
  const Offset externalPosition = Offset(40.0, 30.0);

  Future<void> pumpPhotoView(
    WidgetTester tester, {
    required PhotoViewController controller,
    required PhotoViewScaleStateController scaleStateController,
    required FilterQuality filterQuality,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: PhotoView.customChild(
          child: const SizedBox(width: 100.0, height: 100.0),
          childSize: const Size(100.0, 100.0),
          controller: controller,
          scaleStateController: scaleStateController,
          initialScale: initialScale,
          minScale: 0.5,
          maxScale: 4.0,
          filterQuality: filterQuality,
          enablePanAlways: true,
        ),
      ),
    );
  }

  for (final filterQuality in [FilterQuality.high, FilterQuality.none]) {
    testWidgets(
      'external scale set before any gesture is kept ($filterQuality)',
      (tester) async {
        final controller = PhotoViewController();
        final scaleStateController = PhotoViewScaleStateController();

        try {
          await pumpPhotoView(
            tester,
            controller: controller,
            scaleStateController: scaleStateController,
            filterQuality: filterQuality,
          );

          // No gesture has happened yet: the scale is written from outside.
          controller.updateMultiple(
            scale: externalScale,
            position: externalPosition,
          );
          await tester.pump();

          expect(controller.scale, externalScale);
          expect(controller.position, externalPosition);
          expect(
            scaleStateController.scaleState,
            PhotoViewScaleState.zoomedIn,
          );
        } finally {
          // Unmount before disposing, so the core can remove its listeners.
          await tester.pumpWidget(const SizedBox());
          controller.dispose();
          scaleStateController.dispose();
        }
      },
    );
  }
}
