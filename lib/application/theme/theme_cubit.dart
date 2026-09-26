import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/progress_repository.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final IProgressRepository? _progressRepository;
  
  ThemeCubit({this._progressRepository, bool initialIsDark = false})
    : super(initialIsDark ? ThemeMode.dark : ThemeMode.light);

  void toggleTheme() {
    final nextMode = state == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    emit(nextMode);
    _progressRepository?.saveIsDarkMode(nextMode == ThemeMode.dark);
  }

  void setTheme(ThemeMode mode) {
    emit(mode);
    _progressRepository?.saveIsDarkMode(mode == ThemeMode.dark);
  }
}
