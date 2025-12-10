import os
import sys
import time
import json
import requests
from datetime import datetime

from config import API_KEY, BASE_URL, REQUEST_TIMEOUT_SECONDS, MIN_REQUEST_INTERVAL_SECONDS, LOG_DIR, CITIES
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QLibraryInfo, QUrl, QObject, Signal, Slot

_last_request_time = {}

# Путь к файлу с сохранёнными настройками
SETTINGS_FILE = os.path.join(os.path.dirname(__file__), "data", "settings.json")


# ===== ФУНКЦИИ ДЛЯ СОХРАНЕНИЯ И ЗАГРУЗКИ НАСТРОЕК =====
def save_settings(theme: bool, city: str, city_ru: str):
    """Сохраняет выбранную тему и город в JSON файл"""
    os.makedirs(os.path.dirname(SETTINGS_FILE), exist_ok=True)
    
    settings = {
        "isDarkTheme": theme,
        "selectedCity": city,
        "selectedCityRu": city_ru
    }
    
    try:
        with open(SETTINGS_FILE, 'w', encoding='utf-8') as f:
            json.dump(settings, f, ensure_ascii=False, indent=4)
    except Exception as e:
        log_error("settings", f"Error saving settings: {e}")


def load_settings():
    """Загружает сохранённые настройки из JSON файла"""
    if not os.path.isfile(SETTINGS_FILE):
        return None
    
    try:
        with open(SETTINGS_FILE, 'r', encoding='utf-8') as f:
            settings = json.load(f)
            return settings
    except Exception as e:
        log_error("settings", f"Error loading settings: {e}")
        return None


# ===== ФУНКЦИИ ДЛЯ ОПРЕДЕЛЕНИЯ КАТЕГОРИИ AQI И РЕКОМЕНДАЦИЙ =====
def get_aqi_category(aqi_value):
    """Определяет категорию качества воздуха по AQI"""
    if aqi_value <= 1:
        return "Отличное", "#4caf50"  # Зелёный
    elif aqi_value <= 2:
        return "Хорошее", "#8bc34a"  # Светло-зелёный
    elif aqi_value <= 3:
        return "Умеренное", "#ffc107"  # Жёлтый
    elif aqi_value <= 4:
        return "Вредное", "#ff9800"  # Оранжевый
    else:
        return "Опасное", "#f44336"  # Красный


def get_recommendations(aqi_value, pollutants):
    """Генерирует рекомендации на основе AQI и загрязнителей"""
    
    pm2_5 = pollutants.get('pm2_5', 0)
    pm10 = pollutants.get('pm10', 0)
    o3 = pollutants.get('o3', 0)
    
    recommendations = []
    
    if aqi_value <= 1:
        recommendations.append("Отличный день! Воздух чистый.")
        recommendations.append("Идеальны для прогулок и спорта на свежем воздухе.")
    elif aqi_value <= 2:
        recommendations.append("Воздух в хорошем состоянии.")
        recommendations.append("Можно спокойно гулять и заниматься спортом.")
    elif aqi_value <= 3:
        recommendations.append("Воздух в умеренном состоянии.")
        if pm2_5 > 20:
            recommendations.append("⚠ Людям с чувствительностью дыхания стоит ограничить активность на улице.")
        else:
            recommendations.append("Можно гулять, но рекомендуется избегать интенсивной физической активности.")
    elif aqi_value <= 4:
        recommendations.append("⚠ Воздух вредный!")
        recommendations.append("Рекомендуется ограничить время на улице.")
        
        if pm2_5 > 35:
            recommendations.append("Используйте маску N95 при выходе на улицу.")
        
        if o3 > 100:
            recommendations.append("⚠ Высокая концентрация озона - люди с астмой должны остаться дома.")
        
        recommendations.append("Закройте окна дома и используйте очиститель воздуха если есть.")
    else:
        recommendations.append("🚨 ОПАСНЫЙ УРОВЕНЬ ЗАГРЯЗНЕНИЯ!")
        recommendations.append("❌ НЕ ВЫХОДИТЕ НА УЛИЦУ БЕЗ НЕОБХОДИМОСТИ!")
        recommendations.append("Используйте маску N95 и избегайте физической активности.")
        recommendations.append("Закройте все окна и двери. Включите очиститель воздуха.")
        
        if pm2_5 > 50:
            recommendations.append("⚠ Экстремально высокий уровень PM₂.₅ - риск для здоровья!")
        
        if o3 > 150:
            recommendations.append("⚠ Люди с респираторными заболеваниями и пожилые люди должны остаться дома!")
    
    return " ".join(recommendations)


