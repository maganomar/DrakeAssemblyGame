; #########################################################################
;
;   game.asm - Assembly file for EECS205 Assignment 4/5
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include blit.inc
include game.inc
include keys.inc
include sprites.asm


; For Drawing Text
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib

; For Playing Sound
include \masm32\include\windows.inc
include \masm32\include\winmm.inc
includelib \masm32\lib\winmm.lib	

; For generating random numbers
include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib



.DATA
	
;; If you need to, you can place global variables here


;; EECS205RECT structures for collision

recttest EECS205RECT<485, 315, 620, 470> ;; test for collision
drakerect EECS205RECT<68,368,132,432> ;; INITIALLY
ob1rect EECS205RECT<?,?,?,?>
ob2rect EECS205RECT<?,?,?,?>
ob3rect EECS205RECT<?,?,?,?>
ob4rect EECS205RECT<?,?,?,?>
ob5rect EECS205RECT<?,?,?,?>
ob6rect EECS205RECT<?,?,?,?>
ob7rect EECS205RECT<?,?,?,?>
ob8rect EECS205RECT<?,?,?,?>
ob9rect EECS205RECT<?,?,?,?>
ob10rect EECS205RECT<?,?,?,?>


;; TEXT
whatStr BYTE "YOU LOSE", 0
toomuchstr BYTE "Try not to think about it too much...", 0
restartstr BYTE "Press Spacebar to restart this level!", 0
introtext1 BYTE "WELCOME TO DRAKE", 0
introtext2 BYTE "Press Spacebar to begin", 0
lvlone BYTE "LEVEL HOTLINE BLING", 0
info1 BYTE "You are Drake, and you need to get your girl back", 0
info2 BYTE "There will be things flying from above", 0
info3 BYTE "Avoid ANY distractions, and COLLECT TEN red phones from your girl", 0
info4 BYTE "Move Drake with the left and right arrow keys  <--  -->", 0
infopowerup BYTE "You'll get a power up by going faster when you collect 6 phones", 0
infosorry BYTE "Also, apologies if you get a phone, but the score isn't incremented", 0
infosorry2 BYTE "Consider it a missed call to your girl. Such is life.", 0
infopause BYTE "Press P to pause the game", 0
info5 BYTE "PRESS ENTER IF YOU READY", 0
lvl1hits0 BYTE "HITS: 0", 0
lvl1hits1 BYTE "HITS: 1", 0
lvl1hits2 BYTE "HITS: 2", 0
lvl1score0 BYTE "SCORE: 0", 0
lvl1score1 BYTE "SCORE: 1", 0
lvl1score2 BYTE "SCORE: 2", 0
lvl1score3 BYTE "SCORE: 3", 0
lvl1score4 BYTE "SCORE: 4", 0
lvl1score5 BYTE "SCORE: 5", 0
lvl1score6 BYTE "SCORE: 6 *POWERUP YOU'RE FASTER NOW*", 0
lvl1score7 BYTE "SCORE: 7", 0
lvl1score8 BYTE "SCORE: 8", 0
lvl1score9 BYTE "SCORE: 9", 0
lvl1score10 BYTE "SCORE: 10", 0

youwinstr BYTE "YOU WIN", 0
youwinstr2 BYTE "It was all you", 0

lose1 BYTE "YOU LOSE", 0
lose2 BYTE "You hit 3 obstacles", 0
lose3 BYTE "Try to avoid all money and drinks, and only collect the red phones", 0
lose4 BYTE "Press ENTER, then SPACE to restart", 0
lose5 BYTE "You must be wondering why? Cause assembly, that's why", 0

pausestr1 BYTE "GAME PAUSED", 0
pausestr2 BYTE "Press ENTER to resume", 0


;; was going to do a level two, but didn't have enough time
;; LEVEL TWO

leveltwo BYTE "LEVEL BACK TO BACK", 0
info6 BYTE "Congrats, you got your girl! But now you gotta win back to back", 0
info7 BYTE "Move Drake with the left and right arrow keys  <--  -->", 0
info8 BYTE "And now you can jump by hitting the up arrow key", 0
info9 BYTE "Avoid ALL obstacles as long as you can", 0


;; DRAKE SPRITE position
xpos DWORD ?
ypos DWORD ?

;; MEEK SPRITE position
xpos_meek DWORD ?
ypos_meek DWORD ?

