load(configure)
qtCompileTest(hardfloat)

load(qt_parts)

ios {
    log("The qtjsbackend was disabled from the build because V8 is not ported to iOS.")
    SUBDIRS=
}
