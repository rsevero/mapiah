part of 'mp_create_command_params.dart';

class MPCreatePointCommandParams extends MPCreateCommandParams {
  final int pointMapiahID;

  MPCreatePointCommandParams({required this.pointMapiahID});

  @override
  MPCreateCommandParamsType get paramsType => MPCreateCommandParamsType.point;

  @override
  MPCreateCommandParams copyWith() {
    // TODO: implement copyWith
    throw UnimplementedError();
  }
}
