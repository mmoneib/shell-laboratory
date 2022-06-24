#!/bin/bash
################################################################################
# Procedural Password (Re)Generator
#
# Instead of remembering passwords or saving them on plain sight, this script
# provides an opportunity to regenerate the desired password each time it is
# neeeded in a secure way. The script generates the passwords based on a comb-
# ination of arbitrary text file, arbitrary string-manipulation script, and
# the name of the target, all of which are inputs provided by the user. Thus,
# the target's name acts as the public key, while the supplimentary script
# and text files are the private keys. The separation of the private key,
# therefore, insures extra security without complex encryption being required.
# The generated password is then displayed in a simpeleencrypted format to
# be decrypted manually by the user by referencing auto-generated characters
# dictionaries. The emanual step is to insure no command line spoofing is 
# possible. For maximum security, both supplimentary files should be put in 
# separate, external storages which can be detected automatically by the
# script.
#                                                                              #
# Type: To be used as a standalone or as a source.                             #
# Dependencies: Bash.                                                          #   
# Developed by: Muhammad Moneib.                                               #
################################################################################

target="www.google.com";
quote=$(echo "$(cat resources/procedural_passwords/quote)"|sed 's/ //g');

function applyProcedure {
  echo "$(eval $(cat resources/procedural_passwords/procedure))";
}

function applyQuote {
  inp="$1";
  for ((c=0;c<${#inp};c++)); do
    acc=0;
    acc=$((acc+$(printf '%d' "'${inp:c:1}")));
    outp="$outp""${inp:c:1}""${quote:$((acc%${#quote})):1}";
  done
  echo "$outp";
}

function applyCapitalLetter {
  inp="$1";
  ind=$((${#quote}%${#inp}));
  c=${inp:ind:1};
  echo ${inp:0:ind}"${c^^}"${inp:ind+1}
}

function applySpecialLetter {
  inp="$1";
  ind=$(((${#quote}+$(printf '%d' "'${quote:0:1}"))%${#inp}));
  c=${inp:ind:1};
  echo ${inp:0:ind}"\$"${inp:ind}
}

str=$(applyProcedure);
str=$(applyQuote "$str");
str=$(applyCapitalLetter "$str");
str=$(applySpecialLetter "$str");

echo "$str";


