.globl _start
.section .text.init
_start:
trap_vec_init:
  la x13, other_exp
  csrw 0x305, x13 # MTVEC
  la x13, other_exp_s
  csrw 0x105, x13 # STVEC
mepc_setup:
  la x13, init
  csrw 0x341, x13
init_env:
  li x26, 0x0000000a001c2920
  csrw 0x300, x26 # MSTATUS (MPP=1)
  li x16, -0x1
  csrw 0x3b0, x16 # pmpaddr0 = all 1s (NAPOT full coverage)
  li x16, 0x1f
  csrw 0x3a0, x16 # pmpcfg0: entry 0 = NAPOT+RWX
  li x16, 0x0
  csrw 0x3a2, x16 # pmpcfg2 = 0 (disable entries 8-15)
  sfence.vma x0, x0
  li x26, 0x0
  csrw 0x302, x26 # MEDELEG - no delegation to S-mode
  csrw 0x303, x26 # MIDELEG - no delegation to S-mode
  csrw 0x304, x26 # MIE
  csrw 0x340, x26 # MSCRATCH - init to 0 for cosim sync
  csrw 0x343, x26 # MTVAL - init to 0 for cosim sync
  csrw 0x342, x26 # MCAUSE - init to 0 for cosim sync
  csrw 0x140, x26 # SSCRATCH - init to 0 for cosim sync
  csrw 0x143, x26 # STVAL - init to 0 for cosim sync
  csrw 0x142, x26 # SCAUSE - init to 0 for cosim sync
  csrw 0x141, x26 # SEPC - init to 0 for cosim sync
  mret
init:
  fsrmi 0
  csrwi fflags, 0
  li x1, 0xf36e6d3cd07743a7
  li x2, 0xc6462325ff58c155
  li x3, 0x38604a783f209981
  li x4, 0xac11cde4c0a433fe
  li x5, 0x4f7168fae590a6f1
  li x6, 0x4e8902cc98dc730c
  li x7, 0x792720f78f7b2ab1
  li x8, 0x48bca8b028723763
  li x9, 0xa7b43f853716f6e1
  li x10, 0x3027c83d01bb3d95
  li x11, 0xaecf0bd6b9b6adf6
  li x12, 0x568e142202a50f9f
  li x13, 0xe7e45fd25998db2c
  li x14, 0xa236b1cf90fbdc86
  li x15, 0x4fef7fe9b8813f22
  li x16, 0x8b551e37cf542faf
  li x17, 0xa7c8f61606e6015a
  li x18, 0x6ec3a9dee38fba51
  li x19, 0x98b0848906fe0a27
  li x20, 0xa7fb8a6644dfa4ee
  li x21, 0xf0f8f31ce0ede037
  li x22, 0x4c0bc773a3e2d2d5
  li x23, 0xdf9e4095e36a63d7
  li x24, 0xfc08ce664c4c2e3f
  li x25, 0xe3f1c48df63b4347
  li x26, 0x2232b84dabd09412
  li x27, 0x6ff34680123aa968
  li x28, 0x60e97baae6679520
  li x29, 0xa488047c81b039f1
  li x30, 0xec92527fe642ef33
  li x31, 0x625f1594bbdd3872
  li x5, 0x2eadc619f285f133
  fmv.d.x f0, x5
  li x5, 0x0dcc4973de544433
  fmv.d.x f1, x5
  li x5, 0xb9ca8af9be0db7bc
  fmv.w.x f2, x5
  li x5, 0xe4d237d61794e4eb
  fmv.d.x f3, x5
  li x5, 0x7b126347f4a6a2fb
  fmv.w.x f4, x5
  li x5, 0x98f1bbdd3bde72e9
  fmv.w.x f5, x5
  li x5, 0xa9c0bfff1d86dda8
  fmv.w.x f6, x5
  li x5, 0x1196e10e13dc9e94
  fmv.w.x f7, x5
  li x5, 0x6fbf0f33da21382d
  fmv.w.x f8, x5
  li x5, 0xf795558d6b5932d8
  fmv.w.x f9, x5
  li x5, 0x5a622c0077a5f98f
  fmv.d.x f10, x5
  li x5, 0x514276493662e5fe
  fmv.w.x f11, x5
  li x5, 0xbfc4ee7ed09088c0
  fmv.w.x f12, x5
  li x5, 0xdfe5af6cff150c64
  fmv.w.x f13, x5
  li x5, 0x187ef91fa04351d4
  fmv.d.x f14, x5
  li x5, 0x676c7d11bc59b4f9
  fmv.d.x f15, x5
  li x5, 0x66334f1d1a1862fd
  fmv.w.x f16, x5
  li x5, 0x47376ba7c59937de
  fmv.d.x f17, x5
  li x5, 0x5a5a8f49dcb9ab84
  fmv.w.x f18, x5
  li x5, 0x93133ec3ab18ab01
  fmv.w.x f19, x5
  li x5, 0x0c84e7900184bd95
  fmv.w.x f20, x5
  li x5, 0xf0cb728037547628
  fmv.w.x f21, x5
  li x5, 0x4fa7c5cfcbcc8801
  fmv.w.x f22, x5
  li x5, 0x506ac2aa710a641e
  fmv.w.x f23, x5
  li x5, 0xee744c42fa33f1d4
  fmv.d.x f24, x5
  li x5, 0x3695ae0b81abe447
  fmv.w.x f25, x5
  li x5, 0xda11ced6ec425940
  fmv.w.x f26, x5
  li x5, 0xb9cc6a3735208938
  fmv.d.x f27, x5
  li x5, 0x1bdf2bf4b174fd8f
  fmv.d.x f28, x5
  li x5, 0xacdd214091db60f0
  fmv.w.x f29, x5
  li x5, 0xd07923ddcdc74594
  fmv.w.x f30, x5
  li x5, 0x2531120ee5b7d240
  fmv.w.x f31, x5
  la t6, mem_region
  li t5, 4096
  add t6, t6, t5
  j main
