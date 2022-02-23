# VDIConverter
**RU**  
`VDIConverter` - конвертирует файлы `VDI` (RootFS) в `TAR` и `SQFS`. Разметка диска виртуальной машины должна быть простейшей: `своп + корень`. Преобразование в TAR предназначено для создания архивов, которые можно импортировать в Docker для создания готового контейнера. Сжатие SQFS используется для создания готового модуля `.sqfs` для флешки MgaRemix или для другого (модульного) дистрибутива.

**EN**  
`VDIConverter` - converting `VDI` files (RootFS) to `TAR` and `SQFS`. The virtual machine disk layout should be the simplest: `swap + root`. Conversion to TAR is designed to create archives that can be imported into Docker to create a ready-made container. SQFS compression is used to create a ready-made `.sqfs` module for an MgaRemix flash drive or for another (modular) distribution.

VirtualBox (VDI) -> VDIConverter (TAR) -> Docker (Import)  
VirtualBox (VDI) -> VDIConverter (SQFS) -> USB flash drive/loopbacks/distrib.sqfs
