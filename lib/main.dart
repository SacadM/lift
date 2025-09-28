import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/workout_provider.dart';
import 'providers/diet_provider.dart';
import 'providers/ingredient_provider.dart';
import 'providers/meal_template_provider.dart';
import 'screens/workouts_screen.dart';
import 'screens/diet_overview_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LiftApp());
}

class LiftApp extends StatelessWidget {
  const LiftApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => DietProvider()),
        ChangeNotifierProvider(create: (_) => IngredientProvider()),
        ChangeNotifierProvider(create: (_) => MealTemplateProvider()),
      ],
      child: const CupertinoApp(
        debugShowCheckedModeBanner: false,
        title: 'Lift',
        theme: CupertinoThemeData(
          primaryColor: CupertinoColors.systemBlue,
          brightness: Brightness.light,
        ),
        home: MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.sportscourt), label: 'Workouts'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.square_split_2x2), label: 'Diet'),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 1:
            return const WorkoutsScreen();
          case 0:
            return const DietOverviewScreen();
          default:
            return const DietOverviewScreen();
        }
      },
    );
  }
}
