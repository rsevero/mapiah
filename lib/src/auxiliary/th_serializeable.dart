abstract interface class THSerializable {
  String toJson();

  Map<String, dynamic> toMap();

  Object copyWith();
}
