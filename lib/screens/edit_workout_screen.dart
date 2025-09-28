import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';

class EditWorkoutScreen extends StatefulWidget {
  final Workout workout;

  const EditWorkoutScreen({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late TextEditingController _notesController;
  
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with workout data
    _nameController = TextEditingController(text: widget.workout.name);
    _weightController = TextEditingController(text: widget.workout.weight.toString());
    _repsController = TextEditingController(text: widget.workout.reps.toString());
    _notesController = TextEditingController(text: widget.workout.notes ?? '');
    
    _selectedDate = widget.workout.date;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    _notesController.dispose();
    super.dispose();
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
      
      final updatedWorkout = Workout(
        id: widget.workout.id,
        name: _nameController.text.trim(),
        date: _selectedDate,
        weight: double.parse(_weightController.text),
        reps: int.parse(_repsController.text),
        notes: _notesController.text.isNotEmpty ? _notesController.text.trim() : null,
      );
      
      workoutProvider.updateWorkout(updatedWorkout);
      
      // Show success message
      _showSuccessMessage();
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
                    const Expanded(child: Text('Workout updated successfully')),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton.filled(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeletion(BuildContext context) async {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            height: 240,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            color: CupertinoColors.systemBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Delete "${widget.workout.name}"?', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('This action cannot be undone.'),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      color: CupertinoColors.destructiveRed,
                      child: const Text('Delete'),
                      onPressed: () {
                        workoutProvider.deleteWorkout(widget.workout.id);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        border: const Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey5,
            width: 0.5,
          ),
        ),
        middle: const Text(
          'Edit Workout',
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
              
              // Workout name
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
                        style: TextStyle(
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
                    'Update Workout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Delete button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CupertinoColors.destructiveRed,
                    width: 1.5,
                  ),
                ),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onPressed: () => _confirmDeletion(context),
                  child: const Text(
                    'Delete Workout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.destructiveRed,
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
