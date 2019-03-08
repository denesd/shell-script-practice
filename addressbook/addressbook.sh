#!/bin/ash

# Functions

format_echo()
{
	echo "$1" | sed 's/:/ | /g'
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
	INDEX=1
	echo "Name	Phone	  Email"
	while IFS= read LINE
	do
		echo "$INDEX " `format_echo "$LINE"`
		INDEX=`expr $INDEX + 1`
	done < data.txt
	echo
}

search_entrie()
{
	while IFS= read LINE
	do
		RESULT=`echo "$LINE" | grep "$1"`
		format_echo "$RESULT"
	done < data.txt
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
			INDEX=1
			while IFS= read LINE
			do
				if [ "$INDEX" -eq "$1" ]
				then
					if [ "$2" -eq "1" ]
					then
						NAME="$3"
					else
						NAME=`echo "$LINE" | cut -d ":" -f "1"`
					fi
					if [ "$2" -eq "2" ]
					then
						PHONE="$3"
					else
						PHONE=`echo "$LINE" | cut -d ":" -f "2"`
					fi
					if [ "$2" -eq "3" ]
					then
						EMAIL="$3"
					else
						EMAIL=`echo "$LINE" | cut -d ":" -f "3"`
					fi

					save_entrie "$NAME" "$PHONE" "$EMAIL"
					if [ "$?" -eq "0" ]
					then
						remove_entrie "$1" "y"
						echo "Entrie has been edited..."
						echo
					else
						echo "Error(couldn't save entrie)"
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

remove_or_edit_entrie()
{
	if [ "$2" = "edit" ]
	then
		INDEX=1
                while IFS= read LINE
                do
                        echo "$INDEX " $LINE | grep "$1" | sed 's/:/ | /g'
			if [ "$?" -eq "0" ]
			then
				EDIT_INDEX=$INDEX
			fi
                        INDEX=`expr $INDEX + 1`
                done < data.txt
                if [ `grep -r "$1" data.txt | wc -l` -gt "1" ]
		then
			echo "Which entrie do you want to edit?(Number of entrie)"
                        read EDIT_INDEX
                fi
		echo "Which field do you want to edit?(Number of option)"
	        echo "1 Name"
	        echo "2 Phone number"
	        echo "3 Email address"
        	read EDIT_FIELD
        	echo "Type in your change..."
	        read CHANGE
		edit_entrie "$EDIT_INDEX" "$EDIT_FIELD" "$CHANGE"
	else
		INDEX=1
		while IFS= read LINE
		do
			echo "$INDEX " $LINE | grep "$1" | sed 's/:/ | /g'
			if [ "$?" -eq "0" ]
                        then
                                REMOVE_INDEX=$INDEX
                        fi
			INDEX=`expr $INDEX + 1`
		done < data.txt
		if [ `grep -r "$1" data.txt | wc -l` -gt "1" ]
		then
			echo "Which entrie do you want to remove?(Number of entrie)"
			read REMOVE_INDEX
		fi
		remove_entrie "$REMOVE_INDEX"
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
				echo "Search for entrie..."
				read SEARCH
				echo
				search_entrie $CHOICE $SEARCH
				;;
			remove)
				echo "Search for entrie to remove..."
				read REMOVE
				echo
				remove_or_edit_entrie $REMOVE "remove"
				;;
			edit)
				echo "Search for entrie to edit..."
				read EDIT
				remove_or_edit_entrie $EDIT "edit"
				;;
			*)
				echo "No option like $INPUT"
				echo
				;;
		esac
	done
fi
