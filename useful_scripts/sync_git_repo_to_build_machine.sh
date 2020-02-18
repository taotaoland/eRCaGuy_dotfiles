#!/bin/bash

# This file is part of eRCaGuy_dotfiles: https://github.com/ElectricRCAircraftGuy/eRCaGuy_dotfiles

# sync_git_repo_to_build_machine.sh
# - Sometimes you need to develop software on one machine (ex: a decent laptop, running an IDE like Eclipse) 
#   while building on a remote server machine (ex: a powerful desktop, or a paid cloud-based server such as 
#   AWS or Google Cloud). The problem, however, is "how do I sync from the machine I work on to the machine 
#   I build on?". This script answers that problem. It uses git to sync from one to the other. Git is 
#   preferred over rsync or other sync tools since they try to sync *everything* and on large repos 
#   they take FOREVER (dozens of minutes, to hours)! This script is lightning-fast (seconds)! 
# - Run it from the *client* machine where you develop code, NOT the server where you will build the code!
# - It MUST be run from a directory inside the repo you are syncing FROM.

# INSTALLATION:
# todo

# References:
# 1. For main notes & reference links see "sync_git_repo_to_build_machine--notes.txt"
# 1. Bash numerical comparisons: 
#    https://stackoverflow.com/questions/18668556/comparing-numbers-in-bash/18668580#18668580

# Background Research:
# 1. 

# . ~/.bashrc # contains ##########

# --------------------
# USER PARAMETERS:
MY_NAME="gabriel.staples" # No spaces allowed! Recommended to use all lower-case.
# --------------------


echo -e "Pushing current branch with all changes (including staged, unstaged, & untracked files)\n"\
"  to remote sync branch."

DIR_START="$(pwd)"
# echo "DIR_START = $DIR_START" # debugging

# Get git root dir (so you can do `git commit -A` from this dir in case you are in a lower dir--ie: cd to 
# the root FIRST, then `git commit -A`, then cd back to where you were)
# See: https://stackoverflow.com/questions/957928/is-there-a-way-to-get-the-git-root-directory-in-one-command/957978#957978
DIR_REPO_ROOT="$(git rev-parse --show-toplevel)" # Ex: /home/gabriel/dev/eRCaGuy_dotfiles
# echo "DIR_REPO_ROOT = $DIR_REPO_ROOT" # debugging

# Make a temp dir one level up from DIR_REPO_ROOT, naming it "repo-name_temp"
BASENAME="$(basename $DIR_REPO_ROOT)" # Ex: eRCaGuy_dotfiles
DIRNAME="$(dirname $DIR_REPO_ROOT)" # Ex: /home/gabriel/dev
TEMP_DIR="${DIRNAME}/${BASENAME}_temp" # this is where temp files will be stored
# echo "TEMP_DIR = $TEMP_DIR" # debugging
mkdir -p "$TEMP_DIR"

echo "Storing temp files in \"$TEMP_DIR\"."

# See if any changes exist (as normally shown by `git status`). 
# If any changes do exist, back up the file paths which are:
# 1) changed and staged
# 2) changed and not staged
# 3) untracked

FILE_STAGED="$TEMP_DIR/1_staged.txt"
FILE_NOT_STAGED="$TEMP_DIR/2_not_staged.txt"
FILE_UNTRACKED="$TEMP_DIR/3_untracked.txt"

# 1) Get list of changed and staged files:
# See: https://stackoverflow.com/questions/33610682/git-list-of-staged-files/33610683#33610683
git diff --name-only --cached > "$FILE_STAGED"
num_staged=$(cat "$FILE_STAGED" | wc -l)
echo "  num_staged = $num_staged"

# 2) Get list of changed and not staged files:
# See (Implicitly learned from here): https://stackoverflow.com/questions/33610682/git-list-of-staged-files/33610683#33610683
git diff --name-only > "$FILE_NOT_STAGED"
num_not_staged=$(cat "$FILE_NOT_STAGED" | wc -l)
echo "  num_not_staged = $num_not_staged"

# 3) Get list of untracked files:
# See: https://stackoverflow.com/questions/3801321/git-list-only-untracked-files-also-custom-commands/3801554#3801554
git ls-files --others --exclude-standard > "$FILE_UNTRACKED"
num_untracked=$(cat "$FILE_UNTRACKED" | wc -l)
echo "  num_untracked = $num_untracked"

total=$[$num_staged + $num_not_staged + $num_untracked]
echo "  total = $total"

# Commit uncommitted changes (if any exist) into a temporary commit we will uncommit later
made_temp_commit=false
if [ "$total" -gt "0" ]; then
    made_temp_commit=true

    echo "Making a temporary commit of all uncommitted changes."
    cd "$DIR_REPO_ROOT"
    git add -A
    git commit -m "SYNC TO BUILD MACHINE"
fi

echo "Force pushing to remote \"${MY_NAME}_SYNC_TO_BUILD_MACHINE\" branch."
# TODO: figure out if origin is even available (ex: via a ping or something), and if not, error out right here!
# git push --force origin HEAD:${MY_NAME}_SYNC_TO_BUILD_MACHINE ########## UNCOMMENT THIS FOR FINAL SCRIPT


# exit #######

# Uncommit the temporary commit we committed above
if [ "$made_temp_commit" = "true" ]; then
    echo "Uncommitting the temporary commit we made above."
    git reset HEAD~

    # Now re-stage any files that were previously staged
    # See: 1) https://stackoverflow.com/questions/4227994/how-do-i-use-the-lines-of-a-file-as-arguments-of-a-command/4229346#4229346
    # and  2) *****https://www.cyberciti.biz/faq/unix-howto-read-line-by-line-from-file/
    if [ "$num_staged" -gt "0" ]; then
        echo "Re-staging (via 'git add') any files that were previously staged."

        # for line in $(cat "$FILE_STAGED")
        # do
        #     echo "$line"
        #     git add "$line" 
        # done

        while IFS= read -r line
        do
            echo "  git add \"$line\""
            git add "$line" 
        done < "$FILE_STAGED"
    fi
fi

# cd back to where we started
cd "$DIR_START"




# On local machine:
# Look for changes. Commit them to current local branch. Force Push them to remote SYNC branch. 
# Uncommit them on local branch. Restore original state by re-staging any files that were previously staged.
# Done.
sync_pc1_to_remote_sync () {
    echo "todo"
}

# On remote machine:
# Look for changes. Commit them to a new branch forked off current branch. Call it 
# current_branch_SYNC_BAK_20200217-2310hrs. Check out SYNC branch. Pull and hard reset. 
# Done! We are ready to build now!
sync_remote_sync_to_pc2 () {
    echo "todo"
}