import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/config/languages.dart';

class LocaleController extends ChangeNotifier {
  bool _isVietnamese = false;

  bool get isVietnamese => _isVietnamese;
  Map<String, String> get text => _isVietnamese ? Languages.vi : Languages.en;

  String tr(String key, {Map<String, String>? params}) {
    var value = text[key] ?? key;
    if (params != null) {
      params.forEach((k, v) => value = value.replaceAll('{$k}', v));
    }
    return value;
  }

  void toggle() {
    _isVietnamese = !_isVietnamese;
    notifyListeners();
  }
}

class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    super.key,
    required LocaleController controller,
    required super.child,
  }) : super(notifier: controller);

  static LocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null, 'LocaleScope not found in widget tree');
    return scope!.notifier!;
  }
}
