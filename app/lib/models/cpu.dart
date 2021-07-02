import 'dart:developer';

class Frequency {
  final num current;
  final num min;
  final num max;

  Frequency({
    required this.current,
    required this.min,
    required this.max,
  });

  factory Frequency.fromJson(Map<String, dynamic> json) {
    return Frequency(
      current: json['current'],
      min: json['min'],
      max: json['max'],
    );
  }
}

class CPU {
  final Frequency frequency;

  CPU({
    required this.frequency,
  });

  factory CPU.fromJson(Map<String, dynamic> json) {
    return CPU(
      frequency: Frequency.fromJson(json['cpu']['frequency']),
    );
  }
}
