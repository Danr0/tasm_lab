.model medium
.stack 100h
.486

public start

; Data
extrn usrans:byte ; user answer


; Proc
extrn menu:far

.code

start:

mov ax, @data
mov ds, ax
mov es, ax
cld

c:
  call menu ; Show menu to user
  movsx ax, usrans
  cmp ax, '0' ; If answer = 0 => exit
  je q
jmp c

q:

mov ax, 4c00h
int 21h

end start