# Контроллер для взаимодействия с QML
class Controller(QObject):
    continueClicked = Signal()
    citySelected = Signal(str)  # Сигнал для выбора города

    def __init__(self, engine):
        super().__init__()
        self.engine = engine
        self.main_window = None

    @Slot()
    def on_continue_clicked(self):
        """Обработчик нажатия кнопки "Продолжить" из QML"""
        self.continueClicked.emit()
        self.go_to_city_selection()
    
    def go_to_city_selection(self):
        """Переходит на экран выбора города"""
        if self.main_window:
            self.main_window.setProperty('currentScreen', 'city-selection')
    
    @Slot(str)
    def on_city_selected(self, city_name):
        """Обработчик выбора города"""
        self.citySelected.emit(city_name)

    @Slot(str)
    def save_user_preferences(self, city_name):
        """Сохраняет предпочтения пользователя (тема и город)"""
        if self.main_window:
            theme = self.main_window.property('isDarkTheme')
            city_ru = self.main_window.property('selectedCityRu')
            save_settings(theme, city_name, city_ru)

    @Slot()
    def save_theme_preference(self):
        """Сохраняет только выбранную тему"""
        settings = load_settings()
        if settings is None:
            # Если нет сохранённых настроек, не сохраняем только тему
            return
        
        if self.main_window:
            theme = self.main_window.property('isDarkTheme')
            city = settings.get("selectedCity", "")
            city_ru = settings.get("selectedCityRu", "")
            save_settings(theme, city, city_ru)

    def load_and_apply_preferences(self):
        """Загружает сохранённые предпочтения и применяет их к окну, возвращает экран для отображения"""
        settings = load_settings()
        
        if settings is None:
            # Первый запуск - показываем welcome экран
            return "welcome"
        
        # Были сохранённые настройки
        if self.main_window:
            # Восстанавливаем тему
            is_dark = settings.get("isDarkTheme", False)
            self.main_window.setProperty('isDarkTheme', is_dark)
            
            # Восстанавливаем город
            city = settings.get("selectedCity", "")
            city_ru = settings.get("selectedCityRu", "")
            
            if city:
                self.main_window.setProperty('selectedCity', city)
                self.main_window.setProperty('selectedCityRu', city_ru)
                # Загружаем историю для города
                self.fetchLocalHistory(city)
                # Возвращаем город-экран
                return "city"
        
        return "welcome"

    @Slot(str)
    def fetchLocalHistory(self, city_name):
        """Читает локальный файл истории для города и обновляет свойства главного окна."""
        if not self.main_window:
            return

        try:
            base = os.path.dirname(__file__)
            filename = os.path.join(base, 'data', 'logs', 'history', f"{city_name}.json")
            if not os.path.isfile(filename):
                # нет файла — ничего не делаем
                return

            with open(filename, 'r', encoding='utf-8') as f:
                try:
                    history = json.load(f)
                except json.JSONDecodeError:
                    history = []

            if not history:
                return

            # Последний элемент — текущее состояние
            last = history[-1]
            data = last.get('data', {}) if isinstance(last, dict) else {}

            # Обновляем свойства окна
            try:
                aqi_value = int(data.get('aqi')) if data.get('aqi') is not None else self.main_window.property('aqi')
                self.main_window.setProperty('aqi', aqi_value)
                
                # Определяем категорию и цвет AQI
                category, color = get_aqi_category(aqi_value)
                self.main_window.setProperty('aqiCategory', category)
                self.main_window.setProperty('aqiColor', color)

                pollutants = {
                    'pm2_5': data.get('pm2_5', 0),
                    'pm10': data.get('pm10', 0),
                    'o3': data.get('o3', 0),
                    'no2': data.get('no2', 0),
                    'so2': data.get('so2', 0),
                    'co': data.get('co', 0),
                }
                self.main_window.setProperty('pollutants', pollutants)

                # Генерируем рекомендации
                recommendation = get_recommendations(aqi_value, pollutants)
                self.main_window.setProperty('recommendation', recommendation)

                # Собираем до 10 последних AQI
                aqi_hist = []
                for entry in history[-10:]:
                    d = entry.get('data') if isinstance(entry, dict) else None
                    if d and 'aqi' in d:
                        try:
                            aqi_hist.append(int(d.get('aqi')))
                        except Exception:
                            pass

                self.main_window.setProperty('aqiHistory', aqi_hist)
            except Exception as e:
                log_error(city_name, f"Failed to set main_window properties: {e}")

        except Exception as e:
            log_error(city_name, f"fetchLocalHistory error: {e}")

