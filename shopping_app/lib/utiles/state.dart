import 'package:flutter/material.dart';

class LifeCycleManager extends StatefulWidget {
  final Widget child;
  const LifeCycleManager({Key? key, required this.child}) : super(key: key);
  _LifeCycleManagerState createState() => _LifeCycleManagerState();

  static _LifeCycleManagerState of(BuildContext context) {
    final _LifeCycleManagerState? manager = context
        .dependOnInheritedWidgetOfExactType<_LifeCycleManagerInherited>()
        ?.manager;
    assert(manager != null, 'No LifeCycleManager found in context');
    return manager!;
  }
}

class _LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;

  AppLifecycleState get appLifecycleState => _appLifecycleState;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _appLifecycleState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _LifeCycleManagerInherited(
      manager: this,
      child: widget.child,
    );
  }
}

class _LifeCycleManagerInherited extends InheritedWidget {
  final _LifeCycleManagerState manager;

  _LifeCycleManagerInherited({
    Key? key,
    required Widget child,
    required this.manager,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
