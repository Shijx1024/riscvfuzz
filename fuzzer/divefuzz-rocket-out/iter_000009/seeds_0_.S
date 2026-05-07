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
  li x26, 0x0000000a00284888
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
  fsrmi 4
  csrwi fflags, 0
  li x1, 0xe007149746565d7f
  li x2, 0x2bfc13bd6bb0c5eb
  li x3, 0x6948033f5239a131
  li x4, 0xd45f4c937ed923cf
  li x5, 0x3cd65c256ed0ab71
  li x6, 0x2562ac5901728a5b
  li x7, 0x2e81ead25c1d4074
  li x8, 0x9e7a0a84ad5ff939
  li x9, 0x1b2ad683459ff7ba
  li x10, 0x0a25127569e3ce74
  li x11, 0xb317a9e7c52a662e
  li x12, 0x5764493c0af48eac
  li x13, 0x7aeb44a89f987ea4
  li x14, 0x0f15ef5680179ea3
  li x15, 0x3268f92847be1aa2
  li x16, 0x2dc6213d395a361b
  li x17, 0xfaa80f47d9b40eba
  li x18, 0xea0d63180ed317e8
  li x19, 0x59bbe8a3f72e31c3
  li x20, 0x08844f09cc73c17a
  li x21, 0x06900d0aeb0b9eb7
  li x22, 0x34ed1f786d8e4c60
  li x23, 0x19f53704a292dd50
  li x24, 0x6d76c2cdb5452c85
  li x25, 0xfd27daee997d23f9
  li x26, 0xdf14ded5512ba49f
  li x27, 0xbc978a6704fde758
  li x28, 0x8caab74fb49749b3
  li x29, 0xebccfa4fb1f782c6
  li x30, 0x61ead0dc0f8e36e4
  li x31, 0x8da3d06d1a29f436
  li x5, 0x7505f408a648540b
  fmv.d.x f0, x5
  li x5, 0x3475aea98b65d06f
  fmv.w.x f1, x5
  li x5, 0xe81a23833c15eaa4
  fmv.w.x f2, x5
  li x5, 0xaab5aec51a685f11
  fmv.w.x f3, x5
  li x5, 0x1c67339fa2c0a343
  fmv.d.x f4, x5
  li x5, 0xaada9ed4b67ce385
  fmv.w.x f5, x5
  li x5, 0x12f98bd74a945986
  fmv.w.x f6, x5
  li x5, 0xc75da3c68792cbf7
  fmv.w.x f7, x5
  li x5, 0xffc1ce3c751ce5f8
  fmv.d.x f8, x5
  li x5, 0xb7efa90e60cb057b
  fmv.w.x f9, x5
  li x5, 0x93e0be165bf87cf9
  fmv.d.x f10, x5
  li x5, 0x63a2b6f15fa45edf
  fmv.d.x f11, x5
  li x5, 0x67133762b854350b
  fmv.d.x f12, x5
  li x5, 0xe2401720b45401fd
  fmv.w.x f13, x5
  li x5, 0x7fe79973d17f7296
  fmv.d.x f14, x5
  li x5, 0xbf817c118d9b1186
  fmv.d.x f15, x5
  li x5, 0x662576e568c334cd
  fmv.w.x f16, x5
  li x5, 0x5b53cc8ee7392145
  fmv.d.x f17, x5
  li x5, 0xe97bb7cf0dac0893
  fmv.d.x f18, x5
  li x5, 0x0901e565f31573bd
  fmv.w.x f19, x5
  li x5, 0x3cf3a9b4ef7645d2
  fmv.d.x f20, x5
  li x5, 0x29972adda2db9098
  fmv.w.x f21, x5
  li x5, 0x91e617f2382b1782
  fmv.w.x f22, x5
  li x5, 0x81f4e24acc7c99d8
  fmv.w.x f23, x5
  li x5, 0xd3a4a38fca2644af
  fmv.w.x f24, x5
  li x5, 0x7e180ab54fd82e90
  fmv.w.x f25, x5
  li x5, 0x10b9eea1f517c2c0
  fmv.w.x f26, x5
  li x5, 0x79632c15db45918f
  fmv.d.x f27, x5
  li x5, 0x65bc8cbafc4cb8e3
  fmv.d.x f28, x5
  li x5, 0xf1ff7daa353eabb8
  fmv.w.x f29, x5
  li x5, 0x9fef1f9ac998ba72
  fmv.w.x f30, x5
  li x5, 0x3a8385dcd5dae90b
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
  amoadd.w.aq a1, a1, (t6)
  fcvt.s.lu fa3, a1, dyn
  fnmadd.d fs3, fs3, fa3, fs5, dyn
  mulhsu a0, a1, a1
  amoadd.d.aq s10, a0, (t6)
  fcvt.lu.s zero, fa3, dyn
  fcvt.l.s a6, ft2, dyn
  fadd.d fs4, fs3, fs3, dyn
  fdiv.d fs9, fa7, fs9, dyn
  sd a3, 1112(t6)
  flw ft9, -1956(t6)
  fcvt.lu.s a2, ft8, dyn
  amomaxu.d.aq t3, a3, (t6)
  fnmsub.d fa1, fs9, ft8, fs9, dyn
  fmv.x.d tp, fa1
  sll t2, t1, a1
  fcvt.l.d a0, fa3, dyn
  andi ra, a7, -802
  divu tp, a0, s5
  divu a3, t3, t2
  remuw s1, s1, ra
  sd s8, -1928(t6)
  divuw s8, s8, tp
  amominu.w.aqrl ra, a0, (t6)
  div gp, s6, s8
  amomaxu.d t2, a1, (t6)
  fcvt.l.d a6, fs7, dyn
  rem zero, ra, s9
  amoxor.d.rl s6, zero, (t6)
  fcvt.s.lu fa6, s2, dyn
  divw sp, zero, s10
  blt sp, s6, . + 24
  ori s2, s10, 1932
  mul s9, s6, s8
  lh s5, -624(t6)
  xori t0, sp, -1368
  fcvt.l.s a7, fs9, dyn
  fwd_0:
  divu t3, a7, s2
  fmax.d ft5, fs9, fs6
  ecall
  fcvt.l.d s4, fa6, dyn
  feq.d s5, fs4, fs4
  sw a3, -1404(t6)
  mulhu s11, s7, t4
  fcvt.s.l fs7, s4, dyn
  fcvt.lu.s s2, fs7, dyn
  sraiw s7, s8, 13
  fcvt.s.l fs8, s2, dyn
  remw t4, t0, s4
  fsw fa2, -1420(t6)
  fcvt.s.lu ft2, gp, dyn
  div a0, s2, t4
  sb s1, 1975(t6)
  slti s1, s2, -2048
  fcvt.s.l fs0, s0, dyn
  amomin.d s11, s11, (t6)
  fcvt.l.d sp, ft7, dyn
  fnmsub.d fa6, ft7, fs9, fs1, dyn
  fcvt.s.lu ft8, a0, dyn
  mulhsu gp, s11, s4
  sraw s9, s9, a7
  mulw s3, s3, zero
  mulhu s8, gp, s3
  fcvt.d.l ft6, s3, dyn
  rem a7, s10, gp
  lr.w.aq t0, (t6)
  fcvt.s.l fa3, s9, dyn
  srliw a2, a7, 29
  subw sp, a7, s8
  amominu.d.rl s6, sp, (t6)
  fmv.x.d sp, ft10
  fcvt.d.lu fs3, s8, dyn
  divu s2, sp, t2
  sh a0, 1746(t6)
  feq.d a7, ft4, fa1
  amoxor.w s11, s6, (t6)
  amomin.w.aqrl t1, a7, (t6)
  fcvt.s.l ft0, sp, dyn
  slt s3, s3, a1
  srli s10, a7, 32
  amoswap.d.rl s10, t1, (t6)
  amoand.d.aq a6, a6, (t6)
  slti a1, t1, -284
  amoswap.d.aq a2, s10, (t6)
  divuw t0, a2, a2
  amoand.d t1, s6, (t6)
  lr.d s2, (t6)
  fmv.d.x ft5, t1
  fsd fs6, 760(t6)
  amomaxu.d.rl s7, a2, (t6)
  addw s11, t0, t0
  amoand.d.aqrl s11, s11, (t6)
  fcvt.s.l fs1, t3, dyn
  mulhu a5, s6, s6
  fsw fa1, -1212(t6)
  mulhsu a3, sp, t4
  amomaxu.w t4, s5, (t6)
  fcvt.lu.s s8, ft10, dyn
  fcvt.l.s a7, fa4, dyn
  mulw s11, a3, s11
  sltu sp, a7, sp
  lr.w.rl zero, (t6)
  fcvt.l.s s5, ft4, dyn
  amoadd.d.rl a7, zero, (t6)
  fcvt.l.d s11, ft4, dyn
  fsw fs10, -2044(t6)
  divw s4, zero, a7
  and t4, zero, zero
  divw s7, s5, s7
  sc.d gp, a7, (t6)
  fcvt.lu.d a4, fa1, dyn
  rem t2, a4, gp
  fcvt.s.lu fs1, s0, dyn
  jal s9, . + 36
  fcvt.l.s s2, fs6, dyn
  fcvt.s.l fs11, s7, dyn
  fcvt.s.l ft2, s9, dyn
  fmul.d fa6, fs3, fa3, dyn
  fnmsub.d fs5, fa3, fs1, fa6, dyn
  mulw a6, a6, gp
  flw fa5, -1852(t6)
  fence
  fwd_1:
  srai gp, s2, 53
  divuw ra, sp, a6
  fmax.d fs6, fs6, fa3
  remu s6, ra, sp
  amoadd.d s9, gp, (t6)
  fcvt.d.l ft6, gp, dyn
  fcvt.l.s t3, fa6, dyn
  fcvt.l.s s10, fs5, dyn
  mulhu a2, a2, t1
  fdiv.d fs11, ft6, fs11, dyn
  divuw t2, s10, t2
  mulw s2, tp, t4
  slt a7, a3, tp
  mulw s3, a3, a7
  addi s4, s4, -2048
  fcvt.l.s s11, ft1, dyn
  fcvt.d.lu ft4, a7, dyn
  fcvt.lu.s t3, ft0, dyn
  amomin.d.rl s5, s5, (t6)
  lr.d.aq zero, (t6)
  fcvt.d.w fs4, t4
  srlw s2, zero, s2
  mulw s10, s10, gp
  fcvt.d.lu fs2, s5, dyn
  slli s7, s2, 57
  lh tp, -1052(t6)
  amoor.w.aqrl s3, s11, (t6)
  mul s0, s2, tp
  addw a7, s0, s3
  fcvt.l.s a4, fa3, dyn
  mulhu t2, a7, t2
  srl s4, s0, t2
  amomaxu.d.aq a5, s2, (t6)
  mulw s1, s1, sp
  fsw fs5, -1088(t6)
  slli a1, s6, 52
  fsub.d ft10, ft6, ft10, dyn
  amomax.d.aq s11, s1, (t6)
  srliw gp, s8, 3
  amoswap.w.aq t4, a1, (t6)
  mulw s9, s11, s1
  fcvt.lu.s a4, ft2, dyn
  fmv.d.x fs6, a4
  slt s6, a4, s8
  fmv.d.x ft10, s11
  sc.d.rl s4, s8, (t6)
  fcvt.s.lu fs2, s11, dyn
  divu ra, s6, s9
  srlw s1, s1, a1
  fcvt.s.lu ft1, a4, dyn
  lr.w a7, (t6)
  or s5, s6, s1
  fld fs8, -1104(t6)
  flt.d sp, ft3, ft1
  fsw ft3, 728(t6)
  sc.w s11, a4, (t6)
  divu a2, a0, t4
  mul s11, t4, s11
  lui t1, 540761
  remuw gp, s5, t1
  amoswap.w.rl s11, s1, (t6)
  amoadd.d s4, s1, (t6)
  sraw s0, a1, s11
  fcvt.lu.s s2, ft3, dyn
  divw s5, s11, s11
  amoadd.w.aq a0, s4, (t6)
  remuw s11, s11, a0
  fdiv.d fs0, fa2, ft3, dyn
  fcvt.d.l fs6, s5, dyn
  add zero, s5, t3
  divw a7, a0, a7
  fsw fa3, -1924(t6)
  mulhu s4, a7, a0
  div a5, s4, s11
  div gp, a7, s1
  fcvt.s.d fs8, fs6, dyn
  fcvt.s.lu fa7, t1, dyn
  fcvt.l.s a3, fs8, dyn
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
.word 0x56d315cd, 0xb5b5ad47, 0x19d7ecd5, 0xdfa30b21, 0x17a25147, 0x69b946aa, 0x4263a44d, 0x993dcdd4
.section .mem_region, "aw", @progbits
.align 4
mem_region:
.word 0x84aeaf4c, 0x9452c398, 0x13b7bbe4, 0xa22f350b, 0x4ca16092, 0xe2477b3a, 0x7135731e, 0x9224ea4f
.word 0xd71af0ad, 0x46d788c8, 0x8bb55321, 0xdde0ded8, 0x0d1d17cb, 0x98ccd106, 0xb6248baa, 0xf2c78359
.word 0xdb3a80df, 0x79d267b0, 0x2930bc67, 0x08b74cdb, 0x43cea187, 0x092fc230, 0xb64d5eb6, 0x098bbe51
.word 0xee53809e, 0xeeb0d5a7, 0x3979949e, 0xea3edcdc, 0xc00d4b3a, 0x18ad9d29, 0xbb065c4e, 0x89350c47
.word 0xf7924785, 0x2050c3d0, 0xa248e505, 0xf57f3236, 0x4584d8c1, 0x11d9bb80, 0x80a1cee2, 0x57c22cdf
.word 0x445a88fb, 0x11a36785, 0x20f9d90c, 0x8c8bbbe5, 0x82c6b70c, 0xf746b6a3, 0xcafca530, 0x74dc7c41
.word 0xc00c868f, 0xeedf6d2b, 0x2edb9146, 0x805860b8, 0xc78d6ff3, 0xdd9b99be, 0x27120e9d, 0xcb681ced
.word 0xa14d4a53, 0xc0cca0f7, 0x51f2ef27, 0xba432f5b, 0x7cf067c6, 0xadd23ac5, 0x9dd82dd1, 0xa59f3ef2
.word 0xd0c019fa, 0x8a702eda, 0x1e8b99b6, 0xe741d274, 0xe6f1f5a6, 0x0d20da15, 0xdb9c5179, 0xadeb4059
.word 0x8e00f0e2, 0xe7c62652, 0xa05939ec, 0xccd3ab9d, 0xdb121e2f, 0x6188ade2, 0x37962645, 0x9c1e9b3c
.word 0x83ab80ac, 0x01d029b8, 0xc37f2feb, 0xf7d74a8f, 0x754aa189, 0x349e6fd2, 0x753586b2, 0x0d7b9c9c
.word 0xadd155a8, 0xd77ac5aa, 0x6a932896, 0xb351e47c, 0x8a4979d0, 0x46de3112, 0xa0fc0fd6, 0x7d8467ab
.word 0x170e7a71, 0xc17bb920, 0xb2aac77c, 0x2f307837, 0x5fbcc5d2, 0x5e787fbd, 0x4c05d6b0, 0x1b58229a
.word 0x56feb985, 0x07c2ee44, 0x35eb5579, 0xb87661f1, 0x19b9c03e, 0x0ba1f3d6, 0x447cc0e6, 0x7c9f49ed
.word 0xf5000afe, 0xb319713e, 0x420bbfab, 0x30840b74, 0x0b7d9c30, 0x38b3cb8e, 0xa24e78a6, 0xf9cd5914
.word 0xdf9725ed, 0x7c828317, 0xf0f203d3, 0xd8ecb975, 0xd75dbbf7, 0xd779753c, 0x4ae0d84e, 0x1493579b
.word 0x942ff2f0, 0xb69dc104, 0x29656638, 0x2900eb1e, 0x81ec784e, 0xb82cdd9e, 0x71136333, 0xabb38402
.word 0xb8366dfb, 0xf61fe1c5, 0x41ee35c0, 0x1891718e, 0x81ac8c7f, 0xd1212064, 0x43d40c0e, 0xa707aa64
.word 0x50824749, 0x7a388685, 0x63a1b21e, 0x926e4144, 0xc3810b8a, 0x22b63307, 0x346f4464, 0xb5a64cb2
.word 0x66f0ddcf, 0xed2bafee, 0x54a89161, 0xc84bf9c3, 0xffcad0b0, 0x3b2a990b, 0x2678c554, 0xedf8fdfc
.word 0x83228f12, 0x55071c6d, 0xc20850ba, 0x325fb6ee, 0x834d8536, 0x85e11752, 0xb7fc0210, 0xd97a7832
.word 0xb406794a, 0x04df8087, 0xc9832263, 0xa6899a27, 0x4cc0f75f, 0x99124fd4, 0x5f753ba7, 0x5fd06f01
.word 0x82d6d233, 0xf6471604, 0x14d34dce, 0x9ae0d5db, 0xbb2f79e7, 0xc41c689e, 0xa9e260a2, 0x4dc52325
.word 0x44c470f5, 0xb96f72b3, 0x3b1dbf76, 0x30a6a3ad, 0x892acf7c, 0xcfca0097, 0xd4ec9a61, 0xb1ccf813
.word 0x359a2511, 0x2ffb6d94, 0xad9512dc, 0x1c7039f9, 0x4a94adbf, 0x942c71b7, 0x341eca22, 0xcd6fc245
.word 0x858895ab, 0x2f6feca6, 0x7f7df331, 0xc85ce62d, 0xc780b932, 0x462cd37c, 0xb1ec6998, 0x8a3b7b54
.word 0x8c5ad75e, 0xbae27e78, 0xe7b703a7, 0x6de79db1, 0xa9b8400e, 0x6a4b32e4, 0xc11ab28d, 0xcacc9545
.word 0x15e60a18, 0xc6e799f7, 0xbc2cb68c, 0x379275c3, 0xf063dc2a, 0xdc810dcd, 0x96ed57f7, 0xa4948995
.word 0xa6a67d80, 0x31ac9af9, 0x0428049d, 0x050f166d, 0x4d076970, 0xbb767ad5, 0x877f5c8b, 0xf5be93d5
.word 0xc17b37c7, 0xe18226e3, 0x95220b30, 0x97811360, 0xca576a80, 0xafa2d2b0, 0xa5f47394, 0x89b7da3d
.word 0x4d897fed, 0x581dfc74, 0xc23b89fc, 0x155848a3, 0xbff1b8c2, 0xfcafda0f, 0xcf3e0ab3, 0x5ad10523
.word 0x08854c5b, 0x63476134, 0x8523a444, 0xd20421a1, 0xaa5a7993, 0xd5042a51, 0x3bd8eae0, 0xa4191943
.zero 7168
mem_region_end:
