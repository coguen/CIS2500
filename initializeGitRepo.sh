#!/bin/sh

# CIS*2500 Git Repository clone and setup script.
#
# This script clones and initializes a GIT repository using a skeleton provided
# in a course repository bearing the same name as the repository to be initialized.
# The rough procedure (ignoring all of the error handling) is:
#
# git clone <repository URL>
# enter the repository
# git remote add <course repository name> <course repository URL>
# git pull <course repository name> <branch>
# git push origin <branch>
#
# For both the push and the pull operation the branch will default to "master"
#
# Inputs:
#	The central login id (Gryph Mail Username) of the student cloning the repository.
#	The name of the repository to clone.
#
# Outputs:
#	A directory with the name of the repository to clone, containing the contents
#	of the repository and any initialization data.
#
# Errors:
#	1 - Program was called with the incorrect number of arguments
#	2 - Git binary not found
#	3 - Clone operation failed
#	4 - Pull operation failed
#	5 - Push operation failed

# Binaries
GIT="/usr/bin/git"

# GIT URL Components
HOSTNAME="bucky.socs.uoguelph.ca"
GITROOT="git"
GITPROTO="https"
USERNAME=""
REPONAME=""

# Name and Location of the Course repository
REMOTENAME="cis2500"
REMOTEDIR="CIS2500"

# Branch Names
REMOTEBRANCH="master"
LOCALBRANCH="master"

# Options to GIT commands
CLONEOPTS="--config http.sslVerify=off"
PULLOPTS=""
PUSHOPTS=""

# Exit Status
STATUS=0

# Check for the presence of the required arguments and load them.
# Print a usage message and exit if they are missing.
if [ "$#" = "2" ]; then
	USERNAME=`echo "$1" | tr '[:upper:]' '[:lower:]'`
	REPONAME=`echo "$2" | tr '[:upper:]' '[:lower:]'`
else
	echo "Usage: $0 <Central Login ID> <Repository Name>"
	echo
	echo "<Central Login ID> is your gryph mail username"
	echo "<Repository Name> is the name of the repository that you wish to setup"

	exit 1
fi

# Make sure that the git binary exists and is executable.
if [ ! -x $GIT ]; then
	echo "$GIT doesn't exist or is not executable.  Please make sure that git is"
	echo "installed.  If you have installed git in a non standard location then update"
	echo "the value of the GIT variable to point at your git binary."
	exit 2
fi

# Clone GIT repository
echo "Cloning your git repository..."

if $GIT clone $CLONEOPTS "$GITPROTO://$USERNAME@$HOSTNAME/$GITROOT/$USERNAME/$REPONAME"; then

	# Enter the Git repository, as the following operation must be run from inside the repository
	cd $REPONAME

	# Add the remote for the course repository
	$GIT remote add $REMOTENAME "$GITPROTO://$USERNAME@$HOSTNAME/$GITROOT/$REMOTEDIR/$REPONAME"

	# Pull the skeleton from the course repository.  if the skeleton has already been pulled then 
	# this will do nothing (successfully).
	echo "Pulling in data from the course repository..."
	if $GIT pull $PULLOPTS $REMOTENAME $REMOTEBRANCH; then

		# Push the initialized repository back to the server.  If the repository on the server has already
		# been initialized then this will do nothing (successfully).
		echo "Pushing your repository to the Server..."
		if $GIT push $PUSHOPTS "origin" $LOCALBRANCH; then
			echo
			echo "Git Repository setup complete."
		else
			echo
			echo "Failed to push to your repository on $HOSTNAME.  Did you enter your"
			echo "password correctly? You can either delete the $REPONAME directory, and try"
			echo "again, or you may attempt to run the following command manually:"
			echo
			echo "$GIT $PUSHOPTS push "origin" $LOCALBRANCH"
			echo
			echo "If all of this fails please post a message to the forums on"
			echo "bucky.socs.uoguelph.ca asking for help.  Please include all commands that"
			echo "you ran and all of the output so that you can get a quickest possible"
			echo "solution to this problem."

			STATUS=5
		fi
	else
		echo
		echo "Failed to pull from the Course Repository.  Did you enter your password"
		echo "correctly?  You can either delete the $REPONAME directory, and try again,"
		echo "or you may attempt to run the following two commands manually:"
		echo
		echo "$GIT pull $PULLOPTS $REMOTENAME $REMOTEBRANCH"
		echo "$GIT push $PUSHOPTS "origin" $LOCALBRANCH"
		echo
		echo "If all of this fails please post a message to the forums on"
		echo "bucky.socs.uoguelph.ca asking for help.  Please include all commands that"
		echo "you ran and all of the output so that you can get a quickest possible" 
		echo "solution to this problem."

		STATUS=4
	fi

	# Return the working directory to the place from which we started.
	cd $OLDPWD
else
	echo
	echo "The clone operation for your git repository failed.  Please make sure that you"
	echo "entered your central login id, repository name, and password correctly.  If"
	echo "your are sure that you entered everything correctly then please post a request"
	echo "for help to the forums on bucky.socs.uoguelph.ca.  Please be sure to include:"
	echo "The command that you just ran, this message and everything that was printed"
	echo "between them."

	STATUS=3
fi

exit $STATUS
