.model small
.stack 100h

.data
    msg db "Enter text: $"
    buff db 255, 0, 255 dup('0')
    line db 0dh, 0ah, 24h
  
.code
    start:

        mov ax, @data
        mov ds, ax

        mov ah, 9
        mov dx, offset msg
        int 21h

        mov ah, 0ah
        mov dx, offset buff
        int 21h

        xor cx, cx
        mov cl, ds: [buff+1]
        mov bx, offset ds: [buff+2]

        L:
            mov al, ds: [bx]
            JCXZ exit
            cmp al, 'A'
            JB continue
            cmp al, 'Z'
            JA continue

            add al, 20h
            mov ds: [bx], al

            continue:
            inc bx

        loop L

        mov ah, 9
        mov dx, offset line
        int 21h

        mov ah, 40h
        mov bx, 1
        xor cx, cx
        mov cl, ds: [buff+1]

        mov dx, offset buff+2
        int 21h

        exit:
        mov ax, 4c00h

        mov ax, 4c00h 
        int 21h

    end start