.align 12
other_exp:
.option norvc
  csrr x14, 0x342
  blt x14, x0, m_handle_interrupt_rocket
  csrr x13, 0x341
  addi x13, x13, 4
  csrw 0x341, x13
  mret
m_handle_interrupt_rocket:
  li x15, 0
  csrw 0x304, x15
  csrr x13, 0x300
  li x15, -9
  and x13, x13, x15
  csrw 0x300, x13
  mret
.option rvc
other_exp_s:
.option norvc
  csrr x14, 0x142
  blt x14, x0, s_handle_interrupt_rocket
  csrr x13, 0x141
  addi x13, x13, 4
  csrw 0x141, x13
  sret
s_handle_interrupt_rocket:
  li x15, 0
  csrw 0x104, x15
  csrr x13, 0x100
  li x15, -3
  and x13, x13, x15
  csrw 0x100, x13
  sret
.option rvc
.align 2
.option norvc
main:
  and s2, s2, s11
  div a1, s2, a1
  fcvt.s.l fs7, a1, dyn
  flw ft1, -428(t6)
  sltiu s0, a1, -1
  fsw fs7, -1036(t6)
  fcvt.s.lu ft8, s0, dyn
  fmadd.d ft2, ft1, ft1, ft1, dyn
  mul t4, s0, t1
  sc.d.rl s11, t4, (t6)
  fcvt.s.lu fa1, a1, dyn
  div s6, t4, a3
  fsw fs11, -116(t6)
  amoswap.w.aqrl s10, t2, (t6)
  fsw ft10, 140(t6)
  amomin.w.aq s0, t2, (t6)
  sllw tp, a6, a6
  remu zero, t0, s0
  amoxor.w a4, tp, (t6)
  fld fs4, -856(t6)
  remuw s11, tp, sp
  fmin.d fs9, fa1, fs4
  fmv.x.d s6, fa3
  fsd fa2, 312(t6)
  remuw a3, s6, zero
  fmv.x.d a6, ft11
  remu s7, s1, a6
  amoor.d.rl s4, a3, (t6)
  fcvt.l.s ra, fs9, dyn
  remu t2, s5, a6
  fcvt.lu.d s0, fs0, dyn
  amoor.w a0, s7, (t6)
  amoswap.d.aq gp, s0, (t6)
  sc.d t1, t2, (t6)
  amoadd.w.aqrl a1, a0, (t6)
  fcvt.d.lu fa7, tp, dyn
  fcvt.lu.d a6, fa7, dyn
  fcvt.d.l ft3, a1, dyn
  amomaxu.w.rl tp, tp, (t6)
  amomax.d.rl a2, a6, (t6)
  amomaxu.d.aqrl s3, a5, (t6)
  fadd.d fs2, fs11, fs11, dyn
  bge a0, t1, . + 16
  flw fs3, 524(t6)
  sraw s6, t3, a2
  fmv.x.d s10, fs4
  fwd_0:
  remuw s0, a2, tp
  mulhu ra, s3, s11
  fnmadd.d fs7, fs10, fs3, ft0, dyn
  srli s6, s6, 0
  amomin.w.rl a3, s10, (t6)
  divw sp, s6, ra
  amomaxu.w.rl s11, s2, (t6)
  fsw fa3, -64(t6)
  amoadd.d.aq t4, s2, (t6)
  srli t1, sp, 1
  fcvt.lu.d a4, fa5, dyn
  divuw s11, ra, sp
  fclass.d s7, fs10
  fsw fs5, -1872(t6)
  divw ra, sp, sp
  amomaxu.w a2, a5, (t6)
  fcvt.l.s s5, fa3, dyn
  sllw s8, a2, ra
  amomaxu.d.rl tp, a2, (t6)
  sc.d.aq a1, s5, (t6)
  or a0, s0, s5
  amoswap.w.rl s1, s1, (t6)
  remu s6, s2, s6
  fmv.d.x fs0, s6
  xor s11, s2, s0
  srai t2, t2, 0
  remuw zero, t2, s11
  slti s0, t2, 0
  mulhsu a1, zero, s11
  fcvt.d.lu ft11, s0, dyn
  fsw ft8, 788(t6)
  div t0, t0, a1
  fcvt.lu.s a7, fa3, dyn
  flt.d a5, fs10, fs0
  fcvt.d.l ft7, t3, dyn
  slt a4, s7, a4
  amoand.w.aqrl s5, tp, (t6)
  sh a7, 82(t6)
  amomax.d a0, s5, (t6)
  fcvt.l.d s4, ft11, dyn
  auipc a4, 0
  addi a4, a4, 44
  jalr ra, 0(a4)
  remu a6, tp, s5
  sc.d.aq s1, s1, (t6)
  divuw a3, s1, s1
  fcvt.s.l ft1, a3, dyn
  fmv.d.x ft4, a3
  flw fs10, -1024(t6)
  flw fs11, -1752(t6)
  nop
  fwd_1:
  fcvt.l.s t4, ft4, dyn
  bgeu s6, a6, . + 16
  fsgnj.d fa1, fa1, ft1
  or t1, a4, a3
  mulw s4, t1, a0
  fwd_2:
  fcvt.d.l fa2, s1, dyn
  srai s6, t1, 22
  lhu a2, -74(t6)
  bltu s6, a2, . + 32
  mulhsu a5, a4, a2
  fcvt.d.l fa3, a2, dyn
  fmul.d fs1, fs11, fs11, dyn
  lhu s8, -42(t6)
  fcvt.s.lu ft0, t1, dyn
  flw ft11, -64(t6)
  flw ft8, 668(t6)
  fwd_3:
  mulhu s3, s6, s3
  divuw s9, s8, s9
  amomin.w s4, s3, (t6)
  amoadd.w.aqrl s5, zero, (t6)
  slli sp, sp, 0
  remuw s1, s3, sp
  remw a4, a4, sp
  remu zero, s10, s5
  amomin.d.aqrl a2, a4, (t6)
  divw a4, zero, a2
  fcvt.lu.d s6, fs1, dyn
  fmsub.d fa7, fa6, fa3, fs1, dyn
  fmadd.d fa0, fa0, ft11, fa7, dyn
  amoadd.d.aq s2, s1, (t6)
  amoand.w.aq a0, a0, (t6)
  fcvt.d.lu fs4, s1, dyn
  amoand.w.aq ra, s1, (t6)
  fcvt.l.s s11, ft10, dyn
  sc.w.aqrl zero, ra, (t6)
  fsqrt.d fs4, fa3, dyn
  subw a2, s11, zero
  fcvt.l.d sp, fa6, dyn
  amoadd.w s7, zero, (t6)
  remw s3, s3, sp
  divuw s9, a2, s7
  div s1, sp, sp
  fcvt.d.l ft6, s3, dyn
  fsw fa6, 732(t6)
  fcvt.d.lu ft4, s9, dyn
  amominu.d.aq s8, sp, (t6)
  amominu.d.rl s11, a0, (t6)
  fsw ft4, -1216(t6)
  sc.w s1, s1, (t6)
  divuw s4, s8, s4
  lui a7, 869096
  amomax.d.rl t1, s5, (t6)
  sllw a5, a7, s6
  fcvt.s.l ft2, ra, dyn
  fcvt.lu.s tp, ft7, dyn
  fcvt.d.l ft3, t2, dyn
  divu zero, a6, tp
  subw a1, t2, a6
  fcvt.s.l fs5, t2, dyn
  subw s7, s2, s8
  divuw s10, tp, s7
  sraw s3, zero, tp
  fcvt.s.lu fs4, a1, dyn
  fcvt.l.s t0, ft3, dyn
  fsqrt.d fs0, ft7, dyn
  amoxor.d.aqrl a5, s3, (t6)
  rem t3, a5, a5
  remw s10, s3, s7
  fcvt.l.s ra, fs0, dyn
  fcvt.s.lu fa3, a5, dyn
  fmv.x.d a3, fs4
  srli s11, s11, 0
  div zero, s11, a4
  fmv.x.d t1, ft5
  sw t0, 1292(t6)
  remw s8, a4, s11
  fsgnjn.d fa4, ft3, ft2
  sllw s10, s8, a3
  amoswap.w ra, s2, (t6)
  fcvt.d.w fa7, s5
  flt.d a6, ft8, fa3
  divuw t3, t2, s1
  mul a0, a0, t3
  amoand.w a7, a0, (t6)
  divuw a2, a0, t1
  fcvt.d.l ft6, s0, dyn
  fcvt.s.l fs4, s6, dyn
  fcvt.lu.s s8, fs4, dyn
  remu t0, t0, s8
  sltiu t2, a0, -2048
  slliw t3, t3, 10
  lr.d s5, (t6)
  fcvt.s.l ft5, t3, dyn
  fcvt.d.l fs11, t3, dyn
  amominu.w tp, s4, (t6)
  feq.d s4, fs8, ft10
  amominu.w.aq s11, t2, (t6)
  divw t2, s3, a3
  sb tp, 1131(t6)
  fcvt.lu.s s7, fs8, dyn
  mulw s5, a1, s7
  amoswap.d.aq a6, s5, (t6)
  mul s2, a3, gp
  fsw fs8, -728(t6)
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
.4byte 0x0000006b
.option rvc
write_tohost:
  la t1, tohost
  li t2, 0x1
  sw t2, 0(t1)
