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

## Laika Configurator

  On launch will scan all the modules in `lib/laika/mod/`, reading for eachone all the installation informations.
  Once ready, will show the menu interface.
  
```
   Лайка Модули Конфигурация в.0.9.3.
   ================================================

>> CONFIGURE LAIKA
   -
   INSTALL MODULES
   CONFIG INSTALLED MODS
   -
   BUILD LAIKA
   -
   CREDITS
   -
   REBOOT
   EXIT
```
### Installing and configurig modules

  Select the modules to install in the list available from the `>> INSTALL MODULES` menu. If found, a description for the current modules will be shown at the bottom of the terminal screen.
  
  You can get back to the main menu using the `RETURN` menu or by hitting the `DELETE` key.
```
   AVAILABLE MODS
   ================================================

   Flight Data Recorder    [ X ]
>> PID Controller          [ X ]                    True
   -
   RETURN
```

  The `CONFIG INSTALLED MODS` menu will show the list of the installed mod.
```
   INSTALLED MODS
   ================================================

>> Flight Data Recorder                             Menu
   PID Controller
   -
   RETURN
```

  Entering each module, you can configure the interface installation options as well as any extra mod specific parameter.
```
   'Flight Data Recorder' CONFIGURATION
   ================================================

   --| LAIKA UI OPTIONS |--
>> MENU NAME               FDR
   PARENT MENU             MAIN
   PARENT MENU BUTTON      8

   --| MODULE OPTIONS |--
   Destination Dir         0:/telemetry/
   File Prefix             FDR_
   Sampling Rate           1
   REVERT TO DEFAULTS

   --| INSTALL OPTIONS |--
   Export CSV              [   ]
   Export Octave           [ X ]
   REVERT TO DEFAULTS
   -
   RETURN
```

### Building Laika Computer

  Choose `BUILD LAIKA` to process and compile Laika core, libraries and all the modules.
  The current configuration will be saved in the file `config.lk`, stored in the installation drive.
  
  Once the installation has been done, you'll get the report of the total warnings and errors.
```
      [INFO]: 0 WARNINGS in total,
              0 ERRORS in total.
[Press any key to continue]
```

## Laika Sample Interface Screen

```
                    Лайка Модульный Компьютер в.0.9.5               80%
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃                         Flight Data Recorder                         ┃
┃----------------------------------------------------------------------┃
┃                                                                      ┃
┃  Idle.                                                               ┃
┃                                                                      ┃
┃                                                                      ┃
┃                                                                      ┃
┃                                                                      ┃
┃                                                                      ┃
┃                                                                      ┃
┃                                                                      ┃
┃                                                                      ┃
┃                                                                      ┃
┃                                                                      ┃
┃                                                                      ┃
┃                                                                      ┃
┃                                                                      ┃
┃                                                                      ┃
┃                                                                      ┃
┃                                                                      ┃
┃                                                                      ┃
┃                                                                      ┃
┃                                                                      ┃
┃                                                                      ┃
┃                                                                      ┃
┃                                                                      ┃
┃______________________________________________________________________┃
┃  SR: 1s        Δt: 0s                                           OCT  ┃
┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
┗━━━━━━━━━━━━━┓                 ┃ FDR ┃                  ┏━━━━━━━━━━━━━┛
              ┃                 ┗━━━━━┛                  ┃
┏━━━━━━━━━━━━━┛                                          ┗━━━━━━━━━━━━━┓
┗━━━━━━━━━━━━━┓                                          ┏━━━━━━━━━━━━━┛
              ┃               POWER DRAIN:               ┃
┏━━━━━━━━━━━━━┛                  0.08%/m                 ┗━━━━━━━━━━━━━┓
┗━━━━━━━━━━━━━┓                                          ┏━━━━━━━━━━━━━┛
              ┃               DISK SPACE:                ┃
┏━━━━━━━━━━━━━┛                1: 25201b                 ┗━━━━━━━━━━━━━┓
┗━━━━━━━━━━━━━┓                                          ┏━━━━━━━━━━━━━┛
○ START       ┃               ┏━━━━━━━━━━┓               ┃        STOP ○
┏━━━━━━━━━━━━━┛               ┃ ● НАЗАД  ┃               ┗━━━━━━━━━━━━━┓
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛          ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
 ⑦ След.  ⑧ Пред.                                         ⑨ Поступать
```

### Interface Navigation
  While the focus is on KSP interface, you can navigate the interface with Action Group commands. 
  
  You can use:
  * `AG7` to move to the next button,
  * `AG8` to move to the previous button,
  * `AG9` to trigger the current button.
  
  If the focus is on KoS terminal, you can navigate using the `cursor arrows`, trigger the current button with `ENTER` and the `НАЗАД` (Back) button with `DELETE`. You can use the number keys `7`, `8` and `9` aswell, that replicates the Action Group's behaviour.

## Credits

#### Laika Modular Computer, Laika Configurator and KoS Preprocessor
  Made and maintained by Pacrox.

#### Ozin Libraries
  Modified from the originals made by ozin370.

  https://github.com/ozin370/Script

#### Laika GUI Library (lk_gui)
  Made and maintained by Pacrox, uses code portions by TDW86.
  
  https://github.com/KSP-KOS/KSLib

#### KoS Language Interpreter and Compiler
  Originally made by Nivekk, currently mantained by Dunbaratu.
  
  https://github.com/KSP-KOS/KOS
