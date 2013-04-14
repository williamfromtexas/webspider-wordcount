#!/bin/bash

# get word counts on a website for a list of words and generate json file of results

# modified from original spider and quoter by tony baldwin / baldwinsoftware.com
# with help from the linuxfortranslators group on yahoo!
# released according to the terms of the Gnu Publi License, v. 3 or later

# collecting necessary data:
#read -p "Please enter the rate (only numbers, like 0.12). 1 is best, we're not doing percentages: " rate
read -p "Enter domain (do not include http://www, just, for example, somedomain.com): " url

# if we've run this script in this dir, old files will mess us up
for i in pagelist.txt wordcount*.txt plist-wcount*.txt; do
  if [[ -f $i ]]; then
		echo removing old $i
		rm $i
	fi
done

echo "getting pages ...  this could take a bit ... "

# mirrors the site except this stuff
wget -m -q -E -R pdf,swf,jpg,tar,gz,png,gif,mpg,mp3,iso,wav,ogg,ogv,css,zip,djvu,js,rar,mov,3gp,tiff,mng $url

# makes a list of html pages 
find . -type f | grep html > pagelist.txt

echo "okay, counting words...yeah...we're counting words..."

# start json file
echo -e "{\n\"site\": \"$url\",\n\"time\": \"2013-04-13\",\n\"words\": {" >> plist-wcount.txt

# be sure you have a word list!
for word in $(cat wordlist.txt); do

# runs the list item by item thru the webpage htmls downloaded
for file in $(cat pagelist.txt); do
	lynx -dump -nolist  $file | grep -o -w $word | wc -w >> wordcount-$word.txt
	paste pagelist.txt wordcount-$word.txt > plist-wcount-$word.txt
done

urlnullCounter=0	
for urlnullOrnot in $(cat wordcount-$word.txt); do
	if (( $urlnullOrnot == 0 ))
		then
		urlnullCounter=$((urlnullCounter + 1))
	fi
done
lineTotal=$(wc -l < plist-wcount-$word.txt) #>> urlcount-$word.txt	
lineCounter=$((lineTotal - urlnullCounter))
echo "lineTotal is $lineTotal .. lineCounter is $lineCounter "


# need to count URLs with occurances, as-is outputs total urls checked .. for the future
#lineTotal=0
#for u in $(cat urlcount-$word.txt); do
#	lineTotal=$((lineTotal + u))
#	echo "the occurances for $word is $lineTotal urls"
#done

echo "adding up totals...almost there..."
wordTotal=0
for t in $(cat wordcount-$word.txt); do
	wordTotal=$((wordTotal + t))
#	echo "the total for $word is vtotal $wordTotal vt $t"
done

#echo "calculating  ... "
#price=`echo "$total * $rate" | bc`

# outputs counts to json file
echo -e "\"$word\": {\n\"count\": $wordTotal,\n\"urls\": $lineCounter }" >> plist-wcount.txt

# closes loop for word, moves to next word
done

# closes json file
echo -e "}\n}" >> plist-wcount.txt
#echo -e "the total is $total
#------------------------------" >> plist-wcount.txt

# prints verbage to terminal
echo "Okay, that should just about do it!"
echo  -------------------------------
sed 's/\.\///g' plist-wcount.txt > $url.wordlist.json
#rm plist-wcount.txt
cat $url.wordlist.json
echo This information is saved in $url.wordlist.json
exit
