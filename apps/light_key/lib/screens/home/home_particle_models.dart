import 'package:flutter/material.dart';


class HomeParticleOrigin {
  const HomeParticleOrigin({required this.left, required this.bottom});

  final double left;
  final double bottom;
}

class HomeReactionParticle {
  const HomeReactionParticle({
    required this.id,
    required this.reaction,
    required this.left,
    required this.bottom,
    required this.fontSize,
    required this.driftX,
    required this.rise,
    this.angle = 0.0,
    this.iconData,
    this.iconColor,
    this.avatarUrl,
    this.isAccent = false,
  });

  final int id;
  final String reaction;
  final IconData? iconData;
  final Color? iconColor;
  final String? avatarUrl;
  final bool isAccent;
  final double left;
  final double bottom;
  final double fontSize;
  final double driftX;
  final double rise;
  final double angle;
}
