import 'rar_entry.dart';
import '../util/archive_exception.dart';
import '../util/input_stream.dart';

enum RarVersion {
  none,
  rar14,
  rar15,
  rar50,
  future
}

class RarArchive {
  List<RarEntry> entries = [];
  RarVersion version = RarVersion.none;

  RarArchive(InputStreamBase input) {
    version = _readSignature(input);
    if (version == RarVersion.none) {
      throw ArchiveException("Invalid archive");
    }

    _readHeader(input);
  }

  void _readHeader(InputStreamBase input) {
    switch (version) {
      case RarVersion.none:
        break;
      case RarVersion.rar14:
        _readHeader14(input);
        break;
      case RarVersion.rar15:
        _readHeader15(input);
        break;
      case RarVersion.rar50:
        _readHeader50(input);
        break;
      case RarVersion.future:
        break;
    }
  }

  void _readHeader14(InputStreamBase input) {
  }

  void _readHeader15(InputStreamBase input) {
    var raw = input.readBytes(7);
    var crc = raw.readUint16();
    var headerType = raw.readByte();
    var flags = raw.readUint16();
    var headSize = raw.readUint16();
  }

  void _readHeader50(InputStreamBase input) {

  }

  RarVersion _readSignature(InputStreamBase input) {
    var signature = input.readBytes(7).toUint8List();
    if (signature.length != 7 || signature[0] != 0x52) {
      return RarVersion.none;
    }
    if (signature[1] == 0x45 && signature[2] == 0x7e && signature[3] == 0x5e) {
      return RarVersion.rar14;
    }
    if (signature[1] == 0x61 && signature[2] == 0x72 && signature[3] == 0x21 &&
        signature[4] == 0x1a && signature[5] == 0x07) {
      if (signature[6] == 0x00) {
        return RarVersion.rar15;
      }
      if (signature[6] == 0x01) {
        input.skip(1); // RAR 5 signature is 8 bytes
        return RarVersion.rar50;
      }
      if (signature[6] > 1 &&signature[6] < 5) {
        return RarVersion.future;
      }
    }
    return RarVersion.none;
  }

  int _readVInt(InputStreamBase input) {
    int result = 0;
    for (int shift = 0; !input.isEOS && shift < 64; shift += 7) {
      var curByte = input.readByte();
      result += (curByte & 0x7f) << shift;
      if ((curByte & 0x80) == 0) {
        return result;
      }
    }
    // out of buffer border
    return 0;
  }

  bool _compareLists(List a, List b) {
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; ++i) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}