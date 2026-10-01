import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {

    id: panel

    property var model

    color: "#18191b"

    ColumnLayout {

        anchors.fill: parent
        anchors.margins: 20

        spacing: 12

        Label {
            text: "wood-it"

            font.pixelSize: 24
            font.bold: true

            color: "white"
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1

            color: "#38393d"
        }

        Label {
            text: "PEÇA 2D"

            color: "#aaaaaa"

            font.pixelSize: 12
        }

        Label {
            text:
                "Vértices: " +
                (model ? model.vertexCount : 0)

            color: "white"
        }

        Label {
            text:
                "Área: " +
                (model
                 ? model.area().toFixed(2)
                 : "0") +
                " mm²"

            color: "white"
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1

            color: "#38393d"
        }

        Label {
            text: "VÉRTICE SELECIONADO"

            color: "#aaaaaa"

            font.pixelSize: 12
        }

        Label {
            text:
                "V" +
                ((model ? model.selectedIndex : 0) + 1)

            color: "#ffb74d"

            font.pixelSize: 20
            font.bold: true
        }

        GridLayout {

            columns: 2

            Layout.fillWidth: true

            Label {
                text: "X:"
                color: "#bbbbbb"
            }

            TextField {
                id: xField

                Layout.fillWidth: true

                text:
                    model
                    ? model.vertexX(model.selectedIndex).toFixed(2)
                    : "0"

                selectByMouse: true

                onEditingFinished: {

                    if (!model)
                        return

                    var x = Number(text)

                    if (!isNaN(x)) {

                        model.setVertex(
                            model.selectedIndex,
                            x,
                            model.vertexY(
                                model.selectedIndex
                            )
                        )
                    }
                }
            }

            Label {
                text: "Y:"
                color: "#bbbbbb"
            }

            TextField {
                id: yField

                Layout.fillWidth: true

                text:
                    model
                    ? model.vertexY(model.selectedIndex).toFixed(2)
                    : "0"

                selectByMouse: true

                onEditingFinished: {

                    if (!model)
                        return

                    var y = Number(text)

                    if (!isNaN(y)) {

                        model.setVertex(
                            model.selectedIndex,
                            model.vertexX(
                                model.selectedIndex
                            ),
                            y
                        )
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1

            color: "#38393d"
        }

        Label {
            text: "GEOMETRIA"

            color: "#aaaaaa"

            font.pixelSize: 12
        }

        Label {
            text:
                model
                ? "Ângulo: " +
                  model.interiorAngle(
                      model.selectedIndex
                  ).toFixed(2) +
                  "°"
                : "Ângulo: --"

            color: "white"

            font.pixelSize: 16
        }

        Label {
            text:
                model
                ? "Aresta seguinte: " +
                  model.edgeLength(
                      model.selectedIndex
                  ).toFixed(2) +
                  " mm"
                : "Aresta: --"

            color: "white"

            font.pixelSize: 16
        }

        Item {
            Layout.fillHeight: true
        }

        Button {
            text: "Novo retângulo"

            Layout.fillWidth: true

            onClicked: {

                if (model)
                    model.reset()
            }
        }

        Button {
            text: "Adicionar vértice"

            Layout.fillWidth: true

            onClicked: {

                if (model)
                    model.addVertex()
            }
        }
    }

    Connections {
        target: model

        function onGeometryChanged() {

            if (!model)
                return

            xField.text =
                model.vertexX(
                    model.selectedIndex
                ).toFixed(2)

            yField.text =
                model.vertexY(
                    model.selectedIndex
                ).toFixed(2)
        }

        function onSelectedIndexChanged() {

            if (!model)
                return

            xField.text =
                model.vertexX(
                    model.selectedIndex
                ).toFixed(2)

            yField.text =
                model.vertexY(
                    model.selectedIndex
                ).toFixed(2)
        }
    }
}