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
        ;jnb    b64_testchar
;0f
        db      73h, (05h + key1) & 0ffh
        ;add    al, (('/' shl 2) + 1) & 0ffh
;11
        db      (04h + key2) & 0ffh, (0bdh + key3 + key1) & 0ffh
        ;shr    al, 2 ;because '+' and '/' differ by only 1 bit
;12, 13
        db      (0c0h + key4) & 0ffh, (0e8h + key1) & 0ffh, (02h + 1 + key2) & 0ffh

b64_testchar:
        ;add    al, 4
        db      (04h + key3) & 0ffh, (04h + key4) & 0ffh
        cmp     al, 3fh
        ;jbe    b64_store
;1a
        db      76h, (08h + key1) & 0ffh
        sub     al, 45h
        ;cmp    al, 19h
;1e
        db      3Ch, (19h + key1) & 0ffh
        ;jbe    b64_store
;20
        db      76h, (02h + key1) & 0ffh
        ;sub    al, 6
;22
        db      2Ch, (06h + key1) & 0ffh

b64_store:
        ;shrd   ebx, eax, 26h
        ;again, we want 6, CPU performs &1fh, so we can encode as ASCII to avoid decoding
;24
        db      (0fh + key2) & 0ffh, (0ach + key3 + key1) & 0ffh, (0c3h + key4) & 0ffh, 26h
        ;loop   b64_inner
;27
        db      (0e2h + key1) & 0ffh, (0e0h + 1 + key2) & 0ffh
        ;xchg   ebx, eax
;29
        db      (93h + 1 + key3 + key1) & 0ffh
        ;bswap  eax
;2b
        db      (0fh + 1 + key4) & 0ffh, (0c8h + key1) & 0ffh
        ;stosd
;2c
        db      (0abh + key1 + key1) & 0ffh
        ;cmp    byte [esi], '+'
        db      (80h + 1 + key2 + key2) & 0ffh, 3eh, 2bh
        ;[dec   edi]
        ;[jnb   b64_outer]
        ;the dec and branch are base64-encoded to reduce size

b64decode_end:
        db      "T3PS" 
        ;append your base64 data here
        ;terminate with printable character less than '+'
