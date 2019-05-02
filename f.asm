data segment
	prime_log db 100 dup(?)
	len dw ($-prime_log)
	output_num dw 100 dup(?)
	init_str db 'Figures 1-100 are as follows:',0ah,0dh,'$'
	sieve_str db 'The current sieve is :$'
	sieve_end db 'The algorithm runs out',0ah,0dh,'$'
	ave_prime db 'The average of these primes is :$'
	color db 84h,0dh,05h,01h,0h,04h
	color_choose db ?
	col dw 0
	row db 1
	col_earse dw ?
	row_earse db ?
data ends
stack segment stack
	dw 200(?)
stack ends
code segment
	assume cs:code , ds:data , ss:stack
	main proc far
start:
	mov ax , data
	mov ds , ax
	
	
	mov ax , 03h  ;切换显示器模式
	int 10h
	
	call init 
	call Clear_Screen
	call print_number
	call Sieve_method
	call Average_prime
	
	mov ax , 4c00h
	int 21h
	main endp
;----------------------------------------
;----------------------------------------
	init proc near
	mov cx , 100
	mov di , 1
	mov si , 1
	mov bx , 0
	mov bp , 0
L1:
	mov prime_log[bx] , 1
	mov output_num[bp] , si
	add bp , 2
	inc si
	inc bx
	loop L1
	ret
	init endp
;----------------------------------------
;----------------------------------------
	Clear_Screen proc near   ;调用int 10h中06功能
	push ax 
	push bx 
	push cx
	push dx
	mov ah , 6
	mov al , 0
	mov cx , 0
	mov dh , 24
	mov dl , 79
	mov bh , 07
	int 10h
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	Clear_Screen endp
;-----------------------------------------
;-----------------------------------------
	print_number proc near
	
	lea dx , init_str
	mov ah , 09h
	int 21h
	
	mov dl ,color+1  ;dl用于选择颜色
	mov color_choose , dl
	
	mov cx , len
	mov bp , 0
	mov dx , 0
	
Pri:
	mov ax , output_num[bp]
	call print          ;被输出数字在ax中,颜色在被选中颜色内存中
	inc dx 
	add bp , 2
	cmp dx ,0ah   ;dx计数，如果到10个换行
	jnz pri_2
	inc row
	mov col , 0
	xor dx , dx
pri_2:
	loop Pri
	
	mov dh , row   ;移动光标
	mov dl , byte ptr col
	mov ah , 02h
	int 10h
	
	lea dx , sieve_str
	mov ah , 09h 
	int 21h
	
	ret
	print_number endp
;------------------------------------------
;------------------------------------------
	print proc near  ;先除10压栈，之后int 10h中09号功能调用输出字符，每次输出完自动列数加3
	push cx
	push dx
	push di
	push si
	push bx
	mov si , col
	xor cx , cx
Push_num:       
	xor dx , dx
	mov di, 10
	div di
	or dx , 0930h
	push dx
	inc cx 
	cmp ax , 0
	jnz Push_num
	mov bh , 0
Out_num:
	pop ax
	push cx
	push ax
	mov ah , 02h
	mov dx , si
	mov dh , row
	int 10h
	
	pop ax
	mov bl , color_choose
	mov cx , 1
	int 10h
	inc si
	
	pop cx
	loop Out_num
	add col ,3
	pop bx
	pop si
	pop di
	pop dx
	pop cx
	ret
	print endp
;------------------------------------------
;------------------------------------------
	delay proc near  ;延迟空循环空转
	push cx 
	push bx
	mov bx , 100
wait_1:
	mov cx , 2801
dlay:
	loop dlay
	dec bx
	jnz wait_1
	pop bx
	pop cx
	ret
	delay endp
;------------------------------------------
;------------------------------------------
	Sieve_method proc near
	
	mov ax , 1
	call erase 	;ax中存放想要抹掉的数字
	mov prime_log , 0
	
	mov bx , 2
Si_me:
	cmp prime_log[bx][-1],1
	jnz next_num
	mov dl , 2
	call curr_num  ;将bx中的筛子输出
excute:
		mov ax , bx
		mul dl
		cmp ax , 100
		ja next_num
		mov di , ax
		cmp prime_log[di][-1] , 1  ;如果已经筛过就不重复显示
		jnz no_re
		mov prime_log[di][-1],0
		call erase
no_re:
		mov ax , bx
		inc dl
		jmp excute
next_num:
	call delay
	inc bx
	cmp bx , 101
	je exit
	jmp Si_me

exit:
	mov dh , 12
	mov dl , 0
	mov ah , 02
	mov bh, 0
	int 10h
	lea dx , sieve_end
	mov ah , 09h
	int 21h
	
	ret
	Sieve_method endp
;------------------------------------------
;------------------------------------------
	erase proc near
	push dx
	push di
	push bx
	push ax
	mov bl ,10  ;通过除10判断余数来判断是否为10的倍数，来确定这个数和他行、列的关系
	div bl
	cmp ah , 0
	jnz n_tens
	mov ah , 09h
	jmp print_num
n_tens:
	add al  , 1
	sub ah , 1
print_num:
	xor bh , bh
	mov row , al
	mov bl , ah
	
	mov col , bx
	add col , bx
	add col , bx
	
	mov dh , row
	mov dl ,byte ptr col
	
	mov row_earse , dh
	mov col_earse , dl
	
	mov ah , 02h
	mov bh , 0
	int 10h
	
	mov dl , color
	mov color_choose ,dl
	pop ax
	call print
	call delay
	call delay
	
	mov dh , row_earse ;通过保存的位置，颜色选择黑色制造消失现象
	mov dl , byte ptr col_earse
	
	mov row , dh
	mov col , dl
	
	mov ah ,02h
	mov bh , 0
	int 10h
	
	
	mov dl ,color+4
	mov color_choose,dl
	call print
	
	pop bx
	pop di
	pop dx
	ret
	erase endp
;------------------------------------------
;------------------------------------------
	curr_num proc near ;在特定位置输出数字
	push ax
	push dx
	push bx
	mov row ,11
	mov col ,23
	
	mov ax , bx
	mov dl , color+3
	mov color_choose,dl
	call print
		
	pop bx
	pop dx
	pop ax
	
	ret
	curr_num endp
;-------------------------------------------
;-------------------------------------------
	Average_prime proc near
	lea dx , ave_prime
	mov ah , 09h
	int 21h
	
	mov ax , 0
	mov cx , len
	mov bx , 0
	mov dx , 1
	mov si , 0   ;记录素数个数
ad_sum:
	cmp prime_log[bx] , 1
	jnz nex_pri
	add ax , dx
	inc si
nex_pri:
	inc dx
	add bx , 1
	loop ad_sum
	
	mov dx ,  0
	div si
	
	sub si , dx        ;判断四舍五入
	cmp si , dx
	ja num_4
	add ax , 1
num_4:
	mov row ,13
	mov col ,33
	mov dl , color+5
	mov color_choose, dl
	call print
	
	
	ret
	Average_prime endp
;-------------------------------------------
code ends
end start
