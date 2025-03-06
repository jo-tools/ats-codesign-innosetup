#! /bin/sh
#

CODESIGN_FILES="$*"

echo "Setting up Environment"

AZURE_JSON="/etc/ats-codesign/azure.json"
ACS_JSON="/etc/ats-codesign/acs.json"

if [ -z "${AZURE_TENANT_ID}" ]; then
	AZURE_TENANT_ID=$( [ -f ${AZURE_JSON} ] && cat ${AZURE_JSON} | jq -r '.TenantId')
fi
if [ -z "${AZURE_CLIENT_ID}" ]; then
	AZURE_CLIENT_ID=$( [ -f ${AZURE_JSON} ] && cat ${AZURE_JSON} | jq -r '.ClientId')
fi
if [ -z "${AZURE_CLIENT_SECRET}" ]; then
	AZURE_CLIENT_SECRET=$( [ -f ${AZURE_JSON} ] && cat ${AZURE_JSON} | jq -r '.ClientSecret')
fi
if [ -z "${ACS_ACCOUNT_NAME}" ]; then
	ACS_ACCOUNT_NAME=$( [ -f ${ACS_JSON} ] && cat ${ACS_JSON} | jq -r '.CodeSigningAccountName')
fi
if [ -z "${ACS_CERTIFICATE_PROFILE_NAME}" ]; then
	ACS_CERTIFICATE_PROFILE_NAME=$( [ -f ${ACS_JSON} ] && cat ${ACS_JSON} | jq -r '.CertificateProfileName')
fi
if [ -z "${ACS_ENDPOINT}" ]; then
	ACS_ENDPOINT=$( [ -f ${ACS_JSON} ] && cat ${ACS_JSON} | jq -r '.Endpoint')
fi

JSIGN_TSAURL=
if [ ! -z "${TIMESTAMP_SERVER}" ]; then
	JSIGN_TSAURL="--tsaurl ${TIMESTAMP_SERVER}"
fi

JSIGN_TSMODE=
if [ ! -z "${TIMESTAMP_MODE}" ]; then
	JSIGN_TSMODE="--tsmode ${TIMESTAMP_MODE}"
fi

echo "Checking Environment"

ENV_CHECK=1
if [ -z "${AZURE_TENANT_ID}" ] || [ -z "${AZURE_CLIENT_ID}" ] || [ -z "${AZURE_CLIENT_SECRET}" ]; then
	echo "Environment variables not set: AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_CLIENT_SECRET"
	if [ ! -f /etc/ats-codesign/azure.json ]; then
		echo "File is not mounted: /etc/ats-codesign/azure.json"
	fi
	ENV_CHECK=0
fi
if [ -z "${ACS_ACCOUNT_NAME}" ] || [ -z "${ACS_CERTIFICATE_PROFILE_NAME}" ] || [ -z "${ACS_ENDPOINT}" ]; then
	echo "Environment variables not set: ACS_ACCOUNT_NAME, ACS_CERTIFICATE_PROFILE_NAME, ACS_ENDPOINT"
	if [ ! -f /etc/ats-codesign/acs.json ]; then
		echo "File is not mounted: /etc/ats-codesign/acs.json"
	fi
	ENV_CHECK=0
fi

echo "Checking Parameters"

if [ -z "${CODESIGN_FILES}" ]; then
    echo "Parameter CODESIGN_FILES is empty"
	ENV_CHECK=0
fi

if [ ${ENV_CHECK} -ne 1 ]; then
	exit 10
fi

echo "Fetching AZURE_ACCESS_TOKEN"

AZURE_ACCESS_TOKEN=$( curl -X POST -d "grant_type=client_credentials&client_id=${AZURE_CLIENT_ID}&client_secret=${AZURE_CLIENT_SECRET}&resource=https%3A%2F%2Fcodesigning.azure.net" https://login.microsoftonline.com/${AZURE_TENANT_ID}/oauth2/token | jq -r '.access_token' )

retVal=$?
if [ $retVal -ne 0 ]; then
	echo "Error Fetching AZURE_ACCESS_TOKEN"
	exit $retVal
fi

echo "ats-codesign [jsign]: Begin"

jsign --storetype TRUSTEDSIGNING \
		--keystore ${ACS_ENDPOINT} \
		--storepass ${AZURE_ACCESS_TOKEN} \
		--alias ${ACS_ACCOUNT_NAME}/${ACS_CERTIFICATE_PROFILE_NAME} \
		${JSIGN_TSAURL} ${JSIGN_TSMODE} \
		--replace \
		${CODESIGN_FILES}

retVal=$?
if [ $retVal -ne 0 ]; then
	echo "ats-codesign [jsign]: Error occurred during codesigning"
	exit $retVal
fi

echo "ats-codesign [jsign]: Finished"

exit 0
