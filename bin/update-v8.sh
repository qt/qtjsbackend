#!/bin/bash
#############################################################################
##
## Copyright (C) 2012 Nokia Corporation and/or its subsidiary(-ies).
## Contact: http://www.qt-project.org/
##
## This file is the build configuration utility of the Qt Toolkit.
##
## $QT_BEGIN_LICENSE:LGPL$
## GNU Lesser General Public License Usage
## This file may be used under the terms of the GNU Lesser General Public
## License version 2.1 as published by the Free Software Foundation and
## appearing in the file LICENSE.LGPL included in the packaging of this
## file. Please review the following information to ensure the GNU Lesser
## General Public License version 2.1 requirements will be met:
## http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
##
## In addition, as a special exception, Nokia gives you certain additional
## rights. These rights are described in the Nokia Qt LGPL Exception
## version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
##
## GNU General Public License Usage
## Alternatively, this file may be used under the terms of the GNU General
## Public License version 3.0 as published by the Free Software Foundation
## and appearing in the file LICENSE.GPL included in the packaging of this
## file. Please review the following information to ensure the GNU General
## Public License version 3.0 requirements will be met:
## http://www.gnu.org/copyleft/gpl.html.
##
## Other Usage
## Alternatively, this file may be used in accordance with the terms and
## conditions contained in a signed written agreement between you and Nokia.
##
##
##
##
##
##
## $QT_END_LICENSE$
##
#############################################################################

die() {
    echo $*
    exit 1
}

if [ $# -eq 2 ]; then
    repository=$1
    tag=$2
else
    die "usage: $0 [url] [commit]"
fi

require_clean_work_tree() {
    # test if working tree is dirty
    git rev-parse --verify HEAD > /dev/null &&
    git update-index --refresh &&
    git diff-files --quiet &&
    git diff-index --cached --quiet HEAD ||
    die "Working tree is dirty"
}

test -z "$(git rev-parse --show-cdup)" || {
       exit=$?
       echo >&2 "You need to run this command from the toplevel of the working tree."
       exit $exit
}

echo "checking working tree"
require_clean_work_tree

echo "fetching"
git fetch $repository $tag
if [ $? != 0 ]; then
    die "git fetch failed"
fi

rev=`git rev-parse FETCH_HEAD`

srcdir=src/3rdparty/v8
absSrcDir=$PWD/$srcdir
localDiff=

echo "replacing $srcdir"
if [  -d $srcdir ]; then
    git ls-files $srcdir | xargs rm
    git ls-files -z $srcdir | git update-index --force-remove -z --stdin
    lastImport=`git rev-list --max-count=1 HEAD -- $srcdir/ChangeLog`
    changes=`git rev-list --no-merges --reverse $lastImport.. -- $srcdir`
    localDiff=/tmp/v8_patch
    echo -n>$localDiff
    for change in $changes; do
        echo "Saving commit $change"
        git show -p --stat "--pretty=format:%nFrom %H Mon Sep 17 00:00:00 2001%nFrom: %an <%ae>%nDate: %ad%nSubject: %s%n%b%n" $change -- $srcdir >> $localDiff
        echo "-- " >> $localDiff
        echo "1.2.3" >> $localDiff
        echo >> $localDiff
    done
    if [ -s $localDiff ]; then
        echo "Saved locally applied patches to $localDiff"
    else
        localDiff=""
    fi
else
    mkdir -p $srcdir
fi

git read-tree --prefix=$srcdir $rev
git checkout $srcdir

cat >commitlog.txt <<EOT
Updated V8 from $repository to $rev
EOT

echo "Changes:"
echo
git --no-pager diff --name-status --cached $srcdir

echo
echo "Wrote commitlog.txt. Use with"
echo
echo "    git commit -e -F commitlog.txt"
echo
echo "to commit your changes"

if [ -n "$localDiff" ]; then
    echo
    echo "The Qt specific modifications to V8 are now stored as a git patch in $localDiff"
    echo "You may want to appy them with"
    echo
    echo "    git am -3 $localDiff"
    echo
fi
