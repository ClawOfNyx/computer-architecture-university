.model small
.386
.stack 100h
.data
    lowerCaseCount dw 0
    capitalsCount dw 0
    charsCount dw 0
    WordsCount dw 1
    spaceCount dw 0
    h dw 0
    fileNameLength db 0
    dataNames db 20 dup(?)
    fileName db 256 dup(0)
    buffer db 255 dup(?)
    helpMessage db "When launching the program please enter the names of files you wish to work with.$", 10, 13
    fileError db "Unable to open at least one of specified files. File(s) might not exist.$"
    lowerCaseOutput db 13, 10, "Lower case letters count: $"
	capitalsOutput db 13, 10, "Capital letters count: $"
	charsOutput db 13, 10, "Characters count: $"
	wordsOutput db 13, 10, "Words count: $"
    newLine db 13, 10, 13, 10, '$'

.code
START:
    mov ax, @data
    mov ds, ax

    mov bx, 82h ;address where text saved from command line is saved
    mov si, offset fileName

    CMP byte ptr es:[80h], 0 ; checks if there are any arguments
    JE helpCall

    mov cl, byte ptr es:[80h] ; save the length of the argument

    readFileName:
        loop1:
            CMP byte ptr es:[bx], 32 ; checking if by index bx is a space
            JE openFile

            CMP byte ptr es:[bx], 13 ; checking if by index bx is end of line
            JE openFile

            mov dl, byte ptr es:[bx] ; if nothing above matched, that means it is another char
            mov [si], dl ; moving to filename buffer to si

            INC si
            INC fileNameLength
            JMP sameFile

            continue:
                pop bx ; popping current place in the line 
                pop cx ; popping cx to know how much there is left to read
            sameFile:
                INC bx ; to read next characters

            LOOP loop1
            JMP close1 ; end when all files have been worked with

    openFile:
        push cx
        push bx

        mov dx, offset fileName
        mov ax, 3d00h ; opens a file, zero isn't needed at the end because the buffer is full of them
        int 21h
        JC error ; if unable to open file

        mov [h], ax
        mov bx, ax

        read: 
            mov ah, 3fh
            mov cx, 100h
            mov dx, offset buffer
            int 21h

            JC finish

            OR ax, ax
            JZ finish ; EOF

            CALL Count               ; read and count 
            jmp read

    finish:
        CMP charsCount, 0
        JNE skipNull
        mov WordsCount, 0

        skipNull:
        mov dl, 36 ; $
	    mov [si], dl
        mov dx, offset fileName
        CALL print

        ; print lower case statistics
        mov dx, offset lowerCaseOutput
        CALL print
        mov ax, lowerCaseCount
        CALL printProc
        mov lowerCaseCount, 0

        ; print upper case statistics
        mov dx, offset capitalsOutput
        CALL print
        mov ax, capitalsCount
        CALL printProc
        mov capitalsCount, 0

        ; print characters statistics
        mov dx, offset charsOutput
        CALL print
        mov ax, charsCount
        CALL printProc
        mov charsCount, 0

        ; print words statistics
        mov dx, offset wordsOutput
        CALL print
        mov ax, wordsCount
        CALL printProc
        mov wordsCount, 0

        ; print a couple of new lines =
        mov dx, offset newLine
        CALL print
        ; mov dx, offset newLine
        ; CALL print

        mov bx, [h]
        OR bx, bx
        JZ close1
        mov ah, 3eh
        int 21h

    reset:
        mov dl, 48 ; moving 0 to dl
        mov [si], dl ; moving to [si], dl that is 0

        CMP fileNameLength, 0 ; if file name is zero
        JE continue

        DEC fileNameLength
        DEC si

        JMP reset

    close1:
        mov ax, 4c00h
        int 21h

    helpCall:
        mov dx, offset helpMessage
        CALL print
        CALL close1

    error:
        mov ax,03h
        int 10h

        mov dx, offset fileError
        CALL print
        CALL close1

    print:
        mov ah, 09h
        int 21h
        RET

    Count:
        push ax
        push bx
        push cx
            
        mov cx, ax
        XOR bx, bx
        counting:
            mov al, [buffer + bx]
            CMP al, 'a' ; if below 'a' then not a lower case letter
            JB skip1
            CMP al, 'z' ; if above 'z' then not a lower case letter
            JA skip1
            INC lowerCaseCount

            skip1:
            CMP al, 'A' ; if below 'A' then not a capital letter
            JB skip2
            CMP al, 'Z' ; if below 'Z' then not a capital letter
            JA skip2
            INC capitalsCount

            skip2:
            CMP al, 10		; if new line then not a char
            JE skip3
            CMP al, 13		; if carriage return, then not a char
            JE skip3
            CMP al, 32      ; if space then not a char
            JE skip3
            INC charsCount	

            skip3:
            cmp al, 32	; if space, then new word
            JE space
            CMP al, 13	; if carriage return then new word
            JE newWord
            JMP skip4	; if not then, it is not a new word and we skip

            cont:
            newWord:
                CMP spaceCount, 1 ; if not more than 1 space
                JA skip4
                CMP [buffer + bx - 1], 32 ; check if it wasn't nulled when there is still space before
                JE skip4 
                inc wordsCount
                mov spaceCount, 0 ; nulling space count if a word was counted
            
            skip4:
                INC bx
        LOOP counting
            
        pop cx
        pop bx
        pop ax
        RET

    space:
        INC spaceCount
        JMP cont

    printProc:		; printing the counts
        mov dx, 0
        mov cx, 0
        
        CMP ax, 9	; if number is of one digit
        mov dx, ax
        JA division
        add dx, 48
        mov ah, 02h
        int 21h
        JMP exitPrinting
        
        ; if more than one digit 
        division:
            XOR dx, dx
            CMP ax, 0
            JE printing
            mov bx, 10
            DIV bx
            
            push dx
            INC cx
        JMP division
        
        printing:	
            CMP cx, 0
            JE exitPrinting
            
            pop dx
            mov ah, 02h
            add dx, 48
            int 21h
            
            DEC cx
            JMP printing
        
        exitPrinting:
        RET

END START