#!/usr/bin/bash

# lpm (Links Package Manager)
#
# Working on a simple script to manage Links extensions
#
# Template Directory for a package:
# ext/
# 	lib/
# 		js/*.js
# 		stdlib/*.links
# 	demo.links (opt)
# 	README.md
#

unset LINKS_DIR

function init_setup {
		if [[ ! -e ~/.lpm ]]
		then
				echo "[lpm] creating ~/.lpm structure"
				mkdir -p ~/.lpm ~/.lpm/packages ~/.lpm/local
		else
				echo "[lpm] ~/.lpm exists"
				return
		fi

		if [[ ! -e ~/.lpm/config ]]
		then
				touch ~/.lpm/config
		else
				echo "[lpm] config exists"
		fi
}

function help {
		printf '\nlpm (Links Package Manager)\n---------------------------\n\n'
		echo 'help :- See this screen.'
		echo 'setup :- Run the initial setup.'
		echo 'install `url` :- Install a package from a GH link.'
    exit 1
}

function install_package {

		mapfile -d $'\0' PACKAGE_LIB_JS < <(find "$1/lib/js/" -name '*.js')
		mapfile -d $'\0' PACKAGE_LIB_LINKS < <(find "$1/lib/js/" -name '*.links')

		for it in $PACKAGE_LIB_JS
		do
				ln -sf "$(pwd)/${it}" "$LINKS_DIR/lib/js/"
		done

		for it in $PACKAGE_LIB_LINKS
		do
				ln -sf "$(pwd)/${it}" "$LINKS_DIR/lib/stdlib/"
		done
}

function find_links_dir () {
		prelude_file=$(find ~ -type f -name 'prelude.links' | grep -v '/\.opam/' | grep '/links/prelude\.links$' | head -n 1)

		if [[ -n "$prelude_file" ]]; then
				LINKS_DIR=$(dirname "$prelude_file")
		fi
}

function install () {
		$(git clone --depth 10 "$1" "$HOME/.lpm/packages/$2")

		find_links_dir

		install_package	"$HOME/.lpm/packages/$2"
}

# Driver

if [[ $# -lt 1 ]]; then
		help
fi


case $1 in
		a|b|c)  # Ok
				;;
		install)
				case $2 in
						https://github.com/*)
								short_name=$(echo "$2" | rev | cut -d '/' -f1 | rev)
								echo "Installing $short_name"
								install "$2" "$short_name"
				esac
				;;
		setup)
				init_setup
				;;
		*)
				# The wrong first argument.
				printf "Unexpected command \'${1}\'\n"
				help
esac

exit 1
