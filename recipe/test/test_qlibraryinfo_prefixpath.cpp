#include <QCoreApplication>
#include <QLibraryInfo>
#include <QDebug>
#include <cstdlib>
#include <QDir>

// This is a regression test for https://github.com/conda-forge/qt-main-feedstock/issues/275
int main(int argc, char *argv[])
{
    QString prefixPath = QLibraryInfo::path(QLibraryInfo::PrefixPath);

    QByteArray envCondaprefix = qgetenv("CONDA_PREFIX");
    if (envCondaprefix.isEmpty()) {
        qCritical() << "CONDA_PREFIX is not set in the environment";
        return EXIT_FAILURE;
    }

    QString expected = QString::fromUtf8(envCondaprefix.constData());

#ifdef Q_OS_WIN
    // On Windows, Qt installs under %CONDA_PREFIX%/Library
    QDir d(expected);
    expected = QDir::cleanPath(d.filePath("Library"));
#else
    expected = QDir::cleanPath(expected);
#endif

    QString actual = QDir::cleanPath(prefixPath);

    bool comparison = false;

    // On Windows comparison should be case-insensitive
#ifdef Q_OS_WIN
    comparison = (actual.compare(expected, Qt::CaseInsensitive) == 0);
#else
    comparison = (actual == expected);
#endif

    if (!comparison) {
        qCritical() << "Prefix mismatch:";
        qCritical() << "  QLibraryInfo::PrefixPath:" << actual;
        qCritical() << "  Expected:" << expected;
        return EXIT_FAILURE;
    }

    qDebug() << "Prefix matches expected:" << actual;
    return EXIT_SUCCESS;
}
