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
  li x26, 0x0000000a006aa1aa
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
  li x1, 0x4f53fddcedf08e63
  li x2, 0xafcbf9ecfd1afeeb
  li x3, 0x035fef288338518d
  li x4, 0xa042d69a9a260224
  li x5, 0x9537cd4bfb72f7d1
  li x6, 0xf74e6587e1d763dc
  li x7, 0x4c141d7a597e5bf9
  li x8, 0xbc022b6fc9709c1b
  li x9, 0x5e199d4131e1b403
  li x10, 0x26fbb6b0413e01dc
  li x11, 0xeb447c5392d69239
  li x12, 0x44962588480706ae
  li x13, 0x4f0e6f942f86fda6
  li x14, 0xd8c4efdf3ad4bb9c
  li x15, 0xe441921eb0f82a20
  li x16, 0x12c7df3fc6862b9e
  li x17, 0x37e111022ae834ab
  li x18, 0xac89abc690f065f5
  li x19, 0x400d17048c9507b9
  li x20, 0xd88b6c3e632c8acc
  li x21, 0xebcfb1de06d03247
  li x22, 0x28ee2c3eb40053f1
  li x23, 0x64f5a90d3cae1fea
  li x24, 0x97d64a1c501b4f07
  li x25, 0x27de369820e81d75
  li x26, 0xdaa2b29ac164b29d
  li x27, 0xa98524dae039b4b4
  li x28, 0x3dae061c20eb5065
  li x29, 0xe7fe89ac3d51d14e
  li x30, 0x6f96e019e9efac26
  li x31, 0x115f67de0e46c0be
  li x5, 0xbfd91567fce317e4
  fmv.d.x f0, x5
  li x5, 0xca5df87adeaacad3
  fmv.w.x f1, x5
  li x5, 0x7ea2402f35dc0938
  fmv.d.x f2, x5
  li x5, 0x21129860710af720
  fmv.d.x f3, x5
  li x5, 0x037999d7224374e9
  fmv.d.x f4, x5
  li x5, 0x494581a90a23b418
  fmv.d.x f5, x5
  li x5, 0xa448064621b317ce
  fmv.w.x f6, x5
  li x5, 0x0b4896e238e1e423
  fmv.w.x f7, x5
  li x5, 0x8f4885e448b3b242
  fmv.w.x f8, x5
  li x5, 0x78826bdc267520ae
  fmv.w.x f9, x5
  li x5, 0x2880c42e7eb5b291
  fmv.d.x f10, x5
  li x5, 0x3e9c3f1260746a7c
  fmv.w.x f11, x5
  li x5, 0x16954cce1d97d4b0
  fmv.d.x f12, x5
  li x5, 0x4be32cc8fb74cda9
  fmv.w.x f13, x5
  li x5, 0xd98eca7834046e1b
  fmv.w.x f14, x5
  li x5, 0x35b2098472d3f71d
  fmv.d.x f15, x5
  li x5, 0x740bd78f9d22a6f6
  fmv.w.x f16, x5
  li x5, 0xbc0b32ba813a0c02
  fmv.d.x f17, x5
  li x5, 0x181f0f8b7381b468
  fmv.w.x f18, x5
  li x5, 0x81505f85cb652ed4
  fmv.w.x f19, x5
  li x5, 0xf2266b1f1a950026
  fmv.w.x f20, x5
  li x5, 0x47a08add74dc1949
  fmv.d.x f21, x5
  li x5, 0x257a62e36e26a573
  fmv.d.x f22, x5
  li x5, 0xdb26ee3ce48cf929
  fmv.d.x f23, x5
  li x5, 0x8993c878f2988961
  fmv.d.x f24, x5
  li x5, 0xdd64108111dbbd0f
  fmv.d.x f25, x5
  li x5, 0xf02c73d3c20ed5a6
  fmv.d.x f26, x5
  li x5, 0x07238c98e1c17bbb
  fmv.d.x f27, x5
  li x5, 0x513302993e7549ad
  fmv.d.x f28, x5
  li x5, 0x670c966cff17587c
  fmv.w.x f29, x5
  li x5, 0xf3bd08f99cc95540
  fmv.w.x f30, x5
  li x5, 0x34f2107b851614b1
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
  fmv.d.x fs5, a0
  rem a4, a4, a4
  div s6, a4, s6
  divuw t3, t3, s6
  fcvt.d.wu ft10, a1
  amominu.w.aq gp, t3, (t6)
  div s9, t3, s6
  mulw a0, s9, s6
  remw s8, s11, s3
  fcvt.d.lu ft0, s6, dyn
  fcvt.s.l fs0, s8, dyn
  amoadd.d.rl s1, s8, (t6)
  fsgnj.d ft3, ft0, ft3
  slliw tp, s9, 4
  amomin.w.aqrl s2, zero, (t6)
  sraw a3, tp, tp
  fcvt.d.l fs7, s1, dyn
  amoxor.d.aq s5, s1, (t6)
  fcvt.d.s ft9, fs0
  remuw t4, s2, tp
  fcvt.l.s s3, fs7, dyn
  fmv.x.d a3, ft9
  mulhu s8, a2, s5
  fsw ft10, 12(t6)
  mulhsu s11, t4, a3
  fsgnj.d fa2, fs7, ft3
  auipc a5, 0
  addi a5, a5, 36
  jalr tp, 0(a5)
  fle.d s6, fs7, ft4
  fnmadd.d fs0, fs7, fa2, fs8, dyn
  flw ft2, 508(t6)
  fsgnjx.d fs2, fs2, fa2
  sltiu t2, s8, 1265
  remu s11, tp, t2
  fwd_0:
  bltu s11, s8, . + 36
  sc.d.rl a4, s8, (t6)
  remuw a0, tp, t2
  remuw s3, s3, t2
  amomaxu.d.aq t1, s0, (t6)
  amomax.d.rl ra, a4, (t6)
  flw fs10, 1504(t6)
  fcvt.l.s s11, fa2, dyn
  lr.w.aq tp, (t6)
  fwd_1:
  srlw s7, tp, a5
  slti s4, s11, 0
  xor s6, s7, s5
  fcvt.l.s s10, ft9, dyn
  amomax.w.rl a6, a6, (t6)
  remuw s3, sp, s4
  fcvt.d.wu ft5, s3
  divuw s2, a0, s2
  fcvt.lu.s a3, ft5, dyn
  auipc t0, 0
  sc.w a2, a2, (t6)
  amomax.d.aqrl s10, s8, (t6)
  divuw a2, s8, a2
  remu a3, a3, t0
  fcvt.s.l fs11, s1, dyn
  fcvt.w.d s5, fs11, dyn
  remuw s6, a2, a6
  sc.d.aq gp, s6, (t6)
  fcvt.w.d a4, ft5, dyn
  flw ft4, -1880(t6)
  fcvt.s.l fs9, s9, dyn
  fcvt.d.l ft4, a4, dyn
  amominu.w.rl s4, a4, (t6)
  slliw s10, s4, 31
  fcvt.d.wu fs8, a4
  subw s6, s11, a4
  fcvt.s.l ft10, s4, dyn
  div t0, s6, s11
  fcvt.lu.s s0, ft10, dyn
  amoor.d.aqrl s0, s11, (t6)
  remw a0, s2, t0
  addw zero, t3, s11
  amominu.w.rl a7, s6, (t6)
  addiw a2, zero, -539
  divu a1, gp, gp
  slliw a6, gp, 0
  fcvt.lu.d t4, fa1, dyn
  fmv.d.x ft7, s6
  amoadd.d.aqrl s0, s0, (t6)
  divuw s2, a1, s0
  fcvt.lu.s a7, ft8, dyn
  andi s1, a7, 1417
  amoor.d s4, s0, (t6)
  fsw ft8, 708(t6)
  rem s8, a7, s8
  fcvt.d.l fs11, s0, dyn
  divw s9, a7, s2
  amominu.d.aq s5, s1, (t6)
  sb t0, -910(t6)
  fsw fa6, 1288(t6)
  amoswap.w.aq s2, s9, (t6)
  amomax.d s10, s4, (t6)
  amomin.d.rl a3, s5, (t6)
  amoxor.d.aqrl a1, s9, (t6)
  fmax.d ft4, fa4, ft4
  mulhsu sp, a3, s2
  slli s11, a1, 0
  fcvt.s.d ft6, ft8, dyn
  sd s11, 1104(t6)
  amoxor.d.rl t4, sp, (t6)
  fclass.d zero, ft8
  fcvt.l.d s4, ft7, dyn
  lui a3, 95429
  amominu.d s5, a3, (t6)
  rem a0, s5, s5
  remu s0, s0, a5
  amoxor.d s8, s5, (t6)
  fmadd.d ft6, ft7, ft0, fa4, dyn
  sraw a2, gp, s2
  divu a4, a0, s5
  remu s2, s8, s8
  srliw s5, a2, 31
  fcvt.w.d s10, ft8, dyn
  fsw ft7, 288(t6)
  divw t2, a4, t1
  fcvt.s.lu fa0, t2, dyn
  fcvt.l.d s8, fa0, dyn
  sraiw a1, s8, 20
  divu s7, a1, a3
  fcvt.s.l fa1, a3, dyn
  fcvt.s.lu fa2, a3, dyn
  fcvt.d.l fs4, s7, dyn
  sc.w.aq zero, s5, (t6)
  fmv.d.x fs2, a3
  rem s9, s2, s2
  srai s3, s9, 63
  remw gp, s9, t3
  amoxor.d.aqrl ra, sp, (t6)
  fcvt.d.l fa6, tp, dyn
  remuw a6, s11, a6
  amomaxu.d.aq ra, t4, (t6)
  auipc s9, 486690
  divuw s8, s8, s9
  divw tp, s4, s8
  fcvt.l.d s2, ft11, dyn
  amomin.d t3, s8, (t6)
  fclass.d a2, ft10
  div a7, s2, a2
  remuw t0, s11, t0
  fcvt.d.lu fa0, t3, dyn
  fsw fa0, 576(t6)
  fsub.d fs7, fs6, fs4, dyn
  fcvt.l.d a5, ft10, dyn
  mulhu s3, a7, s3
  and t3, a5, a5
  fsw fs0, 416(t6)
  mulhu s11, s11, s11
  bgeu s1, a4, . + 16
  lr.w.rl s9, (t6)
  amominu.d.aqrl tp, s10, (t6)
  div s6, s10, s7
  fwd_2:
  mulw s1, a5, s9
  fsw fs9, -1500(t6)
  remw t4, s6, s6
  remw zero, zero, s1
  fcvt.s.lu ft5, s4, dyn
  fcvt.l.s sp, fs9, dyn
  bne gp, s3, . + 36
  fcvt.wu.d zero, fa4, dyn
  ecall
  mulhsu s11, t0, zero
  feq.d s1, fs2, ft5
  srai tp, sp, 0
  amomaxu.w.aq s1, zero, (t6)
  fclass.d a3, fs2
  flw ft9, -1580(t6)
  fwd_3:
  fsw ft5, 1584(t6)
  fcvt.s.l ft8, a3, dyn
  amoand.w.rl s4, ra, (t6)
  fsub.d ft6, ft6, fa0, dyn
  fnmadd.d ft10, fs10, ft10, fs5, dyn
  amomin.d.aqrl a1, s4, (t6)
  divuw s9, a3, a3
  fcvt.s.l ft3, s4, dyn
  amomax.d.aqrl s4, s4, (t6)
  fcvt.d.lu fa7, s9, dyn
  amoxor.d.aqrl ra, s9, (t6)
  fmv.d.x fs3, a3
  divuw s1, s1, s2
  mul a3, a1, ra
  fcvt.lu.d a4, fa5, dyn
  srl a5, zero, s1
  amomin.d.rl t2, s1, (t6)
  mulw t4, s1, t4
  fcvt.d.lu fs7, t3, dyn
  fsgnj.d fa1, fa3, ft3
  amoadd.w.aq s11, s0, (t6)
  fle.d ra, fa5, ft8
  divw s2, s7, sp
  addw a3, s7, sp
  amoor.d.aq t4, s7, (t6)
  sd s2, -72(t6)
  srli a0, a0, 19
  fcvt.d.l ft6, s2, dyn
  lb t2, -1535(t6)
  remu s11, s11, a3
  subw s9, t2, t4
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
.word 0x4948d760, 0xdc3a7d73, 0x505a5777, 0x92dc4582, 0x6b43ce3c, 0x39cc24e9, 0xabc2fe49, 0x9efdff16
.section .mem_region, "aw", @progbits
.align 4
mem_region:
.word 0x6cf5a926, 0x6b79621e, 0x1f8a64b7, 0x01bf274d, 0x3b3c1f08, 0x52d22d3e, 0x1d76721f, 0x4650e82f
.word 0xd36a0bb4, 0xa1533e7b, 0x1b8fcef4, 0x71724e68, 0x934fc5d1, 0xe0ec2827, 0xfb14fc56, 0xb7048f14
.word 0x93cc1c33, 0xc6b2a7ca, 0x75c90ab4, 0x31377f3c, 0x9c0fe1ba, 0x84a86c65, 0x26ef6ca9, 0xf529af67
.word 0xfd6e4aaa, 0xe69e0723, 0x69a92aed, 0x19a715ce, 0x3caad806, 0x5d2875d4, 0xb6ce6889, 0x793e4b0d
.word 0xb515a817, 0x8fdde91e, 0x602f73e1, 0x65b8fd2f, 0xd9e398c4, 0x7782ba8a, 0x9cf6f0e6, 0x51be346c
.word 0x6f35f9a3, 0x8181290d, 0x254460d1, 0x40870ead, 0x431c5520, 0xda71fb09, 0x10101a39, 0x1d095eaa
.word 0x41dc204b, 0x2f778dae, 0xf86a1f25, 0xed26b8e5, 0xe487e16e, 0x6260467d, 0xf89554b4, 0x4ce9c1d5
.word 0x52952990, 0xe609c4b8, 0x1a49ae79, 0x2217918b, 0x3194c8c4, 0xbb9bc02b, 0xb65c7cd1, 0xf5104521
.word 0x17c48c09, 0x71739931, 0x5f8c85dc, 0x697f9d28, 0xd2c43359, 0x33b95753, 0x3aa627d4, 0xc69a9874
.word 0x8a12b897, 0x4b754b07, 0x7d235ff3, 0x73f5cf70, 0x5a5fdf71, 0x8def3b17, 0x329ef47b, 0xef69c6d5
.word 0xed030acc, 0x644c3977, 0x93d597aa, 0x66f9c760, 0x5cbb71d3, 0x6d64d15a, 0xa887321d, 0xa264e1ff
.word 0x8f5f1d2c, 0x238680ed, 0xd71dc53a, 0x7e643a62, 0x9c2a98a5, 0xa3160036, 0x546768c6, 0x2ef9464c
.word 0x4a8d31b1, 0xb794e26b, 0x377a7ffe, 0x5fba7226, 0x9701b135, 0x8f6277bb, 0xf2fd611d, 0xa10d375d
.word 0x6626aa2d, 0xfa754c19, 0x299f62d3, 0x82ad631c, 0xabc78ebc, 0x7397da43, 0x4b28fd48, 0x3753d9a1
.word 0x545e5872, 0x9404ae07, 0xe31eeba7, 0x52b3161d, 0xad96eb01, 0x50540e41, 0x0e76555b, 0xa1fec019
.word 0xb828a3c6, 0x37700029, 0x16de37ca, 0xb8f4bac2, 0x6a6432f9, 0x98ab438f, 0x0857cb95, 0x5f03adbf
.word 0x422b8fc1, 0x9e93e64a, 0x08ddeb36, 0x8abeb463, 0xdc642926, 0x0e8b734c, 0x00549db2, 0x320b7799
.word 0xad7584bf, 0x46c28c1c, 0x92c0c4e2, 0x6fa8b0e8, 0x97c81d37, 0xaf4d5ac3, 0x3227ec72, 0xab8616b6
.word 0xa48f0a17, 0xc076159b, 0x70843461, 0x85d71a06, 0xeec2207a, 0x5a442a88, 0x0bf447dd, 0xb7751440
.word 0xc2f929d7, 0xf18d5b40, 0xfc71eb27, 0x3f6b464c, 0xa3c54385, 0x2b0d3f2f, 0x0bfc4ed2, 0x20db87ba
.word 0xb64805be, 0x76e21e77, 0xc99747b3, 0x9796590e, 0x8acf4640, 0xc7ba4142, 0x21ce73a6, 0x4e1c3153
.word 0xa5be8106, 0xa957d24f, 0x16cbb679, 0x01346d0c, 0x5de6de48, 0xe0f08dfa, 0x4db77682, 0x2d9c8402
.word 0x3009a6fe, 0x4b81c98f, 0x347d9a30, 0x8b586392, 0x37f278bc, 0x059c86af, 0xdc653447, 0x6a039a60
.word 0xb78845e3, 0x7922a2e5, 0x8f764c94, 0x6207f3df, 0x1c4f6cf2, 0x85e65ea0, 0x29e98608, 0x70caea4f
.word 0x39b29cdd, 0xd7c9a98a, 0xfeb65e1e, 0xaa0360de, 0xe84e9fe5, 0x81df69fe, 0xdfafba50, 0xaf802248
.word 0x596a53bc, 0xf07dca67, 0xaaf2b28c, 0x891f1261, 0xcc587955, 0x4f53f63a, 0xfa661f7b, 0x26457863
.word 0x3239d797, 0x2e755055, 0x5e1f7fd4, 0x3a307d58, 0x775aaeed, 0x5e6962f1, 0x6e719c1f, 0x2e7a5262
.word 0x4f10b923, 0xd75bf634, 0x2759d594, 0x2d96f03d, 0x9b3982db, 0x32172835, 0x1eea7e88, 0xe88a5913
.word 0x12a3b5c3, 0x9bb4471f, 0xd0dba5b2, 0xaadaa8ef, 0xc5686dd8, 0x959a97d0, 0x5ff4ac3c, 0xd622c2f8
.word 0x861ff598, 0x1556ac72, 0xebf546a1, 0xbe5d0844, 0xdc153451, 0xa4479af8, 0x44a1dcb6, 0x51653289
.word 0x28fba78a, 0xe4bc1123, 0x32fe141c, 0xdca3cd93, 0x54e98f56, 0xc357c55b, 0x108263d9, 0x22db8b8f
.word 0x6fe6a48c, 0x2303addd, 0x83b6d7b5, 0xe6dba771, 0xb085fe4f, 0xc03b48a0, 0x4d547605, 0xf03ae4f4
.zero 7168
mem_region_end:
