#!/bin/sh
# Copyright (c) 2016 KoriDev
# All rights reserved

# Config ( No Change )
NEXT_VERSION=0.5
PATCH_SERVER=http://koridev.eu/download/install

# Funktionen 

update() {
	clear
	echo "Es wird geprueft ob ein Update vorhanden ist..."
	if wget $PATCH_SERVER -q -O - | grep install${NEXT_VERSION} >> /dev/null; then
		echo "Die neuste Version wird heruntergeladen..."
		sleep 1
		cd /usr/home && rm install.sh
		fetch $PATCH_SERVER/install${NEXT_VERSION}.sh
		mv install${NEXT_VERSION}.sh install.sh
		sh install.sh
	else
		echo "Der Installer ist auf der neusten Version."
		sleep 2
		clear
		main_menue
	fi
	
}

main_menue() {
	clear
	printf "Willkommen im Koridev Server Installer\n
Was willst du machen ?\n
	\n
1 - Ports Aktualisieren\n
2 - Mysql Installieren\n
3 - Python Installieren\n
4 - Libs Installieren\n
5 - KoriDev Files Menue\n
6 - Mysql Menu\n
7 - Exit\n
Antwort: "

	read -r menue
	case $menue in
		1) port_menue;;
		2) mysql_menue;;
		3) python_menue;;
		4) lib_menue;;
		5) files_menue;;
		6) mysql_verwaltung;;
		7) echo "bye";;
		*) main_menue;;
	esac
}

port_menue() {
	echo "Ports werden geupdatet..."
	portsnap fetch extract && portsnap fetch update
	echo "Ports wurden geupdatet"
	main_menue
}

mysql_menue() {
	clear
	if pkg info | grep  mysql55 >> /dev/null; then
		echo "Mysql 5.5 wird Deinstalliert..."
		pkg remove mysql55-server
		echo "Mysql 5.6 wird Installiert..."
		pkg install -y mysql56-server
		echo 'mysql_enable="YES"' >> /etc/rc.conf
		rehash
		echo "Mysql 5.6 wurde Installert"
		main_menue
	elif pkg info | grep  mysql56 >> /dev/null; then
		clear
		echo "Du hast bereits die neuste Verion von Mysql"
		sleep 2
		main_menue
	else
		echo "Es ist kein Mysql Installiert"
		echo "Mysql 5.6 wird Installiert..."
		pkg install -y mysql56-server
		echo 'mysql_enable="YES"' >> /etc/rc.conf
		rehash
		echo "Mysql 5.6 wurde Installert"
		main_menue
	fi
}

