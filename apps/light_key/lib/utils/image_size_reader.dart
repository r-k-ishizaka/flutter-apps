import 'dart:typed_data';

/// 画像バイト列から画像サイズを読み取るユーティリティ。
///
/// PNG / GIF / JPEG / WebP の先頭ヘッダバイトだけで判定するため、
/// フルダウンロード不要で高速にサイズを取得できる。
/// 最低限 4096 バイトあれば大半のフォーマットを解析可能。
class ImageSizeReader {
  const ImageSizeReader._();

  /// [bytes] から画像の (width, height) を取得する。
  /// 不明フォーマット・解析失敗時は null を返す。
  static ({int width, int height})? parse(List<int> bytes) {
    if (bytes.length < 12) return null;
    final b = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    final bd = ByteData.sublistView(b);

    // PNG: \x89PNG\r\n\x1a\n
    if (b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) {
      if (b.length < 24) return null;
      return (
        width: bd.getUint32(16, Endian.big),
        height: bd.getUint32(20, Endian.big),
      );
    }

    // GIF: GIF87a / GIF89a
    if (b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46) {
      if (b.length < 10) return null;
      return (
        width: bd.getUint16(6, Endian.little),
        height: bd.getUint16(8, Endian.little),
      );
    }

    // WebP: RIFF....WEBP
    if (b[0] == 0x52 &&
        b[1] == 0x49 &&
        b[2] == 0x46 &&
        b[3] == 0x46 &&
        b.length >= 16 &&
        b[8] == 0x57 &&
        b[9] == 0x45 &&
        b[10] == 0x42 &&
        b[11] == 0x50) {
      return _parseWebP(b, bd);
    }

    // JPEG: \xff\xd8
    if (b[0] == 0xFF && b[1] == 0xD8) {
      return _parseJpeg(b, bd);
    }

    return null;
  }

  static ({int width, int height})? _parseWebP(Uint8List b, ByteData bd) {
    if (b.length < 16) return null;
    final chunkType = String.fromCharCodes(b.sublist(12, 16));

    switch (chunkType) {
      case 'VP8 ': // lossy
        // Frame tag: bytes 20-22. bit0 == 0 = key frame.
        if (b.length < 30) return null;
        if ((b[20] & 0x01) != 0) return null;
        // Start code: 0x9D 0x01 0x2A
        if (b[23] != 0x9D || b[24] != 0x01 || b[25] != 0x2A) return null;
        return (
          width: bd.getUint16(26, Endian.little) & 0x3FFF,
          height: bd.getUint16(28, Endian.little) & 0x3FFF,
        );

      case 'VP8L': // lossless
        // Signature 0x2F at byte 20, packed dimensions at bytes 21-24.
        if (b.length < 25) return null;
        if (b[20] != 0x2F) return null;
        final bits = bd.getUint32(21, Endian.little);
        return (
          width: (bits & 0x3FFF) + 1,
          height: ((bits >> 14) & 0x3FFF) + 1,
        );

      case 'VP8X': // extended
        // Canvas width-1 at bytes 24-26 (24-bit LE)
        // Canvas height-1 at bytes 27-29 (24-bit LE)
        if (b.length < 30) return null;
        return (
          width: (b[24] | (b[25] << 8) | (b[26] << 16)) + 1,
          height: (b[27] | (b[28] << 8) | (b[29] << 16)) + 1,
        );

      default:
        return null;
    }
  }

  static ({int width, int height})? _parseJpeg(Uint8List b, ByteData bd) {
    var i = 2; // SOI マーカー (FF D8) をスキップ
    while (i + 3 < b.length) {
      if (b[i] != 0xFF) return null;
      final marker = b[i + 1];

      // パディングバイト
      if (marker == 0xFF) {
        i++;
        continue;
      }

      // SOF マーカー: C0-C3, C5-C7, C9-CB, CD-CF
      if ((marker >= 0xC0 && marker <= 0xC3) ||
          (marker >= 0xC5 && marker <= 0xC7) ||
          (marker >= 0xC9 && marker <= 0xCB) ||
          (marker >= 0xCD && marker <= 0xCF)) {
        if (i + 9 >= b.length) return null;
        return (
          width: bd.getUint16(i + 7, Endian.big),
          height: bd.getUint16(i + 5, Endian.big),
        );
      }

      // データなしマーカー (RST0-RST7, SOI, EOI 等)
      if (marker >= 0xD0 && marker <= 0xD9) {
        i += 2;
        continue;
      }

      // 長さフィールド付きセグメント
      if (i + 3 >= b.length) break;
      final segLen = bd.getUint16(i + 2, Endian.big);
      if (segLen < 2) return null;
      i += 2 + segLen;
    }
    return null;
  }
}
