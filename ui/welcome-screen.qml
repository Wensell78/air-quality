import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    anchors.fill: parent
    color: mainWindow.isDarkTheme ? "#1e1e1e" : "#ffffff"
    
    // Плавная анимация смены цвета фона
    Behavior on color {
        ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
    }
    
    // Декоративный элемент в верхнем правом углу
    Rectangle {
        width: 400
        height: 400
        radius: 200
        color: mainWindow.isDarkTheme ? "#2d5016" : "#e8f5f0"
        opacity: mainWindow.isDarkTheme ? 0.15 : 0.3
        
        // Плавная анимация смены цвета декоративного элемента
        Behavior on color {
            ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
        }
        
        Behavior on opacity {
            NumberAnimation { duration: 400; easing.type: Easing.InOutQuad }
        }
        
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: -100
        anchors.topMargin: -100
        
        // Анимация мигания
        SequentialAnimation on opacity {
            running: true
            loops: Animation.Infinite
            NumberAnimation {
                from: mainWindow.isDarkTheme ? 0.15 : 0.3
                to: mainWindow.isDarkTheme ? 0.25 : 0.4
                duration: 3000
            }
            NumberAnimation {
                from: mainWindow.isDarkTheme ? 0.25 : 0.4
                to: mainWindow.isDarkTheme ? 0.15 : 0.3
                duration: 3000
            }
        }
    }
    
    // Декоративный элемент в нижнем левом углу
    Rectangle {
        width: 300
        height: 300
        radius: 150
        color: mainWindow.isDarkTheme ? "#1b5e20" : "#c8e6c9"
        opacity: mainWindow.isDarkTheme ? 0.1 : 0.2
        
        // Плавная анимация смены цвета декоративного элемента
        Behavior on color {
            ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
        }
        
        Behavior on opacity {
            NumberAnimation { duration: 400; easing.type: Easing.InOutQuad }
        }
        
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: -50
        anchors.bottomMargin: -50
        
        // Анимация мигания
        SequentialAnimation on opacity {
            running: true
            loops: Animation.Infinite
            NumberAnimation {
                from: mainWindow.isDarkTheme ? 0.1 : 0.2
                to: mainWindow.isDarkTheme ? 0.2 : 0.3
                duration: 3000
            }
            NumberAnimation {
                from: mainWindow.isDarkTheme ? 0.2 : 0.3
                to: mainWindow.isDarkTheme ? 0.1 : 0.2
                duration: 3000
            }
        }
    }
    
    // Свитчер темы в правом верхнем углу
    Rectangle {
        id: themeToggle
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 20
        anchors.rightMargin: 20
        width: 100
        height: 50
        radius: 25
        color: mainWindow.isDarkTheme ? "#2d3436" : "#e8eef2"
        border.color: mainWindow.isDarkTheme ? "#636e72" : "#bdc3c7"
        border.width: 2
        z: 100
        
        // Плавная анимация смены цвета фона
        Behavior on color {
            ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
        }
        
        Behavior on border.color {
            ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
        }
        
        // Слайдер (круглая кнопка, которая передвигается)
        Rectangle {
            id: slider
            width: 42
            height: 42
            radius: 21
            color: "#ffffff"
            
            // Позиция слайдера зависит от темы
            x: mainWindow.isDarkTheme ? 54 : 4
            y: 4
            
            // Плавная анимация движения слайдера
            Behavior on x {
                NumberAnimation { duration: 400; easing.type: Easing.InOutQuad }
            }
        }
        
        // Текст "☀️" (день/светлая тема) слева
        Image {
            x: 10
            y: 10
            width: 30
            height: 30
            source: "../icons/sun.svg"
            opacity: mainWindow.isDarkTheme ? 0.3 : 1
            
            // Плавная анимация прозрачности
            Behavior on opacity {
                NumberAnimation { duration: 400; easing.type: Easing.InOutQuad }
            }
        }
        
        // Текст "🌙" (ночь/тёмная тема) справа
        Image {
            x: 60
            y: 10
            width: 30
            height: 30
            source: "../icons/moon.svg"
            opacity: mainWindow.isDarkTheme ? 1 : 0.3
            
            // Плавная анимация прозрачности
            Behavior on opacity {
                NumberAnimation { duration: 400; easing.type: Easing.InOutQuad }
            }
        }
        
        // Область нажатия
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            
            onClicked: {
                // Переключаем тему с анимацией
                mainWindow.isDarkTheme = !mainWindow.isDarkTheme
                // Сохраняем тему (если город уже был выбран ранее)
                controller.save_theme_preference()
            }
            
            // Эффект при наведении - легкое изменение масштаба
            onEntered: {
                themeToggleScaleAnim.start()
            }
            
            onExited: {
                themeToggleScaleAnim.stop()
                themeToggle.scale = 1.0
            }
        }
        
        // Анимация при наведении
        SequentialAnimation {
            id: themeToggleScaleAnim
            loops: Animation.Infinite
            NumberAnimation {
                target: themeToggle
                property: "scale"
                from: 1.0
                to: 1.05
                duration: 300
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: themeToggle
                property: "scale"
                from: 1.05
                to: 1.0
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }
    
    // Основное содержимое
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 30
        
        // Верхний спейсер
        Item {
            Layout.fillHeight: true
            Layout.preferredHeight: 30
        }
        
        // Логотип с анимацией
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 0
            
            Image {
                id: logo
                source: "../logo/logo.svg"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 160
                Layout.preferredHeight: 160
                width: 160
                height: 160
                // Запрос большого размера для лучшего качества на больших экранах
                sourceSize: Qt.size(640, 640)
                fillMode: Image.PreserveAspectFit
                mipmap: true
                smooth: true
                antialiasing: true
                cache: false
                
                // Анимация появления и масштабирования
                SequentialAnimation on scale {
                    running: true
                    NumberAnimation {
                        from: 0.8
                        to: 1.0
                        duration: 800
                        easing.type: Easing.OutBack
                    }
                }
                
                // Анимация поворота (легкий эффект)
                SequentialAnimation on rotation {
                    running: true
                    loops: Animation.Infinite
                    RotationAnimation {
                        from: 0
                        to: 5
                        duration: 2000
                    }
                    RotationAnimation {
                        from: 5
                        to: -5
                        duration: 2000
                    }
                    RotationAnimation {
                        from: -5
                        to: 0
                        duration: 2000
                    }
                }
                
                transformOrigin: Item.Center
            }
        }
        
        // Заголовок с анимацией
        Text {
            id: title
            text: "Добро пожаловать в Oxy"
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 44
            font.weight: Font.Bold
            color: mainWindow.isDarkTheme ? "#4caf50" : "#1b5e20"
            font.family: "Segoe UI, Arial, sans-serif"
            
            // Плавная анимация смены цвета заголовка
            Behavior on color {
                ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
            }
            
            // Анимация появления
            opacity: 0
            SequentialAnimation {
                running: true
                PauseAnimation { duration: 300 }
                NumberAnimation {
                    target: title
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 600
                }
            }
        }
        
        // Описание с анимацией
        Text {
            id: description
            text: "Oxy помогает отслеживать качество воздуха в вашем городе,\nанализируя данные и показывая понятные графики и историю изменений."
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: 600
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 18
            font.family: "Segoe UI, Arial, sans-serif"
            color: mainWindow.isDarkTheme ? "#cccccc" : "#555555"
            lineHeight: 1.6
            wrapMode: Text.WordWrap
            
            // Плавная анимация смены цвета описания
            Behavior on color {
                ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
            }
            
            // Анимация появления
            opacity: 0
            SequentialAnimation {
                running: true
                PauseAnimation { duration: 500 }
                NumberAnimation {
                    target: description
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 600
                }
            }
        }
        
        // Спейсер
        Item {
            Layout.fillHeight: true
            Layout.preferredHeight: 30
        }
        
        // Кнопка продолжить с анимацией
        Rectangle {
            id: continueBtn
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 240
            Layout.preferredHeight: 56
            
            color: btnMouse.containsMouse ? (mainWindow.isDarkTheme ? "#66bb6a" : "#2e7d32") : (mainWindow.isDarkTheme ? "#43a047" : "#4caf50")
            radius: 12
            
            // Тень под кнопкой
            Rectangle {
                anchors.fill: parent
                anchors.margins: -4
                color: mainWindow.isDarkTheme ? "#00000045" : "#00000015"
                radius: parent.radius
                z: -1
                
                // Плавная анимация смены цвета тени
                Behavior on color {
                    ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
                }
            }
            
            // Плавная анимация смены цвета кнопки
            Behavior on color {
                ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
            }
            
            // Масштабирование при наведении
            Behavior on scale {
                NumberAnimation { duration: 150 }
            }
            
            Text {
                id: btnText
                anchors.centerIn: parent
                text: "Продолжить"
                font.pixelSize: 16
                font.weight: Font.Medium
                font.family: "Segoe UI, Arial, sans-serif"
                color: "#ffffff"
            }
            
            MouseArea {
                id: btnMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onEntered: {
                    continueBtn.scale = 1.05
                }
                
                onExited: {
                    continueBtn.scale = 1.0
                }
                
                onClicked: {
                    // Эффект нажатия
                    btnClickAnim.start()
                    // Переходим на экран выбора города
                    mainWindow.currentScreen = "city-selection"
                }
            }
            
            // Анимация нажатия
            SequentialAnimation {
                id: btnClickAnim
                NumberAnimation {
                    target: continueBtn
                    property: "scale"
                    to: 0.95
                    duration: 100
                }
                NumberAnimation {
                    target: continueBtn
                    property: "scale"
                    to: 1.05
                    duration: 100
                }
            }
            
            // Анимация появления
            opacity: 0
            SequentialAnimation {
                running: true
                PauseAnimation { duration: 700 }
                NumberAnimation {
                    target: continueBtn
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 600
                }
            }
        }
        
        // Нижний спейсер
        Item {
            Layout.fillHeight: true
            Layout.preferredHeight: 40
        }
    }
}
