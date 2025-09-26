import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/workout.dart';

class WorkoutProvider with ChangeNotifier {
  List<Workout> _workouts = [];
  List<Workout> get workouts => _workouts;
  
  // Map of workout names to their latest details for autofill
  final Map<String, Workout> _workoutTemplates = {};
  Map<String, Workout> get workoutTemplates => _workoutTemplates;

  // Constructor loads data from SharedPreferences
  WorkoutProvider() {
    _loadWorkouts();
  }

  // Load workouts from storage
  Future<void> _loadWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutsJson = prefs.getStringList('workouts') ?? [];
      
      _workouts = workoutsJson
          .map((workoutJson) => Workout.fromMap(json.decode(workoutJson)))
          .toList();
      
      // Sort workouts by date (newest first)
      _workouts.sort((a, b) => b.date.compareTo(a.date));
      
      // Build workout templates map for autofill
      _updateWorkoutTemplates();
      
      notifyListeners();
    } catch (e) {
      print('Error loading workouts: $e');
    }
  }

  // Save workouts to storage
  Future<void> _saveWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutsJson = _workouts
          .map((workout) => json.encode(workout.toMap()))
          .toList();
      
      await prefs.setStringList('workouts', workoutsJson);
    } catch (e) {
      print('Error saving workouts: $e');
    }
  }
  
  // Update the workout templates map for autofill
  void _updateWorkoutTemplates() {
    _workoutTemplates.clear();
    
    // Group workouts by name
    final workoutsByName = <String, List<Workout>>{};
    for (var workout in _workouts) {
      if (!workoutsByName.containsKey(workout.name)) {
        workoutsByName[workout.name] = [];
      }
      workoutsByName[workout.name]!.add(workout);
    }
    
    // For each workout name, use the most recent one as template
    workoutsByName.forEach((name, workouts) {
      // Sort by date descending
      workouts.sort((a, b) => b.date.compareTo(a.date));
      _workoutTemplates[name] = workouts.first;
    });
  }

  // Add a new workout
  Future<void> addWorkout(Workout workout) async {
    final newWorkout = workout.copyWith(id: const Uuid().v4());
    _workouts.add(newWorkout);
    
    // Sort workouts by date (newest first)
    _workouts.sort((a, b) => b.date.compareTo(a.date));
    
    _updateWorkoutTemplates();
    await _saveWorkouts();
    notifyListeners();
  }

  // Update an existing workout
  Future<void> updateWorkout(Workout updatedWorkout) async {
    final index = _workouts.indexWhere((workout) => workout.id == updatedWorkout.id);
    if (index != -1) {
      _workouts[index] = updatedWorkout;
      
      // Sort workouts by date (newest first)
      _workouts.sort((a, b) => b.date.compareTo(a.date));
      
      _updateWorkoutTemplates();
      await _saveWorkouts();
      notifyListeners();
    }
  }

  // Delete a workout
  Future<void> deleteWorkout(String id) async {
    _workouts.removeWhere((workout) => workout.id == id);
    _updateWorkoutTemplates();
    await _saveWorkouts();
    notifyListeners();
  }

  // Get unique workout names
  List<String> getUniqueWorkoutNames() {
    return _workoutTemplates.keys.toList();
  }

  // Get workouts for a specific workout name
  List<Workout> getWorkoutsByName(String name, {int limit = 20}) {
    final filteredWorkouts = _workouts
        .where((workout) => workout.name == name)
        .toList();
    
    // Sort by date (oldest first for graph display)
    filteredWorkouts.sort((a, b) => a.date.compareTo(b.date));
    
    // Return the most recent 'limit' entries
    if (filteredWorkouts.length > limit) {
      return filteredWorkouts.skip(filteredWorkouts.length - limit).toList();
    }
    
    return filteredWorkouts;
  }

  // Get workout template by name (for autofill)
  Workout? getWorkoutTemplate(String name) {
    return _workoutTemplates[name];
  }
  
  // Get the most recent weight used for a specific workout
  double getMostRecentWeight(String workoutName) {
    final template = _workoutTemplates[workoutName];
    return template?.weight ?? 0;
  }
  
  // Get the most recent reps used for a specific workout
  int getMostRecentReps(String workoutName) {
    final template = _workoutTemplates[workoutName];
    return template?.reps ?? 0;
  }
  
  // Get personal record for a specific workout (highest weight × reps)
  Workout? getPersonalRecord(String workoutName) {
    final workoutsForName = _workouts
        .where((workout) => workout.name == workoutName)
        .toList();
        
    if (workoutsForName.isEmpty) return null;
    
    // Calculate 1RM for each workout and find the highest
    Workout bestWorkout = workoutsForName.first;
    double bestOneRM = bestWorkout.estimatedOneRepMax;
    
    for (var workout in workoutsForName) {
      final oneRM = workout.estimatedOneRepMax;
      if (oneRM > bestOneRM) {
        bestOneRM = oneRM;
        bestWorkout = workout;
      }
    }
    
    return bestWorkout;
  }
}