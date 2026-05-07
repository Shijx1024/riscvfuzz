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
  li x26, 0x0000000a00672088
  csrw 0x300, x26 # MSTATUS (MPP=0)
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
  li x1, 0x3c5b632e44632aac
  li x2, 0xe8584a7c1fb0fdf6
  li x3, 0x06ee9989877f4051
  li x4, 0x2422e7225a04a7ee
  li x5, 0x062e3578bb781352
  li x6, 0x24eb3e7667d6fbde
  li x7, 0xa45f9ec7b15850bc
  li x8, 0x8d76d619d0ea60f9
  li x9, 0x08758e6b347d6e9f
  li x10, 0xc344051e93e1d800
  li x11, 0x24583169555a9cf5
  li x12, 0x857fb4239645d410
  li x13, 0x65ff8510184c3bde
  li x14, 0x7b81a6e0fc4e3496
  li x15, 0xe48f15c102b3f842
  li x16, 0x56a7631970946262
  li x17, 0xcfce6c4978694636
  li x18, 0xd3f67b9a5ec7180e
  li x19, 0x779608cce707c064
  li x20, 0xf0c53ee81f051e09
  li x21, 0xd534be92a8a465f7
  li x22, 0x53eadff4876d63aa
  li x23, 0x9560a0495a1be884
  li x24, 0x527292219724e37c
  li x25, 0x2c9a4fde8b8fac21
  li x26, 0x25288d7d7e3fb5ee
  li x27, 0x20c809d6ad9c1cf6
  li x28, 0xd7120c2383d32acf
  li x29, 0x9d80968d82e17c86
  li x30, 0xc5058511f5f8445b
  li x31, 0xc2344789eca2fe50
  li x5, 0x62ecdf7c9b3726e7
  fmv.w.x f0, x5
  li x5, 0x220e7420ae255251
  fmv.d.x f1, x5
  li x5, 0x2aae19b77510be4d
  fmv.d.x f2, x5
  li x5, 0x801c1089828e2816
  fmv.w.x f3, x5
  li x5, 0xcd7be73380682adf
  fmv.d.x f4, x5
  li x5, 0xae231ae27629779a
  fmv.w.x f5, x5
  li x5, 0x008b9e0add502c8b
  fmv.w.x f6, x5
  li x5, 0x6bc54bcb8a9cd1a8
  fmv.w.x f7, x5
  li x5, 0xd180ec0bde44def3
  fmv.d.x f8, x5
  li x5, 0xc84371012e04d32d
  fmv.w.x f9, x5
  li x5, 0x0a6c22c83ec3e336
  fmv.w.x f10, x5
  li x5, 0x107122b9a665d265
  fmv.d.x f11, x5
  li x5, 0xeef44e263bc3b8bc
  fmv.w.x f12, x5
  li x5, 0xc707acc4281496ad
  fmv.w.x f13, x5
  li x5, 0x366f02258675f265
  fmv.w.x f14, x5
  li x5, 0x5c8f26f26e9a4dcf
  fmv.w.x f15, x5
  li x5, 0x8029e2822d14eb82
  fmv.d.x f16, x5
  li x5, 0x25f5c701c6a40211
  fmv.d.x f17, x5
  li x5, 0x46e41564ca49e5aa
  fmv.d.x f18, x5
  li x5, 0x77ebb75cef034217
  fmv.w.x f19, x5
  li x5, 0x0c3cb69d445fcc77
  fmv.w.x f20, x5
  li x5, 0x197fdf48c200bb89
  fmv.d.x f21, x5
  li x5, 0x4d944ddb9fb06d9c
  fmv.w.x f22, x5
  li x5, 0x04734ba058c546a4
  fmv.w.x f23, x5
  li x5, 0x2eaaa1b9fd97931a
  fmv.d.x f24, x5
  li x5, 0x91f2f111cd0ee860
  fmv.d.x f25, x5
  li x5, 0x7b92a3016a1be029
  fmv.d.x f26, x5
  li x5, 0x02b0d379f987f70b
  fmv.d.x f27, x5
  li x5, 0x5867725e07661bec
  fmv.w.x f28, x5
  li x5, 0xad342abf2876c71d
  fmv.d.x f29, x5
  li x5, 0xdad26264801f034a
  fmv.d.x f30, x5
  li x5, 0x277b61de75d11063
  fmv.d.x f31, x5
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
  sll a2, a2, s2
  mul s11, s11, s11
  fsub.d ft1, ft1, ft1, dyn
  andi t2, s11, -1
  fcvt.l.s s6, ft8, dyn
  divw s2, t2, a2
  fcvt.s.l fa0, gp, dyn
  mulhsu s4, a1, a1
  amoadd.d.aq t3, t3, (t6)
  divw s8, s4, s8
  divuw t4, s2, a6
  amoadd.w.aqrl s1, t3, (t6)
  srai a2, a2, 44
  li sp, -549755813888
  srlw t0, t0, a6
  amoand.d s6, t4, (t6)
  sraiw a7, a7, 0
  fcvt.l.s ra, fa0, dyn
  amoor.d.rl s11, a7, (t6)
  fdiv.d fs7, ft8, fs7, dyn
  fcvt.d.lu ft3, s6, dyn
  bne s6, s11, . + 24
  mulw s0, s11, s0
  srai s4, s0, 1
  amoadd.w.aq s8, s4, (t6)
  flw ft9, 164(t6)
  mul s3, s4, s4
  fwd_0:
  jal s5, . + 16
  mulhu a1, s0, s4
  amoadd.w.aq t3, sp, (t6)
  fmul.d ft0, ft1, ft9, dyn
  fwd_1:
  fsw ft3, 2036(t6)
  fcvt.l.d zero, fa3, dyn
  fsub.d ft7, ft3, ft3, dyn
  fcvt.lu.s s7, ft3, dyn
  div a7, a7, zero
  lb t4, 1433(t6)
  fcvt.d.l ft4, s0, dyn
  fcvt.d.l ft11, t3, dyn
  mulhsu s6, t4, a3
  fmin.d fa4, fs6, fs8
  fmv.x.d sp, ft0
  amomin.w.rl tp, sp, (t6)
  mulw t0, s6, a1
  sd s0, 1488(t6)
  fnmsub.d fs4, ft11, ft4, ft0, dyn
  lr.d.aq s3, (t6)
  fcvt.lu.d t3, fa4, dyn
  beq t3, t3, . + 36
  fmv.d.x fa2, sp
  sraw s9, tp, sp
  remuw sp, s5, t4
  fcvt.s.lu fs6, t3, dyn
  mulw t2, s9, sp
  mulhsu s5, s5, s3
  ori ra, s11, -486
  divuw s7, sp, ra
  fwd_2:
  fcvt.d.lu ft2, sp, dyn
  rem t1, t2, ra
  subw a6, a6, a6
  mulw a5, s7, t1
  fcvt.d.l ft9, a5, dyn
  mulw s3, ra, s3
  sllw a3, s7, a5
  fcvt.s.l fs6, s5, dyn
  fcvt.lu.s a6, fs2, dyn
  nop
  fcvt.d.lu ft5, s2, dyn
  amoadd.d.aq s6, a5, (t6)
  fcvt.l.d a3, fs0, dyn
  fcvt.w.d tp, fs8, dyn
  fle.d a0, fa0, ft7
  divu sp, a0, a0
  rem a5, a5, a0
  divw s10, s0, a0
  fsub.d fa1, fa1, fs8, dyn
  fcvt.s.lu fa6, s10, dyn
  ori a2, a5, 720
  amoxor.d.aqrl s5, s10, (t6)
  feq.d s9, fs8, fa7
  lr.d.rl a7, (t6)
  fcvt.lu.s t0, fs1, dyn
  mulhu t2, t0, a7
  fcvt.s.l fs11, a2, dyn
  bgeu t0, t0, . + 20
  mulw s10, s9, t2
  lr.d.aqrl s11, (t6)
  fcvt.lu.s a4, ft5, dyn
  mulhsu s2, a4, t0
  fwd_3:
  amoand.w a1, t2, (t6)
  fcvt.wu.d s3, fs11, dyn
  fcvt.d.l fs3, a1, dyn
  fsqrt.d ft6, ft6, dyn
  mul s1, a1, ra
  fmv.d.x ft7, s3
  remu a6, s3, a6
  fsw fa2, -1260(t6)
  fcvt.l.d t4, fs5, dyn
  mulhu s10, a6, t4
  mulhu s4, t4, gp
  sc.d.aqrl a2, t4, (t6)
  fcvt.l.s a4, fs5, dyn
  amoadd.w.rl s3, a2, (t6)
  fcvt.lu.s a7, fa7, dyn
  remu t4, t4, s5
  amoxor.w.aq s0, t4, (t6)
  sraw s11, s3, s11
  sllw s9, s11, a7
  divw gp, s4, s9
  li s11, 2
  bwd_0:
  addw a0, t4, s10
  amomaxu.d.aqrl a7, s9, (t6)
  remu a3, s11, a2
  lr.d.rl ra, (t6)
  fcvt.lu.s s1, ft6, dyn
  flw fa1, 1992(t6)
  sraiw t3, t3, 4
  addi s11, s11, -1
  bne s11, zero, bwd_0
  lbu s8, 922(t6)
  remw t0, s1, t3
  fsw fs11, -16(t6)
  rem a3, sp, a3
  divu t0, ra, t0
  fmsub.d fa4, fs3, fs5, ft7, dyn
  fnmsub.d ft11, ft6, fa1, ft7, dyn
  xori a2, sp, 1562
  fcvt.s.lu fa3, a2, dyn
  remw s2, s7, sp
  amomaxu.d.aqrl t1, a2, (t6)
  mulw tp, a4, a2
  lui zero, 958101
  amomax.w.aq t2, zero, (t6)
  fcvt.s.lu fs0, tp, dyn
  fdiv.d fa6, fa4, ft0, dyn
  fcvt.lu.s s9, ft0, dyn
  rem t0, t1, s9
  lui s10, 0
  ebreak
  fcvt.s.d fs3, fs0, dyn
  fcvt.lu.s a0, fa5, dyn
  amoadd.d.aqrl a3, s10, (t6)
  subw s8, a3, s9
  divw t2, t2, t0
  andi a1, t3, 1560
  fsgnjn.d ft8, fs7, ft10
  lw s0, 1620(t6)
  amoswap.w.rl s3, s3, (t6)
  fcvt.s.l fs7, s5, dyn
  fcvt.d.wu ft11, gp
  remuw a3, a3, a5
  fcvt.lu.s s0, ft11, dyn
  fmv.d.x fs2, a4
  sltu t4, a2, a3
  fsw fs0, -968(t6)
  fmsub.d ft1, fa3, fs0, ft1, dyn
  fcvt.lu.s s1, fa3, dyn
  srlw t0, t0, s7
  fsw fs1, -56(t6)
  rem gp, s9, gp
  addi tp, a5, -1
  fsw fs7, -1728(t6)
  amoxor.d.aqrl s10, s11, (t6)
  fcvt.lu.s s7, fs10, dyn
  fsw fs6, -632(t6)
  fsqrt.d fs6, fs10, dyn
  fsw fs6, -852(t6)
  fsd fs6, -32(t6)
  fcvt.l.s ra, fs10, dyn
  fmadd.d ft3, ft9, fs11, ft3, dyn
  sc.d.aqrl a2, a2, (t6)
  divuw t1, s10, s7
  amominu.d.aq s1, ra, (t6)
  mul t2, s5, a2
  fcvt.lu.s s7, fs11, dyn
  fcvt.s.l fa7, s7, dyn
  remu s2, s7, a1
  amoor.d.aqrl s4, t3, (t6)
  sraiw t0, t3, 6
  slt a1, t2, s4
  amoadd.w.aqrl tp, s5, (t6)
  srliw s0, a2, 0
  sltu a3, a4, t1
  amoor.w.aqrl gp, a5, (t6)
  sb s1, 2014(t6)
  lh s8, 490(t6)
  auipc s1, 0
  addi s1, s1, 24
  jalr a3, 0(s1)
  amoor.d.rl s9, s0, (t6)
  fcvt.l.s s3, fs6, dyn
  fcvt.d.l fs2, s3, dyn
  fwd_4:
  fmv.d.x ft10, gp
  fcvt.s.lu fs11, a3, dyn
  amomaxu.w a3, s8, (t6)
  amoadd.d a1, gp, (t6)
  fcvt.s.l fs6, s1, dyn
  sc.w.aqrl t1, s1, (t6)
  amoand.d.aqrl a2, s0, (t6)
  fcvt.l.s zero, fs11, dyn
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
.word 0x80199008, 0x88816dd1, 0x663d2ee2, 0xb713f68e, 0x20e24dc0, 0x9187e372, 0xf7c17138, 0x5f6ba213
.section .mem_region, "aw", @progbits
.align 4
mem_region:
.word 0x936cb999, 0x764895f7, 0xcf1e9f20, 0x0ca4dda2, 0x2470bff3, 0xf46bd664, 0x33621f23, 0x0b74abf1
.word 0x25c3034a, 0x40e95947, 0x3d362d91, 0x5a456496, 0x38a15a6a, 0xb43c8ef1, 0x0085d109, 0xba04fe5c
.word 0x76cd67fd, 0xbf601048, 0xe253aa05, 0xc20f9005, 0x2ca40de5, 0xa42aefe4, 0x4230c809, 0x794fa260
.word 0x2515f532, 0xf24520ca, 0x56de632b, 0xd2bb111b, 0x92a809ed, 0x4ba4113f, 0x7027a610, 0x2140f63c
.word 0x3be5b91c, 0x0d94ab55, 0xc1ee1347, 0x9a0c4a8a, 0x300b1c64, 0xa820edc4, 0xf720c4a5, 0x32e9487b
.word 0x1b1fde2c, 0x1ae6fe23, 0x3d4acd2e, 0x2068c653, 0x2cc9e38c, 0x3924d993, 0x75cd16e3, 0xed98879e
.word 0xacec1195, 0xa575b309, 0xe8883cd7, 0x597fbeb9, 0xfddcc3e7, 0x270b37a5, 0xc15efb0f, 0xbbd7fc70
.word 0xe5be5d40, 0xb9196894, 0xcfca3b79, 0x7adae9b9, 0x871dbf98, 0x8cacda0f, 0x65dbbd5a, 0x696e583d
.word 0x3107c0ad, 0xe2724d2e, 0x65df8dcf, 0xe150ed28, 0xff9a9a0c, 0x79a39374, 0x432689ba, 0x13c51287
.word 0x23408869, 0x30174160, 0x85a260f4, 0xf4d46d50, 0x94f371b8, 0xda1f92a1, 0x514e7f3e, 0x47c7f5a4
.word 0x2508afd9, 0xdcb87a9d, 0xbd3655b3, 0x1c72d3b1, 0xeac443cb, 0x966b8862, 0x26df5689, 0x68237ece
.word 0xa794ece2, 0xf115feb1, 0x99ae46b6, 0x43c34e3f, 0xd5f03755, 0xf6d9b723, 0xaabfd4db, 0x17a23b7c
.word 0x0dbcd25f, 0x6899e43b, 0x6ebc64e3, 0x583e4a0d, 0x4fb3e512, 0x22e1090a, 0x0dfd572d, 0xde8b90f0
.word 0x10a4911c, 0xabd3bebf, 0xb52318af, 0xe51bdd58, 0x137b373c, 0x380476c5, 0x593e9619, 0xbf668d30
.word 0xe4c62032, 0x59370a0f, 0xf0594368, 0x50206da4, 0x6faa1db5, 0x6697df79, 0x21bf647b, 0x12facfd2
.word 0x6230d299, 0x4ba198b7, 0x53d94e31, 0xe31b766e, 0x2b9f1337, 0x8285c757, 0x179ca60c, 0x77e13e21
.word 0x6cae80f8, 0xcab44d40, 0xb8c15d53, 0x9da31743, 0x054d7a37, 0x50e67f80, 0x35a92208, 0x09b27beb
.word 0x3b3607a9, 0x0fe27830, 0x29f90602, 0x0e3a1c97, 0x2ef301fb, 0x03c61043, 0x3372a40b, 0x625d0a73
.word 0x3b3a7434, 0xbeabe83a, 0xc364ea02, 0xaf049f9c, 0x1ea01878, 0xc7e046da, 0x60fbe0e9, 0xffb4c618
.word 0xde48f1aa, 0xac01e993, 0x8c101292, 0x2392ca38, 0xee3a67b3, 0x927d9512, 0xd7eff8c6, 0x8e5e5f19
.word 0x5c08e9d4, 0xaf39ad73, 0xeaa0527b, 0xada6fab6, 0x5fb77a8b, 0x020704f4, 0x6ede8dc4, 0x07f0c435
.word 0x8a6e7ed3, 0xbe89a3ef, 0x21246662, 0x95d751d5, 0x92966444, 0x0dc9a41d, 0x341f0c1e, 0x55d8e1d2
.word 0xabfe8f74, 0xabb01279, 0x25c4988d, 0x8dbad856, 0xb647416b, 0x40bc1a93, 0x53bab577, 0x3413b5fe
.word 0xeac90855, 0x978a0dc0, 0xd18dabbe, 0xe6ee6fa1, 0x71913642, 0x9289b5e8, 0xef9d974b, 0x6e64aba4
.word 0x2701862e, 0x18b95d8e, 0xc2d359ec, 0x0504062a, 0x1bfd3da3, 0x589d78fd, 0xd7b77876, 0xb0f77c3d
.word 0x25032eae, 0x2bb8fb6b, 0xa585c958, 0x805afb3a, 0xd4d306b1, 0x73ecda3a, 0x855b5258, 0xa9931e83
.word 0xda5a09aa, 0x030fe994, 0x68e524be, 0x32ea2a27, 0x36541c51, 0x40d5c1e8, 0x3db82140, 0x65069cf2
.word 0x9b87b233, 0x4a166088, 0x7eb517fb, 0x56addf4d, 0x20931fbf, 0x4816ecb7, 0x8bac216a, 0x94c03a04
.word 0xceb395ff, 0x3f74a4c5, 0x52cd4800, 0x12d26add, 0x422248b1, 0xde861851, 0x56aa7b08, 0x91cb9804
.word 0xcbd29762, 0xbfff4241, 0x8bd150ee, 0x45f70851, 0x05a17a8d, 0x95099af2, 0x54d319bd, 0x2e8e63ba
.word 0xa2bdbd13, 0xbdc97fb7, 0x61572345, 0xb5a0cb5d, 0xa1428e46, 0x67d29f5e, 0xd3aa3ae1, 0xb84f0416
.word 0x3d4fff92, 0xdcf5f221, 0x30b94aa1, 0xc479f56b, 0x09c4929f, 0x56d1b426, 0x813f58cb, 0x71c80353
.zero 7168
mem_region_end:
