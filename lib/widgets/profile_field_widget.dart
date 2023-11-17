import 'package:flutter/material.dart';

class ProfileField extends StatefulWidget {
  final String label;
  final String initialValue;
  final bool isReadOnly;
  final TextEditingController? controller; // Make the controller optional

  const ProfileField({
    Key? key,
    required this.label,
    required this.initialValue,
    required this.isReadOnly,
    this.controller, // Make the controller optional
  }) : super(key: key);

  @override
  State<ProfileField> createState() => _ProfileFieldState();
}

class _ProfileFieldState extends State<ProfileField> {
  late TextEditingController _controller; // Declare a local controller

  @override
  void initState() {
    super.initState();
    // Initialize the local controller if the provided controller is null
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    // Dispose of the local controller if it was created here
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        left: 16.0,
        right: 16.0,
        bottom: 8.0,
      ),
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
            controller: _controller, // Use the local controller here
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
