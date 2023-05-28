section .bss
    buffer: resb 600
    struct: resd 1
section .data
    state: dw 0xACE1
    biggerSize: db 0
    maxSize: dd 600
    smallerSize: db 0
section .rodata
    mask: dw 0x002D
    lineFeed: db 10, 0
    form: db "%02hhx", 0
    x_struct: db 5
    x_num: db 0xaa, 1, 2, 0x44, 0x4f
    y_struct: db 6
    y_num: db 0xaa, 1, 2, 3, 0x44, 0x4f
    invalidArgument: db "Invalid argument provided - %s", 10, 0
section .text
global main
extern stdin, fgets, malloc, printf, strlen
main:
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]        
    mov ebx, [ebp + 12]       
    cmp eax, 1              
    je noArguments        
checkArguments:
    mov eax, [ebx + 4]     
    cmp word[eax], "-I"    
    je IFlag
    cmp word[eax], "-R"     
    je RFlag   
noArguments:
    push y_struct         
    push x_struct           
    call addMulti          
    push eax                
    call printM      
    add esp, 12            
    pop ebp
    ret                     

RFlag:
    call PRmulti            
    push eax                
    call PRmulti            
    push eax                
    call addMulti          
    push eax                
    call printM        
    add esp, 12          
    pop ebp                
    ret                    

IFlag:
    call getMulti           
    push eax                
    call getMulti          
    push eax                
    call addMulti         
    push eax              
    call printM   
    add esp, 12            
    pop ebp                 
    ret                     

;Task1a
printM:
    push ebp                   
    mov ebp, esp              
    pushad                     
    mov eax, [ebp + 8]           
    mov ebx, 0                
    mov bl, byte[eax]          

printLoop:
    pushad                      
    mov bl, byte[eax + ebx]     
    push ebx                    
    push form                 
    call printf                 
    add esp, 8                  
    popad                       
    dec ebx                     
    cmp ebx, 0
    ja printLoop               

printNewLine:
    push lineFeed              
    call printf                 
    add esp, 4                  

endFunction:
    popad                       
    pop ebp                     
    ret                        


getMulti:
    push ebp                    
    mov ebp, esp              
    pushad                      
    push dword[stdin]           
    push dword[maxSize]         
    push buffer                 
    call fgets                  
    call strlen                 
    add esp, 12                 
    mov edi, eax                
    sub edi, 2                  
    shr eax, 1                  
    add eax, 1                  
    push eax                     
    call malloc                 
    mov dword[struct], eax      
    mov esi, eax                
    pop eax                     
    dec eax                    
    mov byte[esi], al           
    mov ecx, 1                  
scanInput:
    cmp edi, 0                 
    jl scanDone            
    mov ebx, 0                  
    mov bx, word[buffer + edi - 1]
    call parseBx
constByte:
    shl bl, 4                  
    add bl, bh                   

addStructDigit:
    mov byte[esi + ecx], bl   
    sub edi, 2                 
    inc ecx                   
    jmp scanInput            

parseBx:
    cmp edi, 0
    je resetBl
    cmp bl, '9'                 
    jle number                 
    sub bl, 'a'-0xa            
    jmp checkBh

number:
    sub bl, '0'                
    jmp checkBh
resetBl:
    mov bl, 0
checkBh:
    cmp bh, '9'                
    jle numberBh               
    sub bh, 'a'-0xa             
    ret                         

numberBh:
    sub bh, '0'                
    ret                        

scanDone:
    popad                      
    mov eax, dword[struct]     
    pop ebp                     
    ret                         


;task2a
MaxMin:
    movzx ecx, byte[eax]            
    movzx edx, byte[ebx]           
    cmp ecx, edx                   
    jae no_swap                    
    mov ecx, eax                   
    mov eax, ebx                   
    mov ebx, ecx                   
    no_swap:            
    ret                            

;task2b
addMulti:
    push ebp                   
    mov ebp, esp              
    pushad                     

    mov eax, [ebp + 8]           
    mov ebx, [ebp + 12]          
    call MaxMin                

printStructs:                  
    push eax                    
    call printM            
    add esp, 4                
    push ebx                    
    call printM            
    add esp, 4                  

    mov esi, eax               
    mov edi, ebx               
    movzx eax, byte[esi]       
    add eax, 2                 
    push eax                   
    call malloc                
    mov dword[struct], eax      
    pop ecx                    
    dec ecx                     
    mov byte[eax], cl           
    mov ecx, 0                  
    mov edx, 0                 
appendLoop:
    movzx ebx, byte[esi + edx + 1]
    add ebx, ecx               
    movzx ecx, byte[edi + edx + 1]
    add ebx, ecx                
    mov cl, bh                  
    mov byte[eax + edx + 1], bl 
    inc edx                    
    cmp dl, byte[edi]          
    jne appendLoop            

    cmp dl, byte[esi]           
    je addSkip
appendLoop2:
    movzx ebx, byte[esi + edx + 1]
    add ebx, ecx                
    mov cl, bh                  
    mov byte[eax + edx + 1], bl 
    inc edx
    cmp dl, byte[esi]           
    jne appendLoop2
addSkip:
    mov byte[eax + edx + 1], cl 
    popad                       
    pop ebp                     
    mov eax, dword[struct]      
    ret                        

randomNumber:                       
    push ebp                   
    mov ebp, esp                
    pushad                      

    mov ax, word[state]         
    and ax, [mask]             
    jnp noParity               
parity:
    shr word[state], 1          
    or word[state], 0x80        
    jmp skip                    
noParity:
    shr word[state], 1          

skip:    
    popad                       
    pop ebp                     
    movzx eax, word[state]     
    ret                        

PRmulti:
    push ebp                    
    mov ebp, esp                
    pushad                      
loopUntilNumber:
    call randomNumber               
    cmp al, 0                  
    je loopUntilNumber       

    movzx ebx, al               
    mov esi, ebx                
    add ebx, 1                  
    push ebx                    
    call malloc                
    add esp, 4                  
    mov dword[struct], eax      
    mov ebx, esi                
    mov byte[eax], bl           
    mov esi, eax                
    mov edx, 0                  
    randomLoop:
        call randomNumber         
        mov byte[esi + edx + 1], al 
        inc edx                 
        dec ebx                 
        cmp ebx, 0              
        jnz randomLoop         
    popad                       
    pop ebp                  
    mov eax, [struct]         
    ret                       