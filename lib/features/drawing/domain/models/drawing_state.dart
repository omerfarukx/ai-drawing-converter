import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'drawing.dart';

part 'drawing_state.freezed.dart';

@freezed
class DrawingState with _$DrawingState {
  const factory DrawingState.initial() = _Initial;
  const factory DrawingState.loading() = _Loading;
  const factory DrawingState.loaded({
    required Drawing drawing,
    required List<Offset> points,
    required Color strokeColor,
    required double strokeWidth,
  }) = _Loaded;
  const factory DrawingState.error(String message) = _Error;
}
