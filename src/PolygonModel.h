#pragma once

#include <QObject>
#include <QVariantList>

#include "Geometry.h"

class PolygonModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int vertexCount READ vertexCount NOTIFY geometryChanged)
    Q_PROPERTY(int selectedIndex READ selectedIndex
               WRITE setSelectedIndex
               NOTIFY selectedIndexChanged)

public:
    explicit PolygonModel(QObject* parent = nullptr);

    int vertexCount() const;

    int selectedIndex() const;
    void setSelectedIndex(int index);

    Q_INVOKABLE double vertexX(int index) const;
    Q_INVOKABLE double vertexY(int index) const;

    Q_INVOKABLE void setVertex(
        int index,
        double x,
        double y);

    Q_INVOKABLE double edgeLength(int edgeIndex) const;

    Q_INVOKABLE double interiorAngle(int vertexIndex) const;

    Q_INVOKABLE double area() const;

    Q_INVOKABLE void addVertex();

    Q_INVOKABLE void reset();

signals:
    void geometryChanged();
    void selectedIndexChanged();

private:
    std::vector<Point2D> m_vertices;
    int m_selectedIndex = 0;
};