;; OBSTACLE SPRITE position
xpos_ob1 DWORD ?
ypos_ob1 DWORD ?
xpos_ob2 DWORD ?
ypos_ob2 DWORD ?
xpos_ob3 DWORD ?
ypos_ob3 DWORD ?
xpos_ob4 DWORD ?
ypos_ob4 DWORD ?
xpos_ob5 DWORD ?
ypos_ob5 DWORD ?
xpos_ob6 DWORD ?
ypos_ob6 DWORD ?
xpos_ob7 DWORD ?
ypos_ob7 DWORD ?
xpos_ob8 DWORD ?
ypos_ob8 DWORD ?
xpos_ob9 DWORD ?
ypos_ob9 DWORD ?
xpos_ob10 DWORD ?
ypos_ob10 DWORD ?


;; SONGS
hotlinebling BYTE "hotlinebling.wav", 0
toomuch BYTE "toomuch.wav", 0
mottoinstrumental BYTE "mottoinstrumental.wav", 0
jumpman BYTE "jumpman.wav", 0
allme BYTE "allme.wav", 0

;; GLOBAL VARIABLE FLAGS
lost DWORD 0
flag DWORD 0
introscreen DWORD 0
lvl1info DWORD 0
leveloneinitcheck DWORD 0

levelonehits DWORD 0
levelonescore DWORD 0

youwinflag DWORD 0

youloseflag DWORD 0

pauseflag DWORD 0

powerupflag DWORD 0

;; LEVEL 2
leveltwoinitcheck DWORD 0
leveltwospacecheck DWORD 0 ;; checks to see if you hit space on Level 2 intro screen
leveltwoinit_total DWORD 0


.CODE

;;INITIALIZING DRAKE
drakesprite SPRITE <100, 400>


;;INITIALIZING PHONES
phones SPRITE 100 DUP (<>)


;; Clears entire screen
ClearScreen PROC uses ebx edx
    mov eax, 0
    mov ebx, 0
    mov edx, ScreenBitsPtr
    jmp L3
L1:
    mov BYTE PTR [edx + eax], 0
    inc eax
L2:
    cmp eax, 640
    jl L1
L3:
    inc ebx
    xor eax, eax    
    add edx, 640    
    cmp ebx, 480     
    jl L1

      ret
ClearScreen ENDP




;; ****************************************************************
;; LEVEL ONE SCORE & HIT COUNT
;; ****************************************************************

LevelOneScore PROC

        ;; doing increments of 6 because of the code's structure
        ;; when sprites collide, a variable is incremented
        ;; that variable is incremented by 6 when drake sprite and obstacle go through each other
        ;; then did the math accordingly

         invoke DrawStr, offset levelonehits, 50, 250, 0ffh

        cmp levelonescore, 0
        jg L1
        INVOKE DrawStr, OFFSET lvl1score0, 10, 25, 0ffh
        jmp hitcheck

L1:
        cmp levelonescore, 6
        jg L2
        INVOKE DrawStr, OFFSET lvl1score1, 10, 25, 0ffh
        jmp hitcheck
        

L2:
        cmp levelonescore, 12
        jg L3
        INVOKE DrawStr, OFFSET lvl1score2, 10, 25, 0ffh
        jmp hitcheck

L3:
        cmp levelonescore, 18
        jg L4
        INVOKE DrawStr, OFFSET lvl1score3, 10, 25, 0ffh
        jmp hitcheck

L4:
        cmp levelonescore, 24
        jg L5
        INVOKE DrawStr, OFFSET lvl1score4, 10, 25, 0ffh
        jmp hitcheck

L5:
        cmp levelonescore, 30
        jg L6
        INVOKE DrawStr, OFFSET lvl1score5, 10, 25, 0ffh
        jmp hitcheck

L6:
        cmp levelonescore, 36
        jg L7
        INVOKE DrawStr, OFFSET lvl1score6, 10, 25, 0ffh
        jmp hitcheck

L7:
        cmp levelonescore, 42
        jg L8
        INVOKE DrawStr, OFFSET lvl1score7, 10, 25, 0ffh
        jmp hitcheck

L8:
        cmp levelonescore, 48
        jg L9
        INVOKE DrawStr, OFFSET lvl1score8, 10, 25, 0ffh
        jmp hitcheck

L9:

        INVOKE DrawStr, OFFSET lvl1score9, 10, 25, 0ffh



hitcheck:
    
        cmp levelonehits, 0
        jg L10
        INVOKE DrawStr, OFFSET lvl1hits0, 10, 40, 0ffh
        jmp endlevelonescore

