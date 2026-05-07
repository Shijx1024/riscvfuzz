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
  li x26, 0x0000000a0074a92a
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
  li x1, 0x07dfc5ba6039ec66
  li x2, 0xb720d3367f157ae2
  li x3, 0x48160ebfb5f5ef1f
  li x4, 0xc341f9fd47ed6c29
  li x5, 0x5d37510f4fbf7a44
  li x6, 0x1293b86a512a436f
  li x7, 0x1bc56a606302ec6d
  li x8, 0x0ee162ebd8386453
  li x9, 0x3182a67e8234cc07
  li x10, 0xab5b3c732a0f6e05
  li x11, 0xeded6e05013c75d4
  li x12, 0x538ee4bcd859f165
  li x13, 0x7cfb0d2b2ec8cf50
  li x14, 0xaef6eb89a6f3fb2c
  li x15, 0x3b8b898a5bd61415
  li x16, 0xb8651f8b011a062c
  li x17, 0x0fcdb44959cbb2b8
  li x18, 0xf76fffbe50d59389
  li x19, 0x7e86761f22212a19
  li x20, 0x4cd6ce5aa1ca6ceb
  li x21, 0xceab1c536db1895b
  li x22, 0xe0343e2d832d27d4
  li x23, 0xbdafcc71fca6e6a9
  li x24, 0xae3dfa1293c705bd
  li x25, 0xaa2ea0861533e350
  li x26, 0xc96dd662da3f43bc
  li x27, 0x0355689a479943ab
  li x28, 0xa688b8814c546223
  li x29, 0x2b02211c260648c8
  li x30, 0x5488e2e4a87783e1
  li x31, 0x1d1637139afb66b9
  li x5, 0x37bd94b63dade6fb
  fmv.d.x f0, x5
  li x5, 0x2f1ff71b4e6f1f3d
  fmv.d.x f1, x5
  li x5, 0xe6ad2ba9b25bb320
  fmv.d.x f2, x5
  li x5, 0x938ba1914cc55c44
  fmv.d.x f3, x5
  li x5, 0xe49e541c125f658f
  fmv.d.x f4, x5
  li x5, 0x0f389bc9c4548247
  fmv.w.x f5, x5
  li x5, 0x38f11b5bf510e6dd
  fmv.w.x f6, x5
  li x5, 0xca8265788a12d0da
  fmv.d.x f7, x5
  li x5, 0x788675a285f63439
  fmv.d.x f8, x5
  li x5, 0x2f4e3a299c745332
  fmv.w.x f9, x5
  li x5, 0x35134e3c98802a46
  fmv.d.x f10, x5
  li x5, 0x06265a2d3998198a
  fmv.w.x f11, x5
  li x5, 0x47615ddb9a58d6ee
  fmv.d.x f12, x5
  li x5, 0xc40f7ddc4c630445
  fmv.d.x f13, x5
  li x5, 0xc4e718eedb1b0ea9
  fmv.w.x f14, x5
  li x5, 0x3438c882bb01b77f
  fmv.d.x f15, x5
  li x5, 0xe5921f0fdb2a287b
  fmv.w.x f16, x5
  li x5, 0x1e1e67dacf6cd2c6
  fmv.d.x f17, x5
  li x5, 0xce4eff8e17a62577
  fmv.d.x f18, x5
  li x5, 0xbaabf1cc43ecf1be
  fmv.d.x f19, x5
  li x5, 0x28b2437ca32feaec
  fmv.w.x f20, x5
  li x5, 0x3d9c931bb00e0f18
  fmv.d.x f21, x5
  li x5, 0x051f9658e5869ef9
  fmv.d.x f22, x5
  li x5, 0xe8046234f9579f75
  fmv.w.x f23, x5
  li x5, 0x204efeaf6c71562e
  fmv.d.x f24, x5
  li x5, 0x186cf450217c99e8
  fmv.w.x f25, x5
  li x5, 0x92432f25a35dadc4
  fmv.d.x f26, x5
  li x5, 0xdabd1371416a94c9
  fmv.d.x f27, x5
  li x5, 0xae50b8c3dc1c3d28
  fmv.w.x f28, x5
  li x5, 0xa3ab6e918a05c5b8
  fmv.w.x f29, x5
  li x5, 0x76f9036a84b5ebe0
  fmv.d.x f30, x5
  li x5, 0xb43413b8c0cdafc7
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
  sllw t2, a4, s7
  mulw ra, ra, ra
  mulw t1, ra, t1
  amominu.d.rl a4, a4, (t6)
  fcvt.lu.s s3, fa7, dyn
  fsgnjn.d fa0, fa0, fa0
  fcvt.l.d s2, fa0, dyn
  sc.w.aqrl a1, s9, (t6)
  fcvt.l.s s4, fa0, dyn
  amoor.d.aqrl gp, s3, (t6)
  flw fs3, -1284(t6)
  lwu s1, -344(t6)
  fmax.d fs10, fs3, fs10
  fadd.d ft0, fs3, fa0, dyn
  fcvt.lu.s t2, fs3, dyn
  amomin.d.aqrl a4, a4, (t6)
  fld ft3, 2000(t6)
  slliw s7, a4, 0
  amoxor.d.aq ra, gp, (t6)
  divw s10, s4, t2
  fcvt.s.l fa1, s7, dyn
  fcvt.d.lu fs4, t2, dyn
  sc.w.aq s5, ra, (t6)
  mul zero, zero, tp
  sc.d.rl a6, s10, (t6)
  fcvt.l.s s6, fs3, dyn
  fcvt.s.lu fs6, a5, dyn
  fmv.x.d a0, fs4
  fclass.d sp, fs6
  fcvt.lu.s a4, fs10, dyn
  remw s2, a0, s2
  divu s10, t4, s11
  remu s5, s5, s5
  fcvt.d.lu ft1, a5, dyn
  fsgnj.d fs10, ft2, ft3
  fcvt.lu.d a0, fs5, dyn
  amoadd.w s7, zero, (t6)
  fcvt.d.l fs5, ra, dyn
  sd zero, -912(t6)
  divw s0, t3, a0
  amoadd.d.rl zero, s9, (t6)
  blt a1, zero, . + 32
  ecall
  feq.d s5, fs3, ft1
  sraiw s9, s9, 0
  fcvt.l.d t2, fs5, dyn
  fcvt.lu.s s1, ft2, dyn
  amominu.d.aq s3, s2, (t6)
  divw a1, s1, t1
  fwd_0:
  amominu.w.aqrl s6, tp, (t6)
  amoxor.d.rl s7, s6, (t6)
  amoand.d t1, t1, (t6)
  amoxor.d t2, s6, (t6)
  fsw fs7, 184(t6)
  fle.d s1, ft11, fa0
  fcvt.lu.d t4, ft11, dyn
  fcvt.s.l fa1, t1, dyn
  fcvt.d.lu ft0, ra, dyn
  fcvt.s.lu ft6, s0, dyn
  fcvt.w.d a7, fs7, dyn
  amominu.w s3, s10, (t6)
  lb s0, 470(t6)
  divw a4, s3, s11
  flt.d s7, fs0, fa3
  divuw s4, s5, a5
  divuw s7, s11, s2
  remu gp, a7, gp
  div s7, s5, s7
  fcvt.d.lu fs8, tp, dyn
  fle.d s6, fs8, fs4
  fcvt.lu.s tp, fs7, dyn
  mul a3, gp, a3
  fcvt.s.lu ft0, s0, dyn
  amomax.w.aq s4, tp, (t6)
  amoor.d s11, s11, (t6)
  remuw t2, s9, a7
  div a4, a2, s11
  mulw sp, a7, a6
  slli a5, a2, 20
  fsgnjx.d fa1, fs3, ft5
  amomax.w.rl s1, a1, (t6)
  amoswap.d s7, s7, (t6)
  fcvt.lu.s s8, ft6, dyn
  fcvt.lu.d s8, fs6, dyn
  fcvt.l.d s10, fs8, dyn
  lbu a5, 1471(t6)
  fcvt.s.l ft6, s1, dyn
  sc.w.rl t2, s1, (t6)
  fmv.d.x fs5, t2
  srliw a5, s8, 19
  fcvt.lu.s tp, fs5, dyn
  divu zero, zero, zero
  amoand.d.aq a4, s11, (t6)
  fcvt.s.lu fa6, a6, dyn
  fcvt.s.lu fa2, s9, dyn
  remu sp, s0, s9
  amomaxu.w.rl s10, t0, (t6)
  fsub.d ft2, fa6, fs11, dyn
  remw t3, s9, t0
  or t0, a4, sp
  amoand.w a5, a5, (t6)
  flt.d a1, fa2, fs6
  addw a1, s11, sp
  amomin.d.aq a0, a5, (t6)
  fnmadd.d fs11, fa6, fs6, fs11, dyn
  lr.w.aq s1, (t6)
  fnmadd.d ft1, ft4, ft2, ft4, dyn
  amomax.w.aqrl s11, s11, (t6)
  fcvt.s.l ft11, a5, dyn
  fcvt.s.l fs7, a0, dyn
  fcvt.l.d a7, fs11, dyn
  fmax.d fa4, ft4, fs11
  amomin.w.aqrl s4, a0, (t6)
  fsgnj.d fa0, fa4, fa1
  amominu.d.rl s10, a7, (t6)
  fcvt.lu.s s7, fa0, dyn
  fcvt.l.s sp, ft8, dyn
  bgeu a3, s7, . + 20
  flw ft3, 1876(t6)
  divw s6, s3, s4
  divu s11, s11, s7
  feq.d s9, ft4, fa2
  fwd_1:
  amoor.d s3, t3, (t6)
  fsgnjx.d ft3, fs2, ft3
  ld t0, 1672(t6)
  fadd.d fs5, ft3, ft8, dyn
  amoor.d.rl a1, s8, (t6)
  amomax.w.aq t2, a5, (t6)
  mulhsu a7, s8, a5
  fcvt.d.l fs0, a4, dyn
  fmadd.d ft5, ft6, ft5, ft3, dyn
  fcvt.l.d a4, ft6, dyn
  remu s6, t2, a7
  fadd.d ft7, fa0, ft5, dyn
  remuw s4, a7, t2
  amoor.w.aqrl s1, a4, (t6)
  fmv.d.x fa3, a1
  fsw ft5, -1408(t6)
  divw t3, t3, s8
  fcvt.s.l fs8, t3, dyn
  amomin.d.aq a6, t3, (t6)
  and a5, s4, s5
  beq t2, t3, . + 36
  fcvt.lu.s sp, fs8, dyn
  mulw s7, zero, a2
  fsub.d ft8, ft5, ft3, dyn
  and s9, sp, a5
  remuw t0, s9, t0
  li s8, -549755813888
  amoand.w.aq a0, a0, (t6)
  fwd_2:
  amomin.d.aqrl s4, a0, (t6)
  fcvt.s.d fa1, fa3, dyn
  fclass.d a3, fs10
  sc.w.aq sp, t0, (t6)
  bne s8, s0, . + 32
  fld ft11, -1328(t6)
  fmv.d.x fs9, t0
  remw t3, t3, t1
  fcvt.d.l ft3, s8, dyn
  fsgnjx.d fa6, fs4, ft3
  flw ft6, -16(t6)
  mulw a4, a4, a0
  fwd_3:
  fmax.d ft8, fa6, ft3
  fcvt.d.lu fa4, a0, dyn
  fcvt.lu.d t1, fa7, dyn
  xori a5, a5, 2047
  amomin.d.rl ra, ra, (t6)
  fcvt.wu.d s4, fa4, dyn
  fcvt.d.l fs4, a0, dyn
  amoxor.d s11, a4, (t6)
  fcvt.l.s s7, fa4, dyn
  srlw t4, t4, t4
  fcvt.d.l fa2, gp, dyn
  lr.w.aqrl s8, (t6)
  fcvt.l.s s5, fs6, dyn
  fnmadd.d fa1, fs9, fs10, ft4, dyn
  divw s2, ra, t3
  amoor.d.aqrl s6, s5, (t6)
  remw a0, a0, s8
  amoswap.d t0, a4, (t6)
  mulhsu a1, a1, t0
  sra s11, a0, t3
  fcvt.d.lu fs3, a1, dyn
  fsw fs7, 1824(t6)
  fcvt.lu.s t4, fs3, dyn
  fcvt.s.l fs10, a1, dyn
  slli s0, s0, 1
  remuw ra, s4, a1
  remu s5, ra, s1
  sraw gp, s0, t4
  sll tp, ra, ra
  mulhu t1, s5, t1
  mulhu s6, ra, t0
  amoadd.d.aq a3, s6, (t6)
  sraiw s5, a3, 16
  amoadd.d.aq a6, a3, (t6)
  amoor.w.rl s10, a6, (t6)
  mul t4, s6, a6
  addw a0, a3, s10
  slti tp, t4, 1677
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
.word 0xe23a384b, 0xc591efb7, 0x395b0e95, 0x2345c879, 0xabb400b0, 0x750f93b3, 0xd2536cef, 0x661dd53b
.section .mem_region, "aw", @progbits
.align 4
mem_region:
.word 0x48cc6e7a, 0x41e7f182, 0x986863c3, 0xf9c2ff40, 0x81534707, 0xf04ad492, 0x7404917f, 0x3257c01d
.word 0x226e992e, 0x33d770e9, 0x3d287f48, 0xc676cafe, 0xf2dd9b2d, 0xa3986994, 0x3e5f6a2d, 0x81941945
.word 0xfdd9c461, 0xff161aa4, 0xee152494, 0x4007d148, 0xee2bff29, 0x32c4f8b5, 0x196bffcd, 0x27d92a47
.word 0x54d8f4e5, 0x21e8ba29, 0x63c8ac8e, 0x51440863, 0x75586464, 0x9f837330, 0x83af3180, 0xb681bd95
.word 0xdf228e7b, 0x429ef9a6, 0xeaf72868, 0xb45330f0, 0x4a3b018e, 0xfbf6a094, 0x2df2be2e, 0x0302743b
.word 0x946163a1, 0xfed4a647, 0x47152b7e, 0x4179d1a7, 0x80cf684a, 0xcdef14d6, 0x71210e3d, 0x38466815
.word 0x36330458, 0x44ec1a84, 0x2747cddb, 0xdab6cc34, 0xe8259485, 0x04aaf575, 0x85c8d646, 0x9d901514
.word 0xc7dc727a, 0xc435c0a9, 0xce957381, 0xc89a5b48, 0xaf90708d, 0x826295ff, 0x09266ab8, 0xcdd17348
.word 0xf9c6b721, 0x7eae5985, 0x8b46e5f0, 0x35314963, 0xe638307f, 0x0d002086, 0x75b71c3b, 0xcca247d7
.word 0x2b3cbe13, 0x475b1ffd, 0x81b58513, 0x09064200, 0xa3170cac, 0xd03eae64, 0x24bed71f, 0x641da521
.word 0x642ad6d7, 0x20bf2fa8, 0xf0da8b02, 0x07dbfdf8, 0xfe667d00, 0xd33fdead, 0x38bf32e0, 0xb5ac2bdd
.word 0x0c1e7d10, 0xbc897865, 0x908e3635, 0xa775b26e, 0x3dc33a59, 0x0a3a4846, 0x43f7d841, 0x215ad0a9
.word 0x7111f6bd, 0xf304c5d0, 0x2be26b0a, 0x707f9db7, 0x709d8a86, 0x01d1c64c, 0xc57e4599, 0xe4bd4852
.word 0xf2504d80, 0xa7b9b87c, 0x199330b9, 0x63c0883c, 0xd0076811, 0xb21781d3, 0x844a2c32, 0xb52b0e80
.word 0x89bd2bfc, 0x3fd3c609, 0x76929c20, 0x6f07f106, 0xea69c287, 0xaec4e3c3, 0xb2bc2fc6, 0xa193b6f6
.word 0x3628a2b8, 0xd9a70a41, 0xfd00ff59, 0x992b9e7d, 0xfcae75bd, 0xf6916a06, 0x1d6bebf2, 0x1f4e846e
.word 0xada32e3b, 0x794e5e93, 0xd7637572, 0xe7ab11ab, 0x97c123dd, 0xa141d831, 0x8ac9d19b, 0x34962461
.word 0x48719983, 0x0c0994e3, 0xab1b290d, 0x7347b4bb, 0x66bb77ce, 0xb380374c, 0x611a6d60, 0xaff3cd89
.word 0x16b8f4d1, 0xcdb8761e, 0x8c1cb46a, 0x8bd17302, 0x75c83a84, 0x5b0bc206, 0x9ea93922, 0x3e87b473
.word 0x9db7077e, 0x9490549d, 0xc0bfa833, 0x40a4dbb4, 0x2742baf6, 0x9c5650bd, 0xae2a8f84, 0x62a86d82
.word 0x346e12b0, 0x2036bad6, 0x06517566, 0x6707d759, 0x2e6d9931, 0xf5ccbc9d, 0x096df07e, 0xf89c8b25
.word 0x1b16ada7, 0x378ddd20, 0x7ad8d789, 0x900b1377, 0x8d499316, 0x73e61c51, 0x2ec34d41, 0x25aeab3a
.word 0x6a3446e9, 0x91bf1c18, 0x75ca69e8, 0x5d1edd35, 0x1068f851, 0x5c9bd690, 0xed76c0c0, 0x7ee8ad28
.word 0xfb0cb541, 0x89eafc4e, 0x1c7e9776, 0xccef128e, 0xb5419193, 0xee64ae52, 0x124964ce, 0x43b94175
.word 0x23eef6d9, 0x7c6a2c73, 0x3aab17aa, 0x7fc2371c, 0x7f53bcd3, 0xd23f96fe, 0x0c333aed, 0xe7c1d9e9
.word 0x44cbe864, 0x22abc90f, 0x84f36f71, 0x81cbb5df, 0x84ec4c33, 0xf1a71acd, 0x92f12fa2, 0xc5143b48
.word 0x8fbe2013, 0x994b821e, 0x3c5acbd1, 0x6647f3e1, 0x1e599029, 0x2c55293d, 0x27c07c6d, 0xed39632c
.word 0x5f8913c9, 0x47c67d94, 0xed553ce2, 0xe2901bf6, 0x239a4450, 0x192ee41d, 0x6ff94b95, 0x1d2b9e3a
.word 0x153945aa, 0x9589bf95, 0x43a858ed, 0x029aa7c3, 0x6aebdd7a, 0x2a618193, 0x751201b0, 0x355da67a
.word 0xf2939364, 0xd93fc5b3, 0xf22d05db, 0x21af1a7e, 0xb5834099, 0x4dc1baf8, 0x6ca3a6ed, 0x00b61cfd
.word 0xb0f6f7d1, 0xdc3601d9, 0x6196cb8e, 0x6bf4afd9, 0x1213f307, 0x23a87bac, 0x34447e96, 0xbae051bf
.word 0x0de287da, 0x836649a0, 0x8adee26e, 0x0abcc2e7, 0x017b84dd, 0x845b184e, 0xba46fa9f, 0xc7e14092
.zero 7168
mem_region_end:
