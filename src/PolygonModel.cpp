#include "PolygonModel.h"

#include <algorithm>
#include <cmath>


PolygonModel::PolygonModel(QObject* parent)
    : QObject(parent)
{
    reset();
}


// ============================================================
// VERTICES
// ============================================================

int PolygonModel::vertexCount() const
{
    return static_cast<int>(
        m_vertices.size()
    );
}


int PolygonModel::selectedIndex() const
{
    return m_selectedIndex;
}


void PolygonModel::setSelectedIndex(
    int index
)
{
    if (index < 0 ||
        index >= vertexCount())
    {
        return;
    }

    if (m_selectedIndex == index)
        return;

    m_selectedIndex = index;

    emit selectedIndexChanged();
}


// ============================================================
// ARESTA SELECIONADA
// ============================================================

int PolygonModel::selectedEdge() const
{
    return m_selectedEdge;
}


void PolygonModel::setSelectedEdge(
    int index
)
{
    if (index < -1 ||
        index >= vertexCount())
    {
        return;
    }

    if (m_selectedEdge == index)
        return;

    m_selectedEdge = index;

    emit selectedEdgeChanged();

    emit constraintsChanged();
}


// ============================================================
// PROPRIEDADES DAS RESTRIÇÕES
// ============================================================

bool PolygonModel::selectedEdgeHorizontal() const
{
    if (m_selectedEdge < 0 ||
        m_selectedEdge >= vertexCount())
    {
        return false;
    }

    return m_horizontalConstraints[
        m_selectedEdge
    ];
}


bool PolygonModel::selectedEdgeVertical() const
{
    if (m_selectedEdge < 0 ||
        m_selectedEdge >= vertexCount())
    {
        return false;
    }

    return m_verticalConstraints[
        m_selectedEdge
    ];
}


// ============================================================
// COORDENADAS
// ============================================================

double PolygonModel::vertexX(
    int index
) const
{
    if (index < 0 ||
        index >= vertexCount())
    {
        return 0.0;
    }

    return m_vertices[index].x;
}


double PolygonModel::vertexY(
    int index
) const
{
    if (index < 0 ||
        index >= vertexCount())
    {
        return 0.0;
    }

    return m_vertices[index].y;
}


// ============================================================
// ALTERAR VÉRTICE
// ============================================================

void PolygonModel::setVertex(
    int index,
    double x,
    double y
)
{
    if (index < 0 ||
        index >= vertexCount())
    {
        return;
    }

    m_vertices[index].x = x;
    m_vertices[index].y = y;

    /*
     * Aplicar restrições das arestas ligadas
     * ao vértice que acabou de ser alterado.
     */

    const int previous =
        (index - 1 + vertexCount())
        % vertexCount();

    const int next =
        (index + 1)
        % vertexCount();


    // --------------------------------------------------------
    // Aresta anterior
    // --------------------------------------------------------

    if (m_horizontalConstraints[previous])
    {
        m_vertices[previous].y =
            m_vertices[index].y;
    }

    if (m_verticalConstraints[previous])
    {
        m_vertices[previous].x =
            m_vertices[index].x;
    }


    // --------------------------------------------------------
    // Aresta seguinte
    // --------------------------------------------------------

    if (m_horizontalConstraints[index])
    {
        m_vertices[next].y =
            m_vertices[index].y;
    }

    if (m_verticalConstraints[index])
    {
        m_vertices[next].x =
            m_vertices[index].x;
    }


    emit geometryChanged();
}


// ============================================================
// COMPRIMENTO DA ARESTA
// ============================================================

double PolygonModel::edgeLength(
    int edgeIndex
) const
{
    if (vertexCount() < 2)
        return 0.0;

    if (edgeIndex < 0 ||
        edgeIndex >= vertexCount())
    {
        return 0.0;
    }

    const int next =
        (edgeIndex + 1)
        % vertexCount();

    return Geometry::distance(
        m_vertices[edgeIndex],
        m_vertices[next]
    );
}


// ============================================================
// ALTERAR COMPRIMENTO
// ============================================================

void PolygonModel::setEdgeLength(
    int edgeIndex,
    double newLength
)
{
    if (edgeIndex < 0 ||
        edgeIndex >= vertexCount())
    {
        return;
    }

    if (newLength <= 0.0)
        return;

    const int next =
        (edgeIndex + 1)
        % vertexCount();

    const Point2D& start =
        m_vertices[edgeIndex];

    Point2D& end =
        m_vertices[next];

    const double dx =
        end.x - start.x;

    const double dy =
        end.y - start.y;

    const double currentLength =
        std::hypot(dx, dy);

    if (currentLength < 0.000001)
        return;

    /*
     * Mantém a direção atual da aresta
     * e altera apenas o comprimento.
     */

    const double scale =
        newLength / currentLength;

    end.x =
        start.x + dx * scale;

    end.y =
        start.y + dy * scale;


    /*
     * Se existir uma restrição horizontal,
     * garantimos Y igual.
     */

    if (m_horizontalConstraints[edgeIndex])
    {
        end.y =
            start.y;
    }


    /*
     * Se existir uma restrição vertical,
     * garantimos X igual.
     */

    if (m_verticalConstraints[edgeIndex])
    {
        end.x =
            start.x;
    }


    emit geometryChanged();
}


// ============================================================
// ÂNGULO
// ============================================================

double PolygonModel::interiorAngle(
    int vertexIndex
) const
{
    return Geometry::interiorAngle(
        m_vertices,
        vertexIndex
    );
}


// ============================================================
// ÁREA
// ============================================================

double PolygonModel::area() const
{
    return std::abs(
        Geometry::polygonArea(
            m_vertices
        )
    );
}


// ============================================================
// VERIFICAR RESTRIÇÃO HORIZONTAL
// ============================================================