L10:

        cmp levelonehits, 6
        jg L11
        INVOKE DrawStr, OFFSET lvl1hits1, 10, 40, 0ffh
        jmp endlevelonescore

L11:
        cmp levelonehits, 12
        INVOKE DrawStr, OFFSET lvl1hits2, 10, 40, 0ffh
        jmp endlevelonescore

endlevelonescore:

        ret

LevelOneScore ENDP


;; ****************************************************************
;; LEVEL ONE PLACEMENT
;; ****************************************************************
        ;;      initializes the obstacles and sets EECS205RECT values for collision test
LevelOnePlacement PROC
    
        ;; OBJECT ONE ----------------------
        INVOKE nrandom, 630
        mov xpos_ob1, 50
        mov ypos_ob1, 0
        INVOKE BasicBlit, OFFSET drink, xpos_ob1, ypos_ob1

        mov edi, OFFSET ob1rect 
        mov eax, xpos_ob1
        add eax, 24                                 ;; half the size of drink sprite
        mov (EECS205RECT PTR [edi]).dwRight, eax
        mov eax, xpos_ob1
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwLeft, eax

        mov eax, ypos_ob1
        add eax, 24                                 ;; half the size of drink sprite
        mov (EECS205RECT PTR [edi]).dwTop, eax
        mov eax, ypos_ob1
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwBottom, eax

        
        ;; OBJECT TWO ------------------------
        INVOKE nrandom, 630
        mov xpos_ob2, eax
        mov ypos_ob2, -100
        INVOKE BasicBlit, OFFSET money, xpos_ob2, ypos_ob2

        mov edi, OFFSET ob2rect 
        mov eax, xpos_ob2
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwRight, eax
        mov eax, xpos_ob2
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwLeft, eax

        mov eax, ypos_ob2
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwTop, eax
        mov eax, ypos_ob2
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwBottom, eax

        
        ;; OBJECT THREE ------------------------
        INVOKE nrandom, 630
        mov xpos_ob3, eax
        mov ypos_ob3, -200
        INVOKE BasicBlit, OFFSET redphone, xpos_ob3, ypos_ob3

        mov edi, OFFSET ob3rect 
        mov eax, xpos_ob3
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwRight, eax
        mov eax, xpos_ob3
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwLeft, eax

        mov eax, ypos_ob3
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwTop, eax
        mov eax, ypos_ob3
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwBottom, eax



        ;; OBJECT FOUR ----------------------------------
        INVOKE nrandom, 630
        mov xpos_ob4, eax
        mov ypos_ob4, -300
        INVOKE BasicBlit, OFFSET money, xpos_ob4, ypos_ob4

        mov edi, OFFSET ob4rect 
        mov eax, xpos_ob4
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwRight, eax
        mov eax, xpos_ob4
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwLeft, eax

        mov eax, ypos_ob4
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwTop, eax
        mov eax, ypos_ob4
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwBottom, eax

        
        ;; OBJECT FIVE ------------------------------------
        INVOKE nrandom, 630
        mov xpos_ob5, eax
        mov ypos_ob5, -500
        INVOKE BasicBlit, OFFSET redphone, xpos_ob5, ypos_ob5

        mov edi, OFFSET ob5rect 
        mov eax, xpos_ob5
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwRight, eax
        mov eax, xpos_ob5
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwLeft, eax

        mov eax, ypos_ob5
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwTop, eax
        mov eax, ypos_ob5
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwBottom, eax


        ;; OBJECT SIX ----------------------------------------------
        INVOKE nrandom, 630
        mov xpos_ob6, eax
        mov ypos_ob6, -600
        INVOKE BasicBlit, OFFSET money, xpos_ob6, ypos_ob6

        mov edi, OFFSET ob6rect 
        mov eax, xpos_ob6
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwRight, eax
        mov eax, xpos_ob6
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwLeft, eax

        mov eax, ypos_ob6
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwTop, eax
        mov eax, ypos_ob6
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwBottom, eax

        ;; OBJECT SEVEN ------------------------------------------------------
        INVOKE nrandom, 630
        mov xpos_ob7, eax
        mov ypos_ob7, -700
        INVOKE BasicBlit, OFFSET drink, xpos_ob7, ypos_ob7

        mov edi, OFFSET ob7rect 
        mov eax, xpos_ob7
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwRight, eax
        mov eax, xpos_ob7
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwLeft, eax

        mov eax, ypos_ob7
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwTop, eax
        mov eax, ypos_ob7
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwBottom, eax


        ;; OBJECT 8 ------------------------------------------------------------
        INVOKE nrandom, 630
        mov xpos_ob8, eax
        mov ypos_ob8, -800
        INVOKE BasicBlit, OFFSET redphone, xpos_ob8, ypos_ob8

        mov edi, OFFSET ob8rect 
        mov eax, xpos_ob8
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwRight, eax
        mov eax, xpos_ob8
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwLeft, eax

        mov eax, ypos_ob8
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwTop, eax
        mov eax, ypos_ob8
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwBottom, eax

        ;; OBJECT NINE ---------------------------------------------------------------

        INVOKE nrandom, 630
        mov xpos_ob9, eax
        mov ypos_ob9, -900
        INVOKE BasicBlit, OFFSET drink, xpos_ob9, ypos_ob9

        mov edi, OFFSET ob9rect 
        mov eax, xpos_ob9
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwRight, eax
        mov eax, xpos_ob9
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwLeft, eax

        mov eax, ypos_ob9
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwTop, eax
        mov eax, ypos_ob9
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwBottom, eax


        ;; OBJECT TEN ----------------------------------------------------------------
        INVOKE nrandom, 630
        mov xpos_ob10, eax
        mov ypos_ob10, -900
        INVOKE BasicBlit, OFFSET money, xpos_ob10, ypos_ob10

        mov edi, OFFSET ob10rect 
        mov eax, xpos_ob10
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwRight, eax
        mov eax, xpos_ob10
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwLeft, eax

        mov eax, ypos_ob10
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwTop, eax
        mov eax, ypos_ob10
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwBottom, eax


        ret

