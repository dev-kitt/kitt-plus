
import 'package:flutter/material.dart';

class DisplayErrorMessage extends StatelessWidget {
  const DisplayErrorMessage({super.key, this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Oh no, something went wrong. '
        'Please check your config. $error',
      ),
    );
  }
}
