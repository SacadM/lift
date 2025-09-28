import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../models/workout.dart';
import '../providers/workout_provider.dart';

class AddWorkoutScreen extends StatefulWidget {
  final String? initialWorkoutName;

  const AddWorkoutScreen({
    Key? key,
    this.initialWorkoutName,
  }) : super(key: key);

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  bool _nameChanged = false;
  List<String> _workoutNames = [];
  
  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateWorkoutNamesList();
      
      // If initialWorkoutName is provided, set it and trigger autofill
      if (widget.initialWorkoutName != null) {
        _nameController.text = widget.initialWorkoutName!;
        _onNameChanged(); // Trigger autofill
      }
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  void _updateWorkoutNamesList() {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    setState(() {
      _workoutNames = workoutProvider.getUniqueWorkoutNames();
    });
  }
  
  void _onNameChanged() {
    setState(() {
      _nameChanged = true;
    });
    
    // Check if the name exists in workout templates for autofill
    if (_nameChanged) {
      final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
      final workoutTemplate = workoutProvider.getWorkoutTemplate(_nameController.text);
      
      if (workoutTemplate != null) {
        setState(() {
          _weightController.text = workoutTemplate.weight.toString();
          _repsController.text = workoutTemplate.reps.toString();
          if (workoutTemplate.notes != null) {
            _notesController.text = workoutTemplate.notes!;
          }
          _nameChanged = false;
        });
      }
    }
  }
  
  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: CupertinoColors.systemBackground,
          child: Column(
            children: [
              Container(
                height: 50,
                color: CupertinoColors.systemGrey6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      child: const Text('Done'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  backgroundColor: CupertinoColors.systemBackground,
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate,
                  minimumDate: DateTime(DateTime.now().year - 2),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (DateTime newDate) {
                    setState(() {
                      _selectedDate = newDate;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _saveWorkout() {
    if (_formKey.currentState!.validate()) {
      final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
      
      final newWorkout = Workout(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        date: _selectedDate,
        weight: double.parse(_weightController.text),
        reps: int.parse(_repsController.text),
        notes: _notesController.text.isNotEmpty ? _notesController.text.trim() : null,
      );
      
      workoutProvider.addWorkout(newWorkout);
      
      // Show success message
      _showSuccessMessage();
      
      // Reset form
      _resetForm();
    }
  }
  
  void _showSuccessMessage() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            height: 220,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            color: CupertinoColors.systemBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Success', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CupertinoColors.activeGreen.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.check_mark,
                        color: CupertinoColors.activeGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Workout added successfully')),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton.filled(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _resetForm() {
    setState(() {
      _nameController.clear();
      _weightController.clear();
      _repsController.clear();
      _notesController.clear();
      _selectedDate = DateTime.now();
    });
  }
  
  void _showSuggestions() {
    if (_workoutNames.isEmpty) return;
    
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: math.min(350, _workoutNames.length * 60.0 + 60),
          decoration: const BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 50,
                decoration: const BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text(
                        'Previous Workouts',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _workoutNames.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: CupertinoColors.systemGrey5,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.arrow_up_left,
                              size: 20,
                              color: CupertinoColors.systemBlue,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _workoutNames[index],
                              style: const TextStyle(
                                fontSize: 16,
                                color: CupertinoColors.label,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          setState(() {
                            _nameController.text = _workoutNames[index];
                            _onNameChanged();
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey5,
            width: 0.5,
          ),
        ),
        middle: Text(
          'Add Workout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Date picker
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 6),
                    child: Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: CupertinoColors.systemGrey4,
                        width: 0.5,
                      ),
                    ),
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      onPressed: _showDatePicker,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                            style: const TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.label,
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.calendar,
                            size: 20,
                            color: CupertinoColors.systemBlue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Workout name with autocomplete
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 6),
                    child: Text(
                      'Exercise Name',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: CupertinoColors.systemGrey4,
                              width: 0.5,
                            ),
                          ),
                          child: CupertinoTextField(
                            controller: _nameController,
                            placeholder: 'e.g. Bench Press',
                            padding: const EdgeInsets.all(12),
                            clearButtonMode: OverlayVisibilityMode.editing,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: CupertinoColors.systemBackground,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CupertinoButton(
                          padding: const EdgeInsets.all(12),
                          onPressed: _showSuggestions,
                          child: const Icon(
                            CupertinoIcons.chevron_down,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Performance details header
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'Performance Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Weight and reps
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 6),
                          child: Text(
                            'Weight (kg)',
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: CupertinoColors.systemGrey4,
                              width: 0.5,
                            ),
                          ),
                          child: CupertinoTextField(
                            controller: _weightController,
                            placeholder: '0.0',
                            padding: const EdgeInsets.all(12),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            clearButtonMode: OverlayVisibilityMode.editing,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: CupertinoColors.systemBackground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 6),
                          child: Text(
                            'Reps',
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: CupertinoColors.systemGrey4,
                              width: 0.5,
                            ),
                          ),
                          child: CupertinoTextField(
                            controller: _repsController,
                            placeholder: '0',
                            padding: const EdgeInsets.all(12),
                            keyboardType: TextInputType.number,
                            clearButtonMode: OverlayVisibilityMode.editing,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: CupertinoColors.systemBackground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Notes
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 6),
                    child: Text(
                      'Notes (optional)',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: CupertinoColors.systemGrey4,
                        width: 0.5,
                      ),
                    ),
                    child: CupertinoTextField(
                      controller: _notesController,
                      placeholder: 'e.g. Felt strong today',
                      padding: const EdgeInsets.all(12),
                      maxLines: 3,
                      clearButtonMode: OverlayVisibilityMode.editing,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: CupertinoColors.systemBackground,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Estimated 1RM Calculator
              if (_weightController.text.isNotEmpty && _repsController.text.isNotEmpty && 
                  double.tryParse(_weightController.text) != null && 
                  int.tryParse(_repsController.text) != null &&
                  int.parse(_repsController.text) > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estimated 1 Rep Max',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_calculateOneRepMax().toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Based on Brzycki formula',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              
              // Save button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      CupertinoColors.systemBlue,
                      CupertinoColors.activeBlue,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  onPressed: _saveWorkout,
                  child: const Text(
                    'Save Workout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  double _calculateOneRepMax() {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final reps = int.tryParse(_repsController.text) ?? 0;
    
    if (weight <= 0 || reps <= 0) return 0;
    if (reps == 1) return weight;
    
    // Brzycki formula
    return weight * (36 / (37 - reps));
  }
}
