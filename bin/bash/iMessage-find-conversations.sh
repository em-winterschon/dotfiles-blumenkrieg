find ./ -name "*et al*" | egrep -v Chris\|Deborah\|Flowers\|Renee\|336 > ~/Desktop/chats/list
c ~/Desktop/chats/list | while read line; do cp "$line" ~/Desktop/chats/; done

find ./ -name "*Carrie*" > ~/Desktop/chats/carrie
c ~/Desktop/chats/carrie | while read line; do cp "$line" ~/Desktop/chats/; done
