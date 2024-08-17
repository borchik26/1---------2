// Общий смысл кода:
// RecipeSearchScreen - это экран, который позволяет пользователю искать рецепты по названию или с помощью фильтров. Пользователь может выбрать категорию, блюдо, кухню, меню, время приготовления, сложность, стоимость, сезонность, способ приготовления, добавить или исключить ингредиенты и задать свои предпочтения.
// Также можно сохранить текущий фильтр для быстрого доступа в будущем.


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recipe_detail_screen.dart';
import 'recipes_list_screen.dart';
import '../models/app_state.dart';
import '../constants/list_constants.dart';
import '../utils/launch.dart';
import '../utils/telegram_helper.dart'; // Импортируем TelegramHelper

class RecipeSearchScreen extends StatefulWidget {
  @override
  _RecipeSearchScreenState createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  String? _selectedCategory; // Выбранная категория рецепта
  String? _selectedDish; // Выбранное блюдо
  String? _selectedCuisine; // Выбранная кухня
  String? _selectedMenu; // Выбранное меню (диета)
  String? _selectedCookingTime; // Выбранное время приготовления
  String? _selectedDifficulty; // Выбранная сложность рецепта
  String? _selectedCost; // Выбранная стоимость рецепта
  String? _selectedSeason; // Выбранный сезон
  String? _selectedCookingMethod; // Выбранный способ приготовления
  int _numberOfPeople = 4; // Количество порций
  String _searchQuery = ""; // Строка для хранения запроса поиска по названию

  // Список включенных и исключенных ингредиентов
  final List<String> _includedIngredients = [];
  final List<String> _excludedIngredients = [];
  // Контроллеры текстовых полей для ввода ингредиентов
  final TextEditingController _includeController = TextEditingController();
  final TextEditingController _excludeController = TextEditingController();
  final TextEditingController _preferencesController = TextEditingController(); // Контроллер для ввода предпочтений
  final TextEditingController _filterNameController = TextEditingController(); // Контроллер для ввода имени фильтра
  
  // Список сохраненных фильтров
  List<Map<String, dynamic>> _savedFilters = [];
  
  // Контроллер для ввода названия рецепта
  final TextEditingController _recipeNameController = TextEditingController();

