import 'package:flutter/material.dart';

class TweenWidget extends StatefulWidget {
  const TweenWidget({Key? key}) : super(key: key);

  @override
  _TweenWidgetState createState() => _TweenWidgetState();
}

class _TweenWidgetState extends State<TweenWidget> with SingleTickerProviderStateMixin {
  late Animation animation;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(vsync: this, duration: Duration(seconds: 5));
    animation = Tween(begin: 200.0, end: 100.0).animate(animationController);

    animationController.addListener(() {
      // setState(() {}); // Trigger rebuild when animation value changes
      print(animation.value);
    });

    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Container(
            width: animation.value,
            height: animation.value,
            color: const Color.fromARGB(255, 33, 243, 121),
          );
        },
      ),
    );
  }
}
