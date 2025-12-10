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
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0
        
        // Заголовок с названием города
        Rectangle {
            color: mainWindow.isDarkTheme ? "#1e1e1e" : "#ffffff"
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            Behavior on color {
                ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
            }
            
            Text {
                anchors.centerIn: parent
                text: "Привет, " + mainWindow.selectedCityRu + "!"
                font.pixelSize: 32
                font.bold: true
                color: mainWindow.isDarkTheme ? "#ffffff" : "#1e1e1e"
                
                // Плавная анимация смены цвета текста
                Behavior on color {
                    ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
                }
            }
        }
        
        // Нижняя панель с кнопками
        Rectangle {
            id: bottomPanel
            color: mainWindow.isDarkTheme ? "#2a2a2a" : "#f5f5f5"
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            border.width: 1
            border.color: mainWindow.isDarkTheme ? "#3a3a3a" : "#e0e0e0"
            
            Behavior on color {
                ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15
                
                // Кнопка настроек
                Rectangle {
                    id: settingsButton
                    width: 50
                    height: 50
                    radius: 10
                    color: settingsMouseArea.containsMouse ? 
                           (mainWindow.isDarkTheme ? "#3d5c1f" : "#d0e8c6") : 
                           (mainWindow.isDarkTheme ? "#2d4a15" : "#e8f5e9")
                    border.color: "#4caf50"
                    border.width: 2
                    
                    Behavior on color {
                        ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                    
                    Image {
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        source: "../icons/settings.svg"
                        fillMode: Image.PreserveAspectFit
                    }
                    
                    MouseArea {
                        id: settingsMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onClicked: {
                            // Будущая логика настроек
                            console.log("Settings clicked")
                        }
                    }
                }
                
                // Заполняющий элемент
                Item {
                    Layout.fillWidth: true
                }
            }
        }
    }
}
