import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'screens/todo_list_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/app_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return CupertinoApp(
            title: 'Todo List',
            theme: CupertinoThemeData(
              brightness: Brightness.light,
              primaryColor: appState.theme.accentColor,
              scaffoldBackgroundColor: appState.theme.backgroundColor,
              textTheme: CupertinoTextThemeData(
                primaryColor: appState.theme.textColor,
                textStyle: TextStyle(
                  color: appState.theme.textColor,
                  fontFamily: 'UKIJ',
                ),
              ),
            ),
            home: const TodoListScreen(),
          );
        },
      ),
    );
  }
}
