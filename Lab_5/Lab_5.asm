;��������� ������� �� ����� ������ ������ �� ��������� ��������. ��� ������� ������� �S� ��������� ��������� ���� ������ �� ��������
        model small
        .386
		stack 100h
;--------------------------------------------------------------------------------------------------------
        dataseg
sector                  db      512 dup (0)   	;����� ������� �����
off_in_sector           dw      0      	        ;�������� � ����������� �������
titles                  db      2688 dup (0)    ;������ ���� ������
title_copy              db      15 dup (0)      ;����� ����� �����
count                   db      0               ;���������� ������ ��������� ��������
screen_message			db		0Ah,0Dh,"Press any key to Exit or <s> to Sort list ...",								0Ah,0Dh,0Ah,0Dh,"$" 
copy_si					dw		0				;����� �������� si						
copy_di					dw		0				;����� �������� di
multipl					db		12				;��������� ��� �������� ��������

        codeseg
;--------------------------------------------------------------------------------------------------------
        startupcode
;������� ������
    mov ax, 0600h   ;��������� ������ ������
    mov bh, 07h     ;����� ������ �� ������ ����
    mov cx, 0000h   ;������� ����� ������
    mov dx, 184fh   ;������ ������ ������
    int 10h
;--------------------------------------------------------------------------------------------------------
    lea si, titles  ;��������� ����� ������� ���� (��� = 12 ����)

    ;�� ���� �������� �������-��������� ���������
    mov dx, 19
lp:
    cmp dx, 33
    je exit_lp
    mov cx, 1
    lea bx, sector
    mov al, 0
    int 25h

		jmp choose
        ret_to_lp:

    inc dx
    jmp lp
;----------------------
;�������� ����� ������ �� �������, ������������ � ������� �������
choose:
    push ax
    push bx
    push cx
    push dx

    mov cx, 16
    ;�� ���� 16 �������, ������������ � ������� �������
	m:
        ;������� �������� � sector
        mov ax, 16
        sub ax, cx
        shl ax, 5
        mov off_in_sector, ax
		;��������� �����
        lea bx, sector
        add bx, off_in_sector
		;���������: ������� �� ����, ��� ���?
        mov al, byte ptr [bx]
        cmp al, 0               ;������ �����
        je Not_file
        cmp al, 0E5h            ;���� ��� ������
        je Not_file
        cmp al, 2Eh             ;���� �������� ��������������
        je Not_file
								
        ;��������� ����� �� ������� ������
        
		push cx
        mov cx, 8
        mm_file_name:
            ;�������� ��� �����
            mov al, byte ptr [bx]
            mov [si], al
            inc bx
            inc si
        loop mm_file_name
		
		;���������� ����� � ��� �����
        mov al, "."
        mov [si], al
        inc si

		;�������� ���������� �����
        mov cx, 3
        mm_file_expansion:
            mov al, byte ptr [bx]
            mov [si], al
            inc bx
            inc si
        loop mm_file_expansion

        ;�������������� ������� �����
        mov al, count
        inc al
        mov count, al
				
		pop cx
        
		Not_file:		;���� ��������� ����
                
    loop m

    pop dx
    pop cx
    pop bx
    pop ax
jmp ret_to_lp

;----------------------
;����� �� �����
exit_lp:
    xor si, si
    lea si, titles
    xor di, di
    lea di, title_copy
	
	;�� ���� ��������� ������
    mov cl, count
    output_to_screen:
		xor di, di
        lea di, title_copy
        push cx
        mov cx, 12
        copy:
			mov al, byte ptr [si]
            cmp al, 32
			je RRR
			mov [di], al
            inc di
			RRR:
			inc si
        loop copy
        pop cx

		mov al, 0Ah
		mov [di], al
		inc di
		mov al, 0Dh
		mov [di], al
		inc di
        mov al, "$"
        mov [di], al

		;���������������� ����� �� �����
        lea dx, title_copy
        mov ah, 09h
        int 21h
    loop output_to_screen
;----------------------
;������ �� ���� �������
Key:
	lea dx, screen_message
    mov ah, 09h
    int 21h
		
	mov ah, 08h			
	int 21h				
	cmp al, 115			
	jne exit

;----------------------
;��������� ������ ����	
Sort:
	mov cl, count
	dec cl
	
    ;������� ����
	external_sort_loop:
        mov al, count
		sub al, cl
		sub al, 1
		mul multipl
		lea si, titles
		add si, ax
	
		mov di, si
		add di, 12
		mov copy_di, di	
			
		push cx
		;���������� ����
		internal_sort_loop:
			push si
			push di
			push cx
			push ax
			push bx
			mov cx, 12
			;���� ��������� �����-����
			compare_loop:
				mov al, byte ptr [si]
				mov bl, byte ptr [di]
				cmp bl, al
				jl m1
				jg m2
				inc si
				inc di
			loop compare_loop
			jmp m2
			m1:	;����� ����������
			pop bx
			pop ax
			pop cx
			pop di
			pop si
				
			push si
			push di
			push cx
			mov cx, 12
			;���� ������ �����-����
			copy_loop:
				mov al, byte ptr [di]
				mov bl, byte ptr [si]
				mov [si], al
				mov [di], bl
				inc si
				inc di
			loop copy_loop
			pop cx
			pop di
			pop si
			jmp m3
			m2:	;�� ����� ����������								
			pop bx
			pop ax
			pop cx
			pop di
			pop si
			m3:
			mov di, copy_di
			add di, 12
			mov copy_di, di
		loop internal_sort_loop
		pop cx
	loop external_sort_loop
	jmp exit_lp
;--------------------------------------------------------------------------------------------------------
; �����
    mov ah, 08h
    int 21h
exit:
    ;������� ������
    mov ax, 0600h   ;��������� ������ ������
    mov bh, 07h     ;����� ������ �� ������ ����
    mov cx, 0000h   ;������� ����� ������
    mov dx, 184fh   ;������ ������ ������
    int 10h

    mov     ah, 4ch
    int     21h
;--------------------------------------------------------------------------------------------------------
QUIT: exitcode  0
    end