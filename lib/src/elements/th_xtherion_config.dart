import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/th_element.dart';

part 'th_xtherion_config.mapper.dart';

@MappableClass()
class THXTherionConfig extends THElement with THXTherionConfigMappable {
  String name;
  String value;

  // Used by dart_mappable.
  THXTherionConfig.notAddToParent(
    super.mapiahID,
    super.parentMapiahID,
    super.sameLineComment,
    this.name,
    this.value,
  ) : super.notAddToParent();

  THXTherionConfig(super.parent, this.name, this.value) : super.addToParent();

  @override
  bool isSameClass(THElement element) {
    return element is THXTherionConfig;
  }
}
