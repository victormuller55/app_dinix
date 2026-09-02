import 'package:app_dinix/app_config/apple_intelligence_bridge.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('app_dinix/apple_intelligence');
  final calls = <MethodCall>[];

  setUp(() {
    debugForceAppleIntelligence = true;
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'consumePendingRoute') {
        return {'route': 'compra', 'id': 'abc'};
      }
      return true;
    });
  });

  tearDown(() {
    debugForceAppleIntelligence = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('setOnScreenEntity envia tipo e id sem valor monetário', () async {
    await setAppleIntelligenceOnScreenEntity(
      type: AppleIntelligenceEntityType.compra,
      id: 'compra-1',
      title: 'iPhone',
    );
    expect(calls.single.method, 'setOnScreenEntity');
    final args = calls.single.arguments as Map;
    expect(args['type'], 'compra');
    expect(args['id'], 'compra-1');
    expect(args['title'], 'iPhone');
    expect(args.containsKey('valor'), isFalse);
  });

  test('clearOnScreenEntity e clearSession não quebram fora do iOS no mock', () async {
    await clearAppleIntelligenceOnScreenEntity();
    await clearAppleIntelligenceSession();
    expect(calls.map((c) => c.method), containsAll(['clearOnScreenEntity', 'clearSession']));
  });

  test('consumePendingRoute devolve mapa da Siri', () async {
    final rota = await consumeAppleIntelligencePendingRoute();
    expect(rota['route'], 'compra');
    expect(rota['id'], 'abc');
  });
}
