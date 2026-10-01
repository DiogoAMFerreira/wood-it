#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "PolygonModel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<PolygonModel>(
        "WoodIt",
        1,
        0,
        "PolygonModel"
    );

    QQmlApplicationEngine engine;

    const QUrl url(
        QStringLiteral("qrc:/WoodIt/qml/Main.qml")
    );

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []()
        {
            QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection
    );

    engine.load(url);

    return app.exec();
}