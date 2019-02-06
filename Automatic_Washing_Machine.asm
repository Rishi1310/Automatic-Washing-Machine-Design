#make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#

#SS=0000h#
#SP=FFFEh#

#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#

; add your code here
         jmp    st1 
         db     5 dup(0)
         dw     tisr
         dw     0000
         db     372 dup(0)
         db     640 dup(0)

;main program
          
st1:      ;int 3
          cli 
; intialize ds, es,ss to start of RAM
          mov       ax,0200h
          mov       ds,ax
          mov       es,ax
          mov       ss,ax
          mov       sp,0FFEh
;initializing 8255	
x1: mov al,83h
    out 06h,al  
    ;int 3   
;initializing 8253(1)
    mov al,36h
    out 16h,al 
    ;int 3
;sending count to counter 0
    mov al,0A8h
    out 10h,al
    mov al,61h
    out 10h,al 
    ;int 3
;initializing counter 1
    mov al,01010110b
    out 16h,al
    mov al,64h
    out 12h,al 
    ;int 3
    
;initializing counter 5hz 0 8253(3)
    mov al,16h
    out 46h,al
    mov al,14h
    out 40h,al
;initializing counter 1 1hz of 8253(3)
    mov al,56h
    out 46h,al
    mov al,64h
    out 42h,al
    ;int 3      
;intializing counter 2 0.5hz of 8253(3)
    mov al,96h
    out 46h,al 
    ;int 3
    mov al,64h
    out 44h,al
    ;int 3
;initializing counter 2 0.5hz of 8253(2)
    mov al,96h
    out 26h,al
    mov al,0C8h
    out 24h,al 
    
;checking for load press
    STI 
    mov cx,0000h 
;polling load    
x3: in al,04h
    and al,01h
    cmp al,00h
    jne x4
    inc cx
    jmp x6
;polling start   
x4: in al,04h
    and al,02h
    cmp al,00h
    je x5
    jmp x3
;checking debounce
x6: in al,04h
    and al,01h
    cmp al,00h
    je x6
    jmp x3 
    
;compare count
x5: cmp cx,0001h
    je x10
x7: cmp cx,0002h
    je x11
x8: cmp cx,0003h
    je x12
    jmp st1
    
x10:CALL LIGHT
    jmp x0
x11:CALL MEDIUM
    jmp x0
x12:CALL HEAVY
    jmp x0
;wait till stop pressed or reloaded
x0: jmp x0



HEAVY:

    ;locking
        mov al,00000001b
        out 00h,al
        
;rinse cycle 3 min   
    ;open water valve
        mov al,00000011b
        out 00h,al    
    ;poll sensor output
    h1: in al,02h
        and al,01h
        cmp al,01h
        je h1        
    ;closing water in valve
        mov al,00000001b
        out 00h,al        
    ;activating o1 and g1
        mov al,00110000b
        out 04h,al          
    ;programming counter 2 of 8253(1) mode 0
        mov al,10010000b
        out 16h,al
        mov al,0B4h ;180 sec
        out 14h,al    
    ;polling X
    h2: in al,04h
        and al,00001000b
        cmp al,00001000b
        je h2
    ;disable gates and output
        mov al,00000000b
        out 04h,al
    ;delay 10s for the motor to stop
        call delay
        call delay
    ;enabling water drain valve
        mov al,00001001b
        out 00h,al
    ;waiting for sensor to give water empty signal
    h3: in al,02h
        and al,00000010b
        cmp al,00000010b
        je h3
    ;disabling water out valve
        mov al,00000001b
        out 00h,al
    ;playing buzzer
        mov al,00000101b
        out 00h,al
    ;waiting for user to press resume
    h17:in al,02h
        and al,04h
        cmp al,04h
        je h17    
;wash cycle 5 min
     
    ;enabling water in valve and detergent valve
        mov al,00100011b
        out 00h,al
    ;wating for sensor output for water full
    h4: in al,02h
        and al,00000001b
        cmp al,01h
        je h4
    ;closing water valve
        mov al,00000001b
        out 00h,al
    ;enabling o1 g1
        mov al,00110000b
        out 04h,al
    ;programming counter 2 of 8253(1)
        mov al,10110000b
        out 16h,al
        mov al,2Ch
        out 14h,al
        mov al,01h
        out 14h,al
    ;polling X
    h5: in al,04h
        and al,00001000b
        cmp al,00001000b
        je h5
    ;disabling gates
        mov al,00000000b
        out 04h,al
        call delay
        call delay
    ;opening water out valve
        mov al,00001001b
        out 00h,al
    ;polling for water empty
    h6: in al,02h
        and al,00000010b
        cmp al,00000010b
        je h6
    ;playing buzzer
        mov al,00010001b
        out 00h,al
    ;waiting for resume to be pressed
    h18:in al,02h
        and al,04h
        cmp al,04h
        je h18    
        
