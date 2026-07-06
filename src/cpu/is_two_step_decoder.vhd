-- Two-step instruction decoder
-- (Use directly if is_two_step is of type boolean)

is_two_step <=
       (virtual_instruction = "00000") or -- ADD
       (virtual_instruction = "00001") or -- SUB
       (virtual_instruction = "00010") or -- INC
       (virtual_instruction = "00011") or -- DEC
       (virtual_instruction = "00101") or -- AND
       (virtual_instruction = "00110") or -- OR
       (virtual_instruction = "00111") or -- NOT
       (virtual_instruction = "01000") or -- XOR
       (virtual_instruction = "01001") or -- ROL
       (virtual_instruction = "01010") or -- ROR
       (virtual_instruction = "01011") or -- LSL
       (virtual_instruction = "01100") or -- LSR
       (virtual_instruction = "01101") or -- PUSH
       (virtual_instruction = "01110") or -- POP
       (virtual_instruction = "10000") or -- LD
       (virtual_instruction = "10001");   -- LDR
