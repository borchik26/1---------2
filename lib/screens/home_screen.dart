// Общий смысл кода:
// HomeScreen - это главный экран приложения, который содержит навигацию и нижнюю панель. CustomNavigator - это виджет для управления навигацией. BottomNavBar - это нижняя панель навигации. Все эти виджеты используют Consumer для доступа к состоянию приложения, которое хранится в AppState.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/myrouteobserver.dart';
import '../utils/telegram_helper.dart';
import 'recipe_search_screen.dart';
import 'favorites_screen.dart';
import 'shopping_list_screen.dart';
import 'recipes_list_screen.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var appState;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return PopScope(
          canPop: false,
          onPopInvoked: (v) {
            // var index = appState.selectedIndex;
            // onTap(0);
            Navigator.pop(context);
          },
          child: const Scaffold(
            body: Stack(
              children: [
                CustomNavigator(), // Виджет для навигации по экранам приложения
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BottomNavBar(), // Виджет нижней панели навигации
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  onTap(index) {
    // appState.setSelectedIndex(index); // Изменение индекса выбранного элемента
    String routeName;
    switch (index) {
      case 0:
        routeName = '/';
        break;
      case 1:
        routeName = '/favorites';
        break;
      case 2:
        routeName = '/shopping_list';
        break;
      default:
        routeName = '/';
        break;
    }
    appState.navigatorKey.currentState?.pushNamed(routeName);
  }
}

class CustomNavigator extends StatelessWidget {
  const CustomNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      // Используем Consumer для доступа к состоянию приложения
      builder: (context, appState, _) {
        appState = appState;
        return Navigator(
          key: appState.navigatorKey, // Ключ для управления навигацией
          initialRoute: '/', // Начальный маршрут
          observers: <NavigatorObserver>[
            MyRouteObserver(), // this will listen all changes
          ],
          onGenerateRoute: (RouteSettings settings) {
            return _generateRoute(settings, appState);
          },
        );
      },
    );
  }
}

Route<dynamic> _generateRoute(RouteSettings settings, AppState appState) {
  try {
    WidgetBuilder builder; // Функция-строитель виджетов
    switch (settings.name) {
      case '/': // Маршрут для экрана поиска рецептов
        builder = (BuildContext _) => RecipeSearchScreen();
        break;
      case '/favorites': // Маршрут для экрана избранных рецептов
        builder = (BuildContext _) => FavoritesScreen();
        break;
      case '/shopping_list': // Маршрут для экрана списка покупок
        builder = (BuildContext _) => ShoppingListScreen();
        break;
      case '/recipes_list': // Маршрут для экрана списка рецептов
        builder = (BuildContext _) => RecipesListScreen(
              selectedCategory: appState.selectedCategory,
              selectedDish: appState.selectedDish,
              selectedCuisine: appState.selectedCuisine,
              selectedMenu: appState.selectedMenu,
              selectedCookingTime: appState.selectedCookingTime,
              selectedDifficulty: appState.selectedDifficulty,
              selectedCost: appState.selectedCost,
              selectedSeason: appState.selectedSeason,
              selectedCookingMethod: appState.selectedCookingMethod,
              numberOfPeople: appState.numberOfPeople,
              // Используем данные о количестве людей из AppState
              includedIngredients: appState.includedIngredients,
              excludedIngredients: appState.excludedIngredients,
              preferences: appState.preferences!,
            );
        break;
      case '/recipe_detail': // Маршрут для экрана с деталями рецепта
        final recipe = settings.arguments
            as String; // Получаем данные о рецепте из аргументов маршрута
        builder = (BuildContext _) => RecipeDetailScreen(recipe: recipe);
        break;
      default:
        throw Exception(
            'Invalid route: ${settings.name}'); // Выбрасываем исключение, если маршрут не найден
    }
    return MaterialPageRoute(
        builder: builder,
        settings:
            settings); // Создание MaterialPageRoute для перехода к нужному экрану
  } catch (e) {
    return _handleError(settings, e);
  }
}

Route<dynamic> _handleError(RouteSettings settings, Object e) {
  if (kDebugMode) {
    print("Error generating route: ${settings.name}, Error: $e");
  }
  TelegramHelper.sendTelegramError(
      "Error generating route: ${settings.name}, Error: $e"); // Отправка сообщения в Telegram о возникшей ошибке
  return MaterialPageRoute(
    builder: (context) => const Scaffold(
      body: Center(child: Text('Error: Invalid route')),
    ),
  );
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      // Используем Consumer для доступа к состоянию приложения
      builder: (context, appState, _) {
        return BottomNavigationBar(
          currentIndex: appState.selectedIndex,
          // Индекс выбранного элемента
          onTap: (index) {
            _onTap(index, appState);
          },
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Поиск',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Избранное',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Список покупок',
            ),
          ],
        );
      },
    );
  }

  void _onTap(int index, AppState appState) {
    try {
      appState.setSelectedIndex(index); // Изменение индекса выбранного элемента
      String routeName;
      switch (index) {
        case 0:
          routeName = '/';
          break;
        case 1:
          routeName = '/favorites';
          break;
        case 2:
          routeName = '/shopping_list';
          break;
        default:
          routeName = '/';
          break;
      }
      appState.navigatorKey.currentState?.pushNamed(routeName);
    } catch (e) {
      print("Error navigating to index $index: $e");
      TelegramHelper.sendTelegramError(
          "Error navigating to index $index: $e"); // Отправка сообщения в Telegram о возникшей ошибке
    }
  }
}
