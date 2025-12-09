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

# Устанавливаем путь к плагинам Qt (нужно на некоторых системах)
os.environ["QT_PLUGIN_PATH"] = QLibraryInfo.path(QLibraryInfo.PluginsPath)


_last_request_time = {}


# Контроллер для взаимодействия с QML
class Controller(QObject):
    continueClicked = Signal()

    def __init__(self):
        super().__init__()

    @Slot()
    def on_continue_clicked(self):
        """Обработчик нажатия кнопки "Продолжить" из QML"""
        print("Пользователь нажал 'Продолжить'")
        self.continueClicked.emit()


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

    # Создаём контроллер и передаём его в QML
    controller = Controller()
    engine.rootContext().setContextProperty("controller", controller)

    # Загружаем QML
    qml_file = os.path.join(os.path.dirname(__file__), 'main.qml')
    engine.load(QUrl.fromLocalFile(qml_file))

    if not engine.rootObjects():
        print("Ошибка загрузки QML.")
        sys.exit(-1)

    # Получаем корневой объект (окно) и показываем его в развернутом виде из Python
    root_objects = engine.rootObjects()
    if root_objects:
        root = root_objects[0]
        try:
            root.showMaximized()
        except Exception:
            try:
                root.setProperty('visible', True)
            except Exception:
                pass

    sys.exit(app.exec())


