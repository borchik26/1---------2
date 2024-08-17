// Этот файл содержит класс TelegramHelper, который предоставляет функцию sendTelegramError для отправки сообщений об ошибках в Telegram.
// Функция получает текст ошибки и информацию об устройстве, формирует сообщение и отправляет его в заданный чат Telegram.
// Для записи ошибок в консоль используется логгер Logger.



import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io'; // Import for Platform
import 'package:logger/logger.dart'; // Import logger package

class TelegramHelper {
  // Токен бота Telegram
  static const String _telegramBotToken =
      "7247841674:AAF0jSv8q6aOdkzCKwpI9nDtm7xnwDoLwrE";
  // ID чата, куда будут отправляться сообщения
  static const int _telegramChatId = 346967554;
  // Экземпляр логгера для записи ошибок
  static final Logger _logger = Logger();

  // Статическая функция для отправки сообщения об ошибке в Telegram
  static Future<void> sendTelegramError(String errorMessage) async {
    try {
      // Получение информации об устройстве
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      Map<String, dynamic> deviceData = {};

      if (Platform.isAndroid) {
        deviceData = (await deviceInfo.androidInfo).toMap();
      } else if (Platform.isIOS) {
        deviceData = (await deviceInfo.iosInfo).toMap();
      } else {
        deviceData = {"platform": "Unknown"};
      }

      // Формирование строки с информацией об устройстве
      String deviceInfoString =
          "Device: ${deviceData["model"]} (${deviceData["manufacturer"]}), OS: ${deviceData["systemVersion"]}";

      // Формирование сообщения для отправки
      String message = 'Ошибка в приложении: $errorMessage\n'
          'Информация об устройстве:\n'
          '$deviceInfoString';

      // Отправка сообщения в Telegram
      final response = await http.post(
        Uri.parse('https://api.telegram.org/bot$_telegramBotToken/sendMessage'),
        body: {
          'chat_id': _telegramChatId.toString(),
          'text': message,
        },
      );

      // Проверка успешности отправки сообщения
      if (response.statusCode != 200) {
        _logger.e("Ошибка отправки сообщения в Telegram: ${response.body}");
      }
    } catch (e) {
      // Запись ошибки в логгер
      _logger.e("Ошибка отправки сообщения в Telegram: $e");
    }
  }
}