os.makedirs(LOG_DIR, exist_ok=True)

# Логирование ошибок
def log_error(city_name, error_message):
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    logfile = os.path.join(LOG_DIR, "errors.log")

    with open(logfile, "a", encoding="utf-8") as f:
        f.write(f"[{timestamp}] {city_name}: {error_message}\n")
    
# Отправка запроса и парсинг данных
def fetch_air_quality(lat, lon, city_name):
    now = time.time()
    if city_name in _last_request_time:
        elapsed = now - _last_request_time[city_name]
        if elapsed < MIN_REQUEST_INTERVAL_SECONDS:
            print(f"Слишком частый запрос для {city_name}.")
            return None
    
    _last_request_time[city_name] = time.time()
    
    url = f"{BASE_URL}?lat={lat}&lon={lon}&appid={API_KEY}"
    
    try:
        response = requests.get(url, timeout=REQUEST_TIMEOUT_SECONDS)
    except requests.exceptions.Timeout:
        log_error(city_name, f"Timeout after {REQUEST_TIMEOUT_SECONDS}s")
        return None
    except requests.exceptions.ConnectionError:
        log_error(city_name, "Connection error (network issue)")
        return None
    except Exception as e:
        log_error(city_name, f"Unexpected error: {e}")
        return None
    
    if response.status_code != 200:
        log_error(city_name, f"Bad status {response.status_code}: {response.text}")
        return None
    
    try:
        data = response.json()
    except json.JSONDecodeError:
        log_error(city_name, "Invalid JSON response")
        return None

    if "list" not in data or not data["list"]:
        log_error(city_name, f"Missing 'list' in API response: {data}")
        return None
    
    entry = data["list"][0]

    if "main" not in entry or "components" not in entry:
        log_error(city_name, f"Missing 'main' or 'components' in data entry: {entry}")
        return None
    
    return {
        "aqi": entry["main"].get("aqi"),
        "pm2_5": entry["components"].get("pm2_5"),
        "pm10": entry["components"].get("pm10"),
        "o3": entry["components"].get("o3"),
        "no2": entry["components"].get("no2"),
        "so2": entry["components"].get("so2"),
        "co": entry["components"].get("co"),
    }


# Сохранение данных в JSON файл
def save_air_quality_json(city_name, data):
    history_dir = os.path.join(LOG_DIR, "history")
    os.makedirs(history_dir, exist_ok=True)

    filename = os.path.join(history_dir, f"{city_name}.json")

    if os.path.isfile(filename):
        with open(filename, "r", encoding="utf-8") as f:
            try:
                history = json.load(f)
            except json.JSONDecodeError:
                history = []
    else:
        history = []

    entry = {
        "timestamp": datetime.now().isoformat(),
        "city": city_name,
        "data": data,
    }

    history.append(entry)

    with open(filename, "w", encoding="utf-8") as f:
        json.dump(history, f, ensure_ascii=False, indent=4)


if __name__ == '__main__':
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # Создаём контроллер и передаём ему engine для управления экранами
    controller = Controller(engine)
    engine.rootContext().setContextProperty("controller", controller)

    # Загружаем главное окно с системой навигации
    qml_file = os.path.join(os.path.dirname(__file__), 'ui', 'main-window.qml')
    engine.load(QUrl.fromLocalFile(qml_file))

    if not engine.rootObjects():
        print("Ошибка загрузки QML.")
        sys.exit(-1)
    
    # Получаем корневой объект (главное окно) и показываем его в развернутом виде
    root = engine.rootObjects()[0]
    controller.main_window = root
    engine.rootContext().setContextProperty("mainWindow", root)
    
    # Загружаем и применяем сохранённые настройки
    initial_screen = controller.load_and_apply_preferences()
    root.setProperty('currentScreen', initial_screen)
    
    root.showMaximized()

    sys.exit(app.exec())


