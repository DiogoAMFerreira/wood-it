#pragma once

#include <QObject>

#include <vector>

#include "Geometry.h"

class PolygonModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(
        int vertexCount
        READ vertexCount
        NOTIFY geometryChanged
    )

    Q_PROPERTY(
        int selectedIndex
        READ selectedIndex
        WRITE setSelectedIndex
        NOTIFY selectedIndexChanged
    )

    Q_PROPERTY(
        int selectedEdge
        READ selectedEdge
        WRITE setSelectedEdge
        NOTIFY selectedEdgeChanged
    )

    Q_PROPERTY(
        bool selectedEdgeHorizontal
        READ selectedEdgeHorizontal
        NOTIFY constraintsChanged
    )

    Q_PROPERTY(
        bool selectedEdgeVertical
        READ selectedEdgeVertical
        NOTIFY constraintsChanged
    )

public:

    explicit PolygonModel(
        QObject* parent = nullptr
    );

    int vertexCount() const;

    int selectedIndex() const;

    void setSelectedIndex(
        int index
    );

    int selectedEdge() const;

    void setSelectedEdge(
        int index
    );

    bool selectedEdgeHorizontal() const;

    bool selectedEdgeVertical() const;

    Q_INVOKABLE double vertexX(
        int index
    ) const;

    Q_INVOKABLE double vertexY(
        int index
    ) const;

    Q_INVOKABLE void setVertex(
        int index,
        double x,
        double y
    );

    Q_INVOKABLE double edgeLength(
        int edgeIndex
    ) const;

    Q_INVOKABLE void setEdgeLength(
        int edgeIndex,
        double newLength
    );

    Q_INVOKABLE double interiorAngle(
        int vertexIndex
    ) const;

    Q_INVOKABLE double area() const;

    Q_INVOKABLE void addVertex();

    Q_INVOKABLE void deleteSelectedVertex();

    Q_INVOKABLE void setEdgeHorizontal(
        int edgeIndex,
        bool enabled
    );

    Q_INVOKABLE void setEdgeVertical(
        int edgeIndex,
        bool enabled
    );

    Q_INVOKABLE bool edgeIsHorizontal(
        int edgeIndex
    ) const;

    Q_INVOKABLE bool edgeIsVertical(
        int edgeIndex
    ) const;

    Q_INVOKABLE void reset();

signals:

    void geometryChanged();

    void selectedIndexChanged();

    void selectedEdgeChanged();

    void constraintsChanged();

private:

    std::vector<Point2D> m_vertices;

    /*
     * Cada posição corresponde a uma aresta.
     *
     * Exemplo:
     *
     * m_horizontalConstraints[0]
     * = restrição da aresta 0
     */
    std::vector<bool> m_horizontalConstraints;

    std::vector<bool> m_verticalConstraints;

    int m_selectedIndex = 0;

    int m_selectedEdge = -1;
};