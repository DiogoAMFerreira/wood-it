import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import WoodIt

ApplicationWindow {
    id: window

    width: 1400
    height: 850

    visible: true
    title: "wood-it"

    color: "#202124"

    PolygonModel {
        id: polygon
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        DrawingCanvas {
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: polygon
        }

        PropertiesPanel {
            Layout.preferredWidth: 320
            Layout.fillHeight: true

            model: polygon
        }
    }
}