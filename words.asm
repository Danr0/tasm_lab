    .model small
    stack 100h
    dataseg
msg1    db  0Ah,0Dh,"Enter string <80(char)",0Ah,0Dh,'$'
string  db  80 dup(?)
msg2    db  0Ah,0Dh,"Reversing string",0Ah,0Dh,'$'
tmp     dw ?
    codeseg
start:  mov ax,@data
	mov ds,ax
	mov es,ax
	cld
    lea dx,msg1
    mov ah,09h ; settings for call
    int 21h ; call output
    mov cx,80
    xor si,si
l1:     mov ah,01h
    int 21h ; input char
    cmp al,0Dh ; end of line
    je continue
    mov string[si],al
    inc si
    loop l1
    
    ;reverse each word
continue:   mov tmp,si
    lea si,string
	lea di,string
	xor bx,bx
	xor cx,cx
m1:	lodsb
	cmp al,0
	je m2
	cmp al,' ' ; compare with end of word chars 
	je m3
    cmp al,','
	je m3
    cmp al,';'
	je m3
	push ax
	inc cx
	jmp m1
m2:	mov bx,1
m3:	jcxz m5 ; Jump if ECX is Zero
	cmp di,offset string
	je m4
	mov al,' '
	stosb
m4:	pop ax
	stosb
	loop m4
m5:	cmp bx,1
	jne m1
	mov al,0
	stosb	

    ;output in reverse
    mov si,tmp
    mov ah,09h
    lea dx,msg2
    int 21h
    cmp si,0
    je exit
    dec si
    mov cx,si
l2: mov si,cx
    mov dl,string[si]
    mov ah,02h
    int 21h
    loop l2
    mov dl,string[0]
    mov ah,02h
    int 21h 
exit:    
    mov ah,4Ch 
    int 21h
    end start