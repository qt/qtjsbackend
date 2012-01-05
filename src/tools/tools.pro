TEMPLATE = subdirs
SUBDIRS =
!cross_compile:contains(QT_CONFIG, v8snapshot): SUBDIRS += mkv8snapshot
