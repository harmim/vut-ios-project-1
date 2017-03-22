#!/usr/bin/env bash

help() {
printf \\n%s\\n "## Spusteni"
printf \\n%s "Pokud se nejedna o uklid, kazde spusteni testu vyvola preklad zdrojoveho
kodu projektu a spusteni zakladnich testu."
printf \\n%s "Spusteni testu:
	bash ./test.sh"
printf \\n%s "Uklid souboru vytvorenych v prubehu testovani:
	bash ./test.sh -c"
printf \\n\\n%s\\n "## Obsah souboru"
printf \\n%s "Ocekavany vystup testu je pripraven v souboru:
	test{cislo testu}-out"
printf \\n%s "Vystup programu je ulozen do souboru:
	test{cislo testu}-my"
printf \\n%s\\n\\n "Chybovy vystup programu je ulozen do souboru:
	test{cislo testu}-error"
}

file='../dirgraph'



# Output settings
TEXT_BOLD=`tput bold`
TEXT_GREEN=`tput setaf 2`
TEXT_RED=`tput setaf 1`
TEXT_RESET=`tput sgr0`
TEXT_BLUE=`tput setaf 4`
TEXT_BROWN=`tput setaf 3`

# IO file names
function errorFileName () {
    printf "test${1}-error"
}
function inFileName () {
    printf "test${1}-in"
}
function outFileName () {
    printf "test${1}-out"
}
function myFileName () {
    printf "test${1}-my"
}

# Test initialization
function initTest () {
    testNumber=$1
    testError=$(errorFileName $testNumber)
    testOut=$(outFileName $testNumber)
    testMy=$(myFileName $testNumber)
}


function green() {
    printf %s "${TEXT_GREEN}$1${TEXT_RESET}"
}

function red() {
    printf %s "${TEXT_RED}$1${TEXT_RESET}"
}


function isOk () {
    local testNumber=$1
    local   testExit=$2
    local  testError=$3

    printf "Test %03d	.." "$1"

    if [ -e ${testOut} ] 
    then
    
        `diff -q ${testOut} ${testMy} > /dev/null`
        local diffResult=$?
        printf %s "isOK   ExitCode: "
        [ $testExit -eq 0 ] && green $testExit || red $testExit
        printf %s\\n ",       output: $([ $diffResult -eq 0 ] && green 'not diff' || red 'diff')"

        err=1
        [ $testExit == 0 ] && [ $diffResult == 0 ] && err=0
    
    else

        printf %s "isFail ExitCode: " 
        [ $testExit -eq 0 ] && red $testExit || green $testExit
        printf %s\\n ", error output: $([ -s $testError ] && green "found" || red "not found")"
        
        err=1
        [ $testExit != 0 ] && [ -s $testError ] && err=0 # True, if <FILE> exists and has size bigger than 0 (not empty).

	[ $err -eq 0 ] && printf "$TEXT_BROWN" && cat $testError
    fi

    [ $err -eq 0 ] && green "ok" || red "fail"

}



test() {
    no=$1
    par="$2"

    initTest ${no}

    `${spoustec} ./${file} $par > ${testMy} 2> ${testError}`
    isOk $testNumber $? $testError
    
    printf \\t%s\\n\\n "${TEXT_BLUE}$info${TEXT_RESET}"

}


file_exists() {
	if [ -e "$1" ]
	then
    		printf "${TEXT_BOLD}Testing file ${1}${TEXT_RESET}\n"
	else
    		printf "${TEXT_RED}Cannot run test without file ${1}.${TEXT_RESET}\n"
    		exit 1
	fi
}


# Cleaning
if [ "$1" == "-h" ]
then
    help
    exit 0
fi

# Cleaning
if [ "$1" == "-c" ]
then
    ls | grep 'test.\+\-\(my\|error\)$' | xargs -d "\n" rm
    exit 0
fi

if [ "$#" -eq 1 ]
then
	spoustec="$1"
else
	spoustec=bash
fi

file_exists "$file"



printf %s\\n "Zakladni testy funkcnosti (spousteno pomoci $spoustec)"

info="Zadany 2 parametry bez -i a -n."
test 1 "a b"

info="Zadan neexistujici adresar."
test 2 neexistuje

info="Zadano 3x -i."
test 3 "-i -i -i"

info="Zadano 3x -n."
test 4 "-n -n -n"

info="Prilis mnoho parametru -i a -n a a."
test 5 "-i a -n a a"

info="Odkaz na prazdny adresar."
test 6 ./test_data/empty

info="Odkaz na prazdny adresar s -n na zacatku."
test 7 "-n ./test_data/empty"

info="Odkaz na prazdny adresar s -n na konci."
test 8 "./test_data/empty -n"

info="Test prvnich 3 velikosti."
test 9 "./test_data/velikosti"

info="To same se zbytecnym parametrem -n."
test 10 "-n ./test_data/velikosti"

info="Test s jedinym souborem a lomitkem na konci cesty."
test 11 "./test_data/one/"

info="Test prilis mnoho souboru."
test 12 "./test_data/nas_mnogo"

info="Test prilis mnoho souboru s -n na zacatku"
test 13 "-n ./test_data/nas_mnogo"

info="Test prilis mnoho souboru s -n na konci"
test 14 "./test_data/nas_mnogo -n"

info="Test vice formatu jak 10."
test 15 "./test_data/formaty"

info="Test vice formatu jak 10 s -n."
test 16 "-n ./test_data/formaty"

info="Test vice formatu jak 10 s -n a -i '^Z80_Compo_6$'.
	Sance ze to selze kvuli jinemu poradi vystupu,
	protoze je nedefinovany pro stejne hodnoty"
test 17 '-n -i ^Z80_Compo_6$ ./test_data/formaty'

info="Jiny test na -n a -i"
test 18 '-i ^10 -n ./test_data/nas_mnogo'

info="Tezky test s hnusnymi jmeny souboru."
test 19 "./test_data/hardcore"

info="Tezky test s hnusnymi jmeny souboru a -i, plus nepokryti cesty."
test 20 "-i ^test_data$ ./test_data/hardcore"

info="Cely adresar /test_data"
test 21 "./test_data"


printf "\n"
