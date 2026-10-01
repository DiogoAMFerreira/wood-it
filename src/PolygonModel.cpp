#include "PolygonModel.h"

PolygonModel::PolygonModel(QObject* parent)
    : QObject(parent)
{
    reset();
}

int PolygonModel::vertexCount() const
{
    return static_cast<int>(m_vertices.size());
}

int PolygonModel::selectedIndex() const
{
    return m_selectedIndex;
}

void PolygonModel::setSelectedIndex(int index)
{
    if (index < 0 || index >= vertexCount())
        return;

    if (m_selectedIndex == index)
        return;

    m_selectedIndex = index;

    emit selectedIndexChanged();
}

double PolygonModel::vertexX(int index) const
{
    if (index < 0 || index >= vertexCount())
        return 0.0;

    return m_vertices[index].x;
}

double PolygonModel::vertexY(int index) const
{
    if (index < 0 || index >= vertexCount())
        return 0.0;

    return m_vertices[index].y;
}

void PolygonModel::setVertex(
    int index,
    double x,
    double y)
{
    if (index < 0 || index >= vertexCount())
        return;

    m_vertices[index].x = x;
    m_vertices[index].y = y;

    emit geometryChanged();
}

double PolygonModel::edgeLength(int edgeIndex) const
{
    if (m_vertices.size() < 2)
        return 0.0;

    if (edgeIndex < 0 ||
        edgeIndex >= static_cast<int>(m_vertices.size()))
        return 0.0;

    const int next =
        (edgeIndex + 1) %
        static_cast<int>(m_vertices.size());

    return Geometry::distance(
        m_vertices[edgeIndex],
        m_vertices[next]);
}

double PolygonModel::interiorAngle(int vertexIndex) const
{
    return Geometry::interiorAngle(
        m_vertices,
        vertexIndex);
}

double PolygonModel::area() const
{
    return std::abs(
        Geometry::polygonArea(m_vertices));
}

void PolygonModel::addVertex()
{
    if (m_vertices.size() < 2)
        return;

    // Adiciona inicialmente um ponto perto do centro.
    // Mais tarde vamos permitir inserir diretamente
    // numa aresta selecionada.
    Point2D p;

    double minX = m_vertices[0].x;
    double maxX = m_vertices[0].x;
    double minY = m_vertices[0].y;
    double maxY = m_vertices[0].y;

    for (const auto& point : m_vertices)
    {
        minX = std::min(minX, point.x);
        maxX = std::max(maxX, point.x);

        minY = std::min(minY, point.y);
        maxY = std::max(maxY, point.y);
    }

    p.x = (minX + maxX) / 2.0;
    p.y = (minY + maxY) / 2.0;

    m_vertices.push_back(p);

    m_selectedIndex = vertexCount() - 1;

    emit geometryChanged();
    emit selectedIndexChanged();
}

void PolygonModel::reset()
{
    m_vertices.clear();

    // Retângulo inicial: 600 x 400 mm
    m_vertices.push_back({0.0, 0.0});
    m_vertices.push_back({600.0, 0.0});
    m_vertices.push_back({600.0, 400.0});
    m_vertices.push_back({0.0, 400.0});

    m_selectedIndex = 0;

    emit geometryChanged();
    emit selectedIndexChanged();
}