_exit:
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  j _exit
debug_rom:
  dret
debug_exception:
  dret
instr_end:
  nop
.section .data
.align 6
.global tohost
tohost:
.dword 0x0
.align 6
.global fromhost
fromhost:
.dword 0x0
.section .region_0, "aw", @progbits
region_0:
.word 0x1d0a8997, 0x1d082175, 0x8ad2ebc3, 0x40e60df2, 0xd1505b32, 0x1b05d548, 0xb01e8bea, 0x3bbbce24
.section .mem_region, "aw", @progbits
.align 4
mem_region:
.word 0x912b5f0c, 0xfb6249bd, 0xd0c47310, 0xa3d28c34, 0xdb897bf6, 0x3a7841e6, 0x19d49627, 0x71a5bdb8
.word 0x986fe6c3, 0xb5de23d0, 0xc43c9374, 0x7e442115, 0xb394a1c6, 0x7ae17238, 0xa10942a9, 0xc0163454
.word 0x3e2f616e, 0xb9f3d4de, 0x41c21e8e, 0x047f31ec, 0x69906b44, 0xd0627362, 0x1c4c6cd3, 0xc79c4c71
.word 0xb38597f3, 0xc6f4d9c2, 0x1868f8e9, 0xf50c06eb, 0xa73b5fbb, 0xdd95e2aa, 0x35efd959, 0xf71214e2
.word 0xf3e401ce, 0x548c8fdc, 0xa438509f, 0xd35be286, 0xba3aafbf, 0xb9c5cdd5, 0xc62b36da, 0x9f1047fe
.word 0x560cff47, 0xa00c97f2, 0x218c2b7f, 0x88281297, 0x03c484b0, 0x31cd53b2, 0x11cd548f, 0xd14698e0
.word 0x1ed62a04, 0x6672dee7, 0x31e4dfef, 0xdcbc0dee, 0x6d20bbe8, 0x0c316be8, 0x5177e132, 0xe1c199f4
.word 0x953331d9, 0xe08e0c39, 0xab71e986, 0x6a35005f, 0x70fbee30, 0xc87905a4, 0xc0848780, 0x5fdbd340
.word 0x8778fe70, 0xc25802dc, 0xe0c28620, 0x0233d356, 0xe97b7908, 0xb61bf2f4, 0x803f869b, 0xf4d3f5ad
.word 0x60f29dc1, 0xa0cab1d6, 0xc517f497, 0xeb5fe889, 0x799f8988, 0xfcc98490, 0x07cac765, 0x9afae820
.word 0x8eb6aab1, 0x536bcb86, 0xe0edc1cd, 0x59965809, 0x95972345, 0x942b6268, 0x8dc41f82, 0x25b2c41a
.word 0x95c05cbe, 0xff7240c9, 0x613c826f, 0xab27138b, 0xf2d6278a, 0x6978f4a9, 0xee261166, 0x1c3701e9
.word 0x5c90285d, 0x9112e2d9, 0x682b2581, 0x2e1b116f, 0xa3378036, 0x21c48405, 0xd6ce6ea6, 0xee58de4b
.word 0xe82a5481, 0x55bd792d, 0x82e2e761, 0xa2e7eb14, 0xcdffa1bf, 0xe8ff53ec, 0x254aa968, 0x44e1bdab
.word 0x0f2a606d, 0x15efe95f, 0x454a10e0, 0xc5a6d3a8, 0xe1129aff, 0xe2840fa2, 0x60e36eae, 0x5ff9b5dd
.word 0x086c0718, 0xc06f654b, 0xa00767e8, 0x735b29e7, 0x525a0846, 0x786c5c48, 0x167067a5, 0xec52c27a
.word 0x3a4954fe, 0xc560465b, 0xb83822ff, 0x02e6ea74, 0xd677ad63, 0x65f1bfaf, 0x534cbc16, 0x9b6ff01f
.word 0xeb3bb408, 0x9cad2724, 0x3454aaa7, 0x77178a2f, 0xe92d0512, 0x22fe54e0, 0x74703add, 0x4a49b496
.word 0xd7a1103f, 0x72ef3caf, 0x56bb9f2a, 0x9daf57e5, 0xb7e6f9fa, 0x7e346348, 0x3f948217, 0xf8b8507b
.word 0x5cf9bd0f, 0xc94cc724, 0x45e40f45, 0x143dc4a1, 0xb2701c68, 0x06d30af2, 0x2a54535a, 0x6636db84
.word 0xa35d3f24, 0x50012f69, 0xaca94162, 0xb162cce2, 0xaae83bca, 0x243bc0c2, 0xf8926c4d, 0xff1f9a64
.word 0xcf47a9ab, 0x3dbace40, 0x0e51d913, 0x9c0982c2, 0xfffbb66c, 0x2fbeeb49, 0x15d289e2, 0x62c64277
.word 0x6641e935, 0x506a80f3, 0x4e88bf0e, 0x3e6c01d9, 0xd02e2a52, 0xb18197bf, 0x2d378701, 0x39bc11a2
.word 0x4d10f12a, 0x2bd6fda5, 0x7b28ac43, 0x46b3ea79, 0x3efda6f5, 0x0bfec1ad, 0xdfeaf391, 0x7eb24e92
.word 0x2ee78005, 0x4526a668, 0xa7920888, 0x8d27c686, 0x27eb1a98, 0x2f6d1e2a, 0xaf730660, 0xa8e8a485
.word 0xad2d24fd, 0x36899371, 0x213bd0ae, 0x3021a890, 0xe64f9550, 0x49cf5f21, 0xe83634fe, 0x3df84c31
.word 0x23e73abf, 0xf0380fcb, 0x755cf1ee, 0x1101e99e, 0xb4ba480c, 0xd684fadf, 0xf009ca34, 0xb699a72f
.word 0x12c7d10f, 0x074a6500, 0xee93f4f5, 0x9c9c888e, 0x63f76a58, 0x8fa1e2d8, 0xdcb01e6a, 0x91756e62
.word 0x1ba1b4df, 0x350e589b, 0x5b0b7c16, 0xa8021cec, 0xb18a5ef2, 0x88c4422e, 0x719a7ce4, 0x8e73cf18
.word 0x26150e28, 0x1316b585, 0x72dd9da9, 0x4a5bf71e, 0xce359788, 0x90b57e40, 0xa5ec5c58, 0x1a99b49c
.word 0xee35d981, 0xd1ca402b, 0xc9422dd5, 0x4c17aba8, 0x856912f3, 0x848fe5cb, 0xc9fff2fb, 0xc4a177e1
.word 0x8ab2daff, 0xd5e4547b, 0x7a65e964, 0xb8ca2ee0, 0xace2b7f8, 0x3898f8b2, 0xd02b572a, 0x1896cc56
.zero 7168
mem_region_end:
