bits 32  
key equ 60h  

%define CR_ALLOWED  ;if carriage-return not acceptable, then comment out but costs 3 bytes  

_decoder:  
        push    (key << 18h) + (key << 10h) + (key << 8) + key  
        pop     ebx  
        sub     [esi + 00h + b64decode - _decoder], bx  
        sub     [esi + 00h + b64decode - _decoder], bl  
        sub     [esi + 06h + b64decode - _decoder], bx  
%ifndef CR_ALLOWED  
        sub     [esi + 07h + b64decode - _decoder], bl  
%endif  
        sub     [esi + 09h + b64decode - _decoder], bx  
        sub     [esi + 0fh + b64decode - _decoder], ebx  
        sub     [esi + 11h + b64decode - _decoder], bl  
        sub     [esi + 13h + b64decode - _decoder], ebx  
        sub     [esi + 1ah + b64decode - _decoder], bl  
        sub     [esi + 1eh + b64decode - _decoder], bl  
        sub     [esi + 20h + b64decode - _decoder], bl  
        sub     [esi + 22h + b64decode - _decoder], ebx  
        sub     [esi + 24h + b64decode - _decoder], bl  
        sub     [esi + 27h + b64decode - _decoder], ebx  
        sub     [esi + 29h + b64decode - _decoder], bl  
        sub     [esi + 2bh + b64decode - _decoder], bl  
        sub     [esi + 2ch + b64decode - _decoder], bx  
        sub     [esi + 2ch + b64decode - _decoder], bx  

b64decode:  
        ;add    esi, b64decode_end - _decoder  
        db      (83h + key + key) & 0ffh, (0c6h + 1 + key) & 0ffh, b64decode_end - _decoder  
        push    esi  
        pop     edi  

b64_outer:  
        ;push   04  
        db      6ah, (04h + key) & 0ffh  
        ;lodsd  
%ifndef CR_ALLOWED  
        db      (0adh + key + key) & 0ffh  
%else  
        db      (0adh + key) & 0ffh  
%endif  
        pop     ecx  

b64_inner:  
        ;rol    eax, 28h ;we want 8, CPU performs &1fh, so we can encode as ASCII to avoid decoding  
        db      (0c1h + key) & 0ffh, (0c0h + 1 + key) & 0ffh, 28h  
        cmp     al, '0'  
        ;jnb    b64_testchar  
        db      73h, (05h + key) & 0ffh  
        ;add    al, (('/' shl 2) + 1) & 0ffh  
        db      (04h + key) & 0ffh, (0bdh + key + key) & 0ffh  
        ;shr    al, 2 ;because '+' and '/' differ by only 1 bit  
        db      (0c0h + key) & 0ffh, (0e8h + key) & 0ffh, (02h + 1 + key) & 0ffh  

b64_testchar:  
        ;add    al, 4  
        db      (04h + key) & 0ffh, (04h + key) & 0ffh  
        cmp     al, 3fh  
        ;jbe    b64_store  
        db      76h, (08h + key) & 0ffh  
        sub     al, 45h  
        ;cmp    al, 19h  
        db      3Ch, (19h + key) & 0ffh  
        ;jbe    b64_store  
        db      76h, (02h + key) & 0ffh  
        ;sub    al, 6  
        db      2Ch, (06h + key) & 0ffh  

b64_store:  
        ;shrd   ebx, eax, 26h  
        ;again, we want 6, CPU performs &1fh, so we can encode as ASCII to avoid decoding  
        db      (0fh + key) & 0ffh, (0ach + key + key) & 0ffh, (0c3h + key) & 0ffh, 26h  
        ;loop   b64_inner  
        db      (0e2h + key) & 0ffh, (0e0h + 1 + key) & 0ffh  
        ;xchg   ebx, eax  
        db      (93h + 1 + key + key) & 0ffh  
        ;bswap  eax  
        db      (0fh + 1 + key) & 0ffh, (0c8h + key) & 0ffh  
        ;stosd  
        db      (0abh + key + key) & 0ffh  
        ;cmp    byte [esi], '+'  
        db      (80h + 1 + key + key) & 0ffh, 3eh, 2bh  
        ;[dec   edi]  
        ;[jnb   b64_outer]  
        ;the dec and branch are base64-encoded to reduce size  

b64decode_end:  
        db      "T3PS" 
