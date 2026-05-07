import 'package:flutter/material.dart';

import '../../models/note_file.dart';
import 'image_viewer_screen_state.dart';

class ImageViewerProvider extends ChangeNotifier {
  ImageViewerProvider({required List<NoteFile> files, required int initialIndex})
      : _files = files,
        _currentIndex = initialIndex,
        _state = const ImageViewerScreenState.initial();

  final List<NoteFile> _files;
  int _currentIndex;
  final ImageViewerScreenState _state;

  /// 表示対象の画像ファイル
  List<NoteFile> get files => _files;

  /// 現在のインデックス
  int get currentIndex => _currentIndex;

  /// 現在の画面状態
  ImageViewerScreenState get state => _state;

  /// 現在表示中の画像ファイル
  NoteFile get currentFile => _files[_currentIndex];

  /// 次の画像へ移動
  void nextImage() {
    if (_currentIndex < _files.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  /// 前の画像へ移動
  void previousImage() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  /// 指定インデックスの画像に移動
  void goToImage(int index) {
    if (index >= 0 && index < _files.length && index != _currentIndex) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// 前の画像があるか
  bool get hasPrevious => _currentIndex > 0;

  /// 次の画像があるか
  bool get hasNext => _currentIndex < _files.length - 1;
}
