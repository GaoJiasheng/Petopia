import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petopia/main.dart';

void main() {
  testWidgets('PetopiaApp 启动：显示 MaterialApp + 加载态', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PetopiaApp()));
    // 仅验证初始帧：根组件与加载指示（bootstrap 异步，不 settle）。
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
