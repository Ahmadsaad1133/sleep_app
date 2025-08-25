import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SleepLog with ChangeNotifier {
  String? id;
  DateTime date; // Changed from Timestamp to DateTime
  String bedtime;
  String wakeTime;
  int quality;
  int waterIntake;
  int caffeineIntake;
  int exerciseMinutes;
  int screenTimeBeforeBed;
  String mood;
  int durationMinutes;
  int stressLevel;
  String sleepEnvironment;
  String dietNotes;
  String medications;
  List<String> disturbances;
  int? latencyMinutes;
  int? wasoMinutes;
  String noiseLevel;
  String lightExposure;
  String temperature;
  String comfortLevel;
  int? timeInBedMinutes;
  int? deepSleepMinutes;
  int? remSleepMinutes;
  int? lightSleepMinutes;
  String? userId;

  // Dream Journal Properties
  String dreamJournal;
  List<String> dreamElements;

  // For tracking active section during validation
  int? _activeIndex;

  bool _disposed = false;

  SleepLog({
    this.id,
    required this.date,
    required this.bedtime,
    required this.wakeTime,
    required this.quality,
    required this.waterIntake,
    required this.caffeineIntake,
    required this.exerciseMinutes,
    required this.screenTimeBeforeBed,
    required this.mood,
    required this.durationMinutes,
    required this.stressLevel,
    required this.sleepEnvironment,
    required this.dietNotes,
    required this.medications,
    required this.disturbances,
    this.latencyMinutes,
    this.wasoMinutes,
    required this.noiseLevel,
    required this.lightExposure,
    required this.temperature,
    required this.comfortLevel,
    this.timeInBedMinutes,
    this.deepSleepMinutes,
    this.remSleepMinutes,
    this.lightSleepMinutes,
    this.userId,
    // Initialize dream properties
    this.dreamJournal = '',
    this.dreamElements = const [],
  });

  factory SleepLog.reset() {
    final user = FirebaseAuth.instance.currentUser;
    return SleepLog(
      id: null,
      date: DateTime.now(),
      bedtime: '',
      wakeTime: '',
      quality: 0,
      waterIntake: 0,
      caffeineIntake: 0,
      exerciseMinutes: 0,
      screenTimeBeforeBed: 0,
      mood: '',
      durationMinutes: 0,
      stressLevel: 0,
      sleepEnvironment: '',
      dietNotes: '',
      medications: '',
      disturbances: [],
      latencyMinutes: null,
      wasoMinutes: null,
      noiseLevel: '',
      lightExposure: '',
      temperature: '',
      comfortLevel: '',
      timeInBedMinutes: null,
      deepSleepMinutes: null,
      remSleepMinutes: null,
      lightSleepMinutes: null,
      userId: user?.uid,
      dreamJournal: '',
      dreamElements: [],
    );
  }

  // Migration helper method
  static Future<void> migrateSleepLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    debugPrint('Starting sleep log migration for user: ${user.uid}');

    try {
      final oldLogs = await FirebaseFirestore.instance
          .collection('anonymous_sleep_logs')
          .where('userId', isEqualTo: user.uid)
          .get();

      debugPrint('Found ${oldLogs.docs.length} logs to migrate');

      final batch = FirebaseFirestore.instance.batch();

      for (final doc in oldLogs.docs) {
        final data = doc.data();
        final newRef = FirebaseFirestore.instance
            .collection('user_sleep_logs')
            .doc(user.uid)
            .collection('logs')
            .doc(doc.id);

        // Convert date if needed
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate();
        }

        batch.set(newRef, data);
      }

      await batch.commit();
      debugPrint('Successfully migrated ${oldLogs.docs.length} sleep logs');
    } catch (e, stack) {
      debugPrint('Migration failed: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  bool get hasSleepStagesData {
    return (deepSleepMinutes ?? 0) > 0 ||
        (remSleepMinutes ?? 0) > 0 ||
        (lightSleepMinutes ?? 0) > 0;
  }

  bool get hasEfficiencyData {
    return latencyMinutes != null ||
        wasoMinutes != null ||
        timeInBedMinutes != null;
  }

  int get effectiveDeepSleepMinutes =>
      deepSleepMinutes ?? (durationMinutes * 0.15).round();
  int get effectiveRemSleepMinutes =>
      remSleepMinutes ?? (durationMinutes * 0.25).round();
  int get effectiveLightSleepMinutes =>
      lightSleepMinutes ?? (durationMinutes * 0.60).round();

  double get efficiencyScore {
    final inBed = (timeInBedMinutes ?? durationMinutes) + (latencyMinutes ?? 0);
    if (inBed <= 0) return 0.0;
    return (durationMinutes / inBed * 100).clamp(0, 100).toDouble();
  }

  TimeOfDay parseTime(String time) {
    try {
      final clean = time.replaceAll(RegExp(r'[^0-9:]'), '');
      final parts = clean.split(':');
      if (parts.length < 2) throw FormatException('Invalid time format: $time');

      int hour = int.tryParse(parts[0]) ?? 0;
      int minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      if (hour >= 24) hour = hour % 24;

      return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
    } catch (e) {
      debugPrint('Time parsing error: $e');
      return TimeOfDay.now();
    }
  }

  int calculateDurationMinutes() {
    try {
      final b = parseTime(bedtime);
      final w = parseTime(wakeTime);
      final bedMin = b.hour * 60 + b.minute;
      final wakeMin = w.hour * 60 + w.minute;
      if (wakeMin > bedMin) return wakeMin - bedMin;
      return (24 * 60 - bedMin) + wakeMin;
    } catch (e) {
      debugPrint('Duration calculation error: $e');
      return 0;
    }
  }

  Map<String, dynamic> toMap() {
    // Ensure duration is always calculated
    durationMinutes = calculateDurationMinutes();

    final m = <String, dynamic>{
      'date': Timestamp.fromDate(date),
      'bedtime': bedtime,
      'wake_time': wakeTime,
      'quality': quality,
      'water_intake': waterIntake,
      'caffeine_intake': caffeineIntake,
      'exercise_minutes': exerciseMinutes,
      'screen_time_before_bed': screenTimeBeforeBed,
      'mood': mood,
      'duration_minutes': durationMinutes,
      'stress_level': stressLevel,
      'sleep_environment': sleepEnvironment,
      'diet_notes': dietNotes,
      'medications': medications,
      'disturbances': disturbances,
      'noise_level': noiseLevel,
      'light_exposure': lightExposure,
      'temperature': temperature,
      'comfort_level': comfortLevel,

      // Dream properties
      'dream_journal': dreamJournal,
      'dream_elements': dreamElements,
    };


    if (userId != null && userId!.isNotEmpty) m['userId'] = userId!;
    if (latencyMinutes != null) m['latency_minutes'] = latencyMinutes!;
    if (wasoMinutes != null) m['waso_minutes'] = wasoMinutes!;
    if (timeInBedMinutes != null) m['time_in_bed_minutes'] = timeInBedMinutes!;
    if (deepSleepMinutes != null) m['deep_sleep_minutes'] = deepSleepMinutes!;
    if (remSleepMinutes != null) m['rem_sleep_minutes'] = remSleepMinutes!;
    if (lightSleepMinutes != null) m['light_sleep_minutes'] = lightSleepMinutes!;

    return m;
  }

  factory SleepLog.fromMap(Map<String, dynamic> map, [String? id]) {
    // Handle date conversion
    dynamic dateValue = map['date'];
    DateTime parsedDate;

    if (dateValue is Timestamp) {
      parsedDate = dateValue.toDate();
    } else if (dateValue is DateTime) {
      parsedDate = dateValue;
    } else {
      parsedDate = DateTime.now();
      debugPrint('Warning: Invalid date format, using current date');
    }

    return SleepLog(
      id: id ?? map['id'] as String?,
      date: parsedDate,
      bedtime: map['bedtime'] as String? ?? '',
      wakeTime: map['wake_time'] as String? ?? '',
      quality: (map['quality'] as int?) ?? 0,
      waterIntake: (map['water_intake'] as int?) ?? 0,
      caffeineIntake: (map['caffeine_intake'] as int?) ?? 0,
      exerciseMinutes: (map['exercise_minutes'] as int?) ?? 0,
      screenTimeBeforeBed: (map['screen_time_before_bed'] as int?) ?? 0,
      mood: map['mood'] as String? ?? '',
      durationMinutes: (map['duration_minutes'] as int?) ?? 0,
      stressLevel: (map['stress_level'] as int?) ?? 0,
      sleepEnvironment: map['sleep_environment'] as String? ?? '',
      dietNotes: map['diet_notes'] as String? ?? '',
      medications: map['medications'] as String? ?? '',
      disturbances: (map['disturbances'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      latencyMinutes: map['latency_minutes'] as int?,
      wasoMinutes: map['waso_minutes'] as int?,
      noiseLevel: map['noise_level'] as String? ?? '',
      lightExposure: map['light_exposure'] as String? ?? '',
      temperature: map['temperature'] as String? ?? '',
      comfortLevel: map['comfort_level'] as String? ?? '',
      timeInBedMinutes: map['time_in_bed_minutes'] as int?,
      deepSleepMinutes: map['deep_sleep_minutes'] as int?,
      remSleepMinutes: map['rem_sleep_minutes'] as int?,
      lightSleepMinutes: map['light_sleep_minutes'] as int?,
      userId: map['userId'] as String?,
      // Dream properties
      dreamJournal: map['dream_journal'] as String? ?? '',
      dreamElements: (map['dream_elements'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }

  SleepLog copy() => SleepLog(
    id: id,
    date: date,
    bedtime: bedtime,
    wakeTime: wakeTime,
    quality: quality,
    waterIntake: waterIntake,
    caffeineIntake: caffeineIntake,
    exerciseMinutes: exerciseMinutes,
    screenTimeBeforeBed: screenTimeBeforeBed,
    mood: mood,
    durationMinutes: durationMinutes,
    stressLevel: stressLevel,
    sleepEnvironment: sleepEnvironment,
    dietNotes: dietNotes,
    medications: medications,
    disturbances: List.from(disturbances),
    latencyMinutes: latencyMinutes,
    wasoMinutes: wasoMinutes,
    noiseLevel: noiseLevel,
    lightExposure: lightExposure,
    temperature: temperature,
    comfortLevel: comfortLevel,
    timeInBedMinutes: timeInBedMinutes,
    deepSleepMinutes: deepSleepMinutes,
    remSleepMinutes: remSleepMinutes,
    lightSleepMinutes: lightSleepMinutes,
    userId: userId,
    dreamJournal: dreamJournal,
    dreamElements: List.from(dreamElements),
  );

  /// Ensures required fields are filled before saving
  bool validate() {
    return bedtime.isNotEmpty &&
        wakeTime.isNotEmpty &&
        quality > 0 &&
        durationMinutes > 0 &&
        mood.isNotEmpty &&
        stressLevel > 0 &&
        sleepEnvironment.isNotEmpty &&
        noiseLevel.isNotEmpty &&
        lightExposure.isNotEmpty &&
        temperature.isNotEmpty &&
        comfortLevel.isNotEmpty &&
        userId != null &&
        userId!.isNotEmpty;
  }

  /// Detailed validation that returns specific missing fields
  String? validateWithDetails() {
    final missing = <String>[];

    // Core required fields
    if (bedtime.isEmpty) missing.add('Bedtime');
    if (wakeTime.isEmpty) missing.add('Wake Time');
    if (quality <= 0) missing.add('Sleep Quality');
    if (durationMinutes <= 0) {
      // Recalculate duration to ensure it's up-to-date
      durationMinutes = calculateDurationMinutes();
      if (durationMinutes <= 0) {
        missing.add('Duration (check your time inputs)');
      }
    }

    // Instead require all four environmental factors:
    if (noiseLevel.isEmpty) missing.add('Noise Level');
    if (lightExposure.isEmpty) missing.add('Light Exposure');
    if (temperature.isEmpty) missing.add('Temperature');
    if (comfortLevel.isEmpty) missing.add('Comfort Level');

    // Always validate sleep stages and efficiency
    if (!hasSleepStagesData) {
      missing.add('Sleep Stages Data (at least one stage required)');
    }

    if (!hasEfficiencyData) {
      missing.add('Sleep Efficiency Data (latency, WASO, or time in bed)');
    }

    // Dream journal is optional
    return missing.isEmpty ? null : missing.join(', ');
  }

  // --- Setters with notifications ---
  void setBedtime(String t) {
    bedtime = t;
    durationMinutes = calculateDurationMinutes();
    if (!_disposed) notifyListeners();
  }

  void setWakeTime(String t) {
    wakeTime = t;
    durationMinutes = calculateDurationMinutes();
    if (!_disposed) notifyListeners();
  }

  void setQuality(int v) {
    quality = v.clamp(0, 10);
    if (!_disposed) notifyListeners();
  }

  void setWater(String v) {
    waterIntake = int.tryParse(v)?.clamp(0, 4000) ?? 0;
    if (!_disposed) notifyListeners();
  }

  void setCaffeine(String v) {
    caffeineIntake = int.tryParse(v)?.clamp(0, 1000) ?? 0;
    if (!_disposed) notifyListeners();
  }

  void setExercise(String v) {
    exerciseMinutes = int.tryParse(v)?.clamp(0, 1440) ?? 0;
    if (!_disposed) notifyListeners();
  }

  void setScreenTime(String v) {
    screenTimeBeforeBed = int.tryParse(v)?.clamp(0, 1440) ?? 0;
    if (!_disposed) notifyListeners();
  }

  void setMood(String v) {
    mood = v;
    if (!_disposed) notifyListeners();
  }

  void setStressLevel(int v) {
    stressLevel = v.clamp(1, 10);
    if (!_disposed) notifyListeners();
  }

  void setDietNotes(String v) {
    dietNotes = v;
    if (!_disposed) notifyListeners();
  }

  void setSleepEnvironment(String v) {
    sleepEnvironment = v;
    if (!_disposed) notifyListeners();
  }

  void setMedications(String v) {
    medications = v;
    if (!_disposed) notifyListeners();
  }

  void setNoiseLevel(String v) {
    noiseLevel = v;
    if (!_disposed) notifyListeners();
  }

  void setLightExposure(String v) {
    lightExposure = v;
    if (!_disposed) notifyListeners();
  }

  void setTemperature(String v) {
    temperature = v;
    if (!_disposed) notifyListeners();
  }

  void setComfortLevel(String v) {
    comfortLevel = v;
    if (!_disposed) notifyListeners();
  }

  void setLatencyMinutes(int? v) {
    latencyMinutes = v;
    if (!_disposed) notifyListeners();
  }

  void setWasoMinutes(int? v) {
    wasoMinutes = v;
    if (!_disposed) notifyListeners();
  }

  void setTimeInBedMinutes(int? v) {
    timeInBedMinutes = v;
    if (!_disposed) notifyListeners();
  }

  void setDeepSleepMinutes(int? v) {
    deepSleepMinutes = v;
    if (!_disposed) notifyListeners();
  }

  void setRemSleepMinutes(int? v) {
    remSleepMinutes = v;
    if (!_disposed) notifyListeners();
  }

  void setLightSleepMinutes(int? v) {
    lightSleepMinutes = v;
    if (!_disposed) notifyListeners();
  }

  // Dream journal setters
  void setDreamJournal(String value) {
    dreamJournal = value;
    if (!_disposed) notifyListeners();
  }

  void addDreamElement(String element) {
    if (!dreamElements.contains(element)) {
      dreamElements.add(element);
      if (!_disposed) notifyListeners();
    }
  }

  void removeDreamElement(String element) {
    dreamElements.remove(element);
    if (!_disposed) notifyListeners();
  }

  void toggleDisturbance(String d) {
    if (disturbances.contains(d)) {
      disturbances.remove(d);
    } else {
      disturbances.add(d);
    }
    if (!_disposed) notifyListeners();
  }

  // Set active section index for validation
  void setActiveIndex(int index) {
    _activeIndex = index;
    if (!_disposed) notifyListeners();
  }

  void reset() {
    final fresh = SleepLog.reset();
    id = fresh.id;
    date = fresh.date;
    bedtime = fresh.bedtime;
    wakeTime = fresh.wakeTime;
    quality = fresh.quality;
    waterIntake = fresh.waterIntake;
    caffeineIntake = fresh.caffeineIntake;
    exerciseMinutes = fresh.exerciseMinutes;
    screenTimeBeforeBed = fresh.screenTimeBeforeBed;
    mood = fresh.mood;
    durationMinutes = fresh.durationMinutes;
    stressLevel = fresh.stressLevel;
    sleepEnvironment = fresh.sleepEnvironment;
    dietNotes = fresh.dietNotes;
    medications = fresh.medications;
    disturbances = List.from(fresh.disturbances);
    latencyMinutes = fresh.latencyMinutes;
    wasoMinutes = fresh.wasoMinutes;
    timeInBedMinutes = fresh.timeInBedMinutes;
    deepSleepMinutes = fresh.deepSleepMinutes;
    remSleepMinutes = fresh.remSleepMinutes;
    lightSleepMinutes = fresh.lightSleepMinutes;
    userId = fresh.userId;
    dreamJournal = fresh.dreamJournal;
    dreamElements = List.from(fresh.dreamElements);
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}