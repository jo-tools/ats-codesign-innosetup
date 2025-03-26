# Configuration: Codesigning Certificate `.pfx`

Template configuration files for Docker Hub: [`jotools/codesign`](https://hub.docker.com/r/jotools/codesign) and [`jotools/innosetup`](https://hub.docker.com/r/jotools/innosetup):
- [`pfx.json`](./pfx.json)  
  Configuration for using the Codesigning Certificate `.pfx`
- `certificate.pfx`  
  And you obviously need the Codesigning certificate file `.pfx`
  

## Configuration: Xojo example project

The Xojo example project `ATS CodeSign InnoSetup.xojo_project` performs codesigning in it's Post Build Scripts.

To enable that functionality the following configuration is required.

### Template Files

1. Place the following files in `~/.pfx-codesign`
   - [`pfx.json`](./pfx.json)  
     Configuration for using the Codesigning Certificate `.pfx`
   - `certificate.pfx`  
     Your actual password protected Codesigning certificate file `.pfx`

2. Fill out the placeholder values in `pfx.json`  
   > **Warning**  
   > For a first atttemp you may fill in the Codesigning Certificate Password in the `pfx.json` configuration file. However, this is **not secure**!

#### Credentials: Secret Storage

3. Place the following script in `~/.pfx-codesign`:
   - [`pfx-codesign-credential.ps1`](./pfx-codesign-credential.ps1)  
     Windows *(Powershell)*
   - [`pfx-codesign-credential.sh`](./pfx-codesign-credential.sh)  
     macOS/Linux *(Shell Script)*

4. Read the comments in the script and securely store your Codesigning Certificate Password
5. Make sure you have removed *(or left blank)* the Codesigning Certificate Password in plain text in the configuration file `pfx.json`
6. If this credential helper script is found by the Post Build Script of the Xojo Example Project in `~/.pfx-codesign`, it will pick up the Codesigning Certificate Password from the secret storage by calling the script

> Hint:  
> Feel free to modify this credentials helper script to use another
> credentials manager. The purpose of the Xojo Example Project is just
> to show how this can be integrated into the Post Build Step(s).
