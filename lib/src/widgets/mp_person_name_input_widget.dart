import 'package:flutter/material.dart';

class MPPersonNameInputWidget extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;

  const MPPersonNameInputWidget({
    super.key,
    this.initialValue,
    this.onChanged,
  }) : super();

  @override
  State<MPPersonNameInputWidget> createState() =>
      _MPPersonNameInputWidgetState();
}

class _MPPersonNameInputWidgetState extends State<MPPersonNameInputWidget> {
  late TextEditingController _nameController;
  final FocusNode _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  String? _validateName(String value) {
    final namePattern = RegExp(
      r'^([^\s/]+(\s+[^\s/]+)+|[^\s/]+(/[^\s/]+)+)$',
    );

    if (value.isEmpty || namePattern.hasMatch(value)) {
      return null; // Valid input
    }
    return 'Invalid name format';
  }

  void _onNameChanged(String value) {
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          focusNode: _nameFocusNode,
          decoration: InputDecoration(
            labelText: 'Person Name',
            hintText: 'FirstName Surname or FirstName/Surname',
            border: OutlineInputBorder(),
            errorText: _validateName(_nameController.text),
          ),
          onChanged: (value) {
            setState(() {}); // Revalidate on input
            _onNameChanged(value);
          },
        ),
        const SizedBox(height: 8.0),
        if (_validateName(_nameController.text) != null)
          Text(
            _validateName(_nameController.text)!,
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }
}
