#! /bin/bash
#
# pfx-innosetup-wine.sh [FILE (such as called from wine)]
# This Script needs to be called from pfx-codesign.bat.
# The Batch Script wait for FILE.signed until it exits.

# InnoSetup signed per file ($f)
# The Parameter will be a Windows style path in Quotes.
# Let's convert that to the corresponding Linux path.
# The reason we're doing this manually is that "winepath"
# doesn't work on arm64 (a lot of other output from box).
FILE=$1

# Remove surrounding quotes
FILE=${FILE//\"/}

# Replace Windows drive letter at the beginning
if [[ $FILE =~ ^[A-Z]:\\ ]]; then
    FILE="/${FILE:3}"  # Remove first 3 characters (e.g., "Z:\") and replace with "/"
fi

# Replace backslashes with forward slashes
FILE=${FILE//\\//}

# Call pfx-codesign.sh to sign the file
/usr/local/bin/pfx-codesign.sh "${FILE}"
PFX_CODESIGN_RESULT=$?

# Write temporary FILE.signed
echo "signed" > "${FILE}.signed"

exit $PFX_CODESIGN_RESULT
