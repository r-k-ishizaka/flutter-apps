import 'package:flutter/material.dart';

/// フォント fallback によるグリフ依存の行高さのズレを抑えた [Text] ラッパー。
///
/// [StrutStyle.forceStrutHeight] を常に有効にすることで、
/// 日英混在テキストでも行高さを primary font のメトリクスで統一する。
/// その他の引数はすべて [Text] と同じ。
class StableText extends StatelessWidget {
  const StableText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  final String data;
  final TextStyle? style;

  /// 未指定の場合は [StrutStyle.forceStrutHeight] = true が自動で適用される。
  final StrutStyle? strutStyle;

  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style,
      strutStyle: strutStyle ?? const StrutStyle(forceStrutHeight: true),
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}
