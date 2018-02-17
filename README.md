# Laika Modular Computer
for KSP-KoS v.1.1.5.0.

## Installation

  Laika should be installed in drive `0:` of KoS, which is normally located in `Kerbal Space Program/Ships/Scripts`, mantaining the same file structure of the package.
  
  The package contains the following files: 
  * `boot/laika.ks                ` the bootstrap file that lauches Laika Configurator
  * `lib/laika/laika_conf.ks      ` Laika Configurator to setup Laika Computer
  * `lib/laika/laika_core.ks      ` Laika Computer that will run during missions
  * `lib/laika/preprocessor.ks    ` a code preprocessor used to build Laika Computer
  * `lib/laika/lib_lk_gui.ks      ` Laika's GUI library
  * `lib/laika/ozin/*             ` libraries needed by Laika Configurator
  * `lib/laika/mod/*              ` modules used to expad Laika Computer fuctionalities

## Usage

  Set `boot/laika.ks` as bootstrap file using the part interface of the Kos Computer in the Building Facility, and launch your vessel.
  
  Once on the Launch-Pad, the KoS terminal should open and Laika Configurator will automatically run. Here you can choose the modules to install and configure them. By default, there are no modules installed.
  
  Build Laika Computer and pay attention not to get any error. Once builded, you can reboot KoS to start Laika Computer.
  
## Laika Sample Interface Screen

![Image][https://github.com/pacrox/Laika/blob/master/doc/images/Laika%20Sample%20Screen.png]
