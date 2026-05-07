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
  li x26, 0x0000000a002cc980
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
  fsrmi 1
  csrwi fflags, 0
  li x1, 0xf4f1ad5ca82e1a0b
  li x2, 0x8e04b0a829e5f509
  li x3, 0x3ed9b1bff2d92dc3
  li x4, 0x7ed7313f7d85b849
  li x5, 0x402e17df6e1e1689
  li x6, 0x8f90f6ba32365a01
  li x7, 0x4327fdf81dc3d069
  li x8, 0x231fef873f34ddaf
  li x9, 0x204bddcdd4ed3dd1
  li x10, 0x05386ec8ca5f411b
  li x11, 0x6e38ddb89d1f5221
  li x12, 0x4f848957feaa717b
  li x13, 0x4febc818e28265cd
  li x14, 0x4f1161ffa2d50222
  li x15, 0x83db15095c55f389
  li x16, 0x119327c4a60d6a6e
  li x17, 0x23166ad64a84589c
  li x18, 0xeb6e1da5401189bd
  li x19, 0xe0b600c950a5a1e6
  li x20, 0x0649503dcd1d4b9a
  li x21, 0x6a8fdea2cfeb16b6
  li x22, 0x4e6d68a4733a9584
  li x23, 0xf17ba630b5b38ca9
  li x24, 0x1b4c6ecc639d1470
  li x25, 0x8201ce62697b7cc8
  li x26, 0xb92e1d3f3eeede04
  li x27, 0x386dd3a215c3ce37
  li x28, 0x02ab5118e278c6fb
  li x29, 0x319ed789d948abaa
  li x30, 0x44eeadf884f51d6c
  li x31, 0xa85d1b09cd325bb2
  li x5, 0x83c61a8b312b7973
  fmv.w.x f0, x5
  li x5, 0x3a764161c5b22b4d
  fmv.d.x f1, x5
  li x5, 0x1de6de112c24b99a
  fmv.w.x f2, x5
  li x5, 0x862736e5db4b6c69
  fmv.w.x f3, x5
  li x5, 0x1cde3fb999ce5008
  fmv.d.x f4, x5
  li x5, 0x1867df4ee764d17b
  fmv.w.x f5, x5
  li x5, 0x97991f509e3fc750
  fmv.d.x f6, x5
  li x5, 0x8e9a1ebbdc179a29
  fmv.w.x f7, x5
  li x5, 0x2bd6ba3aa868d5f6
  fmv.d.x f8, x5
  li x5, 0xc594da0133bc5b73
  fmv.w.x f9, x5
  li x5, 0xc754ea48c577f4af
  fmv.w.x f10, x5
  li x5, 0x4a7d50442009a39c
  fmv.d.x f11, x5
  li x5, 0x924b3a45fd5a229d
  fmv.w.x f12, x5
  li x5, 0xb8a73ed4158d30e3
  fmv.d.x f13, x5
  li x5, 0xdeea888e27e380f8
  fmv.w.x f14, x5
  li x5, 0x02f64e025290823d
  fmv.d.x f15, x5
  li x5, 0xb17a4683265ee637
  fmv.w.x f16, x5
  li x5, 0x0f85e1972f15bf71
  fmv.d.x f17, x5
  li x5, 0xa654d9e0a3780875
  fmv.d.x f18, x5
  li x5, 0x316a34ef46416aa4
  fmv.d.x f19, x5
  li x5, 0x550830c6e302ee16
  fmv.d.x f20, x5
  li x5, 0x1ef1dc1bd6ff493f
  fmv.w.x f21, x5
  li x5, 0x513a98af48371c51
  fmv.w.x f22, x5
  li x5, 0x8788c187d727dcf3
  fmv.w.x f23, x5
  li x5, 0x3dcc951a91665d65
  fmv.w.x f24, x5
  li x5, 0x2a7532c6ee238263
  fmv.d.x f25, x5
  li x5, 0xfdeb31b3bac4a65f
  fmv.w.x f26, x5
  li x5, 0xb84da059a5648db3
  fmv.w.x f27, x5
  li x5, 0xc01b8be3010ba203
  fmv.d.x f28, x5
  li x5, 0x7aef830523039d47
  fmv.w.x f29, x5
  li x5, 0x6c5dec42c7f105ff
  fmv.d.x f30, x5
  li x5, 0x81fae45c41e1e3c8
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
  sd s8, -152(t6)
  divu gp, gp, gp
  remw a4, gp, a2
  fld fa1, -112(t6)
  fmv.x.d s5, fa4
  beq gp, s4, . + 28
  fnmadd.d ft5, fa1, fs3, fa1, dyn
  amoswap.w.aq s6, s5, (t6)
  amominu.w.rl s2, a4, (t6)
  fclass.d s3, fs7
  remuw t1, a4, s3
  fadd.d fa4, fa1, ft11, dyn
  fwd_0:
  srliw t4, t4, 17
  flw fs11, -684(t6)
  fsw fa4, -172(t6)
  amoxor.w.aqrl s0, t1, (t6)
  blt s3, s2, . + 16
  sraiw sp, t4, 1
  fld fs10, 2008(t6)
  fcvt.s.lu ft8, s3, dyn
  fwd_1:
  fsw fa6, -444(t6)
  lwu ra, -720(t6)
  srai t2, s0, 6
  fcvt.lu.s tp, ft6, dyn
  remw zero, t2, s0
  remw a2, s4, ra
  amominu.d.aq a0, tp, (t6)
  amomin.w.aqrl sp, sp, (t6)
  auipc s5, 0
  amoadd.d t2, t2, (t6)
  divu a6, a0, a2
  sraiw ra, a6, 27
  fle.d s6, fs7, ft8
  fsd fs9, -1416(t6)
  feq.d t4, fa4, fs0
  fmadd.d fs5, fa4, fa6, ft10, dyn
  rem a2, a2, t4
  div s9, s6, s6
  slt t3, a2, s7
  remu t4, s9, a2
  srl s2, a2, gp
  feq.d s7, fs6, ft10
  remw a1, t0, s7
  auipc s1, 1
  sd a3, -160(t6)
  remw s5, a7, s9
  amomin.w.aq a6, a6, (t6)
  divuw sp, s9, sp
  fcvt.d.lu fa5, s5, dyn
  fcvt.l.d a4, fa2, dyn
  divuw tp, a7, s5
  mulhu s0, a6, sp
  fnmadd.d fs6, fs3, fs5, ft0, dyn
  amoadd.d.rl t4, s9, (t6)
  slti s11, s4, 0
  fcvt.d.w ft10, t4
  sltu ra, s2, a7
  amoor.w t2, ra, (t6)
  slli t1, ra, 31
  rem sp, t4, t2
  amomaxu.d a3, s0, (t6)
  remw s4, s11, t2
  rem a7, tp, s4
  fcvt.s.lu fa6, s4, dyn
  fsw fs10, -296(t6)
  amomin.d.aq a5, s4, (t6)
  mul s0, s0, tp
  fmv.x.d s2, fs6
  fcvt.l.s a2, ft7, dyn
  addi gp, s2, -2048
  amomin.d a4, s0, (t6)
  fsw ft10, 756(t6)
  sc.d.rl a7, gp, (t6)
  fcvt.w.d s11, ft10, dyn
  lhu t2, 1780(t6)
  srai s8, t2, 60
  feq.d a2, fs5, ft4
  fsw ft9, -224(t6)
  amoswap.w.aqrl a1, t2, (t6)
  amoxor.d.aq sp, a2, (t6)
  amoxor.d.rl t3, sp, (t6)
  fmin.d ft11, fs5, fs5
  fsw fa0, -1212(t6)
  remuw t2, a2, a1
  sraw a6, s10, a3
  srai a2, tp, 44
  amoswap.d.aqrl s4, s1, (t6)
  div a5, s1, a1
  fsgnjn.d fa2, fs5, fa6
  fcvt.lu.s t4, fs10, dyn
  sltiu t3, t4, 1642
  fsw fs8, -1644(t6)
  fcvt.s.lu ft2, a7, dyn
  fcvt.d.lu fs7, t3, dyn
  slli a0, a5, 33
  sd a0, -736(t6)
  amoadd.w.aqrl s10, t3, (t6)
  amoand.w a4, s1, (t6)
  or s6, a0, a4
  fsw fs4, 280(t6)
  fcvt.s.l fs5, s7, dyn
  addw s9, s1, gp
  nop
  remuw s3, s9, a5
  div a5, s10, s7
  divw a3, a4, s10
  sc.w t3, zero, (t6)
  amoadd.d.aqrl s5, a3, (t6)
  fcvt.d.l fa7, a3, dyn
  remw ra, tp, a5
  divuw t2, s5, ra
  fcvt.s.lu ft7, s5, dyn
  amomin.w.rl t1, t4, (t6)
  lb s5, -105(t6)
  srai ra, s3, 0
  fmv.x.d t2, fa3
  fmin.d ft4, ft2, ft2
  ori s6, s5, 1
  bge a6, ra, . + 24
  divuw t1, s11, t4
  fcvt.s.l fs8, t1, dyn
  fnmsub.d fa2, ft9, fa2, ft10, dyn
  sllw s3, ra, t1
  amomin.w.rl a0, ra, (t6)
  fwd_2:
  fcvt.s.lu fs10, t2, dyn
  mulhu sp, s6, a0
  amoswap.w.aq a7, a7, (t6)
  div s4, s2, a0
  sc.d.rl s11, s0, (t6)
  srliw s6, a0, 20
  divuw a5, a7, s4
  fmul.d fs1, ft4, fa2, dyn
  amomin.w.aqrl sp, a5, (t6)
  and s9, sp, a5
  amoadd.d.aqrl gp, gp, (t6)
  fcvt.s.lu fs4, a5, dyn
  amoswap.d.aqrl s4, s4, (t6)
  fsgnjn.d fs3, fs3, fs1
  fsgnj.d fs6, fs10, fs3
  fsw fs3, 1340(t6)
  amominu.w.aqrl a2, gp, (t6)
  fsub.d fs10, fa2, fa2, dyn
  divuw s6, s9, s4
  sc.d.aqrl a5, a2, (t6)
  sub s10, s3, s6
  fcvt.s.l fa4, a5, dyn
  lui ra, 993949
  amomaxu.w.aqrl s11, s11, (t6)
  amomin.w.aq a1, tp, (t6)
  remw a6, s11, a1
  rem gp, sp, gp
  remw a6, a0, a6
  sraw a3, a0, s1
  divuw a1, s5, a7
  remuw s6, a6, a3
  amoxor.w.aqrl a4, s5, (t6)
  divw a7, s6, a7
  divw t4, s9, s6
  fcvt.l.s s10, fs6, dyn
  srlw s9, a4, sp
  fcvt.lu.s t1, fs8, dyn
  mulhu t2, a7, s10
  divw a2, s10, s10
  fsw ft1, 1248(t6)
  rem tp, s1, s9
  fmv.x.d s4, fa4
  fcvt.l.s gp, fa2, dyn
  fmin.d fs0, ft1, fs0
  slli s2, s2, 63
  divuw t0, s3, t0
  sub s0, s11, t3
  sc.d.rl s9, s1, (t6)
  amoswap.w.aq t0, t0, (t6)
  fmul.d fs9, fs0, fs0, dyn
  amoadd.d.rl a4, s9, (t6)
  rem zero, s10, s9
  amominu.w.aq a2, zero, (t6)
  fadd.d ft4, ft9, ft1, dyn
  amomaxu.w.rl s7, t0, (t6)
  srai sp, t0, 1
  sc.w.aq ra, sp, (t6)
  fcvt.lu.d t2, ft1, dyn
  andi a0, ra, -1469
  divw s6, s6, t2
  fnmsub.d fa3, ft4, ft1, fs5, dyn
  fmul.d fa3, ft1, ft7, dyn
  ld s8, 1328(t6)
  fcvt.s.lu ft5, s10, dyn
  fcvt.s.l ft10, s6, dyn
  div a4, t2, a0
  divu s3, sp, s6
  amomin.d tp, tp, (t6)
  amoswap.d.aqrl a2, s3, (t6)
  amoand.w.aq s9, s9, (t6)
  fcvt.d.s fs4, ft5
  mulhu s10, zero, a7
  fcvt.lu.s t1, fs10, dyn
  fcvt.d.l fs8, a2, dyn
  amoxor.w.rl a3, s9, (t6)
  addw s2, s1, a2
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
.word 0x1685b034, 0xfff855c2, 0x7102f849, 0xed289056, 0x3c776603, 0xe9275b9d, 0x2c42a825, 0xd8f3e3f7
.section .mem_region, "aw", @progbits
.align 4
mem_region:
.word 0x4fca20e9, 0x53c6108c, 0xfe64229b, 0x2c9c6234, 0x396a53bd, 0x7417e8fc, 0x8057fe1b, 0xad9c8639
.word 0x4d8c7419, 0xac4ac8e1, 0x374ee2c7, 0x8d44da61, 0xca1bdbfe, 0x96299f07, 0x0a295c37, 0xc7ec749a
.word 0xe9ee6055, 0xdf362e15, 0xf46099aa, 0x0c2b9056, 0xbe4806e9, 0x69336c77, 0x015caebc, 0x981d625b
.word 0x10c49e8a, 0x24380b26, 0x5c3cdb05, 0x32559284, 0x11fba13a, 0x693bf970, 0x0178af30, 0x1fa75ab4
.word 0x979e8fd6, 0x6438f842, 0xe94b23e7, 0xa7d26616, 0xaf8457d4, 0xfa27f78f, 0xb1142d49, 0xc28fced9
.word 0x4f2aa6bb, 0x315fb5b6, 0x1e74b623, 0x85567728, 0xc986ccd8, 0x0afe6be8, 0x3c4ecba2, 0x778eeea2
.word 0x51eee126, 0xa5b10670, 0x77f1788b, 0x357e406c, 0x0a66d665, 0xc30fdcb5, 0xdd6d63e7, 0xcaa93d3c
.word 0x3a945d00, 0x438fc764, 0x061140ef, 0x60bd8528, 0xdcffdeea, 0x7e5d27d4, 0x271ebed1, 0x15629cf3
.word 0x84b45a27, 0x783798d4, 0x2947197c, 0x5d79acc4, 0x3d41b0b7, 0x4ca83fcd, 0x286f459e, 0x90b610d1
.word 0x2193673b, 0xf41fcefc, 0xd8e2c15d, 0xce3346b7, 0xbe067ab1, 0x27f9efa1, 0xcf61d458, 0xd61e5e29
.word 0x130075c3, 0x6c1939b1, 0x5d939ca8, 0x35eb5bb3, 0xb35923f5, 0x5ae60fc1, 0x11c3f4c4, 0x74f4beaf
.word 0x3571f8d6, 0x07572e25, 0x994f8f00, 0x64ef5d51, 0x1bab77ef, 0xac3f5eb8, 0x6911e494, 0x97b2ac0a
.word 0xf7cd1fa1, 0xb1793020, 0x423e507a, 0xee54b854, 0xfb44cd09, 0x155aed3a, 0x9b2dea14, 0x9a8af1a2
.word 0xb7570201, 0x84affe4e, 0xe021b554, 0x7f9d1705, 0xd53411e8, 0x4c55c69b, 0x2e2623f9, 0x6f3ba3df
.word 0xfc23cbed, 0x4d3711e1, 0x1e45652c, 0xcbe69343, 0xa6a08856, 0xeefb2610, 0xc59a8d1e, 0x86d259e1
.word 0xe40b1c19, 0x385ce686, 0x7b7dd04e, 0x8289f46d, 0x154aa6d2, 0x97d6b4c4, 0xcde385d3, 0x95f2bbee
.word 0xbc882dee, 0xf57e3c8a, 0x27a179e9, 0xb998cbcc, 0x721791df, 0x9e6b7bdc, 0xf66f5903, 0xf4249bb9
.word 0x92c5a34a, 0xc1cf5544, 0xa8636953, 0x0241546c, 0x68edf6d9, 0xa2c36a13, 0x36a14c04, 0xc82422b5
.word 0xcd793c59, 0x36ccdd41, 0x2a9505ab, 0x9771b738, 0x5559dbf8, 0xf30acd42, 0x7cafa121, 0x8bd9d4c9
.word 0xe8e07971, 0x908e1f80, 0x2ae553ee, 0x61e5ee07, 0xb64ba3f9, 0xba322951, 0xd4584b9f, 0xe2511788
.word 0x2e84615a, 0xb1198952, 0x6f43f310, 0xd0a91eb0, 0xac0f70a5, 0x98ca2441, 0x6b430def, 0x04a9e7a7
.word 0x9e9086d3, 0xf4811ece, 0x2f0ef27a, 0xb8890004, 0x4c511bd7, 0xa17c838b, 0x520c8143, 0x3bc6358d
.word 0xecdc3edd, 0xad6aa544, 0x7c8035e6, 0x03894532, 0x91f38f3e, 0x3a2c4f8d, 0xb51e448d, 0x6affaef0
.word 0xdc51d1b6, 0x296e9e45, 0x53e21a08, 0x244b85ac, 0x553396f3, 0x8d99d2c2, 0x7ef0468b, 0x65422882
.word 0x16f73b60, 0xd9fa8794, 0x2b1648f5, 0x0f36df44, 0x4868f7a0, 0xe8852f52, 0xcfd9b39b, 0x7a1b3187
.word 0xdbfa730e, 0x1ae50254, 0x88b2742b, 0x1cb69378, 0x600ca4e9, 0x34a92b2b, 0xc6f4b800, 0xe047f686
.word 0xd034feab, 0xbb300980, 0xec1fda32, 0x0e79e3b7, 0x6d75015b, 0x649c1ba3, 0x5fc119ed, 0xe912cb2c
.word 0x9b55217d, 0x01c51d1f, 0xea740918, 0xb99b310f, 0x4a3f5426, 0x32188096, 0x1f1c1304, 0xb5aa9449
.word 0xf38bb9d8, 0xcb38e762, 0xd0082ee2, 0x2af99ee2, 0x4daa44fd, 0xd103c0f1, 0x5205eb40, 0x5fa07084
.word 0x7cf12fbb, 0xf1bbf539, 0xe7fdcd0a, 0x66076ae5, 0x8f8c0f10, 0x6d008a32, 0x982c0c90, 0x71b4c629
.word 0x3055d613, 0x127b0e61, 0xc495fe86, 0x47be2688, 0x79f9595a, 0x9cca62cc, 0xed233078, 0x69c9576d
.word 0xe4ffa928, 0x85f2b9a6, 0xc1e1d892, 0x172b5c67, 0x4690d7d3, 0xd62aec03, 0x69b5e6dd, 0xac4e9582
.zero 7168
mem_region_end:
