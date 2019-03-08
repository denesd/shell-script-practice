#!/bin/ash

# Functions

format_echo()
{
	echo "$1" | sed 's/:/ | /g'
}

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
		format_echo "$LINE"
	done < data.txt
	echo
}

search_entrie()
{
	while IFS= read LINE
	do
		RESULT=$(echo "$LINE" | grep "$1")
		format_echo "$RESULT"
	done < data.txt
}

remove_when_one_entrie()
{
	search_entrie "$1"
                while :
                do
                        echo "Are you sure?(y/n)"
                        read CHOICE
                        if [ "$CHOICE" = "y" ]
                        then
                                grep -v "$1" data.txt > temporary_file
                                mv temporary_file data.txt
                                if [ "$?" -eq "0" ]
                                then
                                        echo "Entrie has been removed..."
                                else
                                        echo "Error(couldn't remove entrie)"
                                fi
                                break
                        elif [ "$CHOICE" = "n" ]
                        then
                                break
                        fi
                        echo
                done
}

remove_when_more_entrie()
{
	while :
        do
		echo "Are you sure?(y/n)"
                read CHOICE
                if [ "$CHOICE" = "y" ]
		then
			INDEX=0
			while IFS= read LINE
			do
				if [ "$INDEX" -eq "$1" ]
				then
					grep -v "$LINE" data.txt > temporary_file
					mv temporary_file data.txt
					if [ "$?" -eq "0" ]
					then
						echo "Entrie has been removed..."
					else
						echo "Error(couldn't remove entrie)"
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

remove_entrie()
{
	if [ `grep -r "$1" data.txt | wc -l` -eq "1" ]
	then
		remove_when_one_entrie "$1"
	else
		INDEX=0
		while IFS= read LINE
		do
			echo "$INDEX " $LINE | grep "$1" | sed 's/:/ | /g'
			INDEX=`expr $INDEX + 1`
		done < data.txt
		echo "Which entrie do you want to remove?(Number of entrie)"
		read REMOVE_INDEX
		remove_when_more_entrie "$REMOVE_INDEX"
	fi
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
			search)
				echo "Search for..."
				read SEARCH
				echo
				search_entrie $CHOICE $SEARCH
				;;
			remove)
				echo "Remove..."
				read REMOVE
				echo
				remove_entrie $REMOVE
				;;
			*)
				echo "No option like $INPUT"
				echo
				;;
		esac
	done
fi
