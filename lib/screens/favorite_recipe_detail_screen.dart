// Общий смысл кода:
// FavoriteRecipeDetailScreen - это экран, который показывает детальную информацию о рецепте из "Избранного". Он предоставляет возможность добавить ингредиенты в список покупок, найти видео рецепта и картинки блюда, а также поделиться рецептом и заказать готовое блюдо.


import 'package:flutter/material.dart';
import '../utils/order_menu_utils.dart'; // Импортируем утилиту для отображения меню заказа
import '../utils/launch.dart'; // Импортируем утилиты для запуска внешних приложений
import '../utils/add_to_shopping_list.dart'; // Импортируем утилиту для добавления ингредиентов в список покупок
import '../utils/share_recipe.dart'; // Импортируем утилиту для обмена рецептом

class FavoriteRecipeDetailScreen extends StatelessWidget {
  final Map<String, String> recipe; // Хранит данные о рецепте

  const FavoriteRecipeDetailScreen({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['title']!), // Заголовок экрана - название рецепта
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipe['title']!, // Вывод названия рецепта
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton.icon(
              icon: Icon(Icons.add_shopping_cart), // Кнопка для добавления ингредиентов в список покупок
              label: Text('Добавить ингредиенты в список покупок'),
              onPressed: () => addToShoppingList(context, recipe), // Вызов функции addToShoppingList для добавления ингредиентов в список покупок
            ),
            const SizedBox(height: 16.0),
            Text(
              recipe['details']!, // Вывод подробного описания рецепта
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16.0),
            Row( // Кнопки для запуска внешних приложений
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.video_library), // Кнопка для поиска видео рецепта
                  label: Text('Видео рецепта'),
                  onPressed: () => launchYouTube(context, recipe['title']!), // Вызов функции launchYouTube для поиска видео рецепта на YouTube
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.image), // Кнопка для поиска картинок блюда
                  label: Text('Картинки блюда'),
                  onPressed: () => launchYandexImages(context, recipe['title']!), // Вызов функции launchYandexImages для поиска картинок блюда в Яндекс Картинках
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Center(
              child: Column( // Кнопки для обмена рецептом и заказа готового блюда
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.share), // Кнопка для обмена рецептом
                    label: Text('Поделиться рецептом'),
                    onPressed: () => shareRecipe(context, recipe), // Вызов функции shareRecipe для обмена рецептом
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton.icon(
                    icon: Icon(Icons.shopping_cart), // Кнопка для заказа готового блюда
                    label: Text('Заказать готовое блюдо'),
                    // Используем метод из utils для отображения меню заказа
                    onPressed: () => showOrderMenu(context, recipe), // Вызов функции showOrderMenu для отображения меню заказа
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}