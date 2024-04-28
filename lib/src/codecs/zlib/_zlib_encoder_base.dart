import 'dart:typed_data';
import '../../util/input_stream.dart';
import '../../util/output_stream.dart';

abstract class ZLibEncoderBase {
  const ZLibEncoderBase();

  Uint8List encode(List<int> bytes, {int level = 6});

  void encodeStream(InputStream input, OutputStream output, {int level = 6});
}
