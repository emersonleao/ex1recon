#!/usr/bin/bash

usage() { echo "Ok, I have to teach you how to use it first. Here it is: ./ex1recon.sh -d domain.com" 1>&2; exit 1; }

while getopts d:h flag; do 
	case "${flag}" in
		d) 
			domain=${OPTARG}
			;;
		h | *) 
			usage
			exit 0
			;;
	esac
done

if [ -z "$domain" ]; then
   usage; exit 1;
fi

mkdir ${domain}

echo "Hey how you doin'? Let's do some recon!
Starting ex1 recon... 
Scanning $domain..."
sublist3r -d $domain -t 10 -v -o ${domain}/$domain.txt > /dev/null 

declare -a LIST=()
input="${domain}/${domain}.txt"
while IFS= read -r line
do
	if [[ $(curl -s -o /dev/null -I -w "%{http_code}" $line -L) == 200 ]]; then
		LIST+=($line)
	else
		:
	fi
done < "$input"
	
printf "%s\n" "${LIST[@]}" > ${domain}/${domain}_200List.txt
echo "Domain scanning done. 
Starting Nuclei."
nuclei -l ${domain}/${domain}_200List.txt -silent > ${domain}/nuclei_${domain}.txt

read -n1 -p "Nuclei done. Dirsearch everything? Default=no[y,n]: " doit 
case $doit in  
  y|Y) echo "\nStarting Dirsearch."
  	   python /home/log1/Hacks/tools/dirsearch/dirsearch.py -l ${domain}/${domain}_200List.txt -o ${domain}/${domain}_DIRSEARCH.txt --format=simple -F > /dev/null
 	   ;; 
  n|N) echo "Here you are! Hope it was useful!" 
  		exit 0;; 
  *) echo "Here you are! Hope it was useful!" 
  		exit 0;; 
esac

echo "Here you are! Hope it was useful!"





