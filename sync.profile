%modules = ( # path to module name map
    "QtV8" => "$basedir/src/v8",
);
%moduleheaders = ( # restrict the module headers to those found in relative path
    "QtV8" => "../3rdparty/v8/include",
);
@allmoduleheadersprivate = (
    "QtV8"
);
%classnames = (
    "qtv8version.h" => "QtV8Version",
);
%mastercontent = ();
%modulepris = (
    "QtV8" => "$basedir/src/modules/qt_v8.pri",
);

# Module dependencies.
# Every module that is required to build this module should have one entry.
# Each of the module version specifiers can take one of the following values:
#   - A specific Git revision.
#   - any git symbolic ref resolvable from the module's repository (e.g. "refs/heads/master" to track master branch)
#
%dependencies = (
        "qtbase" => "refs/heads/master",
);
