#include <QMimeDatabase>
#include <cassert>


int main(int argc, char *argv[]) {
    QMimeDatabase db;
    assert(db.allMimeTypes().size() > 0);
}