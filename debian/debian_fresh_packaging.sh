#!/bin/sh

export NAME="Filipe Azevedo"
export EMAIL="pasnox@gmail.com"
export DEBNAME="$NAME"
export DEBFULLNAME="$NAME"
export DEBEMAIL="$EMAIL"

FRESH_NAME="fresh"
FRESH_VERSION="1.1.0"
FRESH_SUFFIX=".tar.gz"
FRESH_LIB="$FRESH_NAME-$FRESH_VERSION"
FRESH_LIB_SRC="$FRESH_LIB-src"
DEB_FRESH_LIB="$FRESH_NAME"_"$FRESH_VERSION"
FRESH_FILE="$FRESH_LIB$FRESH_SUFFIX"
FRESH_FILE_SRC="$FRESH_LIB_SRC$FRESH_SUFFIX"
DEB_FRESH_ORIG_FILE="$DEB_FRESH_LIB-3.orig$FRESH_SUFFIX"
DEB_PATH="$DEB_FRESH_LIB/debian"
FRESH_URL="https://github.com/downloads/pasnox/fresh/$FRESH_FILE_SRC"

# load usefull functions
. ./functions.sh

# clean files
# $1= optional string meaning some files will not be deleted
clean() {
    # files always deleted
    rm -fr "$DEB_FRESH_LIB"
    rm "$FRESH_NAME"*"$FRESH_SUFFIX"
    rm "$FRESH_NAME"*.build
    rm "$FRESH_NAME"*.upload
    rm "$FRESH_NAME"*.dsc

    # not remove this files is $1 is not empty
    if [ ! -z "$1" ] ; then
        rm "$FRESH_NAME"*.changes
    fi
}

create_debian() {
    banner "Remove debian folder..."
    rm -fr "$DEB_PATH"

    cd "$DEB_PATH"
    if [ ! -d "$DEB_PATH" ] ; then
        banner "Creating debian package folder..."
        dh_make -c "lgpl3" -f "$START_PWD/$FRESH_FILE_SRC" --createorig -l << EOF
EOF
    fi

    cd "$DEB_PATH"
    #if [ -e *.ex ] || [ -e *.EX ] ; then
        banner "Deleting temp files in debian folder..."
        rm *.ex *.EX > /dev/null 2>&1
    #fi
}

copy_files() {
    if [ -e "$START_PWD/rules" ] ; then
        banner "Copying package files..."
        DEB_FILES="changelog control copyright rules compat"
        for file in $DEB_FILES ; do
            cp -f "$START_PWD/$file" .
        done
    fi
}

# loader
banner "Packaging Fresh for Debian..."

clean

# Getting the sources and uncompressing
if [ ! -d "$DEB_FRESH_LIB" ]; then
    banner "Getting sources..."

    if [ ! -e "$FRESH_FILE" ] && [ ! -e "$FRESH_FILE_SRC" ] ; then
        if [ -e "../fresh.pro" ] ; then
            cd ..
            git archive --prefix="$DEB_FRESH_LIB/" master | gzip -9 > "debian/$FRESH_FILE_SRC"
            cd "$START_PWD"
        else
            wget "$FRESH_URL"
        fi
    fi

    arc=`basename "$FRESH_FILE_SRC"`
    unpack "$arc"
    arc=`basename "$FRESH_FILE_SRC" $FRESH_SUFFIX`

    if [ -d "$arc" ] ; then
        if [ "$arc" != "$DEB_FRESH_LIB" ] ; then
            mv "$arc" "$DEB_FRESH_LIB"
        fi
    fi

    # recreate archive with updated debian folder
    rm "$FRESH_NAME"*"$FRESH_SUFFIX"
    rm -fr "$DEB_PATH/"*
    cp * "$DEB_PATH/"
    cp -r source "$DEB_PATH/"
    tar -pczhf "$FRESH_FILE_SRC" "$DEB_FRESH_LIB"

    if [ ! -e "$DEB_FRESH_ORIG_FILE" ] ; then
        ln -s "$START_PWD/$FRESH_FILE_SRC" "$DEB_FRESH_ORIG_FILE"
    fi
fi

banner "Generate package files..."
cd "$DEB_FRESH_LIB"
debuild -S
cd ..

banner "Build package..."
#sudo pbuilder build "$DEB_FRESH_LIB"*.dsc
sudo cowbuilder --build "$DEB_FRESH_LIB"*.dsc

banner "Uploading package..."
dput ppa:pasnox/ppa "$DEB_FRESH_LIB"*source.changes

clean -

banner "Package done."