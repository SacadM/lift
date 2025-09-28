import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';
import 'add_workout_screen.dart';
import 'edit_workout_screen.dart';
import '../widgets/workout_chart.dart';

class WorkoutProgressScreen extends StatefulWidget {
  final String workoutName;
  
  const WorkoutProgressScreen({
    Key? key,
    required this.workoutName,
  }) : super(key: key);

  @override
  State<WorkoutProgressScreen> createState() => _WorkoutProgressScreenState();
}

class _WorkoutProgressScreenState extends State<WorkoutProgressScreen> {
  bool _showWeight = true; // Toggle between weight and estimated 1RM
  
  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final workouts = workoutProvider.getWorkoutsByName(widget.workoutName);
    final personalRecord = workoutProvider.getPersonalRecord(widget.workoutName);
    
    // Calculate total workouts and average weight
    final totalWorkouts = workouts.length;
    double averageWeight = 0;
    double averageReps = 0;
    
    if (totalWorkouts > 0) {
      double totalWeight = 0;
      double totalReps = 0;
      for (var workout in workouts) {
        totalWeight += workout.weight;
        totalReps += workout.reps;
      }
      averageWeight = totalWeight / totalWorkouts;
      averageReps = totalReps / totalWorkouts;
    }
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        border: const Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey5,
            width: 0.5,
          ),
        ),
        middle: Text(
          widget.workoutName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => AddWorkoutScreen(
                  initialWorkoutName: widget.workoutName,
                ),
                fullscreenDialog: true,
              ),
            );
          },
        ),
      ),
      child: SafeArea(
        child: workouts.isEmpty
            ? _buildEmptyState()
            : _buildProgressContent(
                workouts, 
                totalWorkouts, 
                averageWeight, 
                averageReps, 
                personalRecord,
                workoutProvider
              ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.graph_circle,
            size: 80,
            color: CupertinoColors.systemGrey.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No ${widget.workoutName} workouts yet',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first workout to start\ntracking your progress.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            child: const Text('Add First Workout'),
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => const AddWorkoutScreen(),
                  fullscreenDialog: true,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressContent(
    List<Workout> workouts,
    int totalWorkouts,
    double averageWeight,
    double averageReps,
    Workout? personalRecord,
    WorkoutProvider workoutProvider,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Summary cards
        Row(
          children: [
            _buildSummaryCard(
              'Total',
              '$totalWorkouts',
              'workouts',
              CupertinoColors.activeBlue,
              CupertinoIcons.chart_bar,
            ),
            const SizedBox(width: 12),
            _buildSummaryCard(
              'Avg Weight',
              averageWeight.toStringAsFixed(1),
              'kg',
              CupertinoColors.activeOrange,
              CupertinoIcons.arrow_up_right_square,
            ),
            const SizedBox(width: 12),
            _buildSummaryCard(
              'Avg Reps',
              averageReps.toStringAsFixed(1),
              'reps',
              CupertinoColors.activeGreen,
              CupertinoIcons.repeat,
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Personal Record
        if (personalRecord != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey4.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        CupertinoIcons.star_fill,
                        color: CupertinoColors.systemYellow,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Personal Record',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Weight',
                          style: TextStyle(
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${personalRecord.weight.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: CupertinoColors.systemGrey5,
                    ),
                    Column(
                      children: [
                        const Text(
                          'Reps',
                          style: TextStyle(
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${personalRecord.reps}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: CupertinoColors.systemGrey5,
                    ),
                    Column(
                      children: [
                        const Text(
                          'Est. 1RM',
                          style: TextStyle(
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${personalRecord.estimatedOneRepMax.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        
        // Progress Chart
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey4.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CupertinoSegmentedControl<bool>(
                    children: const {
                      true: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Weight'),
                      ),
                      false: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('1RM'),
                      ),
                    },
                    groupValue: _showWeight,
                    onValueChanged: (value) {
                      setState(() {
                        _showWeight = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: WorkoutChart(
                  workouts: workouts,
                  showWeight: _showWeight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Recent workouts header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Text(
            'Recent Workouts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // Recent workouts list
        for (var workout in workouts.reversed.take(5))
          _buildWorkoutItem(context, workout, workoutProvider),
        
        // Show more button if there are more than 5 workouts
        if (workouts.length > 5) ...[
          const SizedBox(height: 16),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: CupertinoColors.systemBlue,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'View All Workouts',
                  style: TextStyle(
                    color: CupertinoColors.systemBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            onPressed: () {
              // Show all workouts in a modal
              _showAllWorkouts(workouts, workoutProvider);
            },
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildSummaryCard(String title, String value, String unit, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey4.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWorkoutItem(BuildContext context, Workout workout, WorkoutProvider workoutProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey4.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoContextMenu(
        actions: [
          CupertinoContextMenuAction(
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Edit'),
                Icon(CupertinoIcons.pencil),
              ],
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToEditWorkout(context, workout);
            },
          ),
          CupertinoContextMenuAction(
            isDestructiveAction: true,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Delete'),
                Icon(CupertinoIcons.delete),
              ],
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await _confirmDeletion(context, workout, workoutProvider);
            },
          ),
        ],
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _navigateToEditWorkout(context, workout),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Date column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM d').format(workout.date),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemBlue,
                      ),
                    ),
                    Text(
                      DateFormat('yyyy').format(workout.date),
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Container(
                  height: 40,
                  width: 1,
                  color: CupertinoColors.systemGrey5,
                ),
                const SizedBox(width: 16),
                
                // Weight and reps
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Weight',
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${workout.weight.toStringAsFixed(1)} kg',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Reps',
                            style: TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${workout.reps}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Estimated 1RM
                Column(
                  children: [
                    const Text(
                      'Est. 1RM',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${workout.estimatedOneRepMax.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _navigateToEditWorkout(BuildContext context, Workout workout) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => EditWorkoutScreen(workout: workout),
      ),
    );
  }
  
  Future<void> _confirmDeletion(BuildContext context, Workout workout, WorkoutProvider workoutProvider) async {
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
                const Text('Delete Workout', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Are you sure you want to delete this ${widget.workoutName} workout from ${DateFormat('MMM d, yyyy').format(workout.date)}?'),
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
                        workoutProvider.deleteWorkout(workout.id);
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
  
  void _showAllWorkouts(List<Workout> workouts, WorkoutProvider workoutProvider) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'All ${widget.workoutName} Workouts',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    // Show in reverse chronological order (newest first)
                    final workout = workouts[workouts.length - 1 - index];
                    return _buildWorkoutItem(context, workout, workoutProvider);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
