#pragma once

#include <vector>
#include <cmath>
#include <algorithm>

struct Point2D
{
    double x = 0.0;
    double y = 0.0;
};

namespace Geometry
{
    inline double distance(const Point2D& a, const Point2D& b)
    {
        const double dx = b.x - a.x;
        const double dy = b.y - a.y;

        return std::hypot(dx, dy);
    }

    inline double cross(
        const Point2D& a,
        const Point2D& b,
        const Point2D& c)
    {
        return
            (b.x - a.x) * (c.y - a.y) -
            (b.y - a.y) * (c.x - a.x);
    }

    inline double polygonArea(const std::vector<Point2D>& points)
    {
        if (points.size() < 3)
            return 0.0;

        double area = 0.0;

        for (size_t i = 0; i < points.size(); ++i)
        {
            const auto& a = points[i];
            const auto& b = points[(i + 1) % points.size()];

            area += a.x * b.y;
            area -= b.x * a.y;
        }

        return area * 0.5;
    }

    inline double interiorAngle(
        const std::vector<Point2D>& points,
        int index)
    {
        const int n = static_cast<int>(points.size());

        if (n < 3 || index < 0 || index >= n)
            return 0.0;

        const int previous = (index - 1 + n) % n;
        const int next = (index + 1) % n;

        const Point2D& current = points[index];
        const Point2D& p1 = points[previous];
        const Point2D& p2 = points[next];

        const double ux = p1.x - current.x;
        const double uy = p1.y - current.y;

        const double vx = p2.x - current.x;
        const double vy = p2.y - current.y;

        const double lenU = std::hypot(ux, uy);
        const double lenV = std::hypot(vx, vy);

        if (lenU < 1e-9 || lenV < 1e-9)
            return 0.0;

        double dot = ux * vx + uy * vy;

        dot /= lenU * lenV;

        dot = std::clamp(dot, -1.0, 1.0);

        double angle = std::acos(dot);

        // Determina se o vértice é côncavo.
        const double turn = ux * vy - uy * vx;
        const double area = polygonArea(points);

        if (area > 0.0 && turn > 0.0)
            angle = 2.0 * M_PI - angle;

        if (area < 0.0 && turn < 0.0)
            angle = 2.0 * M_PI - angle;

        return angle * 180.0 / M_PI;
    }
}