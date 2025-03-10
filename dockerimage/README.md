# Docker Image

The Docker Image is based on Ubuntu and has the following components installed:
- A couple of required Libraries
  - curl, jq, openjdk
- [jsign](https://github.com/ebourg/jsign)  
  Authenticode signing tool in Java
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/)  
  Azure Command-Line Interface
- [ats-codesign.sh](./ats-codesign.sh)  
  Custom Shell Script used for Windows CodeSigning using Azure Trusted Signing  
  Usage: `ats-codesign.sh [FILE] [PATTERN] [@FILELIST]...`  
  Documentation: [jsign - Command Line Tool: `[FILE] [PATTERN] [@FILELIST]...`](https://ebourg.github.io/jsign/)


### Build Docker Image

To build it locally as `mycompany/ats-codesign` on the host machine where you intend to use it:

- Intel 64bit:
  ```
  cd /path/to/folder/with/dockerfile
  docker build --no-cache --platform=linux/amd64 --build-arg ARCH=amd64 -t mycompany/ats-codesign .
  ```
- ARM 64bit:
  ```
  cd /path/to/folder/with/dockerfile
  docker build --no-cache --platform=linux/arm64/v8 --build-arg ARCH=arm64v8 -t mycompany/ats-codesign .
  ```


To create a multi arch Docker Image, push it to Docker Hub and tag it as 'latest':

```
cd /path/to/folder/with/dockerfile
docker build --no-cache --platform=linux/amd64    --build-arg ARCH=amd64   -t mycompany/ats-codesign:1.0.0-amd64 .
docker build --no-cache --platform=linux/arm64/v8 --build-arg ARCH=arm64v8 -t mycompany/ats-codesign:1.0.0-arm64v8 .

docker push mycompany/ats-codesign:1.0.0-amd64
docker push mycompany/ats-codesign:1.0.0-arm64v8

docker manifest create mycompany/ats-codesign:1.0.0 --amend mycompany/ats-codesign:1.0.0-amd64 --amend mycompany/ats-codesign:1.0.0-arm64v8
docker manifest push mycompany/ats-codesign:1.0.0

docker buildx imagetools create -t mycompany/ats-codesign mycompany/ats-codesign:1.0.0
```

### Docker Hub

The built Docker Image is available on Docker Hub: [jotools/ats-codesign](https://hub.docker.com/r/jotools/ats-codesign)

## Windows CodeSign using Azure Trusted Signing

You can use this Docker Image to do Windows Code Signing using [Azure Trusted Signing](https://azure.microsoft.com/en-us/products/trusted-signing).

### Requirements

#### Configuration

Create the following two `.json` files on your host machine:

- **`azure.json`**  
  ```
  {
    "TenantId": "[Azure Tenant Id]",
    "ClientId": "[Azure Client Id]",
    "ClientSecret": "[Azure Client Secret]"
  }
  ```
- **`acs.json`**  
  ```
  {
    "Endpoint": "https://weu.codesigning.azure.net",
    "CodeSigningAccountName": "[ACS CodeSigning Account Name]",
    "CertificateProfileName": "[ACS Certificate Profile Name]"
  }
  ```

And mount them into the following location when running the Docker Container:
- `/etc/ats-codesign/azure.json`
- `/etc/ats-codesign/acs.json`

Instead of mounting the two `.json` files, you can also provide the configuration via Environment Variables:
- `AZURE_TENANT_ID=[Azure Tenant Id]`
- `AZURE_CLIENT_ID=[Azure Client Id]`
- `AZURE_CLIENT_SECRET=[Azure Client Secret]`
- `ACS_ENDPOINT=https://weu.codesigning.azure.net`
- `ACS_ACCOUNT_NAME=[ACS CodeSigning Account Name]`
- `ACS_CERTIFICATE_PROFILE_NAME=[ACS Certificate Profile Name]`

#### Timestamp Server

The Timestamp Server will be automatically chosen by jsign.  
To change it you can set the Environment Variables:
- `TIMESTAMP_SERVER=http://timestamp.domain.org`
- `TIMESTAMP_MODE=[RFC3161|Authenticode]`

### CodeSign using `ats-codesign.sh`

The included Shell Script `ats-codesign.sh` is a helper script which will
- pick up the configuration from Environment Variables or the mounted `.json` files
- perform the Windows CodeSigning using [Azure Trusted Signing](https://azure.microsoft.com/en-us/products/trusted-signing) with [jsign](https://github.com/ebourg/jsign)

#### Example: Docker Run - ATS CodeSign

The following example will
- run the Docker Image [jotools/ats-codesign](https://hub.docker.com/r/jotools/ats-codesign)
- use configuration from `.json` files stored on the host machine
- mount a folder on the host machine into `/data`
- codesign all `.exe`'s and `.dll`'s in `/data` *(recursively)*

```
docker run \
    --rm \
    -v /local/path/to/acs.json:/etc/ats-codesign/acs.json \
    -v /local/path/to/azure.json:/etc/ats-codesign/azure.json \
    -v /local/path/to/build-folder:/data \
    -w /data \
    jotools/ats-codesign \
    /bin/sh -c "ats-codesign.sh \"./**/*.exe\" \"./**/*.dll\""
```

The same example, but
- use a different Timestamp Server *(set via Environment Variable)*

```
docker run \
    --rm \
    -e TIMESTAMP_SERVER=http://timestamp.digicert.com \
    -v /local/path/to/acs.json:/etc/ats-codesign/acs.json \
    -v /local/path/to/azure.json:/etc/ats-codesign/azure.json \
    -v /local/path/to/build-folder:/data \
    -w /data \
    jotools/ats-codesign \
    /bin/sh -c "ats-codesign.sh \"./**/*.exe\" \"./**/*.dll\""
```

#### Example: Docker Container Shell

The following example will
- use Environment Variables to setup the configuration
- mount a folder on the host machine into `/data`
- you then can manually sign files, e.g.:  
  `ats-codesign.sh "./**/*.exe" "./**/*.dll"`  
  `ats-codesign.sh myapp.exe mylib.dll`

```
docker run \
    --rm \
    -it \
    --entrypoint sh \
    -e AZURE_TENANT_ID="MY_AZURE_TENANT_ID" \
    -e AZURE_CLIENT_ID="MY_AZURE_CLIENT_ID" \
    -e AZURE_CLIENT_SECRET="MY_AZURE_CLIENT_SECRET" \
    -e ACS_ENDPOINT=https://weu.codesigning.azure.net \
    -e ACS_ACCOUNT_NAME="ACS CodeSigning Account Name" \
    -e ACS_CERTIFICATE_PROFILE_NAME="ACS Certificate Profile Name" \
    -v /local/path/to/build-folder:/data \
    jotools/ats-codesign
```

The following example will
- use the locally stored configuration files `acs.json` and `azure.json`
- mount a folder on the host machine into `/data`
- you then can manually sign files, e.g.:  
  `ats-codesign.sh "./**/*.exe" "./**/*.dll"`  
  `ats-codesign.sh myapp.exe mylib.dll`

```
docker run \
    --rm \
    -it \
    --entrypoint sh \
    -v /local/path/to/acs.json:/etc/ats-codesign/acs.json \
    -v /local/path/to/azure.json:/etc/ats-codesign/azure.json \
    -v /local/path/to/build-folder:/data \
    jotools/ats-codesign
```
