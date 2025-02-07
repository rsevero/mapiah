part of 'mp_create_command_params.dart';

class MPCreateLineCommandParams extends MPCreateCommandParams {
  final int lineMapiahID;
  final List<THElement> lineChildren;

  MPCreateLineCommandParams({
    required this.lineMapiahID,
    required this.lineChildren,
  });

  @override
  MPCreateCommandParamsType get paramsType => MPCreateCommandParamsType.line;

  @override
  MPCreateCommandParams copyWith({
    int? lineMapiahID,
    List<THElement>? lineChildren,
  }) {
    return MPCreateLineCommandParams(
      lineMapiahID: lineMapiahID ?? this.lineMapiahID,
      lineChildren: lineChildren ?? this.lineChildren,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    map.addAll({
      'lineMapiahID': lineMapiahID,
      //  'lineChildren': ,
    });

    return map;
  }
}
