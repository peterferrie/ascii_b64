bits 32
;is there a key set which requires fewer operations?
key1 equ 60h
key2 equ 60h
key3 equ 60h
key4 equ 60h

;No GetPC(), requires ESI=EIP
%define CR_ALLOWED  ;if carriage-return not acceptable, then comment out but costs 3 bytes

_decoder:
        push    (key4 << 18h) + (key3 << 10h) + (key2 << 8) + key1
        pop     ebx
        sub     [esi + 00h + b64decode - _decoder], bx
        sub     [esi + 00h + b64decode - _decoder], bl
        sub     [esi + 06h + b64decode - _decoder], bx
%ifndef CR_ALLOWED
        sub     [esi + 07h + b64decode - _decoder], bl
%endif
        sub     [esi + 09h + b64decode - _decoder], bx
        sub     [esi + 0fh + b64decode - _decoder], ebx
        sub     [esi + 18h + b64decode - _decoder], bx
        sub     [esi + 1eh + b64decode - _decoder], bl
        sub     [esi + 20h + b64decode - _decoder], bl
        sub     [esi + 23h + b64decode - _decoder], ebx
        sub     [esi + 24h + b64decode - _decoder], bl
        sub     [esi + 27h + b64decode - _decoder], ebx
        sub     [esi + 2bh + b64decode - _decoder], ebx
        sub     [esi + 2bh + b64decode - _decoder], ebx

b64decode:
        ;add    esi, b64decode_end - _decoder
;00
        db      (83h + key1 + key1) & 0ffh, (0c6h + 1 + key2) & 0ffh, b64decode_end - _decoder
        push    esi
        pop     edi

b64_outer:
        ;push   04
;06
        db      6ah, (04h + key1) & 0ffh
        ;lodsd
;07
%ifndef CR_ALLOWED
        db      (0adh + key2 + key1) & 0ffh
%else
        db      (0adh + key2) & 0ffh
%endif
        pop     ecx

b64_inner:
        ;rol    eax, 28h ;we want 8, CPU performs &1fh, so we can encode as ASCII to avoid decoding
;09
        db      (0c1h + key1) & 0ffh, (0c0h + 1 + key2) & 0ffh, 28h
        cmp     al, '0'
        ;jnb    b64_testupr
;0f
        db      73h, (05h + key1) & 0ffh
        ;shr    al, 2 ;because '+' and '/' differ by only 1 bit
        db      (0c0h + key2) & 0ffh, (0e8h + 1 + key3) & 0ffh, (02h + 1 + key4) & 0ffh
        xor     al, '0' ;concatenate numbers and '+' and '/'
b64_testupr:
        cmp     al, 'A'
        ;jnb    b64_testlwr
;18
        db      73h, (02h + key1) & 0ffh
        ;add    al, ('z' + 1) - '0' ;concatenate lowercase and numbers
        db      (04h + key1) & 0ffh, ('z' + 1) - '0'
b64_testlwr:
        cmp     al, 'a'
;1e
        ;jb     b64_store
        db      72h, (02h + key1) & 0ffh
        ;sub    al, 6 ;concatenate uppercase and lowercase
;20
        db      2Ch, (06h + key1) & 0ffh
b64_store:
        sub     al, 'A'
        ;shrd   ebx, eax, 6
;23, 24
        db      (0fh + key1) & 0ffh, (0ach + key1 + key2) & 0ffh, (0c3h + key3) & 0ffh, (06h + 1 + key4) & 0ffh
        ;loop   b64_inner
;27
        db      (0e2h + key1) & 0ffh, (0e0h + 1 + key2) & 0ffh
        ;bswap  eax
        db      (0fh + 1 + key3) & 0ffh, (0cbh + key4) & 0ffh
;2b
        ;nop ;alignment
        db      (90h + key1 + key1) & 0ffh
        ;xchg   ebx, eax
        db      (93h + 1 + key2 + key2) & 0ffh
        ;stosd
        db      (0abh + 1 + key3 + key3) & 0ffh
        ;cmp    byte [esi], '+'
        db      (80h + 1 + key4 + key4) & 0ffh, 3eh, 2bh
        ;[dec   edi]
        ;[jnb   b64_outer]
        ;the dec and branch are base64-encoded to reduce size

b64decode_end:
        db      "T3PR" 
        ;append your base64 data here
        ;terminate with printable character less than '+'
