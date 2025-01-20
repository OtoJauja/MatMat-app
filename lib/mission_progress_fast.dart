class MissionProgress {
  static final Map<String, int> progress = {};

  static int getMissionProgress(String mode) {
    return progress[mode] ?? 0;
  }

  static void incrementMissionProgress(String mode) {
    progress[mode] = (progress[mode] ?? 0) + 1;
  }
}