import 'package:collection/collection.dart';
import 'package:mapiah/src/elements/th_element.dart';

class MPDebugAux {
  static void debugElementByMPIDDifferences(
    Map<int, THElement> a,
    Map<int, THElement> b,
  ) {
    final deepEq = const DeepCollectionEquality();

    print('--- debugElementByMPIDDifferences ---');
    print('First map length: ${a.length}');
    print('Second map length: ${b.length}');
    print('First map key-value pairs:');
    for (final k in a.keys) {
      final v = a[k];
      print('  $k (type: ${k.runtimeType}): $v (type: ${v?.runtimeType})');
    }
    print('Second map key-value pairs:');
    for (final k in b.keys) {
      final v = b[k];
      print('  $k (type: ${k.runtimeType}): $v (type: ${v?.runtimeType})');
    }

    final onlyInA = a.keys.where((k) => !b.containsKey(k)).toList();
    final onlyInB = b.keys.where((k) => !a.containsKey(k)).toList();
    if (onlyInA.isNotEmpty) {
      print('Keys only in first map: $onlyInA');
    }
    if (onlyInB.isNotEmpty) {
      print('Keys only in second map: $onlyInB');
    }

    final allKeys = {...a.keys, ...b.keys};
    for (final key in allKeys) {
      final aValue = a[key];
      final bValue = b[key];
      final keyType = key.runtimeType;
      final aType = aValue?.runtimeType;
      final bType = bValue?.runtimeType;
      if (aValue == null && bValue != null) {
        print('Key $key (type: $keyType) missing in first map');
      } else if (bValue == null && aValue != null) {
        print('Key $key (type: $keyType) missing in second map');
      } else {
        final eq = deepEq.equals(aValue, bValue);
        final eqOperator = aValue == bValue;
        final hashA = aValue?.hashCode;
        final hashB = bValue?.hashCode;
        final mapA = aValue is THElement ? aValue.toMap() : aValue;
        final mapB = bValue is THElement ? bValue.toMap() : bValue;
        if (!eq || !eqOperator) {
          print('Difference at key $key (type: $keyType):');
          print('  First: $aValue (type: $aType)');
          print('    hashCode: $hashA');
          print('    toMap: $mapA');
          print('  Second: $bValue (type: $bType)');
          print('    hashCode: $hashB');
          print('    toMap: $mapB');
          print('  DeepCollectionEquality.equals: $eq');
        }
      }
    }
    print('--- end debugElementByMPIDDifferences ---');
  }
}
