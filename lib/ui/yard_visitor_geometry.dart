import 'package:flutter/widgets.dart';

// Union of painted alpha bounds across all eight existing animation frames,
// padded by 3% of the frame. No artwork is rescaled or replaced.
Rect yardVisitorFrameBounds(String asset) => switch (asset) {
  'assets/art/world/visitors/visitor_butterfly_yard.png' => Rect.fromLTRB(
    0.1550,
    0.1300,
    0.8450,
    0.8850,
  ),
  'assets/art/world/visitors/visitor_calico_yard.png' => Rect.fromLTRB(
    0.1733,
    0.0967,
    0.8233,
    0.9100,
  ),
  'assets/art/world/visitors/visitor_crow_yard.png' => Rect.fromLTRB(
    0.1367,
    0.1100,
    0.8600,
    0.8333,
  ),
  'assets/art/world/visitors/visitor_deer_yard.png' => Rect.fromLTRB(
    0.2450,
    0.1350,
    0.7575,
    0.8800,
  ),
  'assets/art/world/visitors/visitor_egret_yard.png' => Rect.fromLTRB(
    0.2600,
    0.1350,
    0.7400,
    0.8800,
  ),
  'assets/art/world/visitors/visitor_emberlight_yard.png' => Rect.fromLTRB(
    0.2700,
    0.1350,
    0.7300,
    0.8800,
  ),
  'assets/art/world/visitors/visitor_firefly_yard.png' => Rect.fromLTRB(
    0.1567,
    0.1933,
    0.8367,
    0.7500,
  ),
  'assets/art/world/visitors/visitor_fox_yard.png' => Rect.fromLTRB(
    0.2550,
    0.1350,
    0.7450,
    0.8800,
  ),
  'assets/art/world/visitors/visitor_frog_yard.png' => Rect.fromLTRB(
    0.1750,
    0.1400,
    0.8250,
    0.7900,
  ),
  'assets/art/world/visitors/visitor_ghostpuff_yard.png' => Rect.fromLTRB(
    0.1667,
    0.3233,
    0.8300,
    0.9033,
  ),
  'assets/art/world/visitors/visitor_hedgehog_yard.png' => Rect.fromLTRB(
    0.1400,
    0.1250,
    0.8700,
    0.9150,
  ),
  'assets/art/world/visitors/visitor_owl_yard.png' => Rect.fromLTRB(
    0.2067,
    0.0900,
    0.7900,
    0.8167,
  ),
  'assets/art/world/visitors/visitor_pigeon_yard.png' => Rect.fromLTRB(
    0.1550,
    0.0950,
    0.8400,
    0.8350,
  ),
  'assets/art/world/visitors/visitor_rainbowshade_yard.png' => Rect.fromLTRB(
    0.2133,
    0.1367,
    0.7833,
    0.8800,
  ),
  'assets/art/world/visitors/visitor_snail_yard.png' => Rect.fromLTRB(
    0.1600,
    0.1250,
    0.8500,
    0.9150,
  ),
  'assets/art/world/visitors/visitor_snowhare_yard.png' => Rect.fromLTRB(
    0.1733,
    0.3200,
    0.8233,
    0.9033,
  ),
  'assets/art/world/visitors/visitor_sparrow_yard.png' => Rect.fromLTRB(
    0.1100,
    0.2600,
    0.8850,
    0.9150,
  ),
  'assets/art/world/visitors/visitor_squirrel_yard.png' => Rect.fromLTRB(
    0.1900,
    0.1400,
    0.8150,
    0.7900,
  ),
  'assets/art/world/visitors/visitor_starbug_yard.png' => Rect.fromLTRB(
    0.1450,
    0.1050,
    0.8550,
    0.9200,
  ),
  'assets/art/world/visitors/visitor_tanuki_yard.png' => Rect.fromLTRB(
    0.1433,
    0.1367,
    0.8600,
    0.8800,
  ),
  _ => const Rect.fromLTWH(0, 0, 1, 1),
};
