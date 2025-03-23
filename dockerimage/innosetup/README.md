# Docker Image

The Docker Image is based on Debian and has the following components installed:
- A couple of required Libraries
  - curl, jq, default-jdk, wine
- [jsign](https://github.com/ebourg/jsign)  
  Authenticode signing tool in Java
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/)  
  Azure Command-Line Interface
- `ats-codesign.sh` and `pfx-codesign.sh`  
  Custom Shell Script used for Windows Code Signing using Azure Trusted Signing or a codesign certificate `.pfx`   
  - Usage:  
    `ats-codesign.sh [FILE] [PATTERN] [@FILELIST]...`  
    `pfx-codesign.sh [FILE] [PATTERN] [@FILELIST]...`  
  - Documentation: [jsign - Command Line Tool: `[FILE] [PATTERN] [@FILELIST]...`](https://ebourg.github.io/jsign/)
- [InnoSetup](https://jrsoftware.org/isinfo.php)  
  Inno Setup is a free installer for Windows programs
  - This is a windows application, so it runs under [wine](https://www.winehq.org)
  - This Docker Image includes helper scripts:
    - `iscc.sh '[InnoSetup Parameters]'`  
      Invokes InnoSetup running under wine
    - `ats-codesign.bat` | `pfx-codesign.bat`  
      Allows InnoSetup (Un)Installer to be codesigned using Azure Trusted Signing or a codesign certificate `.pfx`
  - Documentation: [InnoSetup: Help file](https://jrsoftware.org/ishelp/)

### Build Docker Image
<details>

<summary>Docker Image: Build instructions</summary>

To build it locally as `mycompany/innosetup` on the host machine where you intend to use it:

**Intel 64bit**
```
cd /path/to/folder/with/dockerfile
docker build --no-cache --platform=linux/amd64 -t mycompany/innosetup .
```

**ARM 64bit**
```
cd /path/to/folder/with/dockerfile
docker build --no-cache --platform=linux/arm64 -t mycompany/innosetup .
```

To create a multi arch Docker Image, push it to Docker Hub and tag it as 'latest':

```
cd /path/to/folder/with/dockerfile
docker build --no-cache --platform=linux/amd64 -t mycompany/innosetup:1.0.0-amd64 .
docker build --no-cache --platform=linux/arm64 -t mycompany/innosetup:1.0.0-arm64 .

docker push mycompany/innosetup:1.0.0-amd64
docker push mycompany/innosetup:1.0.0-arm64

docker manifest create mycompany/innosetup:1.0.0 --amend mycompany/innosetup:1.0.0-amd64 --amend mycompany/innosetup:1.0.0-arm64
docker manifest push mycompany/innosetup:1.0.0

docker buildx imagetools create -t mycompany/innosetup mycompany/innosetup:1.0.0
```

</details>

### Docker Hub

The built Docker Image is available on Docker Hub: [`jotools/innosetup`](https://hub.docker.com/r/jotools/innosetup)

## Documentation

Please refer to the documentation of the included tools:

- [InnoSetup: Help file](https://jrsoftware.org/ishelp/)
- [jsign - Command Line Tool: `[FILE] [PATTERN] [@FILELIST]...`](https://ebourg.github.io/jsign/)


## Windows Code Signing

You can use this Docker Image to do Windows Code Signing using [Azure Trusted Signing](https://azure.microsoft.com/en-us/products/trusted-signing) or a codesign certificate `.pfx`.

Please refer to the examples of the Docker Image [`jotools/codesign`](https://hub.docker.com/r/jotools/codesign).

> **Note**  
> Only use this Docker Image to build windows installers using [InnoSetup](https://jrsoftware.org/isinfo.php).
> If you intend to only use codesigning *(without creating windows installers)*, head over to the smaller Docker Image [`jotools/codesign`](https://hub.docker.com/r/jotools/codesign).  


## Examples

> **Note**  
> InnoSetup is running as a windows application.  
> So it's parameters need to be in windows style.  
> The drive letter `Z:\` will be the Docker Container's root `/`.  
> So `Z:\data` will be the mounted `/data`.


### Codesigning Requirements

> **Note**  
> You can skip the Configuration for Codesigning if you
> just want to build a windows installer without codesigning.

<details>

<summary>Configuration: Azure Trusted Signing</summary>

### Azure Trusted Signing

#### Configuration

Create the following two `.json` files on your host machine:

**`azure.json`**  
```
{
  "TenantId": "[Azure Tenant Id]",
  "ClientId": "[Azure Client Id]",
  "ClientSecret": "[Azure Client Secret]"
}
```

**`acs.json`**  
```
{
  "Endpoint": "https://weu.codesigning.azure.net",
  "CodeSigningAccountName": "[ACS Code Signing Account Name]",
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
- `ACS_ACCOUNT_NAME=[ACS Code Signing Account Name]`
- `ACS_CERTIFICATE_PROFILE_NAME=[ACS Certificate Profile Name]`

#### Timestamp Server

The Timestamp Server will be automatically chosen by jsign.  
To change it you can set the Environment Variables:
- `TIMESTAMP_SERVER=http://timestamp.domain.org`
- `TIMESTAMP_MODE=[RFC3161|Authenticode]`

</details>

<details>

<summary>Configuration: Codesign certificate .pfx</summary>

### Codesign certificate .pfx

#### Configuration

Create the following `.json` file on your host machine:

**`pfx.json`**  
```
{
  "Password": "xxx",
  "TimestampServer": "http://timestamp.digicert.com",
  "TimestampMode": "Authenticode"
}
```

Have your codesign certificate `certificate.pfx` located on your host machine.

Mount them into the following location when running the Docker Container:
- `/etc/pfx-codesign/pfx.json`
- `/etc/pfx-codesign/certificate.pfx` (Note: always required)

Instead of mounting the `.json` file, you can also provide the configuration via Environment Variable:
- `PFX_PASSWORD=[PFX Password]`
- `TIMESTAMP_SERVER=http://timestamp.domain.org`
- `TIMESTAMP_MODE=[RFC3161|Authenticode]`

</details>


### Create a windows installer using InnoSetup with `iscc.sh`

The included Shell Script `iscc.sh` is a helper script which will
- run [InnoSetup](https://jrsoftware.org/isinfo.php) under [wine](https://www.winehq.org)
- let you create a *(codesigned)* installer using the provided `ats-codesign.bat` or `pfx-codesign.bat`, which will call `ats-codesign.sh` or `pfx-codesign.sh` in the linux environment to
  - pick up the configuration from Environment Variables or the mounted `.json` files
  - perform the Windows Code Signing using [Azure Trusted Signing](https://azure.microsoft.com/en-us/products/trusted-signing) or a codesigning certificate with [jsign](https://github.com/ebourg/jsign)

#### Example: Docker Run - InnoSetup

<details>

<summary>InnoSetup | Codesigning using Azure Trusted Signing</summary>

The following example will
- run the Docker Image [`jotools/innosetup`](https://hub.docker.com/r/jotools/innosetup)
- use Azure Trusted Signing configuration from `.json` files stored on the host machine
- mount a folder on the host machine into `/data`  
  that should include
  - the application to be packaged in a windows installer
  - the InnoSetup script `my-installer.iss`
- use entry point `iscc.sh`
- run InnoSetup to create a codesigned windows installer

```
docker run \
    --rm \
    -v /local/path/to/acs.json:/etc/ats-codesign/acs.json \
    -v /local/path/to/azure.json:/etc/ats-codesign/azure.json \
    -v /local/path/to/build-folder:/data \
    -w /data \
    --entrypoint iscc.sh \
    jotools/innosetup \
    '"/SCodeSignScript=Z:/usr/local/bin/ats-codesign.bat \$f" /O"Z:/data" /Dsourcepath="Z:/data/My Windows Application" "Z:/data/my-installer.iss"'
```

The following example will
- use the locally stored Azure Trusted Signing configuration files `acs.json` and `azure.json`
- mount a folder on the host machine into `/data`
- run the Docker Container interactively *(removing it after)*
  - use entry point `sh`
  - you then can manually create a codesigned windows installer, e.g.:  
    `iscc.sh '"/SCodeSignATS=Z:/usr/local/bin/ats-codesign.bat \$f" /O"Z:/data" /Dsourcepath="Z:/data/My Windows Application" "Z:/data/my-installer.iss"'`

```
docker run \
    --rm \
    -it \
    --entrypoint sh \
    -v /local/path/to/acs.json:/etc/ats-codesign/acs.json \
    -v /local/path/to/azure.json:/etc/ats-codesign/azure.json \
    -v /local/path/to/build-folder:/data \
    jotools/innosetup
```
</details>

<details>

<summary>InnoSetup | Codesigning using `.pfx`</summary>

The following example will
- run the Docker Image [`jotools/innosetup`](https://hub.docker.com/r/jotools/innosetup)
- use a codesigning certificate `.pfx` and configuration `pfx.json` stored on the host machine
- mount a folder on the host machine into `/data`  
  that should include
  - the application to be packaged in a windows installer
  - the InnoSetup script `my-installer.iss`
- use entry point `iscc.sh`
- run InnoSetup to create a codesigned windows installer

```
docker run \
    --rm \
    -v /local/path/to/pfx.json:/etc/pfx-codesign/pfx.json \
    -v /local/path/to/my-certificate.pfx:/etc/pfx-codesign/certificate.pfx \
    -v /local/path/to/build-folder:/data \
    -w /data \
    --entrypoint iscc.sh \
    jotools/innosetup \
    '"/SCodeSignScript=Z:/usr/local/bin/pfx-codesign.bat \$f" /O"Z:/data" /Dsourcepath="Z:/data/My Windows Application" "Z:/data/my-installer.iss"'
```

The following example will
- use a codesigning certificate `.pfx` and configuration `pfx.json` stored on the host machine
- mount a folder on the host machine into `/data`
- run the Docker Container interactively *(removing it after)*
  - use entry point `sh`
  - you then can manually create a codesigned windows installer, e.g.:  
    `iscc.sh '"/SCodeSignScript=Z:/usr/local/bin/pfx-codesign.bat \$f" /O"Z:/data" /Dsourcepath="Z:/data/My Windows Application" "Z:/data/my-installer.iss"'`

```
docker run \
    --rm \
    -it \
    --entrypoint sh \
    -v /local/path/to/pfx.json:/etc/pfx-codesign/pfx.json \
    -v /local/path/to/my-certificate.pfx:/etc/pfx-codesign/certificate.pfx \
    -v /local/path/to/build-folder:/data \
    jotools/innosetup
```
</details>

<details>

<summary>InnoSetup | without codesigning</summary>

The following example will
- run the Docker Image [`jotools/innosetup`](https://hub.docker.com/r/jotools/innosetup)
- mount a folder on the host machine into `/data`  
  that should include
  - the application to be packaged in a windows installer
  - the InnoSetup script `my-installer.iss`
- use entry point `iscc.sh`
- run InnoSetup to create a windows installer

```
docker run \
    --rm \
    -v /local/path/to/build-folder:/data \
    -w /data \
    --entrypoint iscc.sh \
    jotools/innosetup \
    '/O"Z:/data" /Dsourcepath="Z:/data/My Windows Application" "Z:/data/my-installer.iss"'
```

The following example will
- mount a folder on the host machine into `/data`
- run the Docker Container interactively *(removing it after)*
  - use entry point `sh`
  - you then can manually create a windows installer, e.g.:  
    `iscc.sh '/O"Z:/data" /Dsourcepath="Z:/data/My Windows Application" "Z:/data/my-installer.iss"'`

```
docker run \
    --rm \
    -it \
    --entrypoint sh \
    -v /local/path/to/pfx.json:/etc/pfx-codesign/pfx.json \
    -v /local/path/to/my-certificate.pfx:/etc/pfx-codesign/certificate.pfx \
    -v /local/path/to/build-folder:/data \
    jotools/innosetup
```
</details>
