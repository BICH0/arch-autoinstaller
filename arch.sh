#!/bin/bash
clear
intro (){
cat << "EOF"
Bienvenido al automatizador de instalaciones de Arch Linux

                   -`
                  .o+`
                 `ooo/
                `+oooo:
               `+oooooo:
               -+oooooo+:
             `/:-:++oooo+:
            `/++++/+++++++:
           `/++++++++++++++:
          `/+++ooooooooooooo/`
         ./ooosssso++osssssso+`
        .oossssso-````/ossssss+`
       -osssssso.      :ssssssso.
      :osssssss/        osssso+++.
     /ossssssss/        +ssssooo/-
   `/ossssso+/:-        -:/+osssso+-
  `+sso+:-`                 `.-/+oso:
 `++:.                           `-/+/
 .`                                 `
 By CONFUGIRADORES®

--------------------------------------------------------------------------------------------------
EOF
}
 intro
 sleep 3
 #COLORS
 nc="\e[m"
 #RESULTS
 error="\e[0;31m[ERROR]\e[m"
 ok="\e[1;32m[OK]\e[m"
 skip="\e[1;33m[SKIP]\e[m"
 warn="\e[1;33m[WARN]\e[m"
 installed="\e[1;32m[INSTALLED]\e[m"
 ##CONST
 discos=$(ls /dev/?d? /dev/nvme0n? 2>/dev/null)
 ohmyzshlink="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
 basepack=('base' 'linux' 'linux-firmware' 'nano' 'wget' 'sudo' 'neofetch')
 bichopack=('dhcpcd' 'git' 'htop' 'neovim' 'conky' 'networkmanager' 'discord' 'obs-studio')
 displayservers=('xorg')
 desktops=('xfce4' 'gnome' 'cinnamon' 'plasma' 'mate' 'deepin')
 dms=('lightdm')
 lightdm_greeters=('lightdm-kde-greeter' 'lightdm-gtk-greeter' 'lightdm-pantheon-greeter' 'lightdm-webkit2-greeter')
 wms=('i3' 'i3-gaps' 'awesome' 'xmonad')
 terminales=('alacritty' 'konsole' 'kitty' 'yakuake' 'terminator')
 shells=('bash' 'zsh' 'ksh' 'fish')
 fms=('dolphin' 'konqueror' 'nautilus' 'krusader')
 navegadores=('firefox' 'vivaldi' 'chromium' 'opera' 'qutebrowser')
 ##FUNCIONES
 empty_lines () {
   clear
   echo ""
   echo "--------------------------------------------------------------------------------------------------"
 }
discos_conectados () {
		echo ""
	 	echo "Tienes los siguientes discos conectados"
	 	n=1
    disk_array=()
	 	for discof in $discos
		 	do
		 		sizef=$(lsblk $discof | head -n2 | tail -n1 | awk '{print $4}')
		 		echo "${n}.${discof} [${sizef}]"
        sizeconver ${sizef}
        disk_array+=(${nsize})
        ((n=n+1))
		 	done
		echo""
	 	echo "---------------------------------------"
	 }
