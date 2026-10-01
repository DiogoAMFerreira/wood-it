cmake_minimum_required(VERSION 3.21)

project(wood-it VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.4)

qt_add_executable(wood-it
    src/main.cpp
    src/PolygonModel.cpp
    src/PolygonModel.h
    src/Geometry.h
)

qt_add_qml_module(wood-it
    URI WoodIt
    VERSION 1.0

    QML_FILES
        qml/Main.qml
        qml/DrawingCanvas.qml
        qml/PropertiesPanel.qml
)

target_link_libraries(wood-it
    PRIVATE Qt6::Quick
)