;rinse cycle 3 mins
    ;closing water out valve and opening water in valve
        mov al,00000011b
        out 00h,al
    ;polling sensor for water full
    h7: in al,02h
        and al,00000001b
        cmp al,01h
        je h7
    ;closing water in valve
        mov al,00000001b
        out 00h,al
    ;enabling gates for rinse
        mov al,00110000b
        out 04h,al
    ;programming counter 2 of 8253(1)
        mov al,10010000b
        out 16h,al
        mov al,0B4h
        out 14h,al
    ;polling x
    h8: in al,04h
        and al,00001000b
        cmp al,00001000b
        je h8
    ;disable gates
        mov al,00000000b
        out 04h,al
        call delay
        call delay
    ;opening water out valve
        mov al,00001001b
        out 00h,al
    ;polling water empty sensor
    h9: in al,02h
        and al,00000010b
        cmp al,00000010b
        je h9
    ;closing water valve
        mov al,00000001b
        out 00h,al
    ;playing buzzer for rinse
        mov al,00000101b
        out 00h,al
        ;call delay
    ;waiting for resume to be pressed 
    h19:in al,02h
        and al,04h
        cmp al,04h
        je h19    
;wash cycle 5 min
     
    ;enabling water in valve and detergent valve
        mov al,00100011b
        out 00h,al
    ;wating for sensor output for water full
    h10:in al,02h
        and al,00000001b
        cmp al,01h
        je h10
    ;closing water valve
        mov al,00000001b
        out 00h,al
    ;enabling o1 g1
        mov al,00110000b
        out 04h,al
    ;programming counter 2 of 8253(1)
        mov al,10110000b
        out 16h,al
        mov al,2Ch
        out 14h,al
        mov al,01h
        out 14h,al
    ;polling X
    h11:in al,04h
        and al,00001000b
        cmp al,00001000b
        je h11
    ;disabling gates
        mov al,00000000b
        out 04h,al
        call delay
        call delay
    ;opening water out valve
        mov al,00001001b
        out 00h,al
    ;polling for water empty
    h12:in al,02h
        and al,00000010b
        cmp al,00000010b
        je h12
    ;playing buzzer
        mov al,00010001b
        out 00h,al
    ;waiting for resume to be pressed 
    h20:in al,02h
        and al,04h
        cmp al,04h
        je h20    
;rinse cycle 3 mins
    ;closing water out valve and opening water in valve
        mov al,00000011b
        out 00h,al
    ;polling sensor for water full
    h13:in al,02h
        and al,00000001b
        cmp al,01h
        je h13
    ;closing water in valve
        mov al,00000001b
        out 00h,al
    ;enabling gates for rinse
        mov al,00110000b
        out 04h,al
    ;programming counter 2 of 8253(1)
        mov al,10010000b
        out 16h,al
        mov al,0B4h
        out 14h,al
    ;polling x
    h14: in al,04h
        and al,00001000b
        cmp al,00001000b
        je h14
    ;disable gates
        mov al,00000000b
        out 04h,al
        call delay
        call delay
    ;opening water out valve
        mov al,00001001b
        out 00h,al
    ;polling water empty sensor
    h15:in al,02h
        and al,00000010b
        cmp al,00000010b
        je h15
    ;closing water valve
        mov al,00000001b
        out 00h,al
    ;playing buzzer for rinse
        mov al,00000101b
        out 00h,al
    ;waiting for resume to be pressed 
    h22:in al,02h
        and al,04h
        cmp al,04h
        je h22
            
;dry cycle 4 mins
    ;enabling gates
        mov al,11000000b
        out 04h,al
    ;programming counter 1 of 8253(2)
        mov al,00010000b
        out 26h,al
        mov al,0F0h
        out 20h,al
    ;polling X
    h16:in al,04h
        and al,00001000b
        cmp al,00001000b
        je h16
    ;disabling gates
        mov al,00000000b
        out 04h,al
        call delay
    ;playing buzzer and opening the lock
        mov al,01000000b
        out 00h,al
        call delay
        mov al,00000000b
        out 00h,al                               
    ret



MEDIUM:
    ;locking
        mov al,00000001b
        out 00h,al
