#!/bin/sh

set -e

# ------ Definitions ------

DOTFILES=~/.dotfiles
DOTFILES_BACKUP=~/.dotfiles_backup
REPO=https://github.com/varoso/dotfiles
BRANCH=master
FILES="misc/hushlogin vim/vimrc zsh/zshrc"
UNNECESARY_FILES=".git assets LICENSE README.md"

THEME_REPO=https://github.com/romkatv/powerlevel10k
THEME_BRANCH=master
THEME_FOLDER=$DOTFILES/zsh/theme/powerlevel10k

RED=$(printf '\033[31m')
GREEN=$(printf '\033[32m')
YELLOW=$(printf '\033[33m')
BLUE=$(printf '\033[34m')
BOLD=$(printf '\033[1m')
RESET=$(printf '\033[m')

# ------ Functions ------

error() {
  echo ${BOLD}${RED}"Error: $@"${RESET} >&2
}

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

# ------ Install ------

# Git install comprobation
command_exists git || {
  error "Git must be installed to continue"
  exit 1
}

# Presentation and install confirmation
printf "${BOLD}${BLUE}"
cat <<'EOF'
__      __                             _       _    __ _ _           
\ \    / /                            | |     | |  / _(_) |          
 \ \  / /_ _ _ __ ___  ___  ___     __| | ___ | |_| |_ _| | ___  ___ 
  \ \/ / _` | '__/ _ \/ __|/ _ \   / _` |/ _ \| __|  _| | |/ _ \/ __|
   \  / (_| | | | (_) \__ \ (_) | | (_| | (_) | |_| | | | |  __/\__ \
    \/ \__,_|_|  \___/|___/\___/   \__,_|\___/ \__|_| |_|_|\___||___/
EOF
printf "${RESET}"

cat <<EOF

${BOLD}${BLUE}You are about to install the following configuration files:${RESET}
${BOLD}${YELLOW}  • .hushlogin${RESET}
${BOLD}${YELLOW}  • .vimrc${RESET}
${BOLD}${YELLOW}  • .zshrc${RESET}

${BOLD}${BLUE}Additionally the ${YELLOW}powerlevel10k ${BLUE}theme with ${YELLOW}rainbow ${BLUE}style will be installed${RESET}

EOF

read -r -p "${BOLD}${BLUE}Do you want to continue? [y/N] ${RESET}" confirmation
if [ "$confirmation" != y ] && [ "$confirmation" != Y ]; then
  echo "${BOLD}${RED}Installation cancelled${RESET}"
  exit
fi

# Clone dotfiles repository
echo "\n${BOLD}${GREEN}Getting Varoso's dotfiles from Github...${RESET}"
git clone --quiet --dept=1 --branch "$BRANCH" "$REPO" "$DOTFILES" > /dev/null || {
  error "Git clone of Varoso's dotfiles failed"
  exit 1
}
echo "${BOLD}${GREEN}Done.${RESET}"

# Create backup folder for old dotfiles
echo "\n${BOLD}${GREEN}Creating backup folder for existing dotfiles in $DOTFILES_BACKUP...${RESET}"
mkdir -p $DOTFILES_BACKUP
echo "${BOLD}${GREEN}Done.${RESET}"

# Backup old files and create symlinks to new files
echo "\n${BOLD}${GREEN}Installing dotfiles...${RESET}"
cd $DOTFILES
for FILE in $FILES; do
  FILE_NAME=."${FILE#*/}"
  if [[ -f ~/$FILE_NAME || -L ~/$FILE_NAME ]]; then
    mv ~/$FILE_NAME $DOTFILES_BACKUP
  fi
  ln -s $DOTFILES/$FILE ~/$FILE_NAME
done
echo "${BOLD}${GREEN}Done.${RESET}"

# Clone theme repository
echo "\n${BOLD}${GREEN}Installing theme...${RESET}"
git clone --quiet --dept=1 --branch "$THEME_BRANCH" "$THEME_REPO" "$THEME_FOLDER" > /dev/null || {
  error "Git clone of theme failed"
  exit 1
}
echo "${BOLD}${GREEN}Done.${RESET}"

# ------ Remove unnecesary files ------
echo "\n${BOLD}${GREEN}Removing unnecesary files...${RESET}"
rm -rf $UNNECESARY_FILES
echo "${BOLD}${GREEN}Done.${RESET}"

echo "\n${BOLD}${BLUE}Installation completed. Don't forget to restart your terminal. Have a nice day.${RESET}"
