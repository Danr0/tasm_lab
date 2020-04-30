	.model small
	.stack 100h
	.data
n	dw 6
m 	dw 4
shift dw 0 ;shift in each loop
shift2 dw 0 
mas	dw 5,3,8,1,9,1
	dw 9,1,3,0,2,8
	dw 5,3,8,1,9,3
	dw 1,6,3,2,9,1
	.code
	mov ax,@data
	mov ds,ax
	mov es,ax
	cld
	xor dx, dx
	mov dx,n
	shl dx,1
	mov shift2,dx
	xor dx,dx ;count loop 


start: cld
	mov cx,n ; cs
	dec cx ; decrease -1
m1:	push cx
	lea si,mas
	;cmp dx,0
	;je nosh 
	add si,shift
;nosh: xor bx,bx
;nosh: lodsw
	lodsw ; load fro si to ax
	mov di,si
m2:	scasw ; Compare AX with word at ES:(E)DI and set status flags
    mov bx,[di] ;cmp 5 7
	jg m3 ; >
	mov si,di
	dec si
	dec si
	lodsw
m3:	loop m2
	cmp si,di
	je m4
	push word ptr [di-2]
	dec di
	dec di
	stosw ;Store AX at address ES:(E)DI
	pop word ptr [si-2]
m4:	pop cx
	loop m1

	xor bx,bx
	mov bx,shift2
	add shift,bx
	inc dx
	cmp dx,m
	jne start
	
	mov ax,4c00h
	int 21h
	end

