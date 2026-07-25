import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('runtime interaction audio has valid low-latency WAV masters', () {
    final manifestFile = File(
      'assets/audio/provenance/sfx_provenance_manifest.json',
    );
    expect(manifestFile.existsSync(), isTrue);
    final manifest =
        jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
    expect(manifest['thirdPartySamples'], isFalse);
    final assets = manifest['assets']! as List<dynamic>;
    expect(assets, hasLength(8));

    for (final entry in assets.cast<Map<String, dynamic>>()) {
      final path = entry['asset']! as String;
      final bytes = File(path).readAsBytesSync();
      expect(String.fromCharCodes(bytes.take(4)), 'RIFF', reason: path);
      expect(String.fromCharCodes(bytes.skip(8).take(4)), 'WAVE', reason: path);
      final data = ByteData.sublistView(Uint8List.fromList(bytes));
      expect(data.getUint16(22, Endian.little), 2, reason: path);
      expect(data.getUint32(24, Endian.little), 48000, reason: path);
      expect(data.getUint16(34, Endian.little), 16, reason: path);
      final duration = (bytes.length - 44) / (48000 * 2 * 2);
      expect(duration, inInclusiveRange(0.4, 1.2), reason: path);
      expect(entry['sha256'], hasLength(64), reason: path);
    }
  });

  test('yard ambience is seamless and every visitor has a voice cue', () {
    final manifestFile = File(
      'assets/audio/provenance/ambient_voc_provenance_manifest.json',
    );
    expect(manifestFile.existsSync(), isTrue);
    final manifest =
        jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
    expect(manifest['thirdPartySamples'], isFalse);
    final assets = (manifest['assets']! as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final ambience = assets
        .where((entry) => entry['kind'] == 'seamless_ambient_loop')
        .toList();
    final voices = assets
        .where((entry) => entry['kind'] == 'visitor_voice')
        .toList();
    expect(ambience, hasLength(6));
    expect(voices, hasLength(20));

    for (final entry in ambience) {
      final wav = File(entry['wav']! as String);
      final m4a = File(entry['m4a']! as String);
      expect(wav.existsSync(), isTrue, reason: wav.path);
      expect(m4a.existsSync(), isTrue, reason: m4a.path);
      final bytes = wav.readAsBytesSync();
      final data = ByteData.sublistView(Uint8List.fromList(bytes));
      expect(data.getUint16(22, Endian.little), 2, reason: wav.path);
      expect(data.getUint32(24, Endian.little), 48000, reason: wav.path);
      expect(data.getUint16(34, Endian.little), 16, reason: wav.path);
      final duration = (bytes.length - 44) / (48000 * 2 * 2);
      expect(duration, closeTo(24, 0.001), reason: wav.path);

      final last = bytes.length - 4;
      final seamLeft =
          (data.getInt16(44, Endian.little) -
                  data.getInt16(last, Endian.little))
              .abs();
      final seamRight =
          (data.getInt16(46, Endian.little) -
                  data.getInt16(last + 2, Endian.little))
              .abs();
      expect(seamLeft, lessThan(2000), reason: wav.path);
      expect(seamRight, lessThan(2000), reason: wav.path);

      final encoded = m4a.readAsBytesSync();
      expect(String.fromCharCodes(encoded.skip(4).take(4)), 'ftyp');
      expect(encoded.length, inInclusiveRange(100000, 1000000));
      expect(entry['sha256'], hasLength(64));
    }

    for (final entry in voices) {
      final wav = File(entry['wav']! as String);
      final m4a = File(entry['m4a']! as String);
      final bytes = wav.readAsBytesSync();
      final data = ByteData.sublistView(Uint8List.fromList(bytes));
      expect(String.fromCharCodes(bytes.take(4)), 'RIFF', reason: wav.path);
      final duration = (bytes.length - 44) / (48000 * 2 * 2);
      expect(duration, inInclusiveRange(0.7, 1.2), reason: wav.path);
      var peak = 0;
      for (var offset = 44; offset + 1 < bytes.length; offset += 2) {
        peak = peak < data.getInt16(offset, Endian.little).abs()
            ? data.getInt16(offset, Endian.little).abs()
            : peak;
      }
      expect(peak, greaterThan(1000), reason: wav.path);

      expect(m4a.existsSync(), isTrue, reason: m4a.path);
      final encoded = m4a.readAsBytesSync();
      expect(String.fromCharCodes(encoded.skip(4).take(4)), 'ftyp');
      expect(encoded.length, inInclusiveRange(5000, 100000), reason: m4a.path);
      expect(entry['sha256'], hasLength(64));
    }
  });
}
