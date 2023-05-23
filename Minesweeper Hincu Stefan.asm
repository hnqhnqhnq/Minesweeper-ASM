.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Minesweeper Hincu Stefan",0

area_width EQU 600
area_height EQU 700
area DD 0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

line_x EQU 10
line_y EQU 10
line_size EQU 560

bomb_count EQU 41

block_count dd 12000
block_count_from_zero dd 0


minesweeper_board_size EQU 196
minesweeper_board_size_copy EQU 196
minesweeper_board dd 'B', '1', '1', 'B', '2', 'B', '2', '1', '0', '1', '1', '1', '0', '0'
				  dd '1', '1', '1', '2', '3', '2', 'B', '2', '1', '2', 'B', '2', '1', '0'
				  dd '1', '1', '2', 'B', '2', '3', '3', '3', 'B', '2', '2', 'B', '1', '0'
				  dd '1', 'B', '2', '1', '2', 'B', 'B', '3', '2', '2', '2', '2', '2', '0'
				  dd '2', '2', '3', '1', '3', '4', '4', '3', 'B', '2', '2', 'B', '1', '0'
				  dd '2', 'B', '2', 'B', '2', 'B', 'B', '2', '1', '2', 'B', '2', '1', '0'
				  dd 'B', '3', '3', '3', '3', '4', '3', '3', '1', '2', '1', '1', '0', '0'
				  dd '2', '3', 'B', '2', 'B', '2', 'B', '2', 'B', '3', '2', '2', '1', '1'
				  dd '1', 'B', '2', '2', '2', '3', '2', '2', '2', 'B', 'B', '2', 'B', '1'
				  dd '1', '2', '2', '2', '2', 'B', '2', '2', '2', '3', '3', '3', '1', '1'
				  dd '1', '2', 'B', '2', 'B', '4', 'B', '3', 'B', '2', 'B', '1', '0', '0'
				  dd 'B', '2', '1', '2', '2', 'B', '3', 'B', '3', '3', '2', '0', '0', '0'
				  dd '2', '2', '0', '1', '2', '3', '3', '3', '3', 'B', '1', '0', '0', '0'
				  dd 'B', '1', '0', '1', 'B', '2', 'B', '2', 'B', '2', '1', '0', '0', '0'
				  
minesweeper_board_copy dd '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'
					   dd '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'
				       dd '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'
				       dd '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'
				       dd '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'
				       dd '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'
				       dd '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'
				       dd '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'
				       dd '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'
				       dd '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'
				       dd '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'
				       dd '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'
				       dd '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'
				       dd '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0'
					   
row dd '0'
col dd '0'

print_index_row dd 0
print_index_col dd 0
				  			  
.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
	
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
	
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
	
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
	
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
	
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
	
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
	
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

line_horizontal macro x,y,len,color
local loop_line
	mov eax, y 
	mov ebx, area_width
	mul ebx;
	add eax, x 
	shl eax, 2 
	add eax, area
	mov ecx, len
loop_line:
	mov dword ptr[eax], color
	add eax, 4
	loop loop_line
endm

line_vertical macro x,y,len,color
local loop_line
	mov eax, y 
	mov ebx, area_width
	mul ebx;
	add eax, x 
	shl eax, 2 
	add eax, area
	mov ecx, len
loop_line:
	mov dword ptr[eax], color
	add eax, 4*area_width
	loop loop_line
endm

get_coords macro x, y
	push ecx 
	push eax 
	push edx 

    mov ecx, 40
    mov eax, x
    xor edx, edx
	sub eax,10
    idiv ecx
    mov col, eax
    
    mov eax, y
    xor edx, edx
	sub eax,10
    idiv ecx
    mov row, eax
	
	pop edx 
	pop eax 
	pop ecx 
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
	
evt_click:
	
	get_coords [ebp+arg2], [ebp+arg3]
	mov eax, row
	mov ebx, col
	
	imul eax, 56
	imul ebx, 4
	
	mov minesweeper_board_copy[eax][ebx], 'C'
	
	jmp reveal_values
	; line_horizontal [ebp+arg2], [ebp+arg3], 30, 0FFh
	; line_vertical [ebp+arg2], [ebp+arg3], 30, 0FFh
	; mov eax, [ebp+arg3] ;eax=y
	; mov ebx, area_width
	; mul ebx;
	; add eax, [ebp+arg2] ;eax=y*area_width+x
	; shl eax,2 ; pozitia in area 
	; add eax, area
	; mov dword ptr[eax], 0FF0000h
	; mov dword ptr[eax+4], 0FF0000h
	; mov dword ptr[eax-4], 0FF0000h
	; mov dword ptr[eax+4*area_width], 0FF0000h
	; mov dword ptr[eax-4*area_width ], 0FF0000h
	;mov edi, area
	;mov ecx, area_height
	;mov ebx, [ebp+arg3]
	;and ebx, 7
	;inc ebx