mysql_verwaltung() {
	clear
	printf "Was willst du machen?\n
1 - Mysql Funktionen ( start|stop|restart|status )\n
2 - Mysql Stock err fixx\n
3 - Mysql Passwort aendern\n
4 - zum Installer\n
Antwort: "
	read -r myslver
	case $myslver in
		1) echo "Gib ein was du machen willst ( start|stop|restart|status )"
			read -r mmysql
				if [ "$mmysql" = "start" ] || [ "$mmysql" = "restart" ] || [ "$mmysql" = "stop" ] || [ "$mmysql" = "status" ] ; then
					/usr/local/etc/rc.d/mysql-server "${mmysql}"
				else
					echo "Falsche eingabe."
					sleep 1
					mysql_verwaltung
				fi;;
		2) echo "Clean the database..."
			cd /var/db/mysql && rm ./*.err
			mysql_verwaltung;;
		3) printf "gib dein aktuelles Passwort ein:"
			read -r pw1
			printf "Gib nun dein neues Passwort ein:"
			read -r pw2
			
			mysqladmin -u root -p"$pw1" password "$pw2"
			echo "Das alte passwort: $pw1 wurde zu $pw2 geaendert.";;
		4) clear
			main_menue;;
		*) mysql_verwaltung;;
	esac
}

python_menue() {
	echo "Python wird Installiert..."
	pkg install -y python
	echo "Python wurde Installiert"
	main_menue
}

lib_menue() {
	echo "Libs werden Installiert..."
		if uname -m | grep i38 >> /dev/null; then
			cd /usr/lib || exit
			Files="libc.so.5 libc_r.so.5 libgtest.so.0 libIL.so.2 libjasper.so.4 libjbig.so.1 libjpeg.so.11 liblcms.so.1 libm.so.2 libm.so.4 libmd.so.4 libmng.so.1 libpng15.so.15 libstdc++.so.4 libstdc++.so.6 libtiff.so.4 libz.so.2 libz.so.4 libmysqlclient.so.18"
			n=0
			for i in $Files
				do n=$(("$n" + 1))
					eval file"$n"="$i"
						for f in $(("$n"))
							do if [ -e "$file$i" ]; then
								echo "${f} : $file$i Existiert"
								sleep 1
							else fetch http://koridev.eu/download/libs/"$file$i"
							fi
						done
			done
			if uname -a | grep '10.0-RELEASE' || '10.3-RELEASE' >> /dev/null; then
				fetch http://koridev.eu/download/libs/libmd.so.5
			fi
			
		elif uname -m | grep amd >> /dev/null; then
			cd /usr/lib32 || exit
			Files="libc.so.5 libc_r.so.5 libgtest.so.0 libIL.so.2 libjasper.so.4 libjbig.so.1 libjpeg.so.11 liblcms.so.1 libm.so.2 libm.so.4 libmd.so.4 libmng.so.1 libpng15.so.15 libstdc++.so.4 libstdc++.so.6 libtiff.so.4 libz.so.2 libz.so.4 libmysqlclient.so.18"
			n=0
			for i in $Files
				do n=$(("$n" + 1))
					eval file"$n"="$i"
						for f in $(("$n"))
							do if [ -e "$file$i" ]; then
								echo "${f} : $file$i Existiert"
								sleep 1
							else fetch http://koridev.eu/download/libs/"$file$i"
							fi
						done
			done
			if uname -a | grep '10.0-RELEASE' || '10.3-RELEASE' >> /dev/null; then
				fetch http://koridev.eu/download/libs/libmd.so.5
			fi
		else
			echo "Ein Fehler ist aufgetreten"
		fi
		main_menue
}

update_files() {
	echo "Diese Funktion ist noch im Aufbau."
}

files_menue() {
	clear
	printf "Koridev Serverfiles Menue\n
Was willst du machen?\n
1 - Serverfiles Installieren\n
2 - Serverfiles Updaten\n
3 - Zum Installer zurueck\n
Antwort: "
	read -r awser
	case $awser in
		1) echo "Serverfiles erden heruntergeladen..."
			mkdir /usr/home
			cd / && ln -s /usr/home home
			cd /home && fetch http://koridev.eu/files/game2.tar.gz
			tar xzvf game2.tar.gz
			chmod -R 777 game2
			rm -R game2.tar.gz
			echo "Die game wurde erfolgreich heruntergeladen und entpackt"
			echo "Mysql wird heruntergeladen..."
			cd /var/db && fetch http://koridev.eu/files/mysql.tar.gz
			tar xzvf mysql.tar.gz
			chmod -R 777 mysql
			rm -R mysql.tar.gz
			service mysql-server restart
			echo "Mysql wurde erfolgreich heruntergeladen und entpackt"
			files_menue;;
		2) update_files;;
		3) main_menue;;
		*) files_menue;;
	esac
}

wget_check() {
	if pkg info | grep wget >> /dev/null; then
		update
	else
		pkg install -y wget
		clear
		echo "Wget wurde Installiert."
		update
	fi
}

pkg_check() {
	clear
	if command -v pkg >> /dev/null; then
		wget_check
	else
		cd /usr/ports/ports-mgmt/pkg/ && make install clean
		wget_check
	fi
}
pkg_check
#main_menue