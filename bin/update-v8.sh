#!/bin/bash

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
