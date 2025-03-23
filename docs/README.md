# Docs

Some useful links and archived Web content.

## Links

### Microsoft

- [Azure Trusted Signing](https://azure.microsoft.com/en-us/products/trusted-signing)  
  Secure your applications with a fully managed end-to-end signing service for code, documents, applications, and more
- [Microsoft: Quickstart](https://learn.microsoft.com/en-us/azure/trusted-signing/quickstart)  
  Set up Trusted Signing


### HowTo's
- [Melatonin](https://melatonin.dev/blog/code-signing-on-windows-with-azure-trusted-signing/)  
  Code signing with ATS
- [KoalaDocs](https://github.com/koaladsp/KoalaDocs/blob/master/azure-code-signing-for-plugin-developers.md#232-preparing-signtoolexe)  
  ATS | signtool.exe


### Components
- [Docker Hub: jotools/codesign](https://hub.docker.com/r/jotools/codesign)  
  Azure Trusted Signing | PFX | Docker | jsign
- [Docker Hub: jotools/innosetup](https://hub.docker.com/r/jotools/innosetup)  
  InnoSetup | Docker | jsign
- [jsign](https://github.com/ebourg/jsign)  
  Authenticode signing tool in Java
- [InnoSetup](https://jrsoftware.org/isinfo.php)  
  Inno Setup is a free installer for Windows programs


## Archived Web Content

These articles have been very helpful and are worth being preserved as `.pdf`.

- [Melatonin: Code signing with ATS](./01_Melatonin-Dev_AzureTrustedSigning.pdf)
- [KoalaDocs: ATS | signtool.exe](./02_KoalaDocs_Signtool.pdf)

## Templates

Template configuration files for Docker Hub: [`jotools/codesign`](https://hub.docker.com/r/jotools/codesign) and [`jotools/innosetup`](https://hub.docker.com/r/jotools/innosetup):

### Azure Trusted Signing

Place the following two files in `~/.ats-codesign`
- [`acs.json`](./acs.json)
- [`azure.json`](./azure.json)

### Codesign certificate `.pfx`

Place the following two files in `~/.pfx-codesign`
- [`pfx.json`](./pfx.json)
- `certificate.pfx`
