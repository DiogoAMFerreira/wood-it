import QtQuick
import QtQuick.Controls

Item {
    id: root

    property var model

    property real zoom: 1.0
    property real panX: 0
    property real panY: 0

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

            scaleFactor =
                Math.min(
                    availableWidth / widthMm,
                    availableHeight / heightMm
                ) * root.zoom

            offsetX =
                (width - widthMm * scaleFactor) / 2
                - minX * scaleFactor
                + root.panX

            offsetY =
                (height + heightMm * scaleFactor) / 2
                + minY * scaleFactor
                + root.panY
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

            // GRID

            ctx.strokeStyle = "#35363a"
            ctx.lineWidth = 1

            var grid = 50 * scaleFactor

            if (grid > 8) {
                var startX = offsetX % grid
                var startY = offsetY % grid

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

            // POLYGON

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

            // EDGES

            for (var e = 0; e < model.vertexCount; ++e) {
                var next =
                    (e + 1) % model.vertexCount

                var x1 =
                    screenX(model.vertexX(e))

                var y1 =
                    screenY(model.vertexY(e))

                var x2 =
                    screenX(model.vertexX(next))

                var y2 =
                    screenY(model.vertexY(next))

                ctx.beginPath()
                ctx.moveTo(x1, y1)
                ctx.lineTo(x2, y2)

                if (e === model.selectedEdge) {
                    ctx.strokeStyle = "#ffb74d"
                    ctx.lineWidth = 5
                } else {
                    ctx.strokeStyle = "#e0e0e0"
                    ctx.lineWidth = 2
                }

                ctx.stroke()
            }

            // AXES

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

            function onSelectedIndexChanged() {
                canvas.requestPaint()
            }

            function onSelectedEdgeChanged() {
                canvas.requestPaint()
            }
        }

        Component.onCompleted: {
            calculateTransform()
            requestPaint()
        }
    }

    // =========================================================
    // EDGE CLICK AREAS
    // =========================================================

    Repeater {
        model: root.model
            ? root.model.vertexCount
            : 0

        delegate: MouseArea {
            property int nextIndex:
                (index + 1) %
                root.model.vertexCount

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

            property real edgeWidth:
                Math.max(1, Math.abs(x2 - x1))

            property real edgeHeight:
                Math.max(1, Math.abs(y2 - y1))

            x: Math.min(x1, x2) - 10
            y: Math.min(y1, y2) - 10

            width: edgeWidth + 20
            height: edgeHeight + 20

            acceptedButtons: Qt.LeftButton

            hoverEnabled: true

            onClicked: {
                root.model.selectedEdge = index
                root.model.selectedIndex = index
            }

            onPressed: {
                root.model.selectedEdge = index
            }

            Rectangle {
                anchors.centerIn: parent

                visible:
                    parent.containsMouse &&
                    root.model.selectedEdge !== index

                width: 8
                height: 8

                radius: 4

                color: "#aaaaaa"
            }
        }
    }

    // =========================================================
    // VERTICES
    // =========================================================

    Repeater {
        model: root.model
            ? root.model.vertexCount
            : 0

        delegate: Item {
            width: 28
            height: 28

            x:
                canvas.screenX(
                    root.model.vertexX(index)
                ) - width / 2

            y:
                canvas.screenY(
                    root.model.vertexY(index)
                ) - height / 2

            Rectangle {
                anchors.centerIn: parent

                width: 15
                height: 15

                radius: 7.5

                color:
                    index === root.model.selectedIndex
                    ? "#ffb74d"
                    : "#ffffff"

                border.color: "#222"
                border.width: 2
            }

            MouseArea {
                anchors.fill: parent

                cursorShape:
                    Qt.PointingHandCursor

                onPressed: {
                    root.model.selectedIndex = index
                    root.model.selectedEdge = -1
                }

                onPositionChanged: {
                    if (!pressed)
                        return

                    var mouseX =
                        mouse.x +
                        parent.x +
                        width / 2

                    var mouseY =
                        mouse.y +
                        parent.y +
                        height / 2

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

    // =========================================================
    // EDGE LENGTH LABELS
    // =========================================================

    Repeater {
        model: root.model
            ? root.model.vertexCount
            : 0

        delegate: Rectangle {
            property int nextIndex:
                (index + 1) %
                root.model.vertexCount

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

            x:
                (x1 + x2) / 2
                - width / 2

            y:
                (y1 + y2) / 2
                - height / 2

            width: edgeLabel.width + 10
            height: edgeLabel.height + 6

            color:
                root.model.selectedEdge === index
                ? "#6d4c41"
                : "#252629"

            radius: 3

            opacity:
                root.model.selectedEdge === index
                ? 1.0
                : 0.85

            Text {
                id: edgeLabel

                anchors.centerIn: parent

                text:
                    root.model
                    ? root.model.edgeLength(index)
                        .toFixed(1) + " mm"
                    : ""

                color: "#ffffff"

                font.pixelSize: 13
            }
        }
    }

    // =========================================================
    // ANGLE LABELS
    // =========================================================

    Repeater {
        model: root.model
            ? root.model.vertexCount
            : 0

        delegate: Text {
            property real vx:
                canvas.screenX(
                    root.model.vertexX(index)
                )

            property real vy:
                canvas.screenY(
                    root.model.vertexY(index)
                )

            x: vx + 12
            y: vy + 10

            text:
                root.model
                ? root.model
                    .interiorAngle(index)
                    .toFixed(1) + "°"
                : ""

            color:
                index === root.model.selectedIndex
                ? "#ffb74d"
                : "#bbbbbb"

            font.pixelSize: 11
        }
    }

    // =========================================================
    // PAN
    // =========================================================

    MouseArea {
        anchors.fill: parent

        acceptedButtons: Qt.RightButton

        property real lastX: 0
        property real lastY: 0

        onPressed: {
            lastX = mouse.x
            lastY = mouse.y
        }

        onPositionChanged: {
            if (!pressed)
                return

            root.panX += mouse.x - lastX
            root.panY += mouse.y - lastY

            lastX = mouse.x
            lastY = mouse.y

            canvas.requestPaint()
        }
    }

    // =========================================================
    // ZOOM
    // =========================================================

    WheelHandler {
        acceptedDevices:
            PointerDevice.Mouse |
            PointerDevice.TouchPad

        onWheel: function(event) {
            var factor =
                event.angleDelta.y > 0
                ? 1.15
                : 0.87

            root.zoom =
                Math.max(
                    0.2,
                    Math.min(
                        5.0,
                        root.zoom * factor
                    )
                )

            canvas.requestPaint()
        }
    }
}