LevelOnePlacement ENDP


;; ****************************************************************
;; LEVEL ONE INIT
;; ****************************************************************
                    ;; similar to GameInit, only runs once
LevelOneInit PROC USES ebx ecx
    LOCAL temp: DWORD, halfwidth: DWORD, halfheight: DWORD


        cmp leveloneinitcheck, 1
        je endleveloneinit
                
        mov leveloneinitcheck, 1
        INVOKE PlaySound, OFFSET hotlinebling, 0, SND_FILENAME OR SND_ASYNC
        INVOKE ClearScreen
        INVOKE BasicBlit, OFFSET drakedance1, xpos, ypos
        INVOKE DrawStr, OFFSET lvlone, 10, 10, 0ffh
        INVOKE LevelOneScore

        INVOKE LevelOnePlacement

      

endleveloneinit:
        ret

LevelOneInit ENDP



;; ****************************************************************
;; LEVEL ONE LOOP
;; ****************************************************************
            ;;          loops throughout the level
LevelOneLoop PROC USES ebx edx
        


        INVOKE ClearScreen
        INVOKE BasicBlit, OFFSET drakedance1, xpos, ypos
        INVOKE DrawStr, OFFSET lvlone, 10, 10, 0ffh
        INVOKE LevelOneScore
        
        ;; OB 1 -----------------------------------
        mov ebx, ypos_ob1
        add ebx, 10
        mov ypos_ob1, ebx
        INVOKE BasicBlit, OFFSET drink, xpos_ob1, ypos_ob1

        mov edi, OFFSET ob1rect
        mov eax, ypos_ob1
        add eax, 24                                 ;; half the size of drink sprite
        mov (EECS205RECT PTR [edi]).dwTop, eax
        mov eax, ypos_ob1
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwBottom, eax
 
        ;; OB 2 ---------------------------------------
        mov ebx, ypos_ob2
        add ebx, 10
        mov ypos_ob2, ebx
        INVOKE BasicBlit, OFFSET money, xpos_ob2, ypos_ob2
                
        mov edi, OFFSET ob2rect
        mov eax, ypos_ob2
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwTop, eax
        mov eax, ypos_ob2
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwBottom, eax

        ;; OB 3 ------------------------------------------
        mov ebx, ypos_ob3
        add ebx, 20
        mov ypos_ob3, ebx
        INVOKE BasicBlit, OFFSET redphone, xpos_ob3, ypos_ob3

        mov edi, OFFSET ob3rect
        mov eax, ypos_ob3
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwTop, eax
        mov eax, ypos_ob3
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwBottom, eax

        ;; OB 4 -------------------------------------------
        mov ebx, ypos_ob4
        add ebx, 10
        mov ypos_ob4, ebx
        INVOKE BasicBlit, OFFSET money, xpos_ob4, ypos_ob4

        mov edi, OFFSET ob4rect
        mov eax, ypos_ob4
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwTop, eax
        mov eax, ypos_ob4
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwBottom, eax

        ;; OB 5 ----------------------------------------
        mov ebx, ypos_ob5
        add ebx, 15
        mov ypos_ob5, ebx
        INVOKE BasicBlit, OFFSET redphone, xpos_ob5, ypos_ob5

        mov edi, OFFSET ob5rect
        mov eax, ypos_ob5
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwTop, eax
        mov eax, ypos_ob5
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwBottom, eax

        ;; OB 6 -----------------------------------------
        mov ebx, ypos_ob6
        add ebx, 20
        mov ypos_ob6, ebx
        INVOKE BasicBlit, OFFSET money, xpos_ob6, ypos_ob6

        mov edi, OFFSET ob6rect
        mov eax, ypos_ob6
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwTop, eax
        mov eax, ypos_ob6
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwBottom, eax

        ;; OB 7 ---------------------------------------------
        mov ebx, ypos_ob7
        add ebx, 10
        mov ypos_ob7, ebx
        INVOKE BasicBlit, OFFSET drink, xpos_ob7, ypos_ob7

        mov edi, OFFSET ob7rect
        mov eax, ypos_ob7
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwTop, eax
        mov eax, ypos_ob7
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwBottom, eax

        ;; OB 8 ---------------------------------------------
        mov ebx, ypos_ob8
        add ebx, 30
        mov ypos_ob8, ebx
        INVOKE BasicBlit, OFFSET redphone, xpos_ob8, ypos_ob8

        mov edi, OFFSET ob8rect
        mov eax, ypos_ob8
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwTop, eax
        mov eax, ypos_ob8
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwBottom, eax

        ;; OB 9 ----------------------------------------------
        mov ebx, ypos_ob9
        add ebx, 10
        mov ypos_ob9, ebx
        INVOKE BasicBlit, OFFSET drink, xpos_ob9, ypos_ob9

        mov edi, OFFSET ob9rect
        mov eax, ypos_ob9
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwTop, eax
        mov eax, ypos_ob9
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwBottom, eax

        ;; OB 10 ------------------------------------------
        mov ebx, ypos_ob10
        add ebx, 10
        mov ypos_ob10, ebx
        INVOKE BasicBlit, OFFSET money, xpos_ob10, ypos_ob10

        mov edi, OFFSET ob10rect
        mov eax, ypos_ob10
        add eax, 24                                 
        mov (EECS205RECT PTR [edi]).dwTop, eax
        mov eax, ypos_ob10
        sub eax, 24
        mov (EECS205RECT PTR [edi]).dwBottom, eax


        cmp ypos_ob10, 500
        jl endleveloneloop

        INVOKE LevelOnePlacement

