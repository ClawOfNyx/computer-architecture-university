.model small
.stack 100h

.data
msg db "Enter: $"
msg2 db 13, 10, "Atsakymas:"
out_buff db 255*3 dup("$")
in_buff db 255, ?, 255 dup(?) 
;first create empty buffer and when 0Ah and int 21h is used, read line and puts the amount of read data in ? place

.code
start:
	mov ax, @data
	mov ds, ax ;ideda data segmenta

	mov dx, offset msg ;puts message to dx
	CALL print ;call print function that prints message
	mov ah, 0Ah ;puts 0Ah to ah
	mov dx, offset in_buff ;fills in_buff 
	int 21h

	mov si, offset in_buff + 2 ;to sourse index puts in_buff address + 2, place where my input starts
	XOR cx, cx ;resets/nulls cx
	mov cl, [in_buff + 1] ;puts what is in 'in_buff + 1' (amount of chars read) to cl
	mov di, offset out_buff ;puts out_buff to di, so di shows where needs to be put
	JCXZ close ;if cx is zero jumps to close function

	l1:
		;example imput is abc
		mov al, ds:[si] ;puts to al, what is in data segemnt by address sourse index, a=61, so al now has 61
		SHR al, 4 ;in binary 61 = 0110 0001, shifts by 4 bits and gets rid of 1 (aka 0001) so it could work with 0110 (6)
		CALL convert ;calls convert
		mov al, [si] ;puts what is in data segment by index si to al (gets back the original)
		and al, 0fh ;empties the first 4 bits because first 4 bits in 0F are zeroes
		CALL convert ;again calls convert
		mov al, 32 ;puts space to al because in ASCII 32 is space
		mov [di], al ;adds al that is space to out_buff
		inc di
		inc si

	loop l1

	mov dx, offset msg2 ;puts msg2 to dx
	CALL print ;calls print for it

	close:
		mov ax, 4c00h
		int 21h

	print:
		mov ah, 9 
		int 21h
		RET

	convert:
		CMP al, 0Ah ;compares al to 0Ah, 
		JB digit ;if it's smaller then that means that in al are numbers from 0 to 9 then jumps to digit
		;if al is equal or greater than 0Ah then it first does ADD
		ADD al, 7 ;increases al by 7 then goes to digit 
		;if I had 0Ah(=10) by adding 7 and then 48 it becomes 65=A in ASCII
	
	digit:
		ADD al, 48 ;adds to al 48 so if I had 0 not its 48 as in ASCII table
		mov [di], al ;to data segment from di index puts al
		inc di ;increments di so we can continue filling in the out buffer
		RET ;goes back to the place from where it was called aka back to loop

end start