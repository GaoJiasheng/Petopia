import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared visual tokens for the cream-watercolor interface.
///
/// The bright orange remains available for decorative highlights. Interactive
/// labels and filled controls use the deeper action orange so small text keeps
/// accessible contrast without flattening the art direction.
abstract final class PetopiaColors {
  static const background = Color(0xFFFAF3E3);
  static const paper = Color(0xFFFFFDF7);
  static const ink = Color(0xFF6B5445);
  static const mutedText = Color(0xFF77675A);
  static const decorativeAccent = Color(0xFFE8A15C);
  static const actionAccent = Color(0xFFB45F24);
  static const green = Color(0xFFA7C4A0);
  static const line = Color(0xFFEDE4D3);
}

abstract final class PetopiaMotion {
  static const micro = Duration(milliseconds: 180);
  static const quick = Duration(milliseconds: 260);
  static const standard = Duration(milliseconds: 320);
  static const modal = Duration(milliseconds: 360);
  static const reveal = Duration(milliseconds: 720);

  static Duration duration(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}

abstract final class PetopiaSystemUi {
  static SystemUiOverlayStyle lightSurface() =>
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: PetopiaColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      );

  static SystemUiOverlayStyle yard({required int hour}) {
    final night = hour >= 19 || hour < 6;
    return (night ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
        .copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: night
              ? Brightness.light
              : Brightness.dark,
        );
  }
}
