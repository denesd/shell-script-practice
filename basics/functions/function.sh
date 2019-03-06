#!/bin/sh

add_user()
{
	USER=$1
	PASSWORD=$2
	shift
	shift
	COMMENTS=$@
	echo "Adding user $USER ..."
	echo useradd -c "$COMMENTS" $USER
	echo passwd $USER $PASSWORD
	echo "Added user $USER ($COMMENTS) with pass $PASSWORD"
}

#Main
echo "Start of script..."
add_user bob letmein Bob Holness the presenter
add_user lol catchme Lol Golness the thief
echo "End of script..."
