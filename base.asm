IDEAL
MODEL small
STACK 100h
DATASEG
;------
linepoint db ">$"
Thewordis db "Correct word:$"
words db "first$break$grain$above$block$catch$cares$enter$fault$brick$"
ans db "     $"
msg db "     $"
lostmsg db "you lost$"
letterCount db 0
EntCount db 0
letterloop db 0
spacewrite db "  $"
saveword db "     $"
letterplace db 0
color db 2
correctCounter db 0
correctmsg db "Correct$"
isyellow db 0
;------
CODESEG

proc Write
mov dx, offset msg
mov ah, 9
int 21h
ret
endp Write

proc random
MOV AH, 00h  ; interrupts to get system time        
INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
mov  ax, dx
xor  dx, dx
mov  cx, 10    
div  cx       ; here dx contains the remainder of the division - from 0 to 9 
ret
endp random

proc Rightans
MOV dl, 10
MOV ah, 02h
INT 21h
MOV dl, 13
MOV ah, 02h
INT 21h
mov dx, offset Thewordis
mov ah, 9
int 21h
mov dx, offset ans
mov ah, 9
int 21h
ret
endp rightans

proc PrintLetter
mov ah, 02h
mov bh, 0
mov dh, [EntCount]
dec dh
mov dl, [letterloop]
inc dl
int 10h

mov ah, 09h
mov al, [saveword+bx]
mov bh, 0
mov bl, [color]
mov cx, 1
int 10h
ret 
endp PrintLetter

proc Markyellow
mov [isyellow], 0
mov bx, 0
searchYellow:
cmp [ans+bx], ah
je isInWord
inc bx
cmp bx, 5
jne searchYellow
jmp notInWord
isInWord:
mov [isyellow], 1
notInWord:
ret
endp Markyellow

proc Separate
mov dx, offset spacewrite
mov ah, 9
int 21h
ret
endp Separate

proc Saveuserword
mov bl, [letterCount]
mov bh, 0
mov [saveword+bx],al
ret
endp Saveuserword

proc Delete
mov ah, 02h         ; DOS Display character call 
mov dl, 20h         ; A space to clear old character 
int 21h             ; Display it  
mov dl, 08h         ; Another backspace character to move cursor back again
int 21h
ret
endp Delete

proc Markgreen
jmp loopA
endloop:
call PrintLetter
call Separate
mov dx, offset correctmsg
mov ah, 9
int 21h
jmp exit

loopA:
mov [color],15
mov bl,[letterloop]
mov bh, 0
mov ah,[saveword+bx]
cmp [ans+bx],ah
jne dyeyellow
mov [color],2
inc [correctCounter]
jmp afterDye

dyeyellow:
call Markyellow
mov bl,[letterloop]
mov bh, 0
cmp [isyellow], 1
jne afterDye
mov [color], 14

afterDye:
call PrintLetter
inc [letterloop]
cmp [letterloop],5
jne loopA
cmp [correctCounter],5
je endloop
mov [correctCounter], 0
mov [letterLoop], 0
ret
endp Markgreen

proc Input
WaitForData:
mov ah, 1  ;set to check input
int 16h    ;input interrupt
mov ah, 0  ;set to wait and clear input data
int 16h    ;keyboard interrupt
mov [msg], al
cmp al,97
jl BS_or_ENT
cmp al,122
jg endInput
BS_or_ENT:
cmp al,8
je befBackspace
cmp al,13
je isletter
cmp al,97
jl endInput
mov [msg + 1], '$'
cmp al,13
jne afterEnter
isletter:
cmp [letterCount],5
jne endInput
cmp dx,0            ;checks if the user didnt just BackSpaced nothing
jz endInput
inc [EntCount]
cmp [EntCount],6
je Lost
mov [letterCount],-1
call Markgreen
mov [msg],10
mov [msg + 1],'>'
mov [msg + 2],'$'

afterEnter:
cmp al, 8
je befBackspace
call Saveuserword
cmp [letterCount],5
je endInput
inc [letterCount]
jmp aftBackspace

befBackspace:
cmp [letterCount],0 
je endInput
dec [letterCount]

aftBackspace:
call Write
call Delete
endInput:
ret
endp Input


start:
    mov ax, @data
    mov ds, ax
;--------------
;Graphics:
mov ax,13h
int 10h

;Define ans:
call random
mov ax,6
mul dl
mov dx, ax
mov cx, 0
DefineAns:
mov bx, cx
add bx, dx
mov al, [words+bx]
sub bx, dx
mov [ans+bx], al
inc bx
inc cx
cmp cx, 5
jne DefineAns

;Start:
mov dx, offset linepoint
mov ah, 9
int 21h
Begin:
call Input
jmp Begin
Lost:
call Markgreen
call Rightans
;--------------
exit:
    mov ax, 4c00h
    int 21h
END start
cmp dl, [NextUpdate]
jg AfterTest
cmp dh, [LastSecond]
jg AfterTest
cmp cl, [LastMinute]
jg AfterTest
cmp ch, [LastHour]
jg AfterTest
jmp GameLoop
AfterTest:
;update time
mov [NextUpdate], dl
add [NextUpdate], 4 ;game speed
mov [LastSecond], dh
mov [LastMinute], cl
mov [LastHour], ch
;game step start



;jmp GameLoop 
; --------------------------
    
exit:
    mov ax, 4c00h
    int 21h
END start