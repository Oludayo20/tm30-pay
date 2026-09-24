part of 'theme_bloc.dart';

final class ThemeState extends Equatable {
  const ThemeState(this.preference);

  final ThemePreference preference;

  @override
  List<Object?> get props => [preference];
}
