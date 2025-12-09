import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root
    visible: false
    width: 900
    height: 700
    color: "#ffffff"
    title: "Oxy"
    
    // Отображение встроенных кнопок окна
    flags: Qt.Window | Qt.WindowTitleHint | Qt.WindowSystemMenuHint | Qt.WindowMinimizeButtonHint | Qt.WindowMaximizeButtonHint | Qt.WindowCloseButtonHint
    
    minimumWidth: 600
    minimumHeight: 500

    
    // Градиентный фон
    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
        
        // Декоративный элемент в верхнем правом углу
        Rectangle {
            width: 400
            height: 400
            radius: 200
            color: "#e8f5f0"
            opacity: 0.3
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: -100
            anchors.topMargin: -100
            
            // Анимация масштабирования
            SequentialAnimation on opacity {
                running: true
                loops: Animation.Infinite
                NumberAnimation {
                    from: 0.3
                    to: 0.5
                    duration: 3000
                }
                NumberAnimation {
                    from: 0.5
                    to: 0.3
                    duration: 3000
                }
            }
        }
        
        // Декоративный элемент в нижнем левом углу
        Rectangle {
            width: 300
            height: 300
            radius: 150
            color: "#c8e6c9"
            opacity: 0.2
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: -50
            anchors.bottomMargin: -50
            
            // Анимация масштабирования
            SequentialAnimation on opacity {
                running: true
                loops: Animation.Infinite
                NumberAnimation {
                    from: 0.2
                    to: 0.35
                    duration: 4000
                }
                NumberAnimation {
                    from: 0.35
                    to: 0.2
                    duration: 4000
                }
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
                source: "logo/logo.svg"
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
            color: "#1b5e20"
            font.family: "Segoe UI, Arial, sans-serif"
            
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
            color: "#555555"
            lineHeight: 1.6
            wrapMode: Text.WordWrap
            
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
            
            color: btnMouse.containsMouse ? "#2e7d32" : "#4caf50"
            radius: 12
            
            // Тень под кнопкой
            Rectangle {
                anchors.fill: parent
                anchors.margins: -4
                color: "#00000015"
                radius: parent.radius
                z: -1
            }
            
            Behavior on color {
                ColorAnimation { duration: 200 }
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
                    controller.on_continue_clicked()
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
