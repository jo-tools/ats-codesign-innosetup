# Configuration: Azure Trusted Signing

Template configuration files for Docker Hub: [`jotools/codesign`](https://hub.docker.com/r/jotools/codesign) and [`jotools/innosetup`](https://hub.docker.com/r/jotools/innosetup):
- [`acs.json`](./acs.json)  
  Configuration Code Signing in Azure
- [`azure.json`](./azure.json)  
  Azure Credentials
  

## Configuration: Xojo example project

The Xojo example project `ATS CodeSign InnoSetup.xojo_project` performs codesigning in it's Post Build Scripts.

To enable that functionality the following configuration is required.

### Template Files

1. Place the following configuration files in `~/.ats-codesign`
   - [`acs.json`](./acs.json)
   - [`azure.json`](./azure.json)

2. Fill out the placeholder values with your account details  
   > **Warning**  
   > For a first atttemp you may fill in the Azure Client Secret in the `azure.json` configuration file. However, this is **not secure**!

#### Credentials: Secret Storage

3. Place the following script in `~/.ats-codesign`:
   - [`ats-codesign-credential.ps1`](./ats-codesign-credential.ps1)  
     Windows *(Powershell)*
   - [`ats-codesign-credential.sh`](./ats-codesign-credential.sh)  
     macOS/Linux *(Shell Script)*

4. Read the comments in the script and securely store your Azure Client Secret
5. Make sure you have removed *(or left blank)* the Azure Client Secret in plain text in the configuration file `azure.json`
6. If this credential helper script is found by the Post Build Script of the Xojo Example Project in `~/.ats-codesign`, it will pick up the Azure Client Secret from the secret storage by calling the script

> Hint:  
> Feel free to modify this credentials helper script to use another
> credentials manager. The purpose of the Xojo Example Project is just
> to show how this can be integrated into the Post Build Step(s).
