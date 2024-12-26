// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_element.dart';

class THElementMapper extends ClassMapperBase<THElement> {
  THElementMapper._();

  static THElementMapper? _instance;
  static THElementMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THElementMapper._());
      THFileMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THElement';

  static THParent _$parent(THElement v) => v.parent;
  static const Field<THElement, THParent> _f$parent = Field('parent', _$parent);
  static String? _$sameLineComment(THElement v) => v.sameLineComment;
  static const Field<THElement, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment, mode: FieldMode.member);

  @override
  final MappableFields<THElement> fields = const {
    #parent: _f$parent,
    #sameLineComment: _f$sameLineComment,
  };

  static THElement _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('THElement');
  }

  @override
  final Function instantiate = _instantiate;

  static THElement fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THElement>(map);
  }

  static THElement fromJson(String json) {
    return ensureInitialized().decodeJson<THElement>(json);
  }
}

mixin THElementMappable {
  String toJson();
  Map<String, dynamic> toMap();
  THElementCopyWith<THElement, THElement, THElement> get copyWith;
}

abstract class THElementCopyWith<$R, $In extends THElement, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  THElementCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class THFileMapper extends ClassMapperBase<THFile> {
  THFileMapper._();

  static THFileMapper? _instance;
  static THFileMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THFileMapper._());
      THElementMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THFile';

  static THParent _$parent(THFile v) => v.parent;
  static const Field<THFile, THParent> _f$parent =
      Field('parent', _$parent, mode: FieldMode.member);
  static String? _$sameLineComment(THFile v) => v.sameLineComment;
  static const Field<THFile, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment, mode: FieldMode.member);
  static String _$filename(THFile v) => v.filename;
  static const Field<THFile, String> _f$filename =
      Field('filename', _$filename, mode: FieldMode.member);
  static String _$encoding(THFile v) => v.encoding;
  static const Field<THFile, String> _f$encoding =
      Field('encoding', _$encoding, mode: FieldMode.member);

  @override
  final MappableFields<THFile> fields = const {
    #parent: _f$parent,
    #sameLineComment: _f$sameLineComment,
    #filename: _f$filename,
    #encoding: _f$encoding,
  };

  static THFile _instantiate(DecodingData data) {
    return THFile();
  }

  @override
  final Function instantiate = _instantiate;

  static THFile fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THFile>(map);
  }

  static THFile fromJson(String json) {
    return ensureInitialized().decodeJson<THFile>(json);
  }
}

mixin THFileMappable {
  String toJson() {
    return THFileMapper.ensureInitialized().encodeJson<THFile>(this as THFile);
  }

  Map<String, dynamic> toMap() {
    return THFileMapper.ensureInitialized().encodeMap<THFile>(this as THFile);
  }

  THFileCopyWith<THFile, THFile, THFile> get copyWith =>
      _THFileCopyWithImpl(this as THFile, $identity, $identity);
  @override
  String toString() {
    return THFileMapper.ensureInitialized().stringifyValue(this as THFile);
  }

  @override
  bool operator ==(Object other) {
    return THFileMapper.ensureInitialized().equalsValue(this as THFile, other);
  }

  @override
  int get hashCode {
    return THFileMapper.ensureInitialized().hashValue(this as THFile);
  }
}

extension THFileValueCopy<$R, $Out> on ObjectCopyWith<$R, THFile, $Out> {
  THFileCopyWith<$R, THFile, $Out> get $asTHFile =>
      $base.as((v, t, t2) => _THFileCopyWithImpl(v, t, t2));
}

abstract class THFileCopyWith<$R, $In extends THFile, $Out>
    implements THElementCopyWith<$R, $In, $Out> {
  @override
  $R call();
  THFileCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _THFileCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, THFile, $Out>
    implements THFileCopyWith<$R, THFile, $Out> {
  _THFileCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THFile> $mapper = THFileMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  THFile $make(CopyWithData data) => THFile();

  @override
  THFileCopyWith<$R2, THFile, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _THFileCopyWithImpl($value, $cast, t);
}
