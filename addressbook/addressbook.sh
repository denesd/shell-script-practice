#!/bin/ash

# Functions
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
	echo "		Save entrie with name, phone naumber and email address."
	echo "	-f SEARCH"
	echo "		Find entrie/entries by the given input."
	echo "	-e INDEX FIELD_INDEX CHANGE"
	echo "		Replace entrie's field with CHANGE"
	echo "	-r INDEX"
	echo "		Removes entrie by the given INDEX"
}

save_entrie()
{
	if  grep -q "${1}:${2}:${3}" data.txt
	then
		echo "Entrie already exists..."
		echo
	else
		echo "$1:$2:$3" >> data.txt
                echo Entrie has been saved...
                echo

	fi
}

get_all_entries()
{
	echo "Index	Name	Phone	  Email"
	format_echo "`grep -n "$1" data.txt`"
	echo
}

search_entrie()
{
	format_echo "`grep -n "$1" data.txt`"
}

remove_entrie()
{
	while :
	do
		if [ "$2" != "y" ]
		then
			echo "Are you sure?(y/n)"
			read CHOICE
		fi
		if [ "$CHOICE" = "y" ]
		then
			INDEX=1
        		while IFS= read LINE
        		do
				if [ "$INDEX" = "$1" ]
				then
                             		grep -v "$LINE" data.txt > temporary_file
                               		mv temporary_file data.txt
                               		if [ "$?" -eq "0" ]
                               		then
                                       		if [ "$2" != "y" ]
						then
							echo "Entrie has been removed..."
							echo
						fi
                               		else
                                       		echo "Error(couldn't remove entrie)"
						echo
                               		fi
					break
				fi
				INDEX=`expr $INDEX + 1`
	        	done < data.txt
			break
		elif [ "$CHOICE" = "n" ]
                then
                	break
                fi
                echo
	done
}

edit_entrie()
{
	while :
	do
		echo "Are you sure?(y/n)"
		read CHOICE
		if [ "$CHOICE" = "y" ]
		then
			sed -i "${1}s/`head -n $1 data.txt | tail -n 1 | cut -d : -f $2`/${3}/" data.txt
			if [ "$?" -eq "0" ]
			then
				echo "Entrie has been edited..."
				echo
			else
				echo "Error(couldn't edit entrie)"
				echo
			fi
			break
		elif [ "$CHOICE" = "n" ]
		then
			break
		fi
		echo
	done
}

edit_entrie_menu()
{
	unset EDIT_INDEX
	if [ `grep "$1" data.txt | wc -l` -eq "1" ]
	then
		format_echo `grep "$1" data.txt`
		EDIT_INDEX=`grep -n "$1" data.txt | cut -d : -f 1`
	else
		while [ -z "$EDIT_INDEX" ]
		do
			format_echo "`grep -n "$1" data.txt`"
			echo "Which entrie do you want to edit?(Number of entrie)"
			read EDIT_INDEX
		done
	fi
	unset EDIT_FIELD
	while [ -z "$EDIT_FIELD" ]
	do
		echo "Which field do you want to edit?(Number of option)"
		echo "1 Name"
		echo "2 Phone number"
		echo "3 Email address"
		read EDIT_FIELD
	done
	unset CHANGE
	while [ -z "$CHANGE" ]
	do
		echo "Type in your change..."
		read CHANGE
	done
	edit_entrie "$EDIT_INDEX" "$EDIT_FIELD" "$CHANGE"
}

remove_entrie_menu()
{
	unset REMOVE_INDEX
	if [ `grep "$1" data.txt | wc -l` -eq "1" ]
	then
		format_echo `grep "$1" data.txt`
		REMOVE_INDEX=`grep -n "$1" data.txt | cut -d : -f 1`
	else
		while [ -z "$REMOVE_INDEX" ]
		do
			format_echo "`grep -n "$1" data.txt`"
			echo "Which entrie do you want to remove?(Number of entrie)"
			read REMOVE_INDEX
		done
	fi
	remove_entrie "$REMOVE_INDEX"
}

# Main
if [ "$#" -eq "0" ]
then
	while :
	do
		# Menu
		echo "Addressbook"
		echo "Type 'all' to display all entires"
		echo "Type 'add' to add entire"
		echo "Type 'search' to search entires"
		echo "Type 'edit' to edit an existing entrie"
		echo "Type 'remove' to remove an entire"
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
				save_entrie "$NAME" "$PHONE" "$EMAIL"
				;;
			search)
				echo "Search for entrie..."
				read SEARCH
				echo
				search_entrie $SEARCH
				;;
			remove)
				echo "Search for entrie to remove..."
				read REMOVE
				echo
				remove_entrie_menu $REMOVE
				;;
			edit)
				echo "Search for entrie to edit..."
				read EDIT
				edit_entrie_menu $EDIT
				;;
			*)
				echo "No option like $INPUT"
				echo
				;;
		esac
	done
else
	while getopts 'af:r:e:s:h' c
	do
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
					save_entrie "$2" "$3" "$4"
				else
					echo "Error: need 3 argument"
					exit 1
				fi
				;;
			f)
				search_entrie "$2"
				;;
			e)
				if [ "$#" -eq "4" ]
				then
					edit_entrie "$2" "$3" "$4"
				else
					echo "Error: need 3 argument"
					exit 1
				fi
				;;
			r)
				remove_entrie "$2"
				;;
			*)
				usage
				exit 1
		esac
	done
	shift $((OPTIND -1))
fi
