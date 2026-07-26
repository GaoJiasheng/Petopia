import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_service.dart';

final RouteObserver<PageRoute<dynamic>> petopiaRouteObserver =
    RouteObserver<PageRoute<dynamic>>();

mixin RouteAudio<T extends ConsumerStatefulWidget> on ConsumerState<T>
    implements RouteAware {
  PageRoute<dynamic>? _audioRoute;

  Bgm get routeBgm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is! PageRoute<dynamic> || identical(route, _audioRoute)) return;
    if (_audioRoute != null) {
      petopiaRouteObserver.unsubscribe(this);
    }
    _audioRoute = route;
    petopiaRouteObserver.subscribe(this, route);
    if (route.isCurrent) _playRouteAudio();
  }

  @override
  void didPush() => _playRouteAudio();

  @override
  void didPopNext() => _playRouteAudio();

  @override
  void didPop() {}

  @override
  void didPushNext() {}

  void _playRouteAudio() {
    unawaited(ref.read(audioServiceProvider).playBgm(routeBgm));
  }

  @override
  void dispose() {
    petopiaRouteObserver.unsubscribe(this);
    super.dispose();
  }
}
