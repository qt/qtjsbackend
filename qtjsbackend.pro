TEMPLATE = subdirs

module_qtjsbackend_src.subdir = src
module_qtjsbackend_src.target = module-qtjsbackend-src

module_qtjsbackend_tests.subdir = tests
module_qtjsbackend_tests.target = module-qtjsbackend-tests
module_qtjsbackend_tests.depends = module_qtjsbackend_src
module_qtjsbackend_tests.CONFIG = no_default_install
!contains(QT_BUILD_PARTS,tests):module_qtjsbackend_tests.CONFIG += no_default_target

SUBDIRS += module_qtjsbackend_src \
           module_qtjsbackend_tests

