library image_viewer;

import 'package:flutter/material.dart';

class ImageViewer extends StatefulWidget {
  final ImageProvider image;
  final Color color;
  final bool enablePan;
  final bool enableZoom;
  final bool enableRotating;
  final String loadingImageString;
  final double minZoom;
  final double maxZoom;

  const ImageViewer({
    Key key,
    this.image,
    this.color = const Color(0xFF000000),
    this.loadingImageString = 'Loading full image...',
    this.enablePan = true,
    this.enableZoom = true,
    this.enableRotating = false,
    this.minZoom = 0.5,
    this.maxZoom = 5.0,
  }) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  Offset lastOffset = Offset.zero;
  Offset offset = Offset.zero;

  double lastScale = 1;
  double scale = 1;
  double startScale = 1;
  double lastRotation = 0;
  double rotation = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      onScaleStart: (det) {
        lastOffset = det.focalPoint;
        startScale = scale;
        lastScale = 1.0;
        lastRotation = 0;
      },
      onScaleUpdate: (det) {
        setState(() {
          if (widget.enablePan) offset += det.focalPoint - lastOffset;
          if (widget.enableZoom) scale += startScale * (det.scale - lastScale);
          if (widget.enableRotating) rotation += det.rotation - lastRotation;

          scale = scale.clamp(0.5, 5.0);
          lastOffset = det.focalPoint;
          lastScale = det.scale;
          lastRotation = det.rotation;
        });
      },
      child: Material(
          color: widget.color,
          child: Transform(
            transform: Matrix4.identity()
              ..translate(
                offset.dx,
                offset.dy,
              ),
            alignment: FractionalOffset.center,
            child: Transform(
              transform: Matrix4.identity()
                ..scale(scale)
                ..rotateZ(rotation),
              alignment: FractionalOffset.center,
              child: Image(
                image: widget.image,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  return frame == null
                      ? const Center(child: CircularProgressIndicator())
                      : child;
                },
                loadingBuilder: (context, child, event) {
                  if (event == null) {
                    return child;
                  }

                  final double progress = event != null
                      ? event.cumulativeBytesLoaded / event.expectedTotalBytes
                      : 0.0;

                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '${widget.loadingImageString}\r\n${(progress * 100).round()}%',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        CircularProgressIndicator(value: progress),
                      ],
                    ),
                  );
                },
              ),
            ),
          )),
    );
  }
}
