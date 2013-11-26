#!/bin/bash -x
#
# Copy this file to build.sh so that gitbuilder can run it.
#
# What happens is that gitbuilder will checkout the revision of your software
# it wants to build in the directory called gitbuilder/build/.  Then it
# does "cd build" and then "../build.sh" to run your script.
#
# You might want to run ./configure here, make, make test, etc.
#

REV="$(git rev-parse HEAD)"
OUTDIR="../out/output/sha1/$REV"
OUTDIR_TMP="${OUTDIR}.tmp"
install -d -m0755 -- "$OUTDIR_TMP"
printf '%s\n' "$REV" >"$OUTDIR_TMP/sha1"

# Macports
export PATH=/opt/local/bin:$PATH

# Haskell userland
export PATH=$PATH:$HOME/.cabal/bin

# Macports gnu
export PATH=/opt/local/libexec/gnubin:$PATH

##  #cabal configure || exit 3
##  make || exit 3
##  #make git-annex || exit 3
##  
##  make -q test
##  if [ "$?" = 1 ]; then
##  	# run "make test", but give it a time limit in case a test gets stuck
##  	../maxtime 1800 make test || exit 4
##  fi

#make install PREFIX=/ DESTDIR=git-annex-master-$(uname)-$(uname -m) || exit 4
#git describe > git-annex-master-$(uname)-$(uname -m)/VERSION
#tar -cvjf git-annex-master-$(uname)-$(uname -m).tar.bz2 git-annex-master-$(uname)-$(uname -m) || exit 4
#mv git-annex-master-$(uname)-$(uname -m).tar.bz2 ../out/dist/ || exit 4

UPGRADE_LOCATION=http://downloads.kitenet.net/git-annex/OSX/current/10.7.5_Lion/git-annex.dmg
export UPGRADE_LOCATION

make osxapp || exit 4
cp -a tmp/git-annex.dmg.bz2 $OUTDIR_TMP

# put our temp files inside .git/ so ls-files doesn't see themgit ls-files --modified >.git/modified-files
if [ -s .git/modified-files ]; then
    rm -rf "$OUTDIR_TMP"
    echo "error: Modified files:" 1>&2
    cat .git/modified-files 1>&2
    exit 6
fi

git ls-files --exclude-standard --others >.git/added-files
if [ -s .git/added-files ]; then
    rm -rf "$OUTDIR_TMP"
    echo "error: Added files:" 1>&2
    cat .git/added-files 1>&2
    exit 7
fi

# we're successful, the files are ok to be published; try to be as
# atomic as possible about replacing potentially existing OUTDIR
if [ -e "$OUTDIR" ]; then
    rm -rf -- "$OUTDIR.old"
    mv -- "$OUTDIR" "$OUTDIR.old"
fi
mv -- "$OUTDIR_TMP" "$OUTDIR"
rm -rf -- "$OUTDIR.old"

exit 0
