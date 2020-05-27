.model medium

public items,tmpbuf,filename,inputbuf,errmsg,maxmenu,minmenu,bufsize,fnsize,strsize,filedesc,entermsg,usrans,inputmsg


.data

items db '1. Input from keyboard', 13,10
db '2. Input from file', 13,10
db '3. Output to screen', 13,10
db '4. Output to file', 13,10
db '5. Start work', 13,10
db '6. Clear screen', 13,10
db '0. Exit', 13,10
db '>',0,'$'

usrans db 0 ; User answer
filedesc dw 0 ; File descriptor
fnsize db 80 ; Filename max size
filename db 80 dup(0) ; Filename
strsize dw 0 ; Input string size
bufsize dw 4096 ; Buffer size
inputbuf db 4096 dup(0) ; Input buffer
tmpbuf db 4096 dup(0) ; Temp buffer aka output buffer
errmsg db 'Error',13,10,0 ; Never use
entermsg db 'Enter filename >','$' 
inputmsg db 'Enter your string >','$'

maxmenu db '6' ; Max and min user input in menu
minmenu db '0'

end
