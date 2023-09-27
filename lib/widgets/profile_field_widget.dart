import 'package:flutter/material.dart';

class ProfileField extends StatefulWidget {
  final String label;
  final String initialValue;
  final bool isReadOnly;
  final TextEditingController controller;

  const ProfileField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.isReadOnly,
    required this.controller,
  });

  @override
  State<ProfileField> createState() => _ProfileFieldState();
}

class _ProfileFieldState extends State<ProfileField> {
  @override
  void initState() {
    super.initState();
    //widget.controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          TextField(
            readOnly: widget.isReadOnly,
            controller: widget.controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