;rinse cycle 3 min   
    ;open water valve
        mov al,00000011b
        out 00h,al    
    ;poll sensor output
    m1: in al,02h
        and al,01h
        cmp al,01h
        je m1        
    ;closing water in valve
        mov al,00000001b
        out 00h,al        
    ;activating o1 and g1
        mov al,00110000b
        out 04h,al          
    ;programming counter 2 of 8253(1) mode 0
        mov al,10010000b
        out 16h,al
        mov al,0B4h ;180 sec
        out 14h,al    
    ;polling X
    m2: in al,04h
        and al,00001000b
        cmp al,00001000b
        je m2
    ;disable gates and output
        mov al,00000000b
        out 04h,al
    ;delay 10s for the motor to stop
        call delay           
        call delay
    ;enabling water drain valve
        mov al,00001001b
        out 00h,al
    ;waiting for sensor to give water empty signal
    m3: in al,02h
        and al,00000010b
        cmp al,00000010b
        je m3
    ;disabling water out valve
        mov al,00000001b
        out 00h,al
    ;playing buzzer
        mov al,00000101b
        out 00h,al
    ;waiting for user to press resume
    m11:in al,02h
        and al,04h
        cmp al,04h
        je m11
   
;wash cycle 5 min
     
    ;enabling water in valve and detergent valve
        mov al,00100011b
        out 00h,al
    ;wating for sensor output for water full
    m4: in al,02h
        and al,00000001b
        cmp al,01h
        je m4
    ;closing water valve
        mov al,00000001b
        out 00h,al
    ;enabling o1 g1
        mov al,00110000b
        out 04h,al
    ;programming counter 2 of 8253(1)
        mov al,10110000b
        out 16h,al
        mov al,2Ch
        out 14h,al
        mov al,01h
        out 14h,al
    ;polling X
    m5: in al,04h
        and al,00001000b
        cmp al,00001000b
        je m5
    ;disabling gates
        mov al,00000000b
        out 04h,al
        call delay
        call delay
    ;opening water out valve
        mov al,00001001b
        out 00h,al
    ;polling for water empty
    m6: in al,02h
        and al,00000010b
        cmp al,00000010b
        je m6
    ;playing buzzer and closing water out valve
        mov al,00010001b
        out 00h,al
    ;waiting for user to press resume
    m12:in al,02h
        and al,04h
        cmp al,04h
        je m12    
;rinse cycle 3 mins
    ;opening water in valve
        mov al,00000011b
        out 00h,al
    ;polling sensor for water full
    m7: in al,02h
        and al,00000001b
        cmp al,01h
        je m7
    ;closing water in valve
        mov al,00000001b
        out 00h,al
    ;enabling gates for rinse
        mov al,00110000b
        out 04h,al
    ;programming counter 2 of 8253(1)
        mov al,10010000b
        out 16h,al
        mov al,0B4h
        out 14h,al
    ;polling x
    m8: in al,04h
        and al,00001000b
        cmp al,00001000b
        je m8
    ;disable gates
        mov al,00000000b
        out 04h,al
        call delay
        call delay
    ;opening water out valve
        mov al,00001001b
        out 00h,al
    ;polling water empty sensor
    m9: in al,02h
        and al,00000010b
        cmp al,00000010b
        je m9
    ;closing water valve
        mov al,00000001b
        out 00h,al
    ;playing buzzer for rinse
        mov al,00000101b
        out 00h,al
    ;waiting for user to press resume
    m13:in al,02h
        and al,04h
        cmp al,04h
        je m13
        
;dry cycle 4 mins
    ;enabling gates
        mov al,11000000b
        out 04h,al
    ;programming counter 1 of 8253(2)
        mov al,00010000b
        out 26h,al
        mov al,0F0h
        out 20h,al
    ;polling X
    m10:in al,04h
        and al,00001000b
        cmp al,00001000b
        je m10
    ;disabling gates
        mov al,00000000b
        out 04h,al
        call delay
        call delay
    ;playing buzzer and opening the lock
        mov al,01000000b
        out 00h,al
        call delay
        mov al,00000000b
        out 00h,al           
     ret





LIGHT:
    ;locking
        mov al,00000001b
        out 00h,al
        
