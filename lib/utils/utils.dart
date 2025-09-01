/// Calculates and formats the remaining time in seconds.
String formatRemainingTime(DateTime startTime, int cookingTimeSeconds) {
  final now = DateTime.now();
  final elapsedTime = now.difference(startTime).inSeconds;
  final remainingTime = cookingTimeSeconds - elapsedTime;

  if (remainingTime <= 0) {
    return '0s'; // Or "Done" as a string
  } else {
    return '${remainingTime}s';
  }
}