endleveloneloop:
        ret

LevelOneLoop ENDP


;; *******************************************
;; MOVINGDRAKE SIDEWAYS
;; *******************************************

;; Moving Drake with left and right arrow keys ONLY

MovingDrakeSideways PROC

        ;; moving Drake Sprite
        
        cmp powerupflag, 1
        je FAST
        
REGULAR:


RIGHT:
        cmp xpos, 615
        jge LEFT
        mov ebx, KeyPress
        mov ecx, VK_RIGHT
        cmp ebx, ecx
        jne LEFT
        INVOKE ClearScreen
        add xpos, 20
        INVOKE BasicBlit, offset drakedance1, xpos, ypos
        INVOKE BasicBlit, OFFSET drink, xpos_ob1, ypos_ob1
        INVOKE BasicBlit, OFFSET money, xpos_ob2, ypos_ob2
        INVOKE BasicBlit, OFFSET redphone, xpos_ob3, ypos_ob3
        INVOKE BasicBlit, OFFSET money, xpos_ob4, ypos_ob4
        INVOKE BasicBlit, OFFSET redphone, xpos_ob5, ypos_ob5
        INVOKE BasicBlit, OFFSET money, xpos_ob6, ypos_ob6
        INVOKE BasicBlit, OFFSET drink, xpos_ob7, ypos_ob7
        INVOKE BasicBlit, OFFSET redphone, xpos_ob8, ypos_ob8
        INVOKE BasicBlit, OFFSET drink, xpos_ob9, ypos_ob9
        INVOKE BasicBlit, OFFSET money, xpos_ob10, ypos_ob10

        INVOKE DrawStr, OFFSET lvlone, 10, 10, 0ffh
        INVOKE LevelOneScore


        mov edi, OFFSET drakerect 
        mov eax, (EECS205RECT PTR [edi]).dwRight
        add eax, 20
        mov (EECS205RECT PTR [edi]).dwRight, eax
        mov eax, (EECS205RECT PTR [edi]).dwLeft
        add eax, 20
        mov (EECS205RECT PTR [edi]).dwLeft, eax


        ;mov eax, 1
        ;add levelonescore, eax

