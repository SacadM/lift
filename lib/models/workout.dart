class Workout {
  final String id;
  final String name;
  final DateTime date;
  final double weight; // in kg
  final int reps;
  final String? notes;

  Workout({
    required this.id,
    required this.name,
    required this.date,
    required this.weight,
    required this.reps,
    this.notes,
  });

  // Convert Workout to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.millisecondsSinceEpoch,
      'weight': weight,
      'reps': reps,
      'notes': notes,
    };
  }

  // Create Workout from Map
  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      name: map['name'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      weight: map['weight'],
      reps: map['reps'],
      notes: map['notes'],
    );
  }

  // Create a copy of Workout with optional changes
  Workout copyWith({
    String? id,
    String? name,
    DateTime? date,
    double? weight,
    int? reps,
    String? notes,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      notes: notes ?? this.notes,
    );
  }
  
  // Calculate one rep max estimation using the Brzycki formula
  double get estimatedOneRepMax {
    if (reps == 1) return weight;
    return weight * (36 / (37 - reps));
  }
}