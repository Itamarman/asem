IDEAL
MODEL small
STACK 100h

UP=1
DOWN=2
NONE=0

DATASEG
ObsDir db NONE
StartLbl dw start
init_x dw ?
init_y dw ?
lower_x dw  ?
upper_y dw  ?
erase_init_x dw ?
erase_lower_x dw ?
color dw ?
obs_color dw 6
msg_nni db  'No New Input',13,10,'$'
msg_ni db 'New Input',13,10,'$'
key_chk_msg db 'key check',13,10,'$'
message db 'ESC key pressed',13,10,'$'
spc_message db 'SPC key pressed',13,10,'$'
obs_init_x dw 25
obs_init_y dw 199
obs_lower_x dw  10
obs_upper_y dw  184

lst_time_chk db 0


CODESEG

;proc Delay1
  

    
    ;endp Delay1


proc Delay 
  push dx
  push cx 
  mov dx, 500
DelayLoopOut:
   mov cx, 1000
DelayLoopIn:
   loop DelayLoopIn
   dec dx
   cmp dx, 0
   ja DelayLoopOut
   pop cx
   pop dx
   ret
   endp Delay


proc DrawRect

push bp
mov bp,sp



p_init_x equ [bp+12]
p_init_y equ [bp+10]
p_lower_x equ [bp+8]
p_upper_y equ [bp+6]
p_color equ [bp+4]


mov al,p_color
mov cx,p_init_x
x_loop:
mov dx,p_init_y
y_loop:

mov bh,0
mov ah,0ch
int 10h

dec dx
cmp dx,p_upper_y
jne y_loop

dec cx
cmp cx,p_lower_x
jne x_loop

pop bp
ret 10
 
endp DrawRect


start :
mov ax, @data
mov ds, ax


mov ax,13h
int 10h
mov ax, 0A000h
mov es, ax


push 25
push 199
push 10
push 184
push 6
call DrawRect



mov cx,30

; parameters for proc
 mov [init_x],320
 mov[erase_init_x], 322
 mov [init_y], 200
 
 mov [lower_x], 300
mov[erase_lower_x],320
 mov [upper_y], 150

 mov [color],4
 ; first time draw rect
push  [init_x]
push [init_y]
push [lower_x]
push [upper_y]
push  [color]
call DrawRect
;second time draw (narrow) rect
mov [init_x], 302
mov [lower_x],300

Blink:

in al, 64h ; Read keyboard status port
cmp al, 10b ; Data in buffer ?
je ObsUpdate

in al, 60h ; Get keyboard data
cmp al, 1h ; Is it the ESC key ?
jne cont1

ESCPressed :
jmp exit

cont1:

cmp al,39h 
;mov ah,9
;mov dx,offset spc_message
;int 21h
;time_check:
;    mov ah,2ch
;    int 21h
;    cmp dl,lst_time_chk
;    je time_check                                                                                          
jne ObsUpdate
SpacePressed:
;mov ah,9
;mov dx,offset spc_message
;int 21h
;

mov [ObsDir],UP

ObsUpdate:
cmp [ObsDir], NONE
je cont
push cx
push  [obs_init_x]
push [obs_init_y]
push [obs_lower_x]
push [obs_upper_y]
push 0

call DrawRect
pop cx

cmp [ObsDir], UP
jne ObsDirDown
cmp [obs_upper_y], 10
js ObsChangeDirDown
sub [obs_init_y],5
sub [obs_upper_y],5
jmp DrawObs
ObsChangeDirDown:
mov [ObsDir],DOWN
jmp cont
ObsDirDown:
cmp [ObsDir], DOWN
jne cont
cmp [obs_upper_y],199
je ObsIsBack
add [obs_init_y],5
add [obs_upper_y],5
jmp DrawObs
ObsIsBack:
mov [ObsDir],NONE
jmp cont

DrawObs:

push cx
push  [obs_init_x]
push [obs_init_y]
push [obs_lower_x]
push [obs_upper_y]
push [obs_color]

call DrawRect
pop cx

cont:
;; black 5Xhight pixels
mov [color],0 ;; black, for erasing
sub [erase_init_x], 2
sub [erase_lower_x], 2
;DrawRect rect_x,rect_y,rect_weidth,rect_height,rect_color
push cx
push  [erase_init_x]
push [init_y]
push [erase_lower_x]
push [upper_y]
push  [color]
call DrawRect
pop cx



mov [color],4
sub [init_x], 2
sub [lower_x],2

push cx

push  [init_x]
push [init_y]
push [lower_x]
push [upper_y]
push [color]


call DrawRect 
pop cx
;DrawRect rect_x,rect_y,rect_width,rect_height,rect_color



 call delay
 
;time_check:
;    mov ah,2ch
;    int 21h
;    cmp dl,lst_time_chk
;    je time_check 
;mov lst_time_chk,dl 

;sub [init_x],5
;sub [lower_x],5

;loop Blink
dec cx
je quitloop
jmp Blink
quitloop:





exit :
mov ax, 4C00h
int 21h
END start