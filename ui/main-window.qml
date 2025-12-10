import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: mainWindow
    visible: true
    width: 900
    height: 700
    title: "Oxy"
    
    // Переменная для отслеживания текущей темы
    property bool isDarkTheme: false
    
    // Отображение встроенных кнопок окна
    flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowSystemMenuHint | Qt.WindowMinimizeButtonHint | Qt.WindowMaximizeButtonHint | Qt.WindowCloseButtonHint
    
    minimumWidth: 600
    minimumHeight: 500
    
    // Свойство для управления текущим экраном
    property string currentScreen: "welcome"  // "welcome" или "city-selection"
    
    // Фон с адаптацией к теме
    Rectangle {
        anchors.fill: parent
        color: mainWindow.isDarkTheme ? "#1e1e1e" : "#ffffff"
        
        Behavior on color {
            ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
        }
    }
    
    // Загружаем содержимое в зависимости от currentScreen
    Loader {
        id: screenLoader
        anchors.fill: parent
        source: "welcome-screen.qml"  // Загружаем по умолчанию
        
        onSourceChanged: {
            opacity = 0
            opacity = 1
        }
        
        // Переход между экранами
        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }
    }
    
    // Обработчик смены экрана
    onCurrentScreenChanged: {
        if (currentScreen === "welcome") {
            screenLoader.source = "welcome-screen.qml"
        } else if (currentScreen === "city-selection") {
            screenLoader.source = "city-selection-screen.qml"
        }
    }
    
    // Инициализируем первый экран
    Component.onCompleted: {
        currentScreen = "welcome"
    }
}