LEFT:
        cmp xpos, 20
        jle theend
        mov ebx, KeyPress
        mov ecx, VK_LEFT
        cmp ebx, ecx
        jne theend
        INVOKE ClearScreen
        sub xpos, 20
        INVOKE BasicBlit, offset drakedance1, xpos, ypos
        INVOKE BasicBlit, OFFSET drink, xpos_ob1, ypos_ob1
        INVOKE BasicBlit, OFFSET money, xpos_ob2, ypos_ob2
        INVOKE BasicBlit, OFFSET redphone, xpos_ob3, ypos_ob3
        INVOKE BasicBlit, OFFSET money, xpos_ob4, ypos_ob4
        INVOKE BasicBlit, OFFSET redphone, xpos_ob5, ypos_ob5
        INVOKE BasicBlit, OFFSET money, xpos_ob6, ypos_ob6
        INVOKE BasicBlit, OFFSET drink, xpos_ob7, ypos_ob7
        INVOKE BasicBlit, OFFSET redphone, xpos_ob8, ypos_ob8
        INVOKE BasicBlit, OFFSET drink, xpos_ob9, ypos_ob9
        INVOKE BasicBlit, OFFSET money, xpos_ob10, ypos_ob10

        INVOKE DrawStr, OFFSET lvlone, 10, 10, 0ffh
        INVOKE LevelOneScore

        mov edi, OFFSET drakerect 
        mov eax, (EECS205RECT PTR [edi]).dwRight
        sub eax, 20
        mov (EECS205RECT PTR [edi]).dwRight, eax
        mov eax, (EECS205RECT PTR [edi]).dwLeft
        sub eax, 20
        mov (EECS205RECT PTR [edi]).dwLeft, eax
        jmp theend


;; when you get a score of 6 or above, you get a powerup of going faster
FAST:

FASTRIGHT:
        cmp xpos, 615
        jge FASTLEFT
        mov ebx, KeyPress
        mov ecx, VK_RIGHT
        cmp ebx, ecx
        jne FASTLEFT
        INVOKE ClearScreen
        add xpos, 40
        INVOKE BasicBlit, offset drakedance1, xpos, ypos
        INVOKE BasicBlit, OFFSET drink, xpos_ob1, ypos_ob1
        INVOKE BasicBlit, OFFSET money, xpos_ob2, ypos_ob2
        INVOKE BasicBlit, OFFSET redphone, xpos_ob3, ypos_ob3
        INVOKE BasicBlit, OFFSET money, xpos_ob4, ypos_ob4
        INVOKE BasicBlit, OFFSET redphone, xpos_ob5, ypos_ob5
        INVOKE BasicBlit, OFFSET money, xpos_ob6, ypos_ob6
        INVOKE BasicBlit, OFFSET drink, xpos_ob7, ypos_ob7
        INVOKE BasicBlit, OFFSET redphone, xpos_ob8, ypos_ob8
        INVOKE BasicBlit, OFFSET drink, xpos_ob9, ypos_ob9
        INVOKE BasicBlit, OFFSET money, xpos_ob10, ypos_ob10

        INVOKE DrawStr, OFFSET lvlone, 10, 10, 0ffh
        INVOKE LevelOneScore


        mov edi, OFFSET drakerect 
        mov eax, (EECS205RECT PTR [edi]).dwRight
        add eax, 40
        mov (EECS205RECT PTR [edi]).dwRight, eax
        mov eax, (EECS205RECT PTR [edi]).dwLeft
        add eax, 40
        mov (EECS205RECT PTR [edi]).dwLeft, eax



