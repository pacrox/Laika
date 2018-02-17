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

## Interface Navigation
  While the focus is on KSP interface, you can navigate the interface with Action Group commands. 
  
  You can use:
  * `AG7` to move to the next button,
  * `AG8` to move to the previous button.
  * `AG9` to trigger the current button.
  
  If the focus is on KoS terminal, you can navigate using the `cursor arrows`, trigger the current button with `ENTER` and the НАЗАД (Back) button with `DELETE`. You can use the number keys `7`, `8` and `9` aswell, that replicates the Action Group's behaviour.
