.model small
.stack 100h

.data
    msg db "Enter text: $"
    msg2 db 0dh, 0ah, "Length of words: $"
    in_buff db 255, ?, 255 dup(?)
    out_buff db 255*4 dup('$')

.code
    start:
        mov ax, @data
        mov ds, ax
        ;adds data segment

        mov dx, offset msg
        mov ah, 09h
        int 21h
        ; prints msg

        mov ah, 0Ah
        mov dx, offset in_buff
        int 21h
        ; takes input and fills in_buff

        mov bh, 0 ; sets units as 0
        mov bl, 0 ; sets tens as 0
        mov ch, 0 ; sets hundreds as 0

        mov di, offset in_buff + 2 ;sets di as the starting index for the input

        reading:
            mov al, ds:[di] ; moves what is in data segment by index di to al
            inc di ; increments di

            CMP al, 13 
            JE endReading ; if new line/enter

            CMP al, 32 
            JNE countUnits ; if not space

            CMP ch, 0
            CMP bl, 0
            CMP bh, 0
            JE reading ; if units, tens and hundreds are all zero, loops to read the next character

            CMP ch, 0
            CMP bl, 0
            JE skip ; if tens and hundreds are zero

            CMP ch, 0
            JE skip2 ; if hundreds are zero

            ADD ch, 30h ; convert to ASCII table digit
            mov ds:[out_buff + si], ch ; moves hundreds to data segment by index 'out_buff + si'
            inc si ; increments si


        skip2:
            ADD bl, 30h
            mov ds:[out_buff + si], bl ; moves tens to data segment 
            inc si

            ADD bh, 30h 
            mov ds:[out_buff + si], bh ; moves units to data segment
            inc si

            mov ds:[out_buff + si], 32 ; adds space for seperation
            inc si

            XOR ch, ch
            XOR bl, bl
            XOR bh, bh

            JMP reading ; back to reading another word

        skip:
            ADD bh, 30h 
            mov ds:[out_buff + si], bh ; moves units to data segment by index 'out_buff + si'
            inc si

            mov ds:[out_buff + si], 32 ; adds space for seperation
            inc si

            XOR ch, ch
            XOR bl, bl
            XOR bh, bh

            JMP reading ; back to reading another word
        
        ; counter for units 
        countUnits: 
            inc bh
            CMP bh, 10
            JE countTens ; if bh/units exceed 9

            JMP reading

        ; counter for tens
        countTens: 
            XOR bh, bh ; units are nulled
            inc bl ; tens are incremented
            CMP bl, 10
            JE countHundreds

            JMP reading ; back to reading

        countHundreds:
            XOR bl, bl
            inc ch

            JMP reading

        ; after reading all of the input
        endReading:
            CMP ch, 0
            CMP bl, 0
            JE shortWord ; if less than 10 characters in a word

            CMP ch, 0
            JE mediumWord  ; if less than 100 characters

            ADD ch, 30h
            mov ds:[out_buff + si], ch ; adds ch/hundreds to the out buffer
            inc si

        ; if the character count is less than 100
        mediumWord:
            ADD bl, 30h
            mov ds:[out_buff + si], bl ; adds bl/tens to out buffer
            inc si

        ; if the character count is less than 10 in a word
        shortWord:
            ADD bh, 30h
            mov ds:[out_buff + si], bh ; adds bh/units to out buffer
            inc si

            mov ds:[out_buff + si], 32 ; adds space for seperation
            inc si
        
        mov dx, offset msg2
        mov ah, 09h
        int 21h
        ; prints msg2
        
        mov dx, offset out_buff
        mov ah, 09h
        int 21h
        ; prints out_buff

        close:
            mov ax, 4c00h
            int 21h
            ; ends process

    end start