import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'application/courses/courses_cubit.dart';
import 'application/theme/theme_cubit.dart';
import 'data/repositories/course_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'presentation/router/app_router.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final progressRepo = ProgressRepository();
  await progressRepo.init();
  final isDark = await progressRepo.getIsDarkMode();

  final courseRepo = CourseRepository();

  runApp(MyApp(
    courseRepository: courseRepo,
    progressRepository: progressRepo,
    initialIsDark: isDark,
  ));
}

class MyApp extends StatelessWidget {
  final ICourseRepository courseRepository;
  final IProgressRepository progressRepository;
  final bool initialIsDark;

  const MyApp({
    super.key,
    required this.courseRepository,
    required this.progressRepository,
    this.initialIsDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ICourseRepository>.value(value: courseRepository),
        RepositoryProvider<IProgressRepository>.value(
          value: progressRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(
              progressRepository: progressRepository,
              initialIsDark: initialIsDark,
            ),
          ),
          BlocProvider<CoursesCubit>(
            create: (context) => CoursesCubit(
              courseRepository: courseRepository,
              progressRepository: progressRepository,
            ),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              title: 'ذهين - منصة التعليم الطبي',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              routerConfig: appRouter,
              locale: const Locale('ar'),
              supportedLocales: const [Locale('ar'), Locale('en')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            );
          },
        ),
      ),
    );
  }
}
