#!/bin/bash
# Interactive SSL Creation
# Script.
# Date: 23MAR2017
# Created by: Richard L. Jackson
################################

option=$1
__ssl_certs='/etc/apache2/ssl'

enable_mod(){
	# Enable SSL Module.
	a2enmod ssl
	# Now restart Apache Services.
	service apache2 restart
	}

create_dir(){
	# Certificate Directory.
	[ ! -d "${__ssl_certs}" ] && mkdir -v "${__ssl_certs}" && \
	printf "\033[34mCreating, Directory...\033[0m\n" || \
	printf "\033[32mFound:\033[0m \033[36mDirectory, ${__ssl_certs}\033[0m\n"
	}

create_certs(){
	# Check if OpenSSL installed.
	_found="$(whereis openssl | wc -c)"
	case ${_found} in
		0) printf "\033[32mInstalling,\033[0m \033[35mOpenSSL\033[0m\n"
		yes | apt-get install openssl
		;;
		*) printf "\033[32mFound,\033[0m \033[35mOpenSSL\033[0m\n"
		;;
	esac
	# Create a 1 Year cert
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt
	}

edit_default_conf(){
	__apache_ssl_conf='/etc/apache2/sites-available/default-ssl.conf'
	__base64_conf="PElmTW9kdWxlIG1vZF9zc2wuYz4KICAgIDxWaXJ0dWFsSG9zdCBfZGVmYXVsdF86NDQzPgogICAgICAgIFNlcnZlckFkbWluIGFkbWluQGV4YW1wbGUuY29tCiAgICAgICAgU2VydmVyTmFtZSB5b3VyX2RvbWFpbi5jb20KICAgICAgICBTZXJ2ZXJBbGlhcyB3d3cueW91cl9kb21haW4uY29tCiAgICAgICAgRG9jdW1lbnRSb290IC92YXIvd3d3L2h0bWwKICAgICAgICBFcnJvckxvZyAke0FQQUNIRV9MT0dfRElSfS9lcnJvci5sb2cKICAgICAgICBDdXN0b21Mb2cgJHtBUEFDSEVfTE9HX0RJUn0vYWNjZXNzLmxvZyBjb21iaW5lZAogICAgIAoJU1NMRW5naW5lIG9uCiAgICAgICAgU1NMQ2VydGlmaWNhdGVGaWxlIC9ldGMvYXBhY2hlMi9zc2wvYXBhY2hlLmNydAogICAgICAgIFNTTENlcnRpZmljYXRlS2V5RmlsZSAvZXRjL2FwYWNoZTIvc3NsL2FwYWNoZS5rZXkKCiAgICAgICAgPEZpbGVzTWF0Y2ggIlwuKGNnaXxzaHRtbHxwaHRtbHxwaHApJCI+CiAgICAgICAgICAgICAgICAgICAgICAgIFNTTE9wdGlvbnMgK1N0ZEVudlZhcnMKICAgICAgICA8L0ZpbGVzTWF0Y2g+CgogICAgICAgIDxEaXJlY3RvcnkgL3Vzci9saWIvY2dpLWJpbj4KICAgICAgICAgICAgICAgICAgICAgICAgU1NMT3B0aW9ucyArU3RkRW52VmFycwogICAgICAgIDwvRGlyZWN0b3J5PgogICAgPC9WaXJ0dWFsSG9zdD4KPC9JZk1vZHVsZT4K"

	printf "\033[32mEditing,\033[0m \033[35m${__apache_ssl_conf}\033[0m\n"

	if [ -f "${__apache_ssl_conf}" ];
	then
		read -p "Did you want to archive the current version?[ Y|N ]" _archive
		case ${_archive} in
			y|Y|yes|Yes)
			if [ ! -d "backups" ];
			then
				mkdir -v "backups"
			else
				printf "\033[35mFound local archive directory.\033[0m\n"
			fi
			# Archive old config with timestamp.
			cp -a -v "${__apache_ssl_conf}" backups/default-ssl.config.archive-$(date '+%s')
			;;
		esac
		echo "${__base64_conf}" | base64 --decode | tee "${__apache_ssl_conf}"
	else
		printf "\033[35mError:\033[0m \033[31mMissing configuration file!\033[0m\n"
	fi
	}

enable_default_conf(){
	a2ensite default-ssl.conf
	service apache2 restart
	}

case $option in
	-start|-init)
		printf "\033[36mYou are about to create a SSL Certificate.\033[0m\n"
		read -p "Continue?[ Y|N ]" toggle
		case $toggle in
			y|Y)
			# Completes all functions
			enable_mod
			create_dir
			create_certs
			edit_default_conf
			enable_default_conf
			;;
			*) exit 1;;
		esac
	;;
	--edit-config) edit_default_conf;;
	*) printf "\033[35mError:\033[0m\t\033[31mMissing or invalid command!\033[0m\n";;
esac