FASTLEFT:
        cmp xpos, 20
        jle theend
        mov ebx, KeyPress
        mov ecx, VK_LEFT
        cmp ebx, ecx
        jne theend
        INVOKE ClearScreen
        sub xpos, 40
        INVOKE BasicBlit, offset drakedance1, xpos, ypos
        INVOKE BasicBlit, OFFSET drink, xpos_ob1, ypos_ob1
        INVOKE BasicBlit, OFFSET money, xpos_ob2, ypos_ob2
        INVOKE BasicBlit, OFFSET redphone, xpos_ob3, ypos_ob3
        INVOKE BasicBlit, OFFSET money, xpos_ob4, ypos_ob4
        INVOKE BasicBlit, OFFSET redphone, xpos_ob5, ypos_ob5
        INVOKE BasicBlit, OFFSET money, xpos_ob6, ypos_ob6
        INVOKE BasicBlit, OFFSET drink, xpos_ob7, ypos_ob7
        INVOKE BasicBlit, OFFSET redphone, xpos_ob8, ypos_ob8
        INVOKE BasicBlit, OFFSET drink, xpos_ob9, ypos_ob9
        INVOKE BasicBlit, OFFSET money, xpos_ob10, ypos_ob10

        INVOKE DrawStr, OFFSET lvlone, 10, 10, 0ffh
        INVOKE LevelOneScore

        mov edi, OFFSET drakerect 
        mov eax, (EECS205RECT PTR [edi]).dwRight
        sub eax, 40
        mov (EECS205RECT PTR [edi]).dwRight, eax
        mov eax, (EECS205RECT PTR [edi]).dwLeft
        sub eax, 40
        mov (EECS205RECT PTR [edi]).dwLeft, eax
        jmp theend


theend:
        ret

MovingDrakeSideways ENDP



;; ****************************************************************
;; YOU WIN
;; ****************************************************************

YouWin PROC 

        cmp youwinflag, 0
        jne L1
        mov youwinflag, 1
        INVOKE PlaySound, OFFSET allme, 0, SND_FILENAME OR SND_ASYNC    ;; only plays once
        

L1:

        INVOKE ClearScreen
        INVOKE BasicBlit, OFFSET drakewin1, 340, 200
        INVOKE DrawStr, OFFSET youwinstr, 60, 220, 0ffh
        INVOKE DrawStr, OFFSET youwinstr2, 40, 250, 0ffh
        

        
endyouyin:
        ret

YouWin ENDP

;; ****************************************************************
;; YOU LOSE
;; ****************************************************************


YouLose PROC USES ebx ecx


        cmp youloseflag, 0
        jne L1
        mov youloseflag, 1
        INVOKE PlaySound, OFFSET toomuch, 0, SND_FILENAME OR SND_ASYNC  ; only plays once
        
 
L1:       
        INVOKE ClearScreen
        INVOKE DrawStr, OFFSET lose1, 250, 100, 0ffh
        INVOKE DrawStr, OFFSET lose2, 25, 150, 0ffh
        INVOKE DrawStr, OFFSET lose3, 25, 200, 0ffh
        INVOKE DrawStr, OFFSET lose4, 170, 325, 0ffh
        INVOKE DrawStr, OFFSET lose5, 100, 375, 0ffh
        
        mov ebx, KeyPress
        mov ecx, VK_RETURN
        cmp ebx, ecx
        jne endyoulose

        mov introscreen, 0
        mov lvl1info, 0
        mov leveloneinitcheck, 0
        mov levelonehits, 0
        mov levelonescore, 0
        mov youwinflag, 0
        mov youloseflag, 0
        mov powerupflag, 0

        

        
endyoulose:
        ret
YouLose ENDP


;; ****************************************************************
;; CHECKCOLLISION
;; ****************************************************************

;; Checks if Drake or Meek sprite collides with Nicki 

CheckCollision PROC 
    LOCAL top: DWORD, bottom: DWORD, left: DWORD, right: DWORD, temp: DWORD
;;mov esi, OFFSET drakesprite

    

        INVOKE CheckIntersectRect, OFFSET drakerect, OFFSET ob1rect
        cmp eax, 1
        je collision
        
        INVOKE CheckIntersectRect, OFFSET drakerect, OFFSET ob2rect
        cmp eax, 1
        je collision
        INVOKE CheckIntersectRect, OFFSET drakerect, OFFSET ob4rect
        cmp eax, 1
        je collision
        INVOKE CheckIntersectRect, OFFSET drakerect, OFFSET ob6rect
        cmp eax, 1
        je collision
        INVOKE CheckIntersectRect, OFFSET drakerect, OFFSET ob7rect
        cmp eax, 1
        je collision
        INVOKE CheckIntersectRect, OFFSET drakerect, OFFSET ob9rect
        cmp eax, 1
        je collision
        INVOKE CheckIntersectRect, OFFSET drakerect, OFFSET ob10rect
        cmp eax, 1
        je collision

        INVOKE CheckIntersectRect, OFFSET drakerect, OFFSET ob3rect
        cmp eax, 1
        je goodcollision

        INVOKE CheckIntersectRect, OFFSET drakerect, OFFSET ob5rect
        cmp eax, 1
        je goodcollision

        INVOKE CheckIntersectRect, OFFSET drakerect, OFFSET ob8rect
        cmp eax, 1
        je goodcollision
        jmp returncollision

        
