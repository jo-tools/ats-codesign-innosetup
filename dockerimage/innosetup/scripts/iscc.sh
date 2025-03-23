#!/bin/sh

# Create temporary script to execute wine -> ISCC.exe
echo '#!/bin/sh' > /tmp/wine_run.sh
echo 'wine "/root/.wine/dosdevices/c:/Program Files/Inno Setup 6/ISCC.exe" ' $* >> /tmp/iscc_run.sh
chmod 755 /tmp/iscc_run.sh

# Run script
/tmp/iscc_run.sh
ISCC_RESULT=$?

# Cleanup
rm /tmp/iscc_run.sh

# Result
exit $ISCC_RESULT
