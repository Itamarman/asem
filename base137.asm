IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
PlayerY db 100 
NextUpdate db 0
LastSecond db 60
LastMinute db 60
LastHour db 24
DrawX dw 20
DrawY dw 90
RightX dw 40
LowerY dw 110
;TempY dw 90
;TempX dw 20
DrawColor db 4
; --------------------------
CODESEG
proc DrawPixel
push ax
push bx
push cx
push dx

mov ah, 0ch
mov al, [DrawColor]
mov bh, 0
mov cx, [DrawX]
mov dx, [DrawY]
int 10h

pop dx
pop cx
pop bx
pop ax
ret
endp DrawPixel

proc DrawRect
mov [DrawX],20
;mov dx, [DrawY]
L2:
mov [DrawY],90
L1:
call DrawPixel
inc [DrawY]
cmp [DrawY], 110
jne L1
inc [DrawX]
cmp  [DrawX],40
jne L2
mov bx,0
endp DrawRect
start:

    mov ax, @data
    mov ds, ax
; --------------------------
;activate graphics mode
mov ax, 13h
int 10h

call DrawRect

    
exit:
    mov ax, 4c00h
    int 21h
END start