; bucla_linii:
	; mov eax, [ebp+arg2]
	; and eax, 0FFh
	; provide a new (random) color
	; mul eax
	; mul eax
	; add eax, ecx
	; push ecx
	; mov ecx, area_width
; bucla_coloane:
	; mov [edi], eax
	; add edi, 4
	; add eax, ebx
	; loop bucla_coloane
	; pop ecx
	; loop bucla_linii
	; mov eax,[ebp+arg2]
	; cmp eax, button_x
	; jl button_fail
	; cmp eax, button_x+button_size
	; jg button_fail
	; mov eax, [ebp+arg3]
	; cmp eax, button_y
	; jl button_fail
	; cmp eax, button_y+ button_size
	; jg button_fail
	; s-a dat click in button
	 ; make_text_macro 'O', area, line_x+line_size/2-5, line_y+line_size+10
	; make_text_macro 'K', area, button_x+button_size/2+5, button_y+button_size+10
	; jmp afisare_litere

; button_fail:
	; make_text_macro ' ', area, button_x+button_size/2-5, button_y+button_size+10
	 ;make_text_macro 'O', area, line_x+line_size/2+5, line_y+line_size+10
	; jmp afisare_litere
reveal_values:
    mov esi, minesweeper_board
    mov eax, 0
    mov ebx, 0
    mov ecx, 25
    mov edx, 20
    mov edi, -1
	
    row_loop:
        column_loop:
			
            cmp minesweeper_board_copy[eax][ebx], 'C'
            je is_clicked
            jmp end_clicked

			is_clicked:
				make_text_macro minesweeper_board[eax][ebx], area, ecx, edx
				cmp minesweeper_board[eax][ebx], 'B'
				je is_bomb
				cmp minesweeper_board[eax][ebx], 'B'
				jne is_correct
				jmp afisare_litere

				is_bomb:
					make_text_macro 'G', area, 230, 625
					make_text_macro 'A', area, 240, 625
					make_text_macro 'M', area, 250, 625
					make_text_macro 'E', area, 260, 625
					make_text_macro 'O', area, 280, 625
					make_text_macro 'V', area, 290, 625
					make_text_macro 'E', area, 300, 625
					make_text_macro 'R', area, 310, 625
					jmp afisare_litere
				is_correct:
					sub block_count, 1
					cmp block_count, 0
					je final
					jmp end_clicked

				final:
					make_text_macro 'C', area, 230, 625
					make_text_macro 'O', area, 240, 625
					make_text_macro 'N', area, 250, 625
					make_text_macro 'G', area, 260, 625
					make_text_macro 'R', area, 270, 625
					make_text_macro 'A', area, 280, 625
					make_text_macro 'T', area, 290, 625
					make_text_macro 'S', area, 300, 625
					jmp afisare_litere

			end_clicked:
            add ecx, 40
            add ebx, 4
            inc edi
            cmp edi, 13
            jz end_column_loop
            jmp column_loop

        end_column_loop:
            mov ecx, 25
            add edx, 40
            mov edi, -1
            sub ebx, 4
            add eax, 4
            cmp eax, 56
            jz end_row_loop
            jmp row_loop
			
	end_row_loop:
	
		
evt_timer:
	inc counter
	
	
afisare_litere:

	line_horizontal line_x, line_y, line_size, 0
	line_horizontal line_x, line_y+40, line_size, 0
	line_horizontal line_x, line_y+80, line_size, 0
	line_horizontal line_x, line_y+120, line_size, 0
	line_horizontal line_x, line_y+160, line_size, 0
	line_horizontal line_x, line_y+200, line_size, 0
	line_horizontal line_x, line_y+240, line_size, 0
	line_horizontal line_x, line_y+280, line_size, 0
	line_horizontal line_x, line_y+320, line_size, 0
	line_horizontal line_x, line_y+360, line_size, 0
	line_horizontal line_x, line_y+400, line_size, 0
	line_horizontal line_x, line_y+440, line_size, 0
	line_horizontal line_x, line_y+480, line_size, 0
	line_horizontal line_x, line_y+520, line_size, 0
	line_horizontal line_x, line_y+560, line_size, 0
	
	line_vertical line_x, line_y, line_size, 0
	line_vertical line_x+40, line_y, line_size, 0
	line_vertical line_x+80, line_y, line_size, 0
	line_vertical line_x+120, line_y, line_size, 0
	line_vertical line_x+160, line_y, line_size, 0
	line_vertical line_x+200, line_y, line_size, 0
	line_vertical line_x+240, line_y, line_size, 0
	line_vertical line_x+280, line_y, line_size, 0
	line_vertical line_x+320, line_y, line_size, 0
	line_vertical line_x+360, line_y, line_size, 0
	line_vertical line_x+400, line_y, line_size, 0
	line_vertical line_x+440, line_y, line_size, 0
	line_vertical line_x+480, line_y, line_size, 0
	line_vertical line_x+520, line_y, line_size, 0
	line_vertical line_x+560, line_y, line_size, 0
	
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start