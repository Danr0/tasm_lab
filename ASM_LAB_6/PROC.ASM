.model medium
.stack 100h
.486

public openfile, input, output, menu, algo, close

; Start point
extrn start:far

; Data
extrn filename:byte
extrn items:byte
extrn fnsize:byte
extrn inputbuf:byte
extrn usrans:byte
extrn entermsg:byte
extrn tmpbuf:byte
extrn bufsize:word
extrn strsize:word
extrn filedesc:word
extrn inputmsg:word


; Menu parameters
extrn maxmenu:byte
extrn minmenu:byte

.code

;====================================

input PROC ; Ready
pusha

mov ah, 3fh
; bx - descriptor
; dx - input buffer
; cx - buffer size

int 21h

; ax => bytes amount
mov [strsize], ax

popa
ret
; Input from console/file
; Input based on descriptor
; 0 - keyboard/console
endp

;====================================

clearscreen Proc
pusha
  mov ax, 03
  int 10h
popa
ret

;====================================

output PROC
pusha

mov ah, 40h
; bx - descriptor
; dx - buffer
; cx - buffer size

int 21h

popa
ret
; Output to console/file
; Output based on descriptor
; 0 - keyboard/console
endp

;====================================

openfile PROC
pusha

mov ah, 09h
lea dx, entermsg ; Ask user to write filename
int 21h

xor bx,bx
lea dx, filename
movsx cx, fnsize
call input ; Now we have filename

; Filename should end with 0 byte ?
movsx cx, fnsize
lea si, filename
cycle:
  lodsb ; load current char to al
  cmp al,13
  je m
loop cycle

m:
dec si
mov di, si
mov al, 0
stosb ; Mov 0 byte to the end of string

mov ah, 5bh ; Create new file
lea dx, filename
xor cx, cx ; What the hell is this???
int 21h

mov ah, 3dh ; Open descriptor
lea dx, filename
mov al, 2
int 21h ; Descriptor in ax

mov [filedesc], ax

popa
ret

; 1) Create file (if it is not exist)
; 2) Open file
; 3) Save descriptor
endp


;====================================

; String to output should be created in tmpbuf
; String size should be writted to strsize (If it has changed)

algo PROC ; Generates new string in tmpbuf
; replace '     ' with ' '
; replace 'test.' with 'test*'
; replace 'test...' with 'test-'
pusha


  push si
  push di
  push ax
  push bx
  push cx
  push dx



  ;reverse each word
continue: lea si,inputbuf
	lea di,tmpbuf
	xor bx,bx
	xor cx,cx
  xor dx,dx
m1:	lodsb
	cmp al,0
	je m2
  cmp al,13
  je m21
	cmp al,' ' ; compare with end of word chars 
	je m3
  cmp al,','
	je m31
  cmp al,';'
	je m32
	push ax
	inc cx
	jmp m1
m2: mov bx,1
  jmp m3
m21:	mov bx,2
  jmp m3
m3:	jcxz m5 ; Jump if CX is Zero
	cmp di,offset tmpbuf
	je m4
  cmp dx,1
  je m41
	mov al,' '
	stosb
  jmp m4
m31:	jcxz m5 ; Jump if CX is Zero
	cmp di,offset tmpbuf
	je m4
  cmp dx,1
  je m41
	mov al,','
	stosb
  jmp m4
m32:	jcxz m5 ; Jump if CX is Zero
	cmp di,offset tmpbuf
	je m4
  cmp dx,1
  je m41
	mov al,';'
	stosb
  jmp m4
m41: xor dx,dx
m4:	pop ax
	stosb
	loop m4
m5:	cmp bx,1
  je null
  cmp bx,2
  je newline
	jmp m1
newline: mov al,13
	stosb	
  mov al,10
  stosb
  inc si
  xor cx,cx
  xor bx,bx
  mov dx,1
  jmp m1
null:	mov al,0
	stosb	
  jmp exit1


exit1: lea si,tmpbuf
	lea di,tmpbuf
	xor bx,bx
	xor cx,cx
  xor dx,dx
am1:	lodsb
	cmp al,0
	je am2
  cmp al,13
  je am3
  cmp al,10
  je am3
	push ax
	inc cx
	jmp am1
am2: mov bx,1
  jmp am3
am21:	mov bx,2
  jmp am3
am3:	jcxz am5 ; Jump if CX is Zero
	cmp di,offset tmpbuf
	je am4
  cmp dx,1
  je am41
	mov al,13
	stosb	
  mov al,10
	stosb
  jmp am4
am41: xor dx,dx
am4:	pop ax
	stosb
	loop am4
am5:	cmp bx,1
  je anull
	jmp am1
anull:	mov al,0
	stosb	
  jmp exit2

exit2:  pop si
  pop di
  pop ax
  pop bx
  pop cx
  pop dx

popa

ret
; Calculation based on inputbuf
; Main PROC that works with string
endp

;====================================

close PROC

pusha

mov ah,3eh
mov bx, filedesc
int 21h

popa
ret
; Close the file
endp

;====================================

menu PROC
pusha

@errinput:

mov ah, 09h
lea dx, items ; Show menu
int 21h

xor ax,ax
mov ah, 01h ; Save user answer to al
int 21h

push ax ; Save answer

mov ah, 02h ; New line
mov dl, 13
int 21h
mov dl, 10
int 21h

pop ax ; Restore answer

cmp minmenu, al ; Check lower border
jg @errinput

cmp maxmenu, al ; Check upper border
jl @errinput

cmp al, '0'
je quit

cmp al, '1'
jne ski

  mov ah, 09h
  lea dx, inputmsg ; Ask user to unput string
  int 21h

  xor bx,bx
  lea dx, inputbuf
  mov cx, bufsize
  call input ; Get string from console

  mov cx, strsize
  lea si, inputbuf ; Copy inputbuf to tmpbuf
  lea di, tmpbuf
  rep movsb

  jmp quit
ski:
cmp al, '2'
jne skif
  call openfile ; Open file, get file descriptor
  mov bx, filedesc
  lea dx, inputbuf
  mov cx, bufsize
  call input ; Read from file

  mov cx, strsize
  lea si, inputbuf ; Copy inputbuf to tmpbuf
  lea di, tmpbuf
  rep movsb

  call close
  jmp quit
skif:
cmp al, '3'
jne skos
  xor bx, bx
  lea dx, tmpbuf
  mov cx, strsize
  call output ; write it to console

  mov ah, 02h ; new line
  mov dl, 13
  int 21h
  mov dl, 10
  int 21h

  jmp quit
skos:
cmp al, '4'
jne skof
  push [strsize] ; Save strsize
  call openfile ; Open file, get file descriptor
  mov bx, filedesc
  lea dx, tmpbuf
  pop [strsize] ; Restore it
  mov cx, strsize
  call output

  call close
  jmp quit
skof:
cmp al, '5'
jne skal
  call algo ; Get new string int tmpbuf
  jmp quit
skal:
cmp al, '6'
jne quit
  call clearscreen
  jmp quit
quit:

mov [usrans], al

popa ; Load all registers
ret
endp

;====================================

end start
