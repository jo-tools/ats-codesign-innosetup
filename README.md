# ATS CodeSign | Docker
Azure Trusted Signing | Docker | jsign

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Description
Are you distributing Windows Software outside of the Microsoft Store? For your users best experience and confidence, your applications should be codesigned.

This example shows how to codesign using [Azure Trusted Signing](https://azure.microsoft.com/en-us/products/trusted-signing).  
Codesigning is using [jsign](https://github.com/ebourg/jsign) in a Docker Container [`jotools/ats-codesign`](https://hub.docker.com/r/jotools/ats-codesign). This allows codesigning to be performed on a host machine running on either Windows, macOS or Linux.

#### Requirements

- Set up [Azure Trusted Signing](https://azure.microsoft.com/en-us/products/trusted-signing)  
  To [get you started]((https://learn.microsoft.com/en-us/azure/trusted-signing/quickstart)) have a look at the included [docs](./docs/).  
  You'll find some useful links and archived Web content there.
- Have [Docker](https://www.docker.com/products/docker-desktop/) up and running

### ATS CodeSign | Docker Image `jotools/ats-codesign`

While the included example project is written with [Xojo](https://www.xojo.com/) you can use this approach with any other development environment.

Please refer to the [Documentation](./dockerimage/) for the provided [Docker Image `jotools/ats-codesign`](./dockerimage/). It includes information about how to set it all up, along with a codesigning example.

### Xojo Example Project

This repository includes a Xojo Example Project `ATS CodeSign Docker.xojo_project` which
- uses a Post Build Script `AzureTrustedSigning` to codesign the Windows builds using [Azure Trusted Signing](https://azure.microsoft.com/en-us/products/trusted-signing)
- uses a Docker Container ([jotools/ats-codesign](https://hub.docker.com/r/jotools/ats-codesign)) to perform the codesigning using [jsign](https://github.com/ebourg/jsign)

This allows the Windows application to be built and codesigned with the Xojo IDE running on all Windows, macOS or Linux.

### ScreenShots

Xojo Example Project: ATS CodeSign | Docker  
![ScreenShot: Xojo Example Project: ATS CodeSign | Docker](screenshots/xojo-example-project.png?raw=true)

Code Signature *(Codesigned with Xojo IDE running on macOS)*
![ScreenShot: Code Signature - Codesigned with Xojo IDE running on macOS](screenshots/code-signature.png?raw=true)


## Xojo
### Requirements
[Xojo](https://www.xojo.com/) is a rapid application development for Desktop, Web, Mobile & Raspberry Pi.  

The Desktop application Xojo example project `ATS CodeSign Docker.xojo_project` and its Post Build Script is using:
- Xojo 2024r4.2
- API 2

### How to use in your own Xojo project?
1. Create a Post Build Script in your project and copy-and-paste the example Post Build Script `AzureTrustedSigning` provided in `ATS CodeSign Docker.xojo_project`
3. Make sure this Post Build Script runs after the Step 'Windows: Build'
4. Read the comments in the provided Post Build Script, modify it according to your needs  
   The default settings are:
   - use the Docker Container [`jotools/ats-codesign`](https://hub.docker.com/r/jotools/ats-codesign)
     - *you might want to build your own Docker Container and use that one instead*
   - Codesign Final and Beta Builds
     - *no Codesigning for Alpha- and Development Builds*
   - Codesign all `.exe` and `.dll` files for Final Builds
     - *Codesign just all `.exe`, but not the `.dll` files for Beta/Alpha/Development Builds*


## About
Juerg Otter is a long term user of Xojo and working for [CM Informatik AG](https://cmiag.ch/). Their Application [CMI LehrerOffice](https://cmi-bildung.ch/) is a Xojo Design Award Winner 2018. In his leisure time Juerg provides some [bits and pieces for Xojo Developers](https://www.jo-tools.ch/).


### Contact
[![E-Mail](https://img.shields.io/static/v1?style=social&label=E-Mail&message=xojo@jo-tools.ch)](mailto:xojo@jo-tools.ch)
&emsp;&emsp;
[![Follow on Facebook](https://img.shields.io/static/v1?style=social&logo=facebook&label=Facebook&message=juerg.otter)](https://www.facebook.com/juerg.otter)
&emsp;&emsp;
[![Follow on Twitter](https://img.shields.io/twitter/follow/juergotter?style=social)](https://twitter.com/juergotter)

### Donation
Do you like this project? Does it help you? Has it saved you time and money?  
You're welcome - it's free... If you want to say thanks I'd appreciate a [message](mailto:xojo@jo-tools.ch) or a small [donation via PayPal](https://paypal.me/jotools).  

[![PayPal Dontation to jotools](https://img.shields.io/static/v1?style=social&logo=paypal&label=PayPal&message=jotools)](https://paypal.me/jotools)