  // Функция поиска рецепта по названию
  void _searchRecipeByName() {
    final recipeName = _searchQuery; // Получение названия рецепта
    // Формирование запроса к модели для получения рецепта
    final prompt =
        'Напиши рецепт "$recipeName" на русском языке. На $_numberOfPeople порций.Точно расчитай ингридиенты по количеству порций. Красиво отформатируй текст. Рецепт должен содержать заголовок с указанием количества порций, время приготовления, подзаголовки: **Ингредиенты:**, **Приготовление:**, **Советы:**.';

    if (recipeName.isNotEmpty) { // Проверка, введено ли название рецепта
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeDetailScreen( // Переход на экран с деталями рецепта
            recipe: prompt, // Передача запроса к модели в качестве аргумента
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Поиск рецептов'), // Заголовок экрана
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Раздел "Поиск по названию блюда"
              Text(
                'Поиск по названию блюда',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _recipeNameController,
                decoration: InputDecoration(
                  labelText: 'Название блюда',
                  hintText: 'Введите название блюда',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value; // Обновление запроса поиска
                  });
                },
              ),
              SizedBox(height: 10),
              // Раздел "На сколько порций?"
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'На сколько порций?',
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_numberOfPeople > 1) { // Уменьшение количества порций
                              _numberOfPeople--;
                            }
                          });
                        },
                        icon: Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '$_numberOfPeople', // Отображение количества порций
                        style: TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _numberOfPeople++; // Увеличение количества порций
                          });
                        },
                        icon: Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton( // Кнопка для поиска рецепта по названию
                  onPressed: _searchRecipeByName,
                  child: Text('Найти'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Divider(height: 20, thickness: 2, color: Colors.purple),
              SizedBox(height: 10),

              // Раздел "Поиск по фильтру"
              Text(
                'Поиск по фильтру',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildCategoryDropdown(
                  'Любая категория', categories, _selectedCategory, (value) { // Выпадающий список для выбора категории
                setState(() {
                  _selectedCategory = value;
                  // Обновление списка блюд в соответствии с выбранной категорией
                  currentDishes = dishesByCategory[value] ?? defaultDishes;
                  _selectedDish = currentDishes.first; // Выбор первого блюда в списке
                  Provider.of<AppState>(context, listen: false)
                      .setSelectedCategory(value!);
                  Provider.of<AppState>(context, listen: false)
                      .setSelectedDish(_selectedDish!); // Обновление выбранного блюда в AppState
                });
              }),

              // Выпадающий список для выбора блюда
              _buildDishDropdown('Любое блюдо', currentDishes, _selectedDish,
                  (value) {
                setState(() {
                  _selectedDish = value;
                  Provider.of<AppState>(context, listen: false)
                      .setSelectedDish(value!);
                });
              }),

              // Выпадающий список для выбора кухни
              _buildCuisineDropdown('Любая кухня', cuisines, _selectedCuisine,
                  (value) {
                setState(() {
                  _selectedCuisine = value;
                  Provider.of<AppState>(context, listen: false)
                      .setSelectedCuisine(value!);
                });
              }),
              // Выпадающие списки для выбора остальных фильтров
              _buildDropdown('Любое меню', menus, _selectedMenu, (value) {
                setState(() {
                  _selectedMenu = value;
                  Provider.of<AppState>(context, listen: false)
                      .setSelectedMenu(value!);
                });
              }),
              _buildDropdown(
                  'Время приготовления', cookingTimes, _selectedCookingTime,
                  (value) {
                setState(() {
                  _selectedCookingTime = value;
                  Provider.of<AppState>(context, listen: false)
                      .setSelectedCookingTime(value!);
                });
              }),
              _buildDropdown('Сложность', difficulties, _selectedDifficulty,
                  (value) {
                setState(() {
                  _selectedDifficulty = value;
                  Provider.of<AppState>(context, listen: false)
                      .setSelectedDifficulty(value!);
                });
              }),
              _buildDropdown('Стоимость ингредиентов', costs, _selectedCost,
                  (value) {
                setState(() {
                  _selectedCost = value;
                  Provider.of<AppState>(context, listen: false)
                      .setSelectedCost(value!);
                });
              }),
              _buildDropdown('Сезонные рецепты', seasons, _selectedSeason,
                  (value) {
                setState(() {
                  _selectedSeason = value;
                  Provider.of<AppState>(context, listen: false)
                      .setSelectedSeason(value!);
                });
              }),
              _buildDropdown('Способ приготовления', cookingMethods,
                  _selectedCookingMethod, (value) {
                setState(() {
                  _selectedCookingMethod = value;
                  Provider.of<AppState>(context, listen: false)
                      .setSelectedCookingMethod(value!);
                });
              }),
              TextField(
                controller: _preferencesController,
                decoration: InputDecoration(
                  labelText: 'Предпочтения',
                  hintText: 'Например, без глютена, кето, низкокалорийные',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                ),
                onChanged: (value) {
                  Provider.of<AppState>(context, listen: false)
                      .setPreferences(value); // Обновление предпочтений в AppState
                },
              ),
              SizedBox(height: 20),
              ElevatedButton( // Кнопка для добавления ингредиентов
                onPressed: () {
                  _showIngredientsDialog(context); // Вызов диалогового окна для ввода ингредиентов
                },
                child: Text('Ингредиенты'),
              ),
              SizedBox(height: 20),
              // Раздел "На сколько порций?" 
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'На сколько порций?',
                    style: TextStyle(fontSize: 16),
                  ),
                  // Изменение количества людей в AppState
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (Provider.of<AppState>(context, listen: false)
                                  .numberOfPeople >
                              1) {
                            Provider.of<AppState>(context, listen: false)
                                .setNumberOfPeople(Provider.of<AppState>(
                                            context,
                                            listen: false)
                                        .numberOfPeople -
                                    1);
                          }
                        },
                        icon: Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '${Provider.of<AppState>(context).numberOfPeople}', // Вывод количества порций
                        style: TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        onPressed: () {
                          Provider.of<AppState>(context, listen: false)
                              .setNumberOfPeople(
                                  Provider.of<AppState>(context, listen: false)
                                          .numberOfPeople +
                                      1);
                        },
                        icon: Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    try {
                      // Переход на экран с результатами поиска
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipesListScreen(
                            selectedCategory: _selectedCategory,
                            selectedDish: _selectedDish,
                            selectedCuisine: _selectedCuisine,
                            selectedMenu: _selectedMenu,
                            selectedCookingTime: _selectedCookingTime,
                            selectedDifficulty: _selectedDifficulty,
                            selectedCost: _selectedCost,
                            selectedSeason: _selectedSeason,
                            selectedCookingMethod:
                                _selectedCookingMethod, // Новое свойство
                            numberOfPeople: _numberOfPeople,
                            includedIngredients:
                                _includedIngredients, // Добавьте это
                            excludedIngredients:
                                _excludedIngredients, // Добавьте это
                            preferences:
                                _preferencesController.text, // Добавьте это
                          ),
                        ),
                      );
                    } catch (e) {
                      // Отправка сообщения в Telegram при ошибке
                      TelegramHelper.sendTelegramError(
                          "Ошибка на экране поиска: $e");
                    }
                  },
                  child: Text('Найти'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton( // Кнопка для сохранения текущего фильтра
                  onPressed: () {
                    try {
                      _showSaveFilterDialog(context); // Вызов диалогового окна для сохранения фильтра
                    } catch (e) {
                      // Отправка сообщения в Telegram при ошибке
                      TelegramHelper.sendTelegramError(
                          "Ошибка при сохранении фильтра: $e");
                    }
                  },
                  child: Text('Сохранить текущий фильтр'),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Сохраненные фильтры',
                style: TextStyle(fontSize: 16),
              ),
              ListView.builder( // Список сохраненных фильтров
                shrinkWrap: true,
                itemCount: _savedFilters.length, // Количество сохраненных фильтров
                itemBuilder: (context, index) {
                  return ListTile( // Элемент списка фильтра
                    title: Text(_savedFilters[index]['name']), // Название фильтра
                    subtitle: Text(_savedFilters[index]['description']), // Описание фильтра
                    onTap: () {
                      try {
                        setState(() {
                          // Загрузка значений фильтра в соответствующие переменные
                          _selectedCategory = _savedFilters[index]['category'];
                          _selectedDish = _savedFilters[index]['dish'];
                          _selectedCuisine = _savedFilters[index]['cuisine'];
                          _selectedMenu = _savedFilters[index]['menu'];
                          _selectedCookingTime =
                              _savedFilters[index]['cookingTime'];
                          _selectedDifficulty =
                              _savedFilters[index]['difficulty'];
                          _selectedCost = _savedFilters[index]['cost'];
                          _selectedSeason = _savedFilters[index]['season'];
                          _selectedCookingMethod =
                              _savedFilters[index]['selectedCookingMethod'];
                          _preferencesController.text =
                              _savedFilters[index]['preferences'];
                          _includedIngredients.clear();
                          _includedIngredients.addAll(
                              _savedFilters[index]['includedIngredients'] ?? []);
                          _excludedIngredients.clear();
                          _excludedIngredients.addAll(
                              _savedFilters[index]['excludedIngredients'] ?? []);
                          _numberOfPeople =
                              _savedFilters[index]['numberOfPeople'];

                          // Обновление состояния в AppState
                          Provider.of<AppState>(context, listen: false)
                              .setSelectedCategory(_selectedCategory);
                          Provider.of<AppState>(context, listen: false)
                              .setSelectedDish(_selectedDish);
                          Provider.of<AppState>(context, listen: false)
                              .setSelectedCuisine(_selectedCuisine);
                          Provider.of<AppState>(context, listen: false)
                              .setSelectedMenu(_selectedMenu);
                          Provider.of<AppState>(context, listen: false)
                              .setSelectedCookingTime(_selectedCookingTime);
                          Provider.of<AppState>(context, listen: false)
                              .setSelectedDifficulty(_selectedDifficulty);
                          Provider.of<AppState>(context, listen: false)
                              .setSelectedCost(_selectedCost);
                          Provider.of<AppState>(context, listen: false)
                              .setSelectedSeason(_selectedSeason);
                          Provider.of<AppState>(context, listen: false)
                              .setPreferences(_preferencesController.text);
                          Provider.of<AppState>(context, listen: false)
                              .setNumberOfPeople(_numberOfPeople);
                        });
                      } catch (e) {
                        // Отправка сообщения в Telegram при ошибке
                        TelegramHelper.sendTelegramError(
                            "Ошибка при загрузке сохраненного фильтра: $e");
                      }
                    },
                  );
                },
              ),

              SizedBox(height: 80), // Добавляем дополнительное пространство внизу
            ],
          ),
        ),
      ),
    );
  }

  // Метод для создания выпадающего списка
  Widget _buildCategoryDropdown(String hint, List<String> items,
      String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.purple),
          ),
        ),
        value: selectedValue,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // Метод для создания выпадающего списка блюд
  Widget _buildDishDropdown(String hint, List<String> items,
      String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.purple),
          ),
        ),
        value: selectedValue,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value),
                // Кнопка поиска картинок для блюда
                if (value != 'Любое блюдо' && _selectedDish != value)
                  IconButton(
                    icon: Icon(Icons.image_search, color: Colors.purple),
                    onPressed: () {
                      openImageSearch(context,
                          'https://yandex.ru/images/search?from=tabbar&text=$value');
                    },
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // Метод для создания выпадающего списка кухонь
  Widget _buildCuisineDropdown(String hint, List<String> items,
      String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.purple),
          ),
        ),
        value: selectedValue,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value),
                // Кнопка поиска картинок для кухни
                if (value != 'Любая кухня' && _selectedCuisine != value)
                  IconButton(
                    icon: Icon(Icons.image_search, color: Colors.purple),
                    onPressed: () {
                      openImageSearch(context,
                          'https://yandex.ru/images/search?from=tabbar&text=$value кухня');
                    },
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // Метод для создания выпадающего списка для остальных фильтров
  Widget _buildDropdown(String hint, List<String> items, String? selectedValue,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.purple),
          ),
        ),
        value: selectedValue,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // Метод для показа диалогового окна для ввода ингредиентов
  void _showIngredientsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Ингредиенты'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ввод включенных ингредиентов
                    _buildIngredientInput('Включить ингредиенты',
                        _includedIngredients, _includeController, (ingredient) {
                      setState(() {
                        _includedIngredients.add(ingredient);
                      });
                    }, setState),
                    // Ввод исключенных ингредиентов
                    _buildIngredientInput('Исключить ингредиенты',
                        _excludedIngredients, _excludeController, (ingredient) {
                      setState(() {
                        _excludedIngredients.add(ingredient);
                      });
                    }, setState),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      // Очистка списков ингредиентов
                      _includedIngredients.clear();
                      _excludedIngredients.clear();
                    });
                    Navigator.of(context).pop(); // Закрытие диалогового окна
                  },
                  child: Text('Очистить всё'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Закрытие диалогового окна
                  },
                  child: Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Метод для показа диалогового окна для сохранения фильтра
  void _showSaveFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Сохранить фильтр'),
          content: TextField(
            controller: _filterNameController,
            decoration: InputDecoration(
              labelText: 'Имя фильтра',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.purple),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Отмена сохранения фильтра
              },
              child: Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                try {
                  setState(() {
                    // Сохранение фильтра
                    _savedFilters.add({
                      'name': _filterNameController.text, // Название фильтра
                      'description': _generateFilterDescription(), // Описание фильтра
                      'category': _selectedCategory, // Выбранная категория
                      'dish': _selectedDish, // Выбранное блюдо
                      'cuisine': _selectedCuisine, // Выбранная кухня
                      'menu': _selectedMenu, // Выбранное меню
                      'cookingTime': _selectedCookingTime, // Выбранное время приготовления
                      'difficulty': _selectedDifficulty, // Выбранная сложность
                      'cost': _selectedCost, // Выбранная стоимость
                      'season': _selectedSeason, // Выбранный сезон
                      'selectedCookingMethod': _selectedCookingMethod, // Выбранный способ приготовления
                      'preferences': _preferencesController.text, // Предпочтения
                      'numberOfPeople': _numberOfPeople, // Количество порций
                      'includedIngredients':
                          List<String>.from(_includedIngredients),
                      'excludedIngredients':
                          List<String>.from(_excludedIngredients),
                    });
                    _filterNameController.clear(); // Очистка поля ввода названия фильтра
                  });
                  Navigator.of(context).pop(); // Закрытие диалогового окна
                } catch (e) {
                  // Отправка сообщения в Telegram при ошибке
                  TelegramHelper.sendTelegramError(
                      "Ошибка при сохранении фильтра: $e");
                }
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  // Генерация описания фильтра
  String _generateFilterDescription() {
    List<String> parts = [];
    if (_selectedCategory != null) parts.add('Категория: $_selectedCategory');
    if (_selectedDish != null) parts.add('Блюдо: $_selectedDish');
    if (_selectedCuisine != null) parts.add('Кухня: $_selectedCuisine');
    if (_selectedMenu != null) parts.add('Меню: $_selectedMenu');
    if (_selectedCookingTime != null) parts.add('Время: $_selectedCookingTime');
    if (_selectedDifficulty != null)
      parts.add('Сложность: $_selectedDifficulty');
    if (_selectedCost != null) parts.add('Стоимость: $_selectedCost');
    if (_selectedSeason != null) parts.add('Сезон: $_selectedSeason');
    if (_selectedCookingMethod != null)
      parts.add('Способ приготовления: $_selectedCookingMethod');
    if (_preferencesController.text.isNotEmpty)
      parts.add('Предпочтения: ${_preferencesController.text}');
    if (_includedIngredients.isNotEmpty)
      parts.add(
          'Включенные ингредиенты: ${_includedIngredients.join(', ')}');
    if (_excludedIngredients.isNotEmpty)
      parts.add(
          'Исключенные ингредиенты: ${_excludedIngredients.join(', ')}');
    return parts.join(', '); // Возвращение сформированного описания
  }

  // Метод для создания виджета ввода ингредиентов
  Widget _buildIngredientInput(
      String label,
      List<String> ingredients,
      TextEditingController controller,
      Function(String) onAdd,
      StateSetter dialogSetState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: label.contains('Включить')
                      ? '+ Ингредиент'
                      : '- Ингредиент',
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  onAdd(controller.text); // Добавление ингредиента в список
                  controller.clear(); // Очистка поля ввода
                }
              },
            ),
          ],
        ),
        Wrap(
          spacing: 8.0,
          children: ingredients.map((ingredient) {
            return Chip(
              label: Text(ingredient),
              onDeleted: () {
                dialogSetState(() {
                  ingredients.remove(ingredient); // Удаление ингредиента из списка
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}