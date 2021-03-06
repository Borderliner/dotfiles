#!/bin/bash
#############################################################
# Install and update go packages
# Author: Vincent Zhang <seagle0128@gmail.com>
# URL: https://github.com/seagle0128/dotfiles
#############################################################

# Go packages
# x tools
x_tools=(
    # golang.org/x/tools/cmd/godoc
    golang.org/x/tools/cmd/goimports
    golang.org/x/tools/cmd/gorename
    golang.org/x/tools/cmd/gotype
    # golang.org/x/tools/cmd/guru
)

# 3rd party tools
packages=(
    # For go-mode
    # github.com/mdempsky/gocode
    github.com/stamblerre/gocode # gocode-gomod
    github.com/rogpeppe/godef
    golang.org/x/tools/cmd/guru

    github.com/golang/lint/golint
    github.com/google/gops
    github.com/derekparker/delve/cmd/dlv
    github.com/aarzilli/gdlv
    github.com/josharian/impl
    github.com/cweill/gotests/...
    github.com/fatih/gomodifytags
    github.com/davidrjenni/reftools/cmd/fillstruct
    github.com/sourcegraph/go-langserver
)

# Use colors, but only if connected to a terminal, and that terminal
# supports them.
if command -v tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
fi

YES=0
NO=1
function promote_yn() {
    eval ${2}=$NO
    read -p "$1 [y/N]: " yn
    case $yn in
        [Yy]* )    eval ${2}=$YES;;
        [Nn]*|'' ) eval ${2}=$NO;;
        *)         eval ${2}=$NO;;
    esac
}

function check() {
    if ! command -v go >/dev/null 2>&1; then
        echo "${RED}Error: go is not installed${NORMAL}" >&2
        exit 1
    fi
}

function install() {
    promote_yn "Install x-tools?" "continue"
    if [ $continue -eq $YES ]; then
        for p in ${x_tools[@]}; do
            printf "${BLUE} ➜  Installing ${p}...${NORMAL}\n"
            go get -u ${p}
        done
    fi

    for p in ${packages[@]}; do
        printf "${BLUE} ➜  Installing ${p}...${NORMAL}\n"
        go get -u ${p}
    done
}

function goclean() {
    go clean -i -n $1
    go clean -i $1
    rm -rf $GOPATH/src/$1
    if [ -d $GOPATH/pkg/${sysOS:l}_amd64/$1 ]; then
        rm -rf $GOPATH/pkg/${sysOS:l}_amd64/$1;
    fi
}

function clean() {
    for p in ${x_tools[@]}; do
        goclean ${p}
    done

    for p in ${packages[@]}; do
        goclean ${p}
    done
}

function main() {
    check

    promote_yn "Clean all packages?" "continue"
    if [ $continue -eq $YES ]; then
        clean
    else
        install
    fi
}

main
