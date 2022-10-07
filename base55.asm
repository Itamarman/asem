IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
PlayerY db 100 
NextUpdate db 0
LastSecond db 0
LastMinute db 0
LastHour db 0
DrawX dw 0
DrawY dw 0
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
start:
    mov ax, @data
    mov ds, ax
; --------------------------
;activate graphics mode
mov ax, 13h
int 10h 
;start game loop
GameLoop:
;get current time
mov ah,2ch
int 21h
;check if enough time has passed
cmp dl, [NextUpdate]
jl GameLoop
cmp dh, [LastSecond]
jl GameLoop
cmp cl, [NextMinute]
jl GameLoop
cmp ch, [NextHour]
jl GameLoop
;update time
mov [NextUpdate], dl
add [NextUpdate], 4
mov [LastSecond], dh
mov [LastMinute], cl
mov [LastHour], ch
;game step start
call DrawPixel


jmp GameLoop 
; --------------------------
    
exit:
    mov ax, 4c00h
    int 21h
END start


