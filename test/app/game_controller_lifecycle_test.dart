import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/app/game_controller.dart';

class _PendingGameController extends GameController {
  final Completer<GameView> ready = Completer<GameView>();

  @override
  Future<GameView> build() => ready.future;
}

void main() {
  test('resume before bootstrap completes is a safe no-op', () async {
    late _PendingGameController controller;
    final container = ProviderContainer(
      overrides: [
        gameControllerProvider.overrideWith(() {
          controller = _PendingGameController();
          return controller;
        }),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(gameControllerProvider).isLoading, isTrue);
    await expectLater(controller.onAppResumed(), completes);
    expect(container.read(gameControllerProvider).isLoading, isTrue);
  });
}
