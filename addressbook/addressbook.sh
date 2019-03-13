#!/usr/bin/env sh

set -eu

# Functions
DATABASE="data.txt"

init_db()
{
	if [ ! -f "$DATABASE" ]; then
		touch "$DATABASE"
	fi
}

format_echo()
{
	echo "$1" | sed 's/:/ | /g'
}

usage()
{
	echo "usage: addressbook [OPTIONS]"
	echo
	echo "OPTIONS"
	echo "	-h"
	echo "		Display usage"
	echo "	-a"
	echo "		Display all entries."
	echo "	-s NAME PHONE EMAIL"
	echo "		Save entry with name, phone number and email address."
	echo "	-f SEARCH"
	echo "		Find entry/entries by the given input."
	echo "	-e INDEX FIELD_INDEX CHANGE"
	echo "		Replace entry's field with CHANGE"
	echo "	-r INDEX"
	echo "		Removes entry by the given INDEX"
}

save_entry()
{

	NAME="$1"
	PHONE="$2"
	EMAIL="$3"
	if [ -z "$NAME" ] || [ -z "$PHONE" ] || [ -z "$EMAIL" ]; then
		echo "None of the fields can be empty..."
		echo
	else
		if  grep -q "$NAME:$PHONE:$EMAIL" "$DATABASE"; then
			echo "Entry already exists..."
			echo
		else
			echo "$NAME:$PHONE:$EMAIL" >> "$DATABASE"
               		echo Entry has been saved...
                	echo
		fi
	fi
}

get_all_entries()
{
	echo "Index	Name	Phone	  Email"
	format_echo "`cat -n  $DATABASE`"
	echo
}

search_entry()
{
	if [ -z "$@" ]; then
		get_all_entries
	else
		format_echo "`grep -n "$1" $DATABASE`"
		echo
	fi
}

remove_entry()
{
	local ENTRY_INDEX=$1
	if [ "$#" -ne "2" ]; then
		local FORCE=""
	else
		local FORCE="$2"
	fi
	while :; do
		if [ "$FORCE" != "y" ]; then
			echo "Are you sure?(y/n)"
			read CHOICE
		fi
		if [ "$CHOICE" = "y" ]; then
			INDEX=1
			while IFS= read LINE; do
				if [ "$INDEX" = "$ENTRY_INDEX" ]; then
					grep -v "$LINE" "$DATABASE" > temporary_file
					mv temporary_file "$DATABASE"
					if [ "$?" -eq "0" ]; then
						if [ "$FORCE" != "y" ]; then
							echo "Entry has been removed..."
							echo
						fi
					else
						echo "Error( couldn't remove entry )"
						echo
					fi
					break
				fi
				INDEX=`expr $INDEX + 1`
			done < "$DATABASE"
			break
		elif [ "$CHOICE" = "n" ]; then
			break
		fi
		echo
	done
}

edit_entry()
{
	ENTRY_INDEX=$1
	EDIT_FIELD=$2
	CHANGE="$3"
	while :; do
		echo "Are you sure?(y/n)"
		read CHOICE
		if [ "$CHOICE" = "y" ]; then
			sed -i "${ENTRY_INDEX}s/`head -n $ENTRY_INDEX $DATABASE \
				| tail -n 1 \
				| cut -d : -f $EDIT_FIELD`/$CHANGE/" "$DATABASE"
			if [ "$?" -eq "0" ]; then
				echo "Entry has been edited..."
				echo
			else
				echo "Error( couldn't edit entry )"
				echo
			fi
			break
		elif [ "$CHOICE" = "n" ]; then
			break
		fi
		echo
	done
}

edit_entry_menu()
{
	if [ -z "$@" ]; then
		SEARCH=""
	else
		SEARCH="$1"
	fi
	local ENTRY_INDEX=
	if [ `grep "$SEARCH" $DATABASE | wc -l` -eq "1" ]; then
		format_echo `grep "$SEARCH" $DATABASE`
		ENTRY_INDEX=`grep -n "$SEARCH" $DATABASE | cut -d : -f 1`
	else
		while [ -z "$ENTRY_INDEX" ]; do
			format_echo "`grep -n "$SEARCH" $DATABASE`"
			echo "Which entry do you want to edit?( Index of entry )"
			read ENTRY_INDEX
		done
	fi
	local FIELD_INDEX=
	while [ -z "$FIELD_INDEX" ]; do
		echo "Which field do you want to edit?( Index of option )"
		echo "1 Name"
		echo "2 Phone number"
		echo "3 Email address"
		read FIELD_INDEX
	done
	local CHANGE=
	while [ -z "$CHANGE" ]; do
		echo "Type in your change..."
		read CHANGE
	done
	edit_entry "$ENTRY_INDEX" "$FIELD_INDEX" "$CHANGE"
}

remove_entry_menu()
{
	if [ -z "$@" ]; then
		SEARCH=""
	else
		SEARCH="$1"
	fi
	local ENTRY_INDEX=
	if [ `grep "$SEARCH" $DATABASE | wc -l` -eq "1" ]; then
		format_echo `grep "$1" $DATABASE`
		ENTRY_INDEX=`grep -n "$1" $DATABASE | cut -d : -f 1`
	else
		while [ -z "$ENTRY_INDEX" ]; do
			format_echo "`grep -n "$SEARCH" $DATABASE`"
			echo "Which entry do you want to remove?( Index of entry )"
			read ENTRY_INDEX
		done
	fi
	remove_entry "$ENTRY_INDEX"
}

# Main
init_db
if [ "$#" -eq "0" ]; then
	while :; do
		# Menu
		echo "Addressbook"
		echo "Type 'all' to display all entires"
		echo "Type 'add' to add entry"
		echo "Type 'search' to search entires"
		echo "Type 'edit' to edit an existing entry"
		echo "Type 'remove' to remove an entry"
		echo "(^C to quit)"
		read INPUT
		echo

		# Cases
		case $INPUT in
			all)
				get_all_entries
				;;
			add)
				echo "Please enter your name:"
				read NAME
				echo "Please enter your phone number:"
				read PHONE
				echo "Please enter your email address:"
				read EMAIL
				echo
				save_entry "$NAME" "$PHONE" "$EMAIL"
				;;
			search)
				echo "Search for entry..."
				read SEARCH
				echo
				search_entry $SEARCH
				;;
			remove)
				echo "Search for entry to remove..."
				read REMOVE
				echo
				remove_entry_menu $REMOVE
				;;
			edit)
				echo "Search for entry to edit..."
				read EDIT
				edit_entry_menu $EDIT
				;;
			*)
				echo "No option like $INPUT"
				echo
				;;
		esac
	done
else
	while getopts 'af:r:e:s:h' c; do
		case $c in
			h)
				usage
				;;
			a)
				get_all_entries
				;;
			s)
				if [ "$#" -eq "4" ]
				then
					save_entry "$2" "$3" "$4"
				else
					echo "Error: need 3 argument"
					exit 1
				fi
				;;
			f)
				search_entry "$2"
				;;
			e)
				if [ "$#" -eq "4" ]
				then
					edit_entry "$2" "$3" "$4"
				else
					echo "Error: need 3 argument"
					exit 1
				fi
				;;
			r)
				remove_entry "$2"
				;;
			*)
				usage
				exit 1
		esac
	done
	shift $((OPTIND -1))
fi
