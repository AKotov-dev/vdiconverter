#!/bin/bash

#Назание финального модуля
VDIFILE="$1"
OUTFILE="$2"
CONVERT="$3"
DIR="$(pwd)"

#Проверка привилегий root
if [ "$EUID" -ne "0" ]; then echo "Требуются привилегии root!"; exit; fi

#Проверка наличия qemu-img и mksquashfs
if [ ! -f /usr/bin/qemu-nbd -o ! -f /usr/bin/mksquashfs ]; then
 echo "Требуются пакеты: qemu-img и squashfs-tools!"
fi

#Удаляем созданный ранее архив
rm -f "$OUTFILE"

echo "Размонтирование предыдущей сессии..."
if [ $(pidof mksquashfs) ]; then killall mksquashfs; fi; umount -l /mnt/vbox; qemu-nbd -d /dev/nbd0; echo

echo -e "Подключаю модуль ядра 'nbd'"
if [[ -n $(lsmod | grep nbd) ]]; then rmmod nbd; fi && modprobe -v nbd max_part=63; echo

echo -e "Монтирую $VDIFILE в /dev/nbd0"
qemu-nbd -c /dev/nbd0 "$VDIFILE"
while [[ -z $(fdisk -l | grep 'nbd0') ]]; do echo "Ожидаю подключения /dev/nbd0..."; sleep 1; done; echo

echo "Ищу раздел (83) на устройстве /dev/nbd0 и монтирую в /mnt/vbox"
SYSPART=$(fdisk -l /dev/nbd0 | grep "83 Linux" | tail -n1)

if [[ -z $SYSPART ]]; then
  echo; read -p "Не найден раздел '83 Linux' внутри VDI. Enter - Выход..."
  exit;
fi

echo "Выбран: $SYSPART"

#Создаю папку /mnt/vbox, если нет
[ ! -d /mnt/vbox ] && mkdir /mnt/vbox
mount $(fdisk -l /dev/nbd0 | grep "83 Linux" | cut -d " " -f1 | tail -n1) /mnt/vbox

#Если раздел не корневой - выходим...
if [ ! -d /mnt/vbox/etc ]; then
  echo; read -p "Разметка VDI должна быть простейшей: / + swap! Enter - Выход..."
  exit
fi
echo

echo "очищаю /mnt/vbox/etc/fstab"
echo "#VDI-Tar Converter clean fstab..." > /mnt/vbox/etc/fstab

echo "удаляю /mnt/vbox/etc/X11/xorg.conf и /mnt/vbox/etc/harddrake2/*[^service.conf]"
rm -f /mnt/vbox/etc/X11/xorg.conf /mnt/vbox/etc/sysconfig/harddrake2/*[^service.conf]
echo "удаляю настройки виртуальной сети /mnt/vbox/etc/sysconfig/network-scripts/{ifcfg-enp*,ifcfg-eno*}"
rm -f /mnt/vbox/etc/sysconfig/network-scripts/{ifcfg-enp*,ifcfg-eno*}
echo "удаляю /mnt/vbox/lost+found и /mnt/vbox/dead.letter"
rm -rf /mnt/vbox/lost+found; rm -f /mnt/vbox/dead.letter
echo;

echo "Создаю файл $OUTFILE"
cd /mnt/vbox

#Сжатие
if [[ "$CONVERT" == "tar" ]]; then
nice -n 19 tar -cvf "$OUTFILE" ./
    else
nice -n 19 mksquashfs ./ "$OUTFILE" -comp zstd -no-xattrs -no-duplicates -noappend -info
fi;

#Выходим из каталога /mnt/vbox в текущий для демонтирования
cd $DIR; echo

echo -e "Последовательное размонтирование, ждите..."
umount -lv /mnt/vbox
for i in $(fdisk -l | grep 'nbd0p' | awk '{ print $1 }'); do qemu-nbd -d $i; sleep 1; done

qemu-nbd -d /dev/nbd0

#Отключение модуля ядра
while [[ $(lsmod | grep nbd) ]]; do modprobe -rv nbd; sleep 1; done

echo; echo "---"
sleep 1
if [[ -f "$OUTFILE" ]]; then echo "Выходной файл: $(du -h "$OUTFILE")"; sleep 1; fi
echo "Завершено..."

exit 0;
