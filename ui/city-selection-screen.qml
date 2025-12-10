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
    
    // Основной контент
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 20
        
        // Заголовок
        Text {
            text: "Выберите город"
            font.pixelSize: 32
            font.bold: true
            color: mainWindow.isDarkTheme ? "#ffffff" : "#000000"
            Layout.alignment: Qt.AlignHCenter
            
            Behavior on color {
                ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
            }
        }
        
        // Поле поиска
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: mainWindow.isDarkTheme ? "#2a2a2a" : "#f5f5f5"
            border.color: mainWindow.isDarkTheme ? "#3d3d3d" : "#e0e0e0"
            border.width: 1
            radius: 8
            
            Behavior on color {
                ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
            }
            
            Behavior on border.color {
                ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
            }
            
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10
                    
                    // Иконка поиска
                    Image {
                        id: searchIcon
                        source: mainWindow.isDarkTheme ? "../icons/search_dark.svg" : "../icons/search_light.svg"
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        Layout.alignment: Qt.AlignVCenter
                        opacity: mainWindow.isDarkTheme ? 0.9 : 0.8
                        fillMode: Image.PreserveAspectFit

                        Behavior on opacity {
                            NumberAnimation { duration: 400; easing.type: Easing.InOutQuad }
                        }
                    }
                // Текстовое поле для ввода
                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 14
                    color: mainWindow.isDarkTheme ? "#ffffff" : "#000000"
                    
                    Behavior on color {
                        ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
                    }
                    
                    // Обновляем модель при вводе
                    onTextChanged: {
                        cityListModel.clear()
                        var searchLower = text.toLowerCase()
                        
                        for (var i = 0; i < citiesList.length; i++) {
                            var city = citiesList[i]
                            var cityRu = cityNames[city]
                            
                            if (cityRu.toLowerCase().includes(searchLower) || 
                                city.toLowerCase().includes(searchLower)) {
                                cityListModel.append({
                                    "cityEng": city,
                                    "cityRu": cityRu
                                })
                            }
                        }
                    }
                }
                
                
                
                // Кнопка очистки
                MouseArea {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    Layout.alignment: Qt.AlignVCenter
                    
                    Image {
                        source: mainWindow.isDarkTheme ? "../icons/cancel_dark.svg" : "../icons/cancel_light.svg"
                        width: 16
                        height: 16
                        anchors.centerIn: parent
                        visible: searchInput.text !== ""
                        fillMode: Image.PreserveAspectFit
                    }
                    
                    onClicked: {
                        if (searchInput.text !== "") {
                            searchInput.text = ""
                        }
                    }
                }
            }
        }
        
        // Прокручиваемый список городов
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: mainWindow.isDarkTheme ? "#252525" : "#fafafa"
            border.color: mainWindow.isDarkTheme ? "#3d3d3d" : "#e0e0e0"
            border.width: 1
            radius: 8
            
            Behavior on color {
                ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
            }
            
            Behavior on border.color {
                ColorAnimation { duration: 400; easing.type: Easing.InOutQuad }
            }
            
            ListView {
                anchors.fill: parent
                anchors.margins: 8
                model: cityListModel
                clip: true
                spacing: 4
                
                // Инициализируем модель при загрузке
                Component.onCompleted: {
                    for (var i = 0; i < citiesList.length; i++) {
                        var city = citiesList[i]
                        cityListModel.append({
                            "cityEng": city,
                            "cityRu": cityNames[city]
                        })
                    }
                }
                
                delegate: Rectangle {
                    width: ListView.view.width
                    height: 50
                    color: "transparent"
                    radius: 4
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 3
                        color: mouseArea.containsMouse ? 
                               (mainWindow.isDarkTheme ? "#3d3d3d" : "#e8f5e9") : 
                               "transparent"
                        radius: 4
                    }
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10
                        
                        Text {
                            text: cityRu
                            font.pixelSize: 16
                            color: mainWindow.isDarkTheme ? "#ffffff" : "#000000"
                            Layout.fillWidth: true
                        }
                    }
                    
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        
                        onClicked: {
                            mainWindow.currentScreen = "welcome"
                            controller.on_city_selected(cityEng)
                        }
                    }
                }
            }
        }
        
        // Кнопка "Назад"
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 150
            Layout.preferredHeight: 45
            
            color: btnBackMouse.pressed ? 
                   (mainWindow.isDarkTheme ? "#1a4d2e" : "#81c784") : 
                   (btnBackMouse.containsMouse ? 
                    (mainWindow.isDarkTheme ? "#2d5016" : "#a5d6a7") : 
                    (mainWindow.isDarkTheme ? "#1b5e20" : "#4caf50"))
            radius: 6
            
            Behavior on color {
                ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
            
            Text {
                anchors.centerIn: parent
                text: "← Назад"
                color: "#ffffff"
                font.pixelSize: 14
                font.bold: true
            }
            
            MouseArea {
                id: btnBackMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: {
                    mainWindow.currentScreen = "welcome"
                }
            }
        }
    }
    
    // Русские названия городов
    property var cityNames: {
        "Astana": "Астана",
        "Aktau": "Актау",
        "Aktobe": "Актобе",
        "Almaty": "Алматы",
        "Atyrau": "Атырау",
        "Baikonur": "Байконур",
        "Balkhash": "Балхаш",
        "Zhanaozen": "Жанаозен",
        "Zhezkazgan": "Жезказган",
        "Karaganda": "Караганда",
        "Kentau": "Кентау",
        "Kokshetau": "Кокшетау",
        "Kostanay": "Костанай",
        "Kulsary": "Кульсары",
        "Kyzylorda": "Кызылорда",
        "Pavlodar": "Павлодар",
        "Petropavlovsk": "Петропавловск",
        "Ridder": "Риддер",
        "Rudny": "Рудный",
        "Sarkand": "Сарканд",
        "Semey": "Семей",
        "Taldykorgan": "Талдыкорган",
        "Taraz": "Тараз",
        "Temirtau": "Темиртау",
        "Turkestan": "Туркестан",
        "Uralsk": "Уральск",
        "Ust-Kamenogorsk": "Усть-Каменогорск",
        "Shymkent": "Шымкент",
        "Ekibastuz": "Экибастуз"
    }
    
    // Список городов в английском формате (для связи с config.py)
    property var citiesList: [
        "Astana", "Aktau", "Aktobe", "Almaty", "Atyrau", "Baikonur", "Balkhash",
        "Zhanaozen", "Zhezkazgan", "Karaganda", "Kentau", "Kokshetau", "Kostanay",
        "Kulsary", "Kyzylorda", "Pavlodar", "Petropavlovsk", "Ridder", "Rudny",
        "Sarkand", "Semey", "Taldykorgan", "Taraz", "Temirtau", "Turkestan",
        "Uralsk", "Ust-Kamenogorsk", "Shymkent", "Ekibastuz"
    ]
    
    // Модель для списка городов
    ListModel {
        id: cityListModel
    }
}
