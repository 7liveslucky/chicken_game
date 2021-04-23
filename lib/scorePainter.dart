// import 'package:flutter/cupertino.dart';
//
// class ScorePainter extends CustomPainter{
//   @override
//   void paint(Canvas canvas, Size size) {
//     var rect = Offset.zero & size;
//     var gradient = RadialGradient(
//       center: const Alignment(0.7, -0.6),
//       radius: 0.2,
//       colors: [const Color(0xFFFFFF00), const Color(0xFF0099FF)],
//       stops: [0.4, 1.0],
//     );
//     canvas.drawRect(
//       rect,
//       Paint()..shader = gradient.createShader(rect),
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     // TODO: implement shouldRepaint
//     throw UnimplementedError();
//   }
//
// }