TEMPLATE = subdirs
SUBDIRS =
false:contains(QT_CONFIG, v8snapshot): SUBDIRS += mkv8snapshot
