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


        // =====================================================
        // TÍTULO
        // =====================================================

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


        // =====================================================
        // PEÇA
        // =====================================================

        Label {
            text: "PEÇA 2D"

            color: "#aaaaaa"

            font.pixelSize: 12
        }


        Label {
            text:
                "Vértices: " +
                (model
                 ? model.vertexCount
                 : 0)

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


        // =====================================================
        // ARESTA SELECIONADA
        // =====================================================

        Label {
            visible:
                model &&
                model.selectedEdge >= 0

            text: "ARESTA"

            color: "#aaaaaa"

            font.pixelSize: 12
        }


        Label {
            visible:
                model &&
                model.selectedEdge >= 0

            text:
                model &&
                model.selectedEdge >= 0
                ? "Aresta " +
                  (model.selectedEdge + 1)
                : ""

            color: "#ffb74d"

            font.pixelSize: 20

            font.bold: true
        }


        Label {
            visible:
                model &&
                model.selectedEdge >= 0

            text: "Comprimento"

            color: "#bbbbbb"
        }


        TextField {
            id: edgeLengthField

            visible:
                model &&
                model.selectedEdge >= 0

            Layout.fillWidth: true

            text:
                model &&
                model.selectedEdge >= 0
                ? model.edgeLength(
                    model.selectedEdge
                  ).toFixed(2)
                : ""

            selectByMouse: true

            validator: DoubleValidator {
                bottom: 0.01

                decimals: 2
            }


            function applyEdgeLength()
            {
                if (!model)
                    return

                if (model.selectedEdge < 0)
                    return

                var value =
                    Number(text)

                if (!isNaN(value) &&
                    value > 0)
                {
                    model.setEdgeLength(
                        model.selectedEdge,
                        value
                    )

                    text =
                        model.edgeLength(
                            model.selectedEdge
                        ).toFixed(2)
                }
            }


            onEditingFinished:
            {
                applyEdgeLength()
            }


            Keys.onReturnPressed:
            {
                applyEdgeLength()
            }
        }


        // =====================================================
        // RESTRIÇÕES
        // =====================================================

        Label {
            visible:
                model &&
                model.selectedEdge >= 0

            text: "RESTRIÇÕES"

            color: "#aaaaaa"

            font.pixelSize: 12
        }


        RowLayout {
            visible:
                model &&
                model.selectedEdge >= 0

            Layout.fillWidth: true

            spacing: 6


            Button {
                text: "Horizontal"

                Layout.fillWidth: true

                checkable: true

                checked:
                    model
                    ? model.selectedEdgeHorizontal
                    : false


                onClicked:
                {
                    if (!model)
                        return

                    model.setEdgeHorizontal(
                        model.selectedEdge,
                        checked
                    )
                }
            }


            Button {
                text: "Vertical"

                Layout.fillWidth: true

                checkable: true

                checked:
                    model
                    ? model.selectedEdgeVertical
                    : false


                onClicked:
                {
                    if (!model)
                        return

                    model.setEdgeVertical(
                        model.selectedEdge,
                        checked
                    )
                }
            }
        }


        // =====================================================
        // VÉRTICE SELECIONADO
        // =====================================================

        Label {
            visible:
                !model ||
                model.selectedEdge < 0

            text:
                "Vértice " +
                (
                    (model
                     ? model.selectedIndex
                     : 0)
                    + 1
                )

            color: "#ffb74d"

            font.pixelSize: 20

            font.bold: true
        }


        // =====================================================
        // COORDENADAS
        // =====================================================

        GridLayout {
            visible:
                !model ||
                model.selectedEdge < 0

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
                    ? model.vertexX(
                        model.selectedIndex
                      ).toFixed(2)
                    : "0"

                selectByMouse: true


                onEditingFinished:
                {
                    if (!model)
                        return

                    var x =
                        Number(text)

                    if (!isNaN(x))
                    {
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
                    ? model.vertexY(
                        model.selectedIndex
                      ).toFixed(2)
                    : "0"

                selectByMouse: true


                onEditingFinished:
                {
                    if (!model)
                        return

                    var y =
                        Number(text)

                    if (!isNaN(y))
                    {
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


        // =====================================================
        // GEOMETRIA DO VÉRTICE
        // =====================================================

        Label {
            visible:
                !model ||
                model.selectedEdge < 0

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
            visible:
                !model ||
                model.selectedEdge < 0

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


        // =====================================================
        // ESPAÇO
        // =====================================================

        Item {
            Layout.fillHeight: true
        }


        // =====================================================
        // BOTÕES
        // =====================================================

        Button {
            text: "Novo retângulo"

            Layout.fillWidth: true

            onClicked:
            {
                if (model)
                    model.reset()
            }
        }


        Button {
            text: "Adicionar vértice"

            Layout.fillWidth: true

            onClicked:
            {
                if (model)
                    model.addVertex()
            }
        }


        Button {
            text: "Apagar vértice"

            Layout.fillWidth: true

            enabled:
                model &&
                model.vertexCount > 3

            onClicked:
            {
                if (model)
                    model.deleteSelectedVertex()
            }
        }
    }


    // =========================================================
    // ATUALIZAÇÃO DA UI
    // =========================================================

    Connections {
        target: model


        function updateFields()
        {
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


        function onGeometryChanged()
        {
            updateFields()


            if (model.selectedEdge >= 0)
            {
                edgeLengthField.text =
                    model.edgeLength(
                        model.selectedEdge
                    ).toFixed(2)
            }
        }


        function onSelectedIndexChanged()
        {
            updateFields()
        }


        function onSelectedEdgeChanged()
        {
            if (!model)
                return


            if (model.selectedEdge >= 0)
            {
                edgeLengthField.text =
                    model.edgeLength(
                        model.selectedEdge
                    ).toFixed(2)
            }
        }


        function onConstraintsChanged()
        {
            // As propriedades Q_PROPERTY
            // atualizam automaticamente
            // os botões Horizontal/Vertical.
        }
    }
}