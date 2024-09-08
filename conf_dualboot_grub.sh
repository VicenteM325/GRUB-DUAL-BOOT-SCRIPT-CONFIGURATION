#!/bin/bash
#SCRIPT PARA INSTALAR Y/O ACTUALIZAR GRUB-DUALBOOT PARA DISTROS CON(GNOME, KDE ...)
 
# Instala os-prober para detectar otros sistemas operativos
sudo pacman -S --noconfirm os-prober
if [ $? -ne 0 ]; then
  echo "Error al instalar os-prober. Saliendo."
  exit 1
fi

# Instala grub, efibootmgr y mtools
sudo pacman -S --noconfirm grub efibootmgr mtools
if [ $? -ne 0 ]; then
  echo "Error al instalar grub, efibootmgr o mtools. Saliendo."
  exit 1
fi

# Define la ruta del archivo de configuración de grub
GRUB_CONFIG="/etc/default/grub"

# Elimina el comentario de GRUB_DISABLE_OS_PROBER=false
if grep -q "^#\s*GRUB_DISABLE_OS_PROBER=false" "$GRUB_CONFIG"; then
  sudo sed -i 's/^#\s*GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' "$GRUB_CONFIG"
  echo "La línea GRUB_DISABLE_OS_PROBER=false ha sido descomentada en $GRUB_CONFIG."
else
  echo "La línea GRUB_DISABLE_OS_PROBER=false ya está descomentada o no existe."
fi

# Ejecuta os-prober para verificar la detección de otros sistemas operativos
sudo os-prober
if [ $? -ne 0 ]; then
  echo "os-prober no detectó otros sistemas o falló en ejecutarse. Por favor, verifica manualmente."
fi

# Instala la configuración del grub
sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
if [ $? -ne 0 ]; then
  echo "Error al instalar Grub. Saliendo."
  exit 1
fi

# Actualiza la configuración de grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
if [ $? -ne 0 ]; then
  echo "Error al actualizar la configuración de Grub."
  exit 1
fi

echo "Grub ha sido instalado y configurado correctamente."
