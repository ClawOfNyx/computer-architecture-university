.model small
.stack 100h

.data
    msg db "Enter text: ", 0dh, 0ah, '$'
    msg2 db 0dh, 0ah, "Answer: $"
    out_buff db 255*4 dup('$')

.code
    start:
        mov ax, @data
        mov ds, ax

        mov dx, offset msg
        mov ah, 09h
        int 21h

        mov bh, 0
        mov bl, 0

        reading:
            mov ah, 1
            int 21h

            CMP al, 13
            JE endReading

            CMP al, 32
            JNE jump

            CMP bl, 0
            CMP bh, 0
            JE reading

            CMP bl, 0
            JE skip

            ADD bl, 30h
            mov [out_buff + si], bl
            inc si

        skip:
            ADD bh, 30h

            mov [out_buff + si], bh
            inc si
            mov [out_buff + si], ''
            inc si
            mov bh, 0
            mov bl, 0
            JMP reading

        jump: 
            inc bh
            CMP bh, 10
            JE x

            JMP reading

        x: 
            mov bh, 0
            inc bl

            JMP reading

        endReading:
            CMP bl, 0
            JE skip1

            ADD bl, 30h
            mov [out_buff + si], bl
            inc si

        skip1:
            ADD bh, 30h

            mov [out_buff + si], bh
            inc si
            mov [out_buff + si], ''

            mov dx, offset msg2
            mov ah, 09h
            int 21h
            
            mov dx, offset out_buff
            mov ah, 09h
            int 21h

        mov ax, 4c00h
        int 21h
    end start