/// "Good morning" before noon, "Good afternoon" until 5pm, and "Good
/// evening" after that.
String greetingFor(DateTime time) {
  if (time.hour < 12) return 'Good morning';
  if (time.hour < 17) return 'Good afternoon';
  return 'Good evening';
}