;rinse cycle   
 
    ;open water valve
        mov al,00000011b
        out 00h,al
    
    ;poll sensor output
    l1: in al,02h
        and al,01h
        cmp al,01h
        je l1
        
    ;closing water in valve
        mov al,00000001b
        out 00h,al
        
    ;activating o1 and g1
        mov al,00110000b
        out 04h,al          
    
    ;programming counter 2 of 8253(1) mode 0
        mov al,10010000b
        out 16h,al
        mov al,78h
        out 14h,al
    
    ;polling X
    l2: in al,04h
        and al,00001000b
        cmp al,00001000b
        je l2
    ;disable gates and output
        mov al,00000000b
        out 04h,al
    ;delay 10s for the motor to stop
        call delay           
        call delay
    ;enabling water drain valve
        mov al,00001001b
        out 00h,al
    ;waiting for sensor to give water empty signal
    l3: in al,02h
        and al,00000010b
        cmp al,00000010b
        je l3
    ;disabling water out valve
        mov al,00000001b
        out 00h,al
    ;playing buzzer
        mov al,00000101b
        out 00h,al
    ;wating for user to press resume button
    l11:in al,02h
        and al,04h
        cmp al,04h
        je l11  
    ;stopping buzzer
        mov al,00000001b
        out 00h,al
        
            
;wash cycle 3 mins

    ;enabling water in valve and detergent valve
        mov al,00100011b
        out 00h,al
    ;wating for sensor output for water full
    l4: in al,02h
        and al,00000001b
        cmp al,01h
        je l4
    ;closing water valve
        mov al,00000001b
        out 00h,al
    ;enabling o1 g1
        mov al,00110000b
        out 04h,al
    ;programming counter 2 of 8253(1)
        mov al,10010000b
        out 16h,al
        mov al,0B4h
        out 14h,al
    ;polling X
    l5: in al,04h
        and al,00001000b
        cmp al,00001000b
        je l5
    ;disabling gates
        mov al,00000000b
        out 04h,al
        call delay
        call delay
    ;opening water out valve
        mov al,00001001b
        out 00h,al
    ;polling for water empty
    l6: in al,02h
        and al,00000010b
        cmp al,00000010b
        je l6
    ;closing water out valve
        mov al,00000001b
        out 00h,al
    ;playing buzzer
        mov al,00010001b
        out 00h,al
    ;wating for user to press resume
    l12:in al,02h
        and al,04h
        cmp al,04h
        je l12  
    ;stopping buzzer
        mov al,00000001b
        out 00h,al    
    
;rinse 2 mins
    ;opening water in valve
        mov al,00000011b
        out 00h,al
    ;polling sensor for water full
    l7: in al,02h
        and al,00000001b
        cmp al,01h
        je l7
    ;closing water in valve
        mov al,00000001b
        out 00h,al
    ;enabling gates for rinse
        mov al,00110000b
        out 04h,al
    ;programming counter 2 of 8253(1)
        mov al,10010000b
        out 16h,al
        mov al,78h
        out 14h,al
    ;polling x
    l8: in al,04h
        and al,00001000b
        cmp al,00001000b
        je l8
    ;disable gates
        mov al,00000000b
        out 04h,al
        call delay
        call delay
    ;opening water out valve
        mov al,00001001b
        out 00h,al
    ;polling water empty sensor
    l9: in al,02h
        and al,00000010b
        cmp al,00000010b
        je l9
    ;closing water valve
        mov al,00000001b
        out 00h,al
        
    ;playing buzzer for rinse
        mov al,00000101b
        out 00h,al
    l13:in al,02h
        and al,04h
        cmp al,04h
        je l13
    ;stopping the buzzer
        mov al,00000001b
        out 00h,al    
;dry cycle 2 mins
    ;enabling gates
        mov al,11000000b
        out 04h,al
    ;programming counter 1 of 8253(2)
        mov al,00010000b
        out 26h,al
        mov al,78h
        out 20h,al
    ;polling X
    l10:in al,04h
        and al,00001000b
        cmp al,00001000b
        je l10
    ;disabling gates
        mov al,00000000b
        out 04h,al
    ;waiting for motor to stop
        call delay
        call delay
    ;playing buzzer and opening the lock
        mov al,01000000b
        out 00h,al
        call delay
        mov al,00000000b
        out 00h,al
    ret
        
        
        
tisr:       mov al,01000000b
            out 00h,al
        ;disabling all signals
            mov al,00000000b
            out 04h,al
            ;call delay
        ;emptying water
            mov al,00001001b
            out 00h,al
        ;polling for empty signal
        t9: in al,02h
            and al,00000010b
            cmp al,00000010b
            je t9
        ;closing water valves and opening locks
            mov al,00000000b
            out 00h,al
        ;overwriting cs and ip
            ;int 3
            pop ax
            pop ax
            pop ax
            pop ax
            pop ax
            pop ax
            pop ax
            pop ax
            pop ax
            mov ax,0000
            push ax
            push st1
            ;int 3
        iret
        
delay:      mov cx,0FFFFh
        d1: loop d1
        ret    