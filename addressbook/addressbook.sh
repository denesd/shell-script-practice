#!/bin/ash

# Functions
save_entrie()
{
	echo "$1:$2:$3" >> data.txt
	echo Entrie has been saved...
	echo
}

get_all_entries()
{
	echo "Name	Phone	  Email"
	while IFS= read LINE
	do
		echo ${LINE} | sed 's/:/ | /g'
	done < data.txt
	echo
}

# Main
if [ -z "$@" ]
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
			*)
				echo "No option like $INPUT"
				echo
				;;
		esac
	done
fi
