import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingManager extends StatelessWidget {
  const LoadingManager({Key? key, required this.child, required this.isLoading})
      : super(key: key);
  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        isLoading
            ? Container(
                color: Colors.black.withOpacity(0.7),
              )
            : Container(),
        isLoading
            ? const Center(
                child: SpinKitFadingFour(
                  duration: Duration(seconds: 4),
                  color: Colors.white,
                  size: 50.0,
                ),
              )
            : Container(),
      ],
    );
  }
}
