// lib/widget/form_section_container.dart
import 'package:flutter/material.dart';

class FormSectionContainer extends StatelessWidget {
  final List<Widget> children;

  const FormSectionContainer({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26), // Using .withAlpha() for better practice
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.shade200,
                indent: 16,
              ),
          ]
        ],
      ),
    );
  }
}