.intel_syntax noprefix


_parse_int:
  xor rdx, rdx
  xor rcx, rcx
_parse_int__again:
  mov cl, [rax]
  inc rax
  cmp cl, 0x30
  jl _parse_int__done
  cmp cl, 0x39
  jg _parse_int__done
  imul rdx, 10
  sub cl, 0x30
  add rdx, rcx
  jmp _parse_int__again
_parse_int__done:
  ret


.globl _main
_main:
  push r13
  push r14
  push rbp
  mov rbp, rsp

  # r13 is the rule, r14 is the array length
  mov r13, 110
  mov r14, 159

  # check if a rule and size are given
  cmp rdi, 2
  jl _main__done_cli_args
  mov rax, [rsi + 8]
  call _parse_int
  mov r13, rdx

  cmp rdi, 3
  jl _main__done_cli_args
  mov rax, [rsi + 16]
  call _parse_int
  mov r14, rdx

_main__done_cli_args:
  # reserve stack space for the array and a null terminator at the end
  lea rdx, [r14 + 16]
  and rdx, 0xFFFFFFFFFFFFFFF0
  sub rsp, rdx

  # write the initial contents of the first array
  xor rax, rax
  xor rdx, rdx
_main__initialize_array__again:
  test rdx, 1
  setnz al
  lea rax, [rax + rax * 2 + 0x20]  # turn 0 into 0x20 (' ') and 1 into 0x23 ('#')
  mov [rsp + rdx], al
  inc rdx
  cmp rdx, r14
  jl _main__initialize_array__again

  # write the null terminator
  mov byte ptr [rsp + r14], 0

  # print the initial string to stdout
  mov rdi, rsp
  call _puts

_main__update_array:
  # load the first cell bit into rax
  xor rcx, rcx
  mov cl, [rsp]
  cmp cl, 0x23
  sete cl

  # loop through all the cells, updating them by shifting through rax
  xor rdx, rdx
_main__update_array__update_cell:
  cmp byte ptr [rsp + rdx + 1], 0x23
  sete dil
  shl rcx, 1
  or cl, dil
  and rcx, 7

  # write the new cell's value
  mov rax, r13
  shr rax, cl
  and rax, 1
  lea rax, [rax + rax * 2 + 0x20]  # turn 0 into 0x20 (' ') and 1 into 0x23 ('#')
  mov [rsp + rdx], al

  # move on to the next cell
  inc rdx
  cmp rdx, r14
  jl _main__update_array__update_cell

  # print the string to stdout
  mov rdi, rsp
  call _puts

  jmp _main__update_array

  # free the string stack space
  lea rdx, [r14 + 16]
  and rdx, 0xFFFFFFFFFFFFFFF0
  add rsp, rdx

  # return 0
  xor rax, rax
  pop rbp
  pop r14
  pop r13
  ret