collision:
        mov eax, 1
        add levelonehits, eax
        jmp returncollision

goodcollision:
        mov eax, 1
        add levelonescore, eax
        jmp returncollision

             
nocollision:
                 
        mov eax, 0              ;; RETURNS 1 IF COLLISION, 0 FOR NO COLLISION
                                ;; never really used eax value as a return value for CheckCollision fuction
returncollision:
        ret
CheckCollision ENDP



;; ****************************************************************
;; GAMEINIT
;; ****************************************************************
                ;; is called only once
GameInit PROC
         LOCAL top: DWORD, bottom: DWORD, left: DWORD, right: DWORD, temp: DWORD

        mov esi, OFFSET drakesprite
        mov ebx, (SPRITE PTR [esi]).xcenter
        mov ecx, (SPRITE PTR [esi]).ycenter
        mov xpos, ebx
        mov ypos, ecx

        INVOKE BasicBlit, OFFSET drakeintro, 250, 200
        INVOKE DrawStr, OFFSET introtext1, 50, 200, 0ffh
        INVOKE DrawStr, OFFSET introtext2, 430, 200, 0ffh
        INVOKE PlaySound, OFFSET mottoinstrumental, 0, SND_FILENAME OR SND_ASYNC    ;; intro music

        ;; For random numbers
        rdtsc
        INVOKE nseed, eax


	ret         ;; Do not delete this line!!!
GameInit ENDP



;; ****************************************************************
;; GAMEPLAY
;; ****************************************************************
        ;; loops continually thoughout game
GamePlay PROC
       

        ;; IntroCheck
        cmp introscreen, 1
        je Lvl1_InfoCheck
        jne IntroScreenCheck


Lvl1_InfoCheck:

        ;; Level 1 info Check
        cmp lvl1info, 1
        je L1
        jne Lvl1_InfoScreen


IntroScreenCheck:

        mov ebx, VK_SPACE
        mov ecx, KeyPress
        cmp ebx, ecx
        jne endgameplay
        mov introscreen, 1
        
 

Lvl1_InfoScreen:
        INVOKE ClearScreen
        ;; invoke strings here
        INVOKE DrawStr, OFFSET lvlone, 210, 50, 0ffh
        INVOKE DrawStr, OFFSET info1, 25, 90, 0ffh
        INVOKE DrawStr, OFFSET info2, 25, 130, 0ffh
        INVOKE DrawStr, OFFSET info3, 25, 170, 0ffh
        INVOKE DrawStr, OFFSET info4, 25, 210, 0ffh
        INVOKE DrawStr, OFFSET infopowerup, 25, 250, 0ffh
        INVOKE DrawStr, OFFSET infopause, 25, 290, 0ffh
        INVOKE DrawStr, OFFSET infosorry, 25, 330, 0ffh
        INVOKE DrawStr, OFFSET infosorry2, 25, 345, 0ffh
        INVOKE DrawStr, OFFSET info5, 210, 400, 0ffh
        mov ebx, VK_RETURN
        mov ecx, KeyPress
        cmp ebx, ecx
        jne endgameplay
        mov lvl1info, 1


L1:

        cmp levelonescore, 30
        jle nevermind
        mov powerupflag, 1

nevermind:

        cmp pauseflag, 1
        je L4

        mov ebx, KeyDown
        mov ecx, VK_P
        cmp ebx, ecx
        je L4
        

        
        cmp levelonescore, 54
        jge L2

        cmp levelonehits, 18
        jge L3
         
        INVOKE LevelOneInit  
        INVOKE LevelOneLoop
        INVOKE MovingDrakeSideways
        INVOKE CheckCollision

        jmp endgameplay
        


L2:
        INVOKE YouWin
        jmp endgameplay


L3:
        INVOKE YouLose  
        jmp endgameplay


L4:
        mov pauseflag, 1
        INVOKE DrawStr, OFFSET pausestr1, 260, 150, 0ffh
        INVOKE DrawStr, OFFSET pausestr2, 230, 200, 0ffh
        mov ebx, KeyDown
        mov ecx, VK_RETURN
        cmp ebx, ecx
        jne endgameplay
        mov pauseflag, 0

             
      
endgameplay:

	ret         ;; Do not delete this line!!!
GamePlay ENDP
	

END
