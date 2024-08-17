// Общий смысл кода:
// HomeScreen - это главный экран приложения, который содержит навигацию и нижнюю панель. CustomNavigator - это виджет для управления навигацией. BottomNavBar - это нижняя панель навигации. Все эти виджеты используют Consumer для доступа к состоянию приложения, которое хранится в AppState.


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../utils/telegram_helper.dart'; 
import 'recipe_search_screen.dart';
import 'favorites_screen.dart';
import 'shopping_list_screen.dart';
import 'recipes_list_screen.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomNavigator(), // Виджет для навигации по экранам приложения
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavBar(), // Виджет нижней панели навигации
          ),
        ],
      ),
    );
  }
}

class CustomNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>( // Используем Consumer для доступа к состоянию приложения
      builder: (context, appState, _) {
        return Navigator(
          key: appState.navigatorKey, // Ключ для управления навигацией
          initialRoute: '/', // Начальный маршрут
          onGenerateRoute: (RouteSettings settings) {
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
                        numberOfPeople: appState.numberOfPeople, // Используем данные о количестве людей из AppState
                        includedIngredients: appState.includedIngredients, 
                        excludedIngredients: appState.excludedIngredients,
                        preferences: appState.preferences!,
                      );
                  break;
                case '/recipe_detail': // Маршрут для экрана с деталями рецепта
                  final recipe = settings.arguments as String; // Получаем данные о рецепте из аргументов маршрута
                  builder = (BuildContext _) => RecipeDetailScreen(recipe: recipe);
                  break;
                default:
                  throw Exception('Invalid route: ${settings.name}'); // Выбрасываем исключение, если маршрут не найден
              }
              return MaterialPageRoute(builder: builder, settings: settings); // Создание MaterialPageRoute для перехода к нужному экрану
            } catch (e) {
              print("Error generating route: ${settings.name}, Error: $e");
              TelegramHelper.sendTelegramError("Error generating route: ${settings.name}, Error: $e"); // Отправка сообщения в Telegram о возникшей ошибке
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: Center(child: Text('Error: Invalid route')),
                ),
              );
            }
          },
        );
      },
    );
  }
}

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>( // Используем Consumer для доступа к состоянию приложения
      builder: (context, appState, _) {
        return BottomNavigationBar(
          currentIndex: appState.selectedIndex, // Индекс выбранного элемента
          onTap: (index) {
            try {
              appState.setSelectedIndex(index); // Изменение индекса выбранного элемента
              switch (index) {
                case 0: // Первый элемент - экран поиска
                  appState.navigatorKey.currentState?.pushReplacementNamed('/');
                  break;
                case 1: // Второй элемент - экран избранных рецептов
                  appState.navigatorKey.currentState?.pushReplacementNamed('/favorites');
                  break;
                case 2: // Третий элемент - экран списка покупок
                  appState.navigatorKey.currentState?.pushReplacementNamed('/shopping_list');
                  break;
              }
            } catch (e) {
              print("Error navigating to index $index: $e");
              TelegramHelper.sendTelegramError("Error navigating to index $index: $e"); // Отправка сообщения в Telegram о возникшей ошибке
            }
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
}