sizeconver () {
  osize=$1
  dsize=$(echo ${osize} | rev | cut -c 2- | rev)
  if [[ $(echo ${osize} | rev | cut -c1) == "T" ]]
  then
    nsize=$(($dsize * 1.048.576))
  elif [[ $(echo ${osize} | rev | cut -c1) == "G" ]]
  then
     nsize=$(($dsize * 1024))
  elif [[ $(echo ${osize} | rev | cut -c1) == "M" ]]
  then
    nsize=${dsize}
  elif [[ $(echo ${osize} | rev | cut -c1) == "K" ]]
  then
    nsize=$(($dsize / 1024))
  elif [[ $(echo ${osize} | rev | cut -c1) == "B" ]]
  then
    nsize=$(($dsize / 1.048.576))
  else
    nsize=${osize}
  fi
}
fdisk_repair (){
	for o in $(seq 1 2)
	do
		opciones+=('nbsp')
	done
}
partition_list () {
  for disco in $discos
  do
    echo "----${disco}"
    partitions=$(lsblk -f $disco | tail +3 | cut -f1,2 -d' ')
    echo "$partitions"
    echo ""
  done
}
locales_list () {
  i=0
  locales=()
  for local in $(cat /mnt/etc/locale.gen | tail +7 | grep -v ^[#] |  cut -f1 -d' ')
  do
    echo "- ${i}.${local}"
    locales+=(${local})
    ((i=i+1))
  done
}
pacman_func () {
  packages=$@
  arch-chroot /mnt pacman -S --noconfirm --needed $packages &>/dev/null
}
install_package () {
  ipr1=""
  ipr2=""
  name=$1 && shift
  cstname=$1 && shift
  iarr=("$@")
  iarr+=('Otro')
  iarr+=('Ninguno')
  while [[ -z $ipr1 ]] || [[ -z ${iarr[${ipr1}]} ]]
  do
    i=0
    empty_lines
    echo "Selecciona ${name}:"
    for entry in ${iarr[@]}
    do
      echo "${i}.${entry}"
      ((i=i+1))
    done
    read ipr1
  done
  if [[ ${iarr[${ipr1}]} == ${iarr[-2]} ]]
  then
    until [[ $ipr2 == s ]] || [[ $ipr2 == S ]]
    do
      echo "Introduce el/los paquete/s ${cstname} que quieras instalar"
      read ipr1
      echo "Quieres continuar con la instalacion de los siguientes paquetes? S/N"
      for pkg in ${ipr1}
      do
        echo "- ${pkg}"
      done
      read ipr2
    done
    pacman_func "${ipr2}"
  elif [[ ${iarr[${ipr1}]} == ${iarr[-1]} ]]
  then
    :
  else
    if [[ ${iarr[${ipr1}]} == xorg ]]
    then
      echo -n "Instalando ${iarr[${ipr1}]} "
      pacman_func "xorg xorg-server"
      echo -e "${ok}"
    elif [[ ${iarr[${ipr1}]} == "plasma" ]]
    then
      echo -n "Instalando ${iarr[${ipr1}]}"
      pacman_func "plasma-desktop"
      echo -e "${ok}"
    elif [[ ${iarr[${ipr1}]} == "lightdm" ]]
    then
      ldm_gr=""
      echo -n "Instalando ${iarr[${ipr1}]}"
      pacman_func "lightdm"
      echo -e "${ok}"
      while [[ -z ${lightdm_greeters[${ldm_gr}]} ]] || [[ -z $ldm_gr ]]
      do
        i=0
        empty_lines
        echo "Introduce el numero del greeter que quieras instalar:"
        for greeter in ${lightdm_greeters[@]}
        do
          echo " ${i}.${greeter}"
          ((i=i+1))
        done
        read ldm_gr
      done
      echo -n "Instalando ${lightdm_greeters[${ldm_gr}]}"
      pacman_func "${lightdm_greeters[${ldm_gr}]}"
      echo -e "${ok}"
      sed -i "s/#greeter-session=example-gtk-gnome/greeter-session=${lightdm_greeters[${ldm_gr}]}/g" /mnt/etc/lightdm/lightdm.conf
      echo -e "${ok}"
    elif [[  ${iarr[${ipr1}]} == "bash"  ]]
    then
      :
    elif [[  ${iarr[${ipr1}]} == "zsh"  ]]
    then
      until [[ $ohmyzsh == s ]] || [[ $ohmyzsh == S ]] || [[ $ohmyzsh == n ]] || [[ $ohmyzsh == N ]]
      do
        empty_lines
        echo "Desea insalar OhMyZSH? s/n"
        read ohmyzsh
      done
      if [[ $ohmyzsh == s ]] || [[ $ohmyzsh == S ]]
      then
        echo -n "Descargando OhMyZSH"
        arch-chroot /mnt sh -c "$(wget -O- $ohmyzshlink)" "" --unattended &>/dev/null
        echo -e "${ok}"
        echo -n "Cambiando shell predeterminada"
        if [[ -z $username ]]
        then
          arch-chroot /mnt su root -c "chsh -s /usr/bin/zsh &>/dev/null"
        else
          arch-chroot /mnt su $USERNAME -c "chsh -s /usr/bin/zsh &>/dev/null"
        fi
        echo -e "${ok}"
        sleep 4
      fi
    else
      echo -n "Instalando ${iarr[${ipr1}]} "
      pacman_func "${iarr[${ipr1}]}"
      echo -e "${ok}"
    fi
  fi
}

#SCRIPT-----------------------------------

if [[ -z $(uname -r | grep arch) ]] ##Elimina este if si sabes lo que haces y no tinenes arch
then
  echo -e "${error} No estas utilizando Arch linux, no se puede seguir con la instalacion"
  exit
fi
if [[ $(whoami) != root ]]
then
  echo -e "${error} Debes ejecutar el programa como root, usa sudo su"
  exit
fi
if [[ -z $discos ]]
then
  echo -e "${error} No hay ningun disco conectado a la maquina"
 	exit
fi
discos_conectados
echo "Selecciona como quieres particionar los discos."
echo "En caso de tener un sistema uefi crea como primera particion"
echo "Una UEFI al menos 256MB en el disco principal"
echo ""
dn=0
for disco in $discos
do
  prm=0
	opciones=()
 	echo "----[${disco}]"
 	echo "1.Particionar 2.No particionar 3.Listar discos"
 	read q1
 	until [[ $q1 == 1 ]] || [[ $q1 == 2 ]]
 	do
    if [[ $q1 == 3 ]]
    then
      clear
      discos_conectados
      echo "----[${disco}]"
      echo "1.Particionar 2.No particionar 3.Listar discos"
			read q1
		else
			echo -e "${error} Debes introducir 1 para particionar, 2 para saltar el disco o 3 para listar de nuevo los discos."
	    read q1
    fi
 	done
 	if [[ $q1 == 1 ]]
 	then
 		clear
    comp=$(ls ${disco}? ${disco}p? 2>/dev/null)
    if [[ -z $comp ]]
    then
			ext=False
      full=False
  		for i in $(seq 1 10)
      do
        if [[ $full == "True" ]]
        then
          break
        fi
        q2=''
				if [[ $prm -le 3 ]]
				then
          if [[ $ext == True ]]
					then
						until [[ $q2 == p ]] || [[ $q2 == P ]] || [[ $q2 == l ]] || [[ $q2 == L ]] || [[ $q2 == c ]] || [[ $q2 == C ]] || [[ $q2 == f ]] || [[ $q2 == F ]]
		        do
              clear
							echo "----[${disco}] Restante: ${disk_array[${dn}]}M"
		          echo ""
		          echo "Debes seleccionar un tipo de particion o cancelar la operacion."
		          echo ""
		          echo "Particion ${i}:"
							if [[ $i == 1 ]]
							then
								echo "(P)rimaria, (L)ogica o (C)ancelar"
							else
								echo "(P)rimaria, (L)ogica, (F)in o (C)ancelar)"
							fi
		           	read q2
            done
					else
						until [[ $q2 == p ]] || [[ $q2 == P ]] || [[ $q2 == e ]] || [[ $q2 == E ]] || [[ $q2 == c ]] || [[ $q2 == C ]] || [[ $q2 == F ]] || [[ $q2 == f ]]
		        do
              clear
		          echo "----[${disco}] Restante: ${disk_array[${dn}]}M"
		          echo ""
		          echo "Debes seleccionar un tipo de particion o cancelar la operacion."
		          echo ""
		          echo "Particion ${i}:"
							if [[ $i == 1 ]]
							then
			  				echo "(P)rimaria, (E)xtendida o (C)ancelar"
							else
								echo "(P)rimaria, (E)xtendida, (F)in o (C)ancelar)"
							fi
		          read q2
            done
					fi
				else
					if [[ $ext == True ]]
					then
						until [[ $q2 == n ]] || [[ $q2 == N ]] || [[ $q2 == f ]] || [[ $q2 == F ]]
						do
              clear
							echo "----[${disco}] Restante: ${disk_array[${dn}]}M"
							echo ""
							echo "Se han terminado de crear todas las particiones primarias, a continuacion se crearan particiones logicas"
							echo "(N)ueva, (F)inalizar"
							read q2
            done
						if [[ $q2 == n ]] || [[ $q2 == N ]]
						then
							q2=x
						fi
					fi
          break
				fi
        if [[ $q2 == p ]] || [[ $q2 == P ]]
        then
					opciones+=('n')
          opciones+=('p')
					fdisk_repair
					((prm=prm+1))
        elif [[ $q2 == e ]] || [[ $q2 == E ]]
        then
					ext=True
					opciones+=('n')
          opciones+=('e')
					fdisk_repair
					((prm=prm+1))
				elif [[ $q2 == l ]] || [[ $q2 == L ]]
				then
					opciones+=('n')
					opciones+=('l')
					opciones+=('nbsp')
        elif [[ $q2 == c ]] || [[ $q2 == C ]]
        then
          break 1
				elif [[ $q2 == f ]] || [[ $q2 == F ]]
				then
					break 1
				elif [[ $q2 == x ]]
				then
					opciones+=('n')
					opciones+=('nbsp')
        fi
        test_size=-1
        until [[ $test_size -gt 0 ]]
        do
  				echo "Que tamaño quieres que tenga la particion."
  				echo "Introduce una cifra acompañada de la unidad (T)erabyte (G)igabyte (M)egabyte o (K)ilobyte o pulsa enter para utilizar el resto."
  				read psize
          if [[ ! -z $psize ]]
          then
            sizeconver ${psize}
            test_size=$((${disk_array[${dn}]} - $nsize))
            if [[ $test_size -eq 0 ]] || [[ $test_size -lt 0 ]]
            then
              echo "${test_size} = ${disk_array[${dn}]} - $nsize"
              echo -e "${error} El tamaño de la particion es superior a la del disco, si quieres que la particion ocupe el resto del disco pulsa solo enter"
            fi
          else
            test_size=1
          fi
        done
        if [[ -z $psize ]]
        then
          opciones+=('nbsp')
          if [[ $ext == "False" ]] || [[ $q2 == "l" ]] || [[ $q2 == "L" ]]
          then
            full=True
          fi
        fi
        opciones+=(+$psize)
        disk_array[${dn}]=$test_size
				if [[ $prm -le 3 ]]
				then
					echo "¿Es una particion especial?"
					echo "(S)wap o (U)efi, (N)o"
					read spc
				  until [[ $spc == S ]] || [[ $spc == s ]] || [[ $spc == U ]] || [[ $spc == u ]] || [[ $spc == N ]] || [[ $spc == n ]]
					do
						echo -e "${error} Debes introducir una opcion valida"
						echo "(S)wap o (U)efi, (N)o"
						read spc
					done
					if [[ $spc == s ]] || [[ $spc == S ]]
					then
						opciones+=('t')
						if [[ ! $i == 1 ]]
						then
							opciones+=($i)
						fi
						opciones+=('82')
					elif [[ $spc == U ]] || [[ $spc == u ]]
					then
            uefi_part="True"
						opciones+=('t')
					  if [[ ! $i == 1 ]]
						then
							opciones+=($i)
						fi
						opciones+=('ef')
					fi
				fi
	    done
			if [[ ! $q2 == C ]] || [[ ! $q2 == c ]]
			then
        opciones+=("w")
				name=$(printf "$disco" | awk -F'/' '{print $3}')
	      touch /tmp/disk${name}.tmp
	      for opt in ${opciones[@]}
	      do
          if [[ $opt == nbsp ]]
					then
            printf "\n" >> /tmp/disk${name}.tmp
					else
	         	printf "$opt\n" >> /tmp/disk${name}.tmp
					fi
        done
				fdisk /dev/${name} < /tmp/disk${name}.tmp &>/dev/null
				rm /tmp/disk${name}.tmp
			fi
    else
      echo -e "${error} El disco no esta vacio, vacialo para particionarlo."
      sleep 3
    fi
 	elif [[ $q1 == 2 ]]
 	then
 		:
 	fi
  ((dn=dn+1))
done
empty_lines
echo "Se han acabado de particionar los discos, ahora es necesario formatearlos."
echo ""
eswap=$(fdisk -l | grep swap | awk '{print $1}')
if [[ $uefi_part == "True" ]]
then
  uefipart=$(fdisk -l | grep ef | cut -f1 -d " ")
  mkfs.fat -F 32 ${uefipart}
fi
if [[ -z $eswap ]]
then
	echo -e "${warn} No existe ninguna particion SWAP."
	echo "¿Quieres convertir una particion existente en SWAP? S/N"
	read q3
	until [[ $q3 == n ]] || [[ $q3 == N ]] || [[ $q3 == s ]] || [[ $q3 == S ]]
	do
		echo -e "${error}${q3} no es un valor valido, introduce S o N"
		read q3
	done
	if [[ $q3 == s ]] || [[ $q3 == S ]]
	then
		echo "Introduce la particion que quieres convertir en swap Ej: sdb2"
		read q4
		while [[ -z $q4 ]]
		do
			echo "Introduzca una particion para convertir en swap o (C)ancelar"
			read q4
			if [[ $q4 == c ]] || [[ $q4 == C ]]
			then
				:
			fi
		done
		spart=$(printf $q4 | cut -c 4)
		printf "t\n${spart}\n82\nw\n" > /tmp/swap.txt
		sdisk=$(printf $q4 | cut -c 1,2,3)
		fdisk /dev/${sdisk} < /tmp/swap.txt 1>/dev/null
		rm /tmp/swap.txt
	fi
fi
until [[ $q7 == n ]] || [[ $q7 == N ]]
do
  clear
	q5=none
	until [[ $q5 == f ]] || [[ $q5 == F ]]
	do
  	echo "---------------Particiones"
  	for disco in $discos
  	do
			echo ""
			echo "--$disco"
    	particiones=$(lsblk $disco | tail +3 | sed -r 's/[ ]+/-/g' | cut -f1,4 -d'-')
    	for line in $particiones
    	do
				echo "$line"
			done
		done
    echo ""
		echo "Introduce una particion para formatear o (F)in"
		read q5
		clear
		if [[ $q5 == f ]] || [[ $q5 == F ]]
		then
			:
		else
			fcomp=$(fdisk -l /dev/${q5} 2>/dev/null)
			if [[ -z $fcomp ]]
			then
				echo -e "${error} ${q5} no es una particion valida"
			elif [[ /dev/$q5 == $eswap ]]
			then
				echo ""
				echo -e "${error} ${q5} no se puede formatear (es la particion de SWAP)"
				echo ""
      elif [[ /dev/$q5 == $uefipart ]]
      then
        echo ""
				echo -e "${error} ${q5} no se puede formatear (es la particion de UEFI)"
				echo ""
			else
					echo "Que formato quieres darle a /dev/${q5}"
					echo "(e)xt4, (f)at32 o (c)ancelar"
					read q6
					if [[ $q6 == e ]] || [[ $q6 == E ]]
					then
						mkfs.ext4 -F /dev/${q5} 1>/dev/null
					elif [[ $q6 == f ]] || [[ $q6 == F ]]
					then
						mkfs.fat -F 32 /dev/${q5} 1>/dev/null
					elif [[ $q6 == c ]] || [[ $q6 == C ]]
					then
						:
					fi
			fi
		fi
	done
	empty_lines
	echo "Se han terminado de fomatear las particiones"
	echo ""
	partition_list
	echo ""
	echo "Desea modificar algun formato? S/N"
	read q7
done
mkswap $eswap
swapon $eswap
while [[ -z $rcomp ]]
do
  empty_lines
  echo "A continuacion se van a montar las particiones"
  echo ""
  partition_list
  echo ""
  echo "Introduzca la particion root (/)"
  read rootp
  rcomp=$(fdisk -l /dev/${rootp} 2>/dev/null)
  if [[ -z $rcomp ]] || [[ "/dev/${rootp}" == "${eswap}" ]] || [[ "/dev/${rootp}" == "${uefipart}" ]]
  then
    rcomp=""
    echo -e "${error} ${rootp} no es una particion valida"
    sleep 2
  fi
done
mount /dev/${rootp} /mnt 2>/dev/null
clear
echo -n "Instalando kernel "
pacstrap /mnt ${basepack[@]} 1>/dev/null
if [[ $uefi_part == "True" ]]
then
  mkdir /mnt/boot/efi
  mount $uefipart /mnt/boot/efi
fi
echo -e "${ok}"
sleep 2
until [[ $part == f ]] || [[ $part == F ]]
do
  empty_lines
  if [[ $part == l ]] || [[ $part == L ]]
  then
    partition_list
  fi
  echo "Introduzca los puntos de montaje de la siguiente manera:"
  echo "sda2 /boot/efi"
  echo "Utilize (F)in para no montar mas unidades o (L)iste las unidades."
  read part mpoint
  mpointf="/mnt/${mpoint}"
  if [[ $part == f ]] || [[ $part == F ]]
  then
    :
  elif [[ $part == l ]] || [[ $part == L ]]
  then
    :
  else
    mcomp=$(fdisk -l /dev/${part} 2>/dev/null)
    mpcheck=$(ls /mnt/$mpoint 2>/dev/null)
    if [[ -z $part ]] || [[ -z $mcomp ]]
    then
      echo -e "${error} Tienes que introducir una particion"
      sleep 2
    elif [[ $part == $rootp ]]
    then
      echo -e "${error} No puedes montar la particion root"
      sleep 2
    elif [[ /dev/${part} == $eswap ]]
    then
      echo -e "${error} No puedes montar la particion swap"
      sleep 2
    elif [[ /dev/${part} == $uefipart ]]
    then
      echo -e "${error} No puedes montar la particion uefi"
      sleep 2
    elif [[ -z $mpoint ]]
    then
      echo -e "${error} Tienes que introducir un punto de montaje"
      sleep 2
    elif [[ -z $mpcheck ]]
    then
      q8="placeholder"
      until [[ $q8 == s ]] || [[ $q8 == S ]] || [[ $q8 == n ]] || [[ $q8 == N ]]
      do
        echo -e "${error} No existe el punto de montaje, quieres crearlo? S/N"
        read q8
      done
      if [[ $q8 == s ]] || [[ $q8 == S ]]
      then
        mkdir -p /mnt/$mpoint
        mount /dev/${part} /mnt/$mpoint
        echo -e "${ok} Se ha creado ${mpoint} y se ha montado ${part}."
        sleep 3
      fi
    fi
  fi
done
clear
echo -n "Generando fstab "
genfstab -U /mnt >> /mnt/etc/fstab
echo -e "${ok}"
sleep 2
until [[ $q9 == s ]] || [[ $q9 == S ]]
do
  hostname=''
  while [[ -z $hostname ]]
  do
    empty_lines
    echo "Cual es el nombre que va a tener este equipo"
    read hostname
  done
  echo $hostname > /mnt/etc/hostname
  empty_lines
  echo "El nombre del equipo es:"
  cat /mnt/etc/hostname
  echo "Es correcto? S/N"
  read q9
done
until [[ $q10 == s ]] || [[ $q10 == S ]]
do
  regionf=''
  ciudadf=''
  q10=''
  while [[ -z $regionf ]]
  do
    i=0
    regiones=()
    empty_lines
    echo "Teclea el numero de la region en la que te encuentras"
    echo ""
    for region in $(ls /mnt/usr/share/zoneinfo/)
    do
      if [[ -f /mnt/usr/share/zoneinfo/$region ]] || [[ $region == Etc ]] || [[ $region == posix ]] || [[ $region == right ]] || [[ $region == SystemV ]]
      then
        :
      else
        echo "${i}.${region}"
        regiones+=(${region})
        ((i=i+1))
      fi
    done
    read regionq
    regionf=${regiones[${regionq}]}
    if [[ -z $regionf ]]
    then
      echo -e "${error} No hay ninguna region con el numero ${regionq}"
      sleep 2
    fi
  done
  while [[ -z $ciudadf ]]
  do
    i=0
    ciudades=()
    ciudadi=''
    ciudadq=''
    while [[ -z $ciudadi ]]
    do
      empty_lines
      echo "Teclea la letra inicial de la ciudad en la que te encuentras"
      echo ""
      read ciudadi
    done
    while [[ -z $ciudadq ]]
    do
      empty_lines
      echo "Teclea el numero de la ciudad en la que te encuentras"
      echo ""
      for ciudad in $(ls /mnt/usr/share/zoneinfo/$regionf/${ciudadi^}* 2>/dev/null)
      do
        ciudad=$(echo "${ciudad}" | cut -f7 -d'/')
        echo "${i}.${ciudad}"
        ciudades+=(${ciudad})
        ((i=i+1))
      done
      read ciudadq
      ciudadf=${ciudades[${ciudadq}]}
    done
    if [[ -z $ciudadf ]]
    then
      echo -e "${error} No hay ninguna ciudad con el numero ${ciudadq}"
      sleep 2
    fi
  done
  until [[ $q10 == S ]] || [[ $q10 == s ]] || [[ $q10 == N ]] || [[ $q10 == n ]]
  do
    empty_lines
    echo "La ubicacion es:"
    echo "${ciudadf}, ${regionf}"
    echo "Es correcto? S/N"
    read q10
  done
done
ln -sf /mnt/usr/share/zoneinfo/$regionf/$ciudadf /mnt/etc/localtime
hwclock --systhoc
empty_lines
echo "A continuacion descomente los locales que quiera instalar"
echo "Presione cualquier tecla para continuar"
read cualquiera
until [[ $q11 == s ]] || [[ $q11 == S ]]
do
  nano /mnt/etc/locale.gen
  empty_lines
  echo "Se van a instalar los siguientes locales:"
  locales_list
  echo ""
  echo "Desea continuar? S/N"
  read q11
done
clear
echo -n "Generando locales "
arch-chroot /mnt locale-gen &>/dev/null
echo -e "${ok}"
sleep 1
until [[ $q12 == s ]] || [[ $q12 == S ]]
do
  langf=''
  q12=''
  lang=''
  while [[ -z $lang ]]
  do
    empty_lines
    echo "Cual va a ser el idioma del sistema operativo:"
    locales_list
    read lang
    langf=${locales[${lang}]}
    if [[ -z $langf ]]
    then
      echo -e "${error} No existe ningun idioma con el numero ${lang}"
      sleep 2
    fi
  done
  empty_lines
  echo "Se va a asignar [${langf}] como idioma principal"
  echo "Desea continuar? S/N"
  read q12
done
echo "LANG=${langf}" > /mnt/etc/locale.conf
until [[ $q13 == s ]] || [[ $q13 == S ]]
do
  keymap='placeholder'
  until [[ -z $keymap ]] || [[ ! -z $(arch-chroot /mnt localectl list-keymaps | grep ${keymap} 2>/dev/null) ]]
  do
    empty_lines
    echo "A continuacion seleccione el layout del teclado (No introduzca nada para US)"
    echo "Pulsa cualquier tecla para mostrar las posibilidades y pulsa Q para salir y seleccionar una"
    read cualquiera
    arch-chroot /mnt localectl list-keymaps
    read keymap
  done
  if [[ -z $keymap ]]
  then
    keymap=us
  fi
  until [[ $q13 == n ]] || [[ $q13 == N ]] || [[ $q13 == s ]] || [[ $q13 == S ]]
  do
    empty_lines
    echo "Se va a instalar el siguiente layout"
    echo "[${keymap}]"
    echo "Desea continuar? S/N"
    read q13
  done
done
echo "KEYMAP=${keymap}" > /mnt/etc/vconsole.conf
until [[ $q14 == n ]] || [[ $q14 == N ]] || [[ $q14 == s ]] || [[ $q14 == S ]]
do
  empty_lines
  echo "Quieres crear un usuario nuevo? S/N"
  read q14
done
if [[ $q14 == s ]] || [[ $q14 == S ]]
then
  while [[ $username == root ]] || [[ -z $username ]]
  do
    empty_lines
    echo "Como va a llamarse?"
    read username
  done
  echo -n "Creando usuario "
  arch-chroot /mnt useradd $username
  echo -e "${ok}"
  echo -n "Creando directorio home de ${username} "
  if [[ -z $(ls /mnt/home/$username 2>/dev/null) ]]
  then
    arch-chroot /mnt mkdir /home/$username
    echo -e "${ok}"
  else
    echo -e "${warn}"
  fi
  echo -n "Cambiando los permisos "
  arch-chroot /mnt chown -R $username:$username /home/$username
  echo -e "${ok}"
  sleep 2
  if [[ -z $(arch-chroot /mnt pacman -Q sudo 2>/dev/null) ]]
  then
    :
  else
    until [[ $q15 == n ]] || [[ $q15 == N ]] || [[ $q15 == s ]] || [[ $q15 == S ]]
    do
      empty_lines
      echo "Quieres agregarlo a sudoers? S/N"
      read q15
    done
    if [[ $q15 == s ]] || [[ $q15 == S ]]
    then
      echo "${username} ALL=(ALL) NOPASSWD: ALL" >> /mnt/etc/sudoers
    else
      :
    fi
  fi
  arch-chroot /mnt passwd ${username}
fi
empty_lines
echo "Asigna una clave al usuario root"
arch-chroot /mnt passwd root
echo "127.0.0.1     localhost" > /mnt/etc/hosts && echo "::1      localhost" >> /mnt/etc/hosts && echo "127.0.1.1     ${hostname}.localdomain     ${hostname}" >> /mnt/etc/hosts
until [[ $q16 == s ]] || [[ $q16 == S ]] || [[ $q16 == n ]] || [[ $q16 == N ]]
do
  empty_lines
  echo "A continuacion se van a instalar las siguientes dependencias:"
  echo ""
  for pq in ${bichopack[@]}
  do
    echo "- ${pq}"
  done
  echo ""
  echo "Desea instalar alguno de los paquetes? S/N"
  read q16
done
if [[ $q16 == s ]] || [[ $q16 == S ]]
then
  while [[ -z $q17 ]]
  do
    clear
    echo ""
    echo "Teclee el/los numeros de los paquetes que desee instalar"
    i=0
    echo "- 40.Ninguno"
    for pq in ${bichopack[@]}
    do
      echo "- ${i}.${pq}"
      ((i=i+1))
    done
    echo "- 30.Todos"
    read q17
  done
  if [[ $q17 == 40 ]]
  then
    :
  elif [[ $q17 == 30 ]]
  then
    echo -n "Instalando todos los paquetes "
    pacman_func "${bichopack[@]}"
    echo -e "${ok}"
  else
    for pq in $q17
    do
      target=${bichopack[$pq]}
      if [[ -z $target ]]
      then
        echo -e "${error} No existe ningun paquete con el numero ${pq}"
      else
        echo -n "Instalando ${target} "
        pacman_func "${target}"
        echo -e "${ok}"
      fi
    done
  fi
 sleep 2
elif [[ $q16 == n ]] || [[ $q16 == N ]]
then
  :
fi
clear
gpuinfo=$(lspci | grep VGA | grep NVIDIA)
if [[ -z $gpuinfo ]]
then
  :
else
  until [[ $q18 == n ]] || [[ $q18 == N ]] || [[ $q18 == s ]] || [[ $q18 == S ]]
  do
    empty_lines
    echo -e "${warn} Se ha detectado que tu tarjeta grafica es NVIDIA, deseas instalar los drivers de NVIDIA? S/N"
    read q18
  done
  if [[ $q18 == s ]] || [[ $q18 == S ]]
  then
    pacman_func "nvidia" "nvidia-utils"
    echo -e "${ok} Se han instalado los drivers de NVIDIA"
  else
    :
  fi
fi
while [[ -z $gcomp ]]
do
  until [[ $biosv == u ]] || [[ $biosv == U ]] || [[ $biosv == b ]] || [[ $biosv == B ]]
  do
    empty_lines
    echo "Para instalar grub es necesario saber el tipo de arranque que tiene."
    echo "Seleccione (U)efi o (B)ios"
    read biosv
  done
  if [[ $biosv == b ]] || [[ $biosv == B ]]
  then
    empty_lines
    echo "A continuacion se va a descargar e instalar grub, seleccione el DISCO de arranque"
    discos_conectados
    read grubd
    gcomp=$(fdisk -l ${grubd} 2>/dev/null)
    biosv=B
  elif [[ $biosv == u ]] || [[ $biosv == U ]]
  then
    empty_lines
    echo "A continuacion se va a descargar e instalar grub, seleccion la particion UEFI"
    partition_list
    read grubd
    gcomp=$(fdisk -l /dev/${grubd} 2>/dev/null)
    biosv=U
  fi
done
echo -n "Descargando GRUB "
pacman_func "grub"
echo -e "${ok}"
if [[ $biosv == U ]]
then
  echo -n "Descargando efibootmgr "
  pacman_func "efibootmgr"
  echo -e "${ok}"
  echo -n "Instalando GRUB "
  uefi_install=$(arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB 2>&1 | grep "EFI")
  if [[ ! -z $uefi_install ]]
  then
    echo -e "${error}"
    echo "Tu sistema no es compatible con UEFI"
    sleep 2
    gcomp=""
    while [[ -z $gcomp ]]
    do
      empty_lines
      echo "Se va a instalar GRUB en su version BIOS, seleccione el DISCO de arranque"
      discos_conectados
      read grubd
      gcomp=$(fdisk -l ${grubd} 2>/dev/null)
    done
    echo -n "Instalando GRUB "
    arch-chroot /mnt grub-install --target=i386-pc "${grubd}" &>/dev/null
  fi
elif [[ $biosv == B ]]
then
  echo -n "Instalando GRUB "
  arch-chroot /mnt grub-install --target=i386-pc "${grubd}" &>/dev/null
fi
echo -e "${ok}"
echo -n "Generando el archivo de configuracion de grub "
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg &>/dev/null
echo -e "${ok}"
sleep 2
until [[ $q19 == n ]] || [[ $q19 == N ]] || [[ $q19 == s ]] || [[ $q19 == S ]]
do
  empty_lines
  echo "Por ultimo vamos a instalar el entorno grafico"
  echo "Desea continuar(s) o quiere instalarlo por su cuenta(n)"
  read q19
done
if [[ $q19 == "n" ]] || [[ $q19 == "N" ]]
then
  empty_lines
  echo ""
  echo "GRACIAS POR UTILIZAR ARCH GUIDE-INSTALL BY CONFUGIRADORES®"
  echo ""
  echo "--------------------------------------------------------------------------------------------------"
  echo "Visita www.confugiradores.es para mas scripts, proyectos y tutoriales."
  sleep 3
  exit
fi
install_package "un Display Server" "del display server" "${displayservers[@]}"
install_package "un Escritorio" "del escritorio" "${desktops[@]}"
install_package "un Display Manager" "del display manager" "${dms[@]}"
arch-chroot /mnt systemctl enable ${iarr[${ipr1}]}
install_package "un Window Manager" "del window manager" "${wms[@]}"
install_package "un Terminal" "del terminal" "${terminales[@]}"
install_package "un Shell" "del shell" "${shells[@]}"
sudo chsh -s /mnt/bin/${iarr[${ipr1}]}
install_package "un File Manager" "del File Manager" "${fms[@]}"
install_package "un Navegador" "del navegador" "${navegadores[@]}"
if [[ ! -z $(arch-chroot /mnt pacman -Q dhcpcd 2>/dev/null) ]]
then
  echo -n "Activando configuracion de red "
  arch-chroot /mnt systemctl enable dhcpcd &>/dev/null
  echo -e "${ok}"
  sleep 2
fi
empty_lines
echo ""
echo "GRACIAS POR UTILIZAR ARCH GUIDE-INSTALL BY CONFUGIRADORES®"
echo ""
echo "--------------------------------------------------------------------------------------------------"
echo "Visita www.confugiradores.es para mas scripts, proyectos y tutoriales."