bool PolygonModel::edgeIsHorizontal(
    int edgeIndex
) const
{
    if (edgeIndex < 0 ||
        edgeIndex >= vertexCount())
    {
        return false;
    }

    return m_horizontalConstraints[
        edgeIndex
    ];
}


// ============================================================
// VERIFICAR RESTRIÇÃO VERTICAL
// ============================================================

bool PolygonModel::edgeIsVertical(
    int edgeIndex
) const
{
    if (edgeIndex < 0 ||
        edgeIndex >= vertexCount())
    {
        return false;
    }

    return m_verticalConstraints[
        edgeIndex
    ];
}


// ============================================================
// DEFINIR HORIZONTAL
// ============================================================

void PolygonModel::setEdgeHorizontal(
    int edgeIndex,
    bool enabled
)
{
    if (edgeIndex < 0 ||
        edgeIndex >= vertexCount())
    {
        return;
    }

    m_horizontalConstraints[
        edgeIndex
    ] = enabled;


    /*
     * Horizontal e Vertical são incompatíveis.
     *
     * Se ativarmos Horizontal,
     * desligamos Vertical.
     */

    if (enabled)
    {
        m_verticalConstraints[
            edgeIndex
        ] = false;

        const int next =
            (edgeIndex + 1)
            % vertexCount();

        m_vertices[next].y =
            m_vertices[edgeIndex].y;
    }


    emit geometryChanged();

    emit constraintsChanged();
}


// ============================================================
// DEFINIR VERTICAL
// ============================================================

void PolygonModel::setEdgeVertical(
    int edgeIndex,
    bool enabled
)
{
    if (edgeIndex < 0 ||
        edgeIndex >= vertexCount())
    {
        return;
    }

    m_verticalConstraints[
        edgeIndex
    ] = enabled;


    /*
     * Horizontal e Vertical são incompatíveis.
     */

    if (enabled)
    {
        m_horizontalConstraints[
            edgeIndex
        ] = false;

        const int next =
            (edgeIndex + 1)
            % vertexCount();

        m_vertices[next].x =
            m_vertices[edgeIndex].x;
    }


    emit geometryChanged();

    emit constraintsChanged();
}


// ============================================================
// ADICIONAR VÉRTICE
// ============================================================

void PolygonModel::addVertex()
{
    if (vertexCount() < 2)
        return;


    Point2D p;

    double minX =
        m_vertices[0].x;

    double maxX =
        m_vertices[0].x;

    double minY =
        m_vertices[0].y;

    double maxY =
        m_vertices[0].y;


    for (const auto& point : m_vertices)
    {
        minX =
            std::min(
                minX,
                point.x
            );

        maxX =
            std::max(
                maxX,
                point.x
            );

        minY =
            std::min(
                minY,
                point.y
            );

        maxY =
            std::max(
                maxY,
                point.y
            );
    }


    p.x =
        (minX + maxX) / 2.0;

    p.y =
        (minY + maxY) / 2.0;


    m_vertices.push_back(p);

    m_horizontalConstraints.push_back(
        false
    );

    m_verticalConstraints.push_back(
        false
    );


    m_selectedIndex =
        vertexCount() - 1;

    m_selectedEdge = -1;


    emit geometryChanged();

    emit selectedIndexChanged();

    emit selectedEdgeChanged();

    emit constraintsChanged();
}


// ============================================================
// APAGAR VÉRTICE
// ============================================================

void PolygonModel::deleteSelectedVertex()
{
    /*
     * Nunca permitir menos de 3 vértices.
     */

    if (vertexCount() <= 3)
        return;

    if (m_selectedIndex < 0 ||
        m_selectedIndex >= vertexCount())
    {
        return;
    }


    /*
     * Ao remover um vértice,
     * removemos também a restrição
     * da aresta que começa nesse vértice.
     */

    m_horizontalConstraints.erase(
        m_horizontalConstraints.begin()
        + m_selectedIndex
    );

    m_verticalConstraints.erase(
        m_verticalConstraints.begin()
        + m_selectedIndex
    );


    m_vertices.erase(
        m_vertices.begin()
        + m_selectedIndex
    );


    /*
     * Agora existem menos arestas,
     * portanto garantimos que os arrays
     * continuam sincronizados.
     */

    while (
        static_cast<int>(
            m_horizontalConstraints.size()
        ) < vertexCount()
    )
    {
        m_horizontalConstraints.push_back(
            false
        );
    }

    while (
        static_cast<int>(
            m_verticalConstraints.size()
        ) < vertexCount()
    )
    {
        m_verticalConstraints.push_back(
            false
        );
    }


    if (m_selectedIndex >= vertexCount())
    {
        m_selectedIndex =
            vertexCount() - 1;
    }


    m_selectedEdge = -1;


    emit geometryChanged();

    emit selectedIndexChanged();

    emit selectedEdgeChanged();

    emit constraintsChanged();
}


// ============================================================
// RESET
// ============================================================

void PolygonModel::reset()
{
    m_vertices.clear();

    m_horizontalConstraints.clear();

    m_verticalConstraints.clear();


    m_vertices.push_back({
        0.0,
        0.0
    });

    m_vertices.push_back({
        600.0,
        0.0
    });

    m_vertices.push_back({
        600.0,
        400.0
    });

    m_vertices.push_back({
        0.0,
        400.0
    });


    /*
     * Uma entrada por aresta.
     */

    m_horizontalConstraints.resize(
        m_vertices.size(),
        false
    );

    m_verticalConstraints.resize(
        m_vertices.size(),
        false
    );


    m_selectedIndex = 0;

    m_selectedEdge = -1;


    emit geometryChanged();

    emit selectedIndexChanged();

    emit selectedEdgeChanged();

    emit constraintsChanged();
}