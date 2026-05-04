import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences _prefs;

  ThemeBloc(this._prefs) : super(const ThemeState()) {
    on<ThemeLoadRequested>(_onThemeLoadRequested);
    on<ThemeToggled>(_onThemeToggled);
  }

  Future<void> _onThemeLoadRequested(
    ThemeLoadRequested event,
    Emitter<ThemeState> emit,
  ) async {
    final isDarkMode = _prefs.getBool(StorageKeys.isDarkMode) ?? false;
    emit(ThemeState(isDarkMode: isDarkMode));
  }

  Future<void> _onThemeToggled(
    ThemeToggled event,
    Emitter<ThemeState> emit,
  ) async {
    final newValue = !state.isDarkMode;
    await _prefs.setBool(StorageKeys.isDarkMode, newValue);
    emit(state.copyWith(isDarkMode: newValue));
  }
}
