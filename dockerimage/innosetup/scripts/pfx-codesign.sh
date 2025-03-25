#! /bin/bash
#
# pfx-codesign.sh [FILE] [PATTERN] [@FILELIST]...

JSIGN_PARAMETERS=("$@")

echo "Setting up Environment"

PFX_JSON="/etc/pfx-codesign/pfx.json"
PFX_CERTIFICATE="/etc/pfx-codesign/certificate.pfx"

if [ -z "${PFX_PASSWORD}" ]; then
	PFX_PASSWORD=$( [ -f ${PFX_JSON} ] && cat ${PFX_JSON} | jq -r '.Password')
fi

JSIGN_TSAURL=
if [ ! -z "${TIMESTAMP_SERVER}" ]; then
	JSIGN_TSAURL="--tsaurl ${TIMESTAMP_SERVER}"
fi
if [ -z "${JSIGN_TSAURL}" ]; then
	JSIGN_TSAURL=$( [ -f ${PFX_JSON} ] && cat ${PFX_JSON} | jq -r '.TimestampServer')
	if [ ! -z "${JSIGN_TSAURL}" ]; then
		JSIGN_TSAURL="--tsaurl ${JSIGN_TSAURL}"
	fi
fi

JSIGN_TSMODE=
if [ ! -z "${TIMESTAMP_MODE}" ]; then
	JSIGN_TSMODE="--tsmode ${TIMESTAMP_MODE}"
fi
if [ -z "${JSIGN_TSMODE}" ]; then
	JSIGN_TSMODE=$( [ -f ${PFX_JSON} ] && cat ${PFX_JSON} | jq -r '.TimestampMode')
	if [ ! -z "${JSIGN_TSMODE}" ]; then
		JSIGN_TSMODE="--tsmode ${JSIGN_TSMODE}"
	fi
fi

echo "Checking Environment"

ENV_CHECK=1
if [ ! -f "${PFX_CERTIFICATE}" ]; then
	echo "File is not mounted: ${PFX_CERTIFICATE}"
	ENV_CHECK=0
fi
if [ -z "${PFX_PASSWORD}" ]; then
	echo "Environment variables not set: PFX_PASSWORD"
	if [ ! -f "${PFX_JSON}" ]; then
		echo "File is not mounted: ${PFX_JSON}"
	fi
	ENV_CHECK=0
fi

echo "Checking Parameters"

if [ ${#JSIGN_PARAMETERS[@]} -eq 0 ]; then
    echo "Parameter(s) [FILE] [PATTERN] [@FILELIST]... are empty"
	ENV_CHECK=0
fi

if [ ${ENV_CHECK} -ne 1 ]; then
	echo ""
	echo "Documentation: see 'Command Line Tool: [FILE] [PATTERN] [@FILELIST]...'"
	echo "               https://ebourg.github.io/jsign/"
	echo "Usage:         pfx-codesign.sh [FILE] [PATTERN] [@FILELIST]..."
	exit 10
fi

#####################
# Start Codesigning #
#####################

echo "Codesign using jsign"

jsign \
	--keystore "${PFX_CERTIFICATE}" \
	--storepass "${PFX_PASSWORD}" \
	${JSIGN_TSAURL} ${JSIGN_TSMODE} \
	--replace \
	"$@"

retVal=$?
if [ $retVal -ne 0 ]; then
	echo "Error occurred during codesigning"
	exit $retVal
fi

exit 0
