import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import 'add_workout_screen.dart';
import 'workout_progress_screen.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final workoutNames = workoutProvider.getUniqueWorkoutNames();
    
    // Filter workout names based on search query
    final filteredWorkoutNames = workoutNames
        .where((name) => name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
    
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
          'Workouts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => const AddWorkoutScreen(),
              ),
            );
          },
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CupertinoSearchTextField(
                  placeholder: 'Search workouts',
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ),
            
            Expanded(
              child: workoutNames.isEmpty
                  ? _buildEmptyState()
                  : filteredWorkoutNames.isEmpty
                      ? _buildNoResultsState()
                      : _buildWorkoutsList(filteredWorkoutNames, workoutProvider),
            ),
          ],
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
            CupertinoIcons.sportscourt,
            size: 80,
            color: CupertinoColors.systemGrey.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          const Text(
            'No workouts yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start tracking your progress by adding\nyour first workout.',
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.search,
            size: 60,
            color: CupertinoColors.systemGrey.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No results for "$_searchQuery"',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a different search term.',
            style: TextStyle(
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWorkoutsList(List<String> workoutNames, WorkoutProvider workoutProvider) {
    return ListView.builder(
      itemCount: workoutNames.length,
      itemBuilder: (context, index) {
        final workoutName = workoutNames[index];
        final pr = workoutProvider.getPersonalRecord(workoutName);
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => WorkoutProgressScreen(workoutName: workoutName),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Exercise icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: CupertinoColors.activeBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        _getExerciseIcon(workoutName),
                        color: CupertinoColors.activeBlue,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Exercise details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workoutName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.label,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (pr != null) ...[
                          Text(
                            'Best: ${pr.weight.toStringAsFixed(1)} kg × ${pr.reps} reps',
                            style: const TextStyle(
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Estimated 1RM: ${pr.estimatedOneRepMax.toStringAsFixed(1)} kg',
                            style: TextStyle(
                              color: CupertinoColors.activeBlue,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'No records yet',
                            style: TextStyle(
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Arrow icon
                  const Icon(
                    CupertinoIcons.chevron_right,
                    color: CupertinoColors.systemGrey,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  IconData _getExerciseIcon(String workoutName) {
    final name = workoutName.toLowerCase();
    
    if (name.contains('bench') || name.contains('press') || name.contains('chest')) {
      return CupertinoIcons.person_crop_rectangle;
    } else if (name.contains('squat') || name.contains('leg')) {
      return CupertinoIcons.arrow_down_right_arrow_up_left;
    } else if (name.contains('deadlift') || name.contains('back')) {
      return CupertinoIcons.arrow_up;
    } else if (name.contains('curl') || name.contains('bicep')) {
      return CupertinoIcons.arrow_up_right;
    } else if (name.contains('row')) {
      return CupertinoIcons.arrow_left_right;
    } else if (name.contains('pull')) {
      return CupertinoIcons.arrow_down;
    } else if (name.contains('run') || name.contains('cardio')) {
      return CupertinoIcons.speedometer;
    }
    
    return CupertinoIcons.sportscourt;
  }
}