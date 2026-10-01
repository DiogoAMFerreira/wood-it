import QtQuick
import QtQuick.Controls

Item {
    id: root

    property var model

    Rectangle {
        anchors.fill: parent
        color: "#292a2d"
    }

    Canvas {
        id: canvas

        anchors.fill: parent

        anchors.margins: 20

        property real scaleFactor: 1.0
        property real offsetX: 0
        property real offsetY: 0

        function calculateTransform() {

            if (!model || model.vertexCount < 1)
                return

            var minX = model.vertexX(0)
            var maxX = minX

            var minY = model.vertexY(0)
            var maxY = minY

            for (var i = 1; i < model.vertexCount; ++i) {

                var x = model.vertexX(i)
                var y = model.vertexY(i)

                minX = Math.min(minX, x)
                maxX = Math.max(maxX, x)

                minY = Math.min(minY, y)
                maxY = Math.max(maxY, y)
            }

            var widthMm = Math.max(1, maxX - minX)
            var heightMm = Math.max(1, maxY - minY)

            var availableWidth = width - 80
            var availableHeight = height - 80

            scaleFactor = Math.min(
                availableWidth / widthMm,
                availableHeight / heightMm
            )

            offsetX =
                (width - widthMm * scaleFactor) / 2
                - minX * scaleFactor

            offsetY =
                (height + heightMm * scaleFactor) / 2
                + minY * scaleFactor
        }

        function screenX(x) {
            return offsetX + x * scaleFactor
        }

        function screenY(y) {
            return offsetY - y * scaleFactor
        }

        function worldX(x) {
            return (x - offsetX) / scaleFactor
        }

        function worldY(y) {
            return (offsetY - y) / scaleFactor
        }

        onPaint: {

            var ctx = getContext("2d")

            ctx.clearRect(0, 0, width, height)

            if (!model || model.vertexCount < 2)
                return

            calculateTransform()

            // Grelha
            ctx.strokeStyle = "#35363a"
            ctx.lineWidth = 1

            var grid = 50 * scaleFactor

            if (grid > 8) {

                var startX =
                    offsetX % grid

                var startY =
                    offsetY % grid

                for (var gx = startX; gx < width; gx += grid) {
                    ctx.beginPath()
                    ctx.moveTo(gx, 0)
                    ctx.lineTo(gx, height)
                    ctx.stroke()
                }

                for (var gy = startY; gy < height; gy += grid) {
                    ctx.beginPath()
                    ctx.moveTo(0, gy)
                    ctx.lineTo(width, gy)
                    ctx.stroke()
                }
            }

            // Peça
            ctx.beginPath()

            ctx.moveTo(
                screenX(model.vertexX(0)),
                screenY(model.vertexY(0))
            )

            for (var i = 1; i < model.vertexCount; ++i) {

                ctx.lineTo(
                    screenX(model.vertexX(i)),
                    screenY(model.vertexY(i))
                )
            }

            ctx.closePath()

            ctx.fillStyle = "#59636e"
            ctx.fill()

            ctx.strokeStyle = "#e0e0e0"
            ctx.lineWidth = 2
            ctx.stroke()

            // Eixos
            ctx.strokeStyle = "#666"
            ctx.lineWidth = 1

            var xAxisY = screenY(0)

            if (xAxisY >= 0 && xAxisY <= height) {
                ctx.beginPath()
                ctx.moveTo(0, xAxisY)
                ctx.lineTo(width, xAxisY)
                ctx.stroke()
            }

            var yAxisX = screenX(0)

            if (yAxisX >= 0 && yAxisX <= width) {
                ctx.beginPath()
                ctx.moveTo(yAxisX, 0)
                ctx.lineTo(yAxisX, height)
                ctx.stroke()
            }
        }

        Connections {
            target: model

            function onGeometryChanged() {
                canvas.requestPaint()
            }
        }

        Component.onCompleted: {
            calculateTransform()
            requestPaint()
        }
    }

    Repeater {
        model: root.model ? root.model.vertexCount : 0

        delegate: Item {

            width: 26
            height: 26

            x: canvas.screenX(
                root.model.vertexX(index)
            ) - width / 2

            y: canvas.screenY(
                root.model.vertexY(index)
            ) - height / 2

            Rectangle {
                anchors.centerIn: parent

                width: 14
                height: 14

                radius: 7

                color:
                    index === root.model.selectedIndex
                    ? "#ffb74d"
                    : "#ffffff"

                border.color: "#222"
                border.width: 2
            }

            MouseArea {
                anchors.fill: parent

                cursorShape: Qt.PointingHandCursor

                onPressed: {
                    root.model.selectedIndex = index
                }

                onPositionChanged: {

                    if (!pressed)
                        return

                    var mouseX =
                        mouse.x + parent.x + width / 2

                    var mouseY =
                        mouse.y + parent.y + height / 2

                    var worldX =
                        canvas.worldX(mouseX)

                    var worldY =
                        canvas.worldY(mouseY)

                    root.model.setVertex(
                        index,
                        worldX,
                        worldY
                    )
                }
            }
        }
    }

    // Comprimentos das arestas
    Repeater {
        model: root.model ? root.model.vertexCount : 0

        delegate: Rectangle {
            property int nextIndex:
                (index + 1) % root.model.vertexCount

            property real x1:
                canvas.screenX(
                    root.model.vertexX(index)
                )

            property real y1:
                canvas.screenY(
                    root.model.vertexY(index)
                )

            property real x2:
                canvas.screenX(
                    root.model.vertexX(nextIndex)
                )

            property real y2:
                canvas.screenY(
                    root.model.vertexY(nextIndex)
                )

            x: (x1 + x2) / 2 - width / 2
            y: (y1 + y2) / 2 - height / 2

            width: edgeLabel.width + 6
            height: edgeLabel.height + 6

            color: "#252629"
            radius: 3
            opacity: 0.9

            Text {
                id: edgeLabel

                anchors.centerIn: parent

                text:
                    root.model
                    ? root.model.edgeLength(index).toFixed(1) + " mm"
                    : ""

                color: "#ffffff"

                font.pixelSize: 13
            }
        }
    }
}