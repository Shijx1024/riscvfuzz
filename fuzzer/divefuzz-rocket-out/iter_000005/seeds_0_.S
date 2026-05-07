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
  li x26, 0x0000000a0047e90a
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
  fsrmi 2
  csrwi fflags, 0
  li x1, 0x741d3bbb3fe8e0c1
  li x2, 0x411059fdf893ff71
  li x3, 0x0e9defd34c48d89b
  li x4, 0x28e3ef2837e053c4
  li x5, 0x1599a19e0a09f019
  li x6, 0x2f15a396c8c642ce
  li x7, 0x0f887875b67e23fd
  li x8, 0x97eba5fe9dd7d887
  li x9, 0xc323619dc592678f
  li x10, 0x54c016f6460d03cb
  li x11, 0xe251bf9a9144f559
  li x12, 0xaddb9792a5192ed9
  li x13, 0xad0fb24b29927912
  li x14, 0xfa85e75121cd468c
  li x15, 0x8696450185e3484b
  li x16, 0x50a5cd061ece88e7
  li x17, 0xfa87b9fc4b165a6b
  li x18, 0x4b28e8326b78ce79
  li x19, 0x7fa069db8ede6cde
  li x20, 0x66555331feab8697
  li x21, 0x19584e291bc3a249
  li x22, 0x862a99a8646f37b6
  li x23, 0x59aeab2103b7e940
  li x24, 0xb16050d0ad6c3106
  li x25, 0xda60e73d9f3ff7c3
  li x26, 0x069a111549fc0916
  li x27, 0xab60cf1508bd2581
  li x28, 0x15475b5a7411c431
  li x29, 0x85cfa30d6ae4a84b
  li x30, 0x20176511b1d4626f
  li x31, 0xe5963876cecd5702
  li x5, 0xc2057f5570d11ebc
  fmv.w.x f0, x5
  li x5, 0xbce4bc7d72dd5710
  fmv.d.x f1, x5
  li x5, 0x3191f1079faf0aea
  fmv.d.x f2, x5
  li x5, 0x20bb5283292fc895
  fmv.d.x f3, x5
  li x5, 0x23233dd101244539
  fmv.d.x f4, x5
  li x5, 0x1eb19e022cad6bb5
  fmv.w.x f5, x5
  li x5, 0x6c5a27866efcd19f
  fmv.w.x f6, x5
  li x5, 0x7569136323dc356f
  fmv.w.x f7, x5
  li x5, 0x4ec53dd93249f69c
  fmv.w.x f8, x5
  li x5, 0xf27bd330a76239c7
  fmv.w.x f9, x5
  li x5, 0x28789904cc33f275
  fmv.d.x f10, x5
  li x5, 0x9cab940f833dd81d
  fmv.d.x f11, x5
  li x5, 0x05502a9d58297533
  fmv.w.x f12, x5
  li x5, 0xc8f0b29cb306a195
  fmv.d.x f13, x5
  li x5, 0x67d5c53390f759a6
  fmv.d.x f14, x5
  li x5, 0x7186f4ffb1512bfc
  fmv.d.x f15, x5
  li x5, 0x987f77172ff11e62
  fmv.d.x f16, x5
  li x5, 0xb0a788e0eac2cb3a
  fmv.w.x f17, x5
  li x5, 0x5cf7fd507641c18f
  fmv.d.x f18, x5
  li x5, 0xb336ab671a3d1f1e
  fmv.w.x f19, x5
  li x5, 0xd43f804fbc5644fd
  fmv.w.x f20, x5
  li x5, 0x0dc503c7981d7f5a
  fmv.d.x f21, x5
  li x5, 0x24247a3479ab4e26
  fmv.w.x f22, x5
  li x5, 0x7e45f78205b7807c
  fmv.w.x f23, x5
  li x5, 0x42d97fedd7f80c89
  fmv.d.x f24, x5
  li x5, 0xf950dce746c3bf5e
  fmv.d.x f25, x5
  li x5, 0x4f32b52e96c75c54
  fmv.w.x f26, x5
  li x5, 0xc55ff483deba6618
  fmv.d.x f27, x5
  li x5, 0xa589c36aabfd8e5b
  fmv.w.x f28, x5
  li x5, 0x4b3d010b1298888f
  fmv.w.x f29, x5
  li x5, 0x7044eddd6b44c9f3
  fmv.w.x f30, x5
  li x5, 0x163d13923776720e
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
  srl sp, a5, sp
  srliw t2, a1, 16
  fcvt.s.l fa3, a4, dyn
  fcvt.w.d a7, fa0, dyn
  amoand.d.aq a5, a5, (t6)
  fmv.x.d t4, fa3
  fsw fa3, -1628(t6)
  div a3, t0, a5
  srai s1, t4, 19
  flw ft4, 1596(t6)
  amomax.d a1, a5, (t6)
  rem s4, a1, a5
  sllw a2, tp, a3
  fsgnjx.d ft10, ft10, ft10
  lhu a7, -84(t6)
  fcvt.d.l fa1, s1, dyn
  subw s11, a7, sp
  lr.d.aq t2, (t6)
  amoor.d.rl s1, a7, (t6)
  fsd fs9, -288(t6)
  fcvt.l.s s8, fa7, dyn
  ecall
  fcvt.d.lu fs7, s1, dyn
  amoand.d tp, t0, (t6)
  fmv.x.d s7, fs6
  amoand.w.rl s9, s9, (t6)
  remu t4, s10, s9
  lh a0, -1572(t6)
  fcvt.s.l ft8, s9, dyn
  subw tp, t4, s7
  divw a1, sp, a0
  lb t3, -1698(t6)
  amomax.d.aq s6, s6, (t6)
  sll zero, zero, a1
  fsw fa2, -52(t6)
  fcvt.l.s s0, ft9, dyn
  amoor.w.rl t2, s6, (t6)
  amoor.w.rl tp, s11, (t6)
  fcvt.s.lu ft4, t0, dyn
  fclass.d t4, fs6
  fcvt.lu.s s6, ft2, dyn
  mul s7, t1, s6
  fcvt.s.l ft0, s7, dyn
  remu s4, tp, t4
  rem a7, s4, t4
  mulhsu a3, s6, a7
  remu zero, gp, a6
  fcvt.s.lu fs7, s4, dyn
  remw t2, t2, s5
  remw a6, a6, t2
  amoand.w.aqrl s3, s8, (t6)
  amomax.d.aqrl sp, t2, (t6)
  sc.w.aq s8, a6, (t6)
  amoswap.w.aq s1, s8, (t6)
  fcvt.lu.s tp, fa2, dyn
  amoor.w.aqrl s3, gp, (t6)
  amoand.d.aqrl s6, s8, (t6)
  fcvt.s.l ft11, s6, dyn
  amoor.w.rl s5, s6, (t6)
  sc.w.aqrl s0, s1, (t6)
  fsqrt.d fa6, ft11, dyn
  amomin.d a7, s1, (t6)
  fcvt.d.l fs11, s4, dyn
  mulw s7, s6, s3
  amoand.w.aq s11, s7, (t6)
  auipc s3, 0
  fcvt.d.l fs5, s3, dyn
  amoor.d.rl s8, s6, (t6)
  fcvt.wu.d a5, fs5, dyn
  amoor.d.rl s3, a6, (t6)
  amomaxu.w t4, a3, (t6)
  fsw fs11, 556(t6)
  fsd ft6, 1200(t6)
  amoand.d.aqrl s1, s3, (t6)
  amomaxu.w.aqrl a7, t0, (t6)
  jal t2, . + 24
  fclass.d a4, fa7
  sltu s0, s0, a7
  flw fs2, -1832(t6)
  amominu.w.rl sp, s0, (t6)
  flw ft3, -1304(t6)
  fwd_0:
  remu s6, a4, sp
  sraw s5, s5, s0
  remu t3, t4, t4
  mulw s7, sp, s6
  fcvt.s.lu fs3, s6, dyn
  fmv.d.x fs8, t3
  amoxor.w.rl gp, s5, (t6)
  fle.d s1, fs6, fs2
  fcvt.s.lu fa6, t4, dyn
  fsw fa6, -1660(t6)
  fcvt.l.d a6, fs4, dyn
  amoand.w t1, s7, (t6)
  fcvt.lu.s a5, fs3, dyn
  fsw fs4, 364(t6)
  amoxor.w.rl a6, a5, (t6)
  sra a6, a4, s7
  mulw s2, a1, s0
  mulw s7, s7, s2
  fmin.d fs1, fs1, fa6
  fmv.d.x fs2, a5
  mul t3, zero, a5
  amomin.d a4, a5, (t6)
  sllw a7, a6, s9
  fmv.d.x fa0, tp
  fsw fa5, -548(t6)
  srai s11, a5, 9
  amoor.d.aq a0, s11, (t6)
  amomin.w s3, s0, (t6)
  sltiu a7, s11, -1332
  amoor.d.aq a2, a0, (t6)
  amomax.d.rl s10, s10, (t6)
  xori t0, s10, -2048
  fsgnj.d fs10, fs0, ft5
  fmv.x.d s9, fs10
  mulw gp, a2, a7
  fsw ft2, 1996(t6)
  mul s3, t3, s9
  fcvt.lu.d s5, fs9, dyn
  fsw fs9, -1104(t6)
  amomaxu.d.aq t3, s1, (t6)
  fcvt.s.lu ft3, t3, dyn
  fcvt.s.l fs10, gp, dyn
  fcvt.s.l fa7, a6, dyn
  and s10, s11, gp
  amomin.d.aq tp, tp, (t6)
  addiw s5, s3, -757
  srai a4, t3, 1
  amoor.d.aq a2, a2, (t6)
  remuw s7, t3, a2
  auipc s5, 42263
  flt.d a7, fs9, ft5
  amoor.d.rl a0, s5, (t6)
  mulw t0, s5, a7
  divu t1, a0, t1
  fsw fa7, -1692(t6)
  fld ft4, -352(t6)
  ld a1, 48(t6)
  remuw tp, t1, a0
  fcvt.s.l fa6, t1, dyn
  amomax.w t2, t2, (t6)
  fmax.d fs0, fs6, fs6
  fcvt.l.s s4, ft5, dyn
  divuw tp, tp, a2
  mulhu a4, t4, t4
  remu s6, a5, a0
  fsgnjx.d ft8, fs6, fa4
  sc.w.aq s8, zero, (t6)
  fadd.d ft2, ft7, fs6, dyn
  remuw a2, s7, t3
  fcvt.d.l fs7, s7, dyn
  rem s7, a2, s7
  sd s7, -904(t6)
  fcvt.l.s t4, ft2, dyn
  amoor.w.rl a2, s8, (t6)
  amoadd.w.rl s10, a2, (t6)
  fcvt.lu.s sp, fa6, dyn
  fcvt.l.d t1, ft2, dyn
  divu a7, a4, a0
  slliw a3, s11, 27
  remu s0, s0, s11
  fcvt.l.s t2, ft1, dyn
  fcvt.d.lu ft7, t4, dyn
  fcvt.d.l ft5, t4, dyn
  fmadd.d fs4, ft5, fs0, ft5, dyn
  mulhsu tp, t4, s0
  fcvt.s.lu fs7, t4, dyn
  fcvt.s.l fs0, ra, dyn
  amoor.d.rl gp, gp, (t6)
  ori a1, a0, 1002
  fcvt.s.l fs3, s2, dyn
  fsqrt.d ft8, fs4, dyn
  sltiu s8, a0, -2048
  fnmsub.d ft5, fs4, fs0, fa0, dyn
  remu s4, s3, t1
  fsgnjn.d fs8, fs0, ft11
  sd t1, -944(t6)
  rem s3, a0, a0
  srai t2, s4, 8
  fsgnj.d fa5, fa2, fs8
  fcvt.wu.d a5, ft9, dyn
  divuw s0, ra, ra
  amominu.w.rl s8, a6, (t6)
  fcvt.lu.s s1, fs2, dyn
  remuw s11, s11, s8
  fcvt.d.wu fa5, s11
  rem sp, s11, s0
  mulw s3, a0, a0
  li s11, 1
  bwd_0:
  amoadd.d.rl s6, t1, (t6)
  flw fa3, 496(t6)
  mulw s10, sp, t3
  flw fs4, 1236(t6)
  remuw s1, s6, t3
  ecall
  fmv.d.x ft9, zero
  divw s2, a2, a2
  addi s11, s11, -1
  bne s11, zero, bwd_0
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
.word 0xff3eeb95, 0x03a72559, 0x693017a5, 0xf6f6c730, 0xc1dd5aba, 0x2b10fd5e, 0x9e54a9bd, 0x60169217
.section .mem_region, "aw", @progbits
.align 4
mem_region:
.word 0xd16a2ac0, 0x9bf24837, 0xc8d3c28a, 0x1c1d4faa, 0x3a2cd642, 0x255334c9, 0xe15f31b9, 0xb7bf1cf3
.word 0x8e228067, 0xf59f9f33, 0xbce54d32, 0x052eef35, 0xe2ccbe87, 0x4746dac0, 0xa2c436db, 0x6d94e8f2
.word 0xce9ca66d, 0x1af91aa4, 0x3b0e247d, 0x44c68b4c, 0xe5be86e0, 0x98e03e38, 0xdb72d444, 0xe56bdb5b
.word 0x232e3a4b, 0x17ab641d, 0xd8ac9a70, 0xa1a30ec9, 0x1c75473a, 0x8b66f56c, 0x82b14d4a, 0x773ae198
.word 0x4cb2665e, 0x7fc509cf, 0xcfd29917, 0x0c9f512b, 0x135fbee0, 0x1f658665, 0x5ec36b15, 0x0c617ac3
.word 0xa2bec52a, 0xcb40c771, 0x81516f27, 0xf12cb29b, 0xedfbd67e, 0xf1290819, 0xeeb2484f, 0x2d358d46
.word 0x251165cf, 0x289ab780, 0xbc6493e1, 0x639e6eb1, 0x6ba450c9, 0x9c5c878f, 0x90fb225f, 0xb9a007f0
.word 0x7d181d9d, 0xe1233932, 0x1c4d652f, 0xd1732d35, 0x5ec017b6, 0x3c79c5ec, 0x8fd0e154, 0x42da8805
.word 0xa9652f15, 0xc13924cc, 0xafa6bea2, 0x6a0093cc, 0x08f4ca0b, 0x63fe367c, 0x48380e55, 0xbca82505
.word 0xb5d1236b, 0x8e4ed631, 0x95e21685, 0x00d91499, 0xcfb05894, 0xb9cb8ad9, 0x4231768b, 0x3b3dada7
.word 0x5204efde, 0xc26213d3, 0xe5c31b37, 0x2c933ad9, 0x76910da2, 0x93e6de8a, 0xf1815114, 0xc915a8d5
.word 0x23a82249, 0x38aaf0c0, 0x29b989ca, 0x37e0277d, 0x96b781a1, 0x1512e2b4, 0x28f4af32, 0x256e63ad
.word 0x1fda4499, 0x3e03d1fc, 0xb95ad9aa, 0x007077bb, 0xf925204b, 0x8c42773d, 0x3de79b5c, 0x4baf5402
.word 0x9aa0b404, 0xd7eb7ddc, 0x2f7adad0, 0xe3930049, 0x4d4287e8, 0x81f7e3a7, 0xed33e2bf, 0xed9eff33
.word 0x11cb7f90, 0x4d9a9025, 0x0337e074, 0x2065fde4, 0xdfb842c5, 0x442266af, 0x0f9d3030, 0xc02e4c25
.word 0x7854fe44, 0xe71ab950, 0xf89d5a4e, 0x5f69a755, 0x6dba2a23, 0x9d39e398, 0x8af6ffac, 0xc43adbfa
.word 0x0317db50, 0xcdef941d, 0xceaf99b4, 0xc8325df7, 0x96cc33d8, 0x2bfb428a, 0x943858b6, 0xe628cc22
.word 0xb77e8f3a, 0x21441eb0, 0x8ee7a107, 0x507399e6, 0xe0286a2e, 0xea618003, 0x3b955c63, 0x6bc2ec68
.word 0x1cf2098c, 0x736c1343, 0xe897ccc3, 0x766c3b4d, 0x3649b37c, 0xe02714e5, 0x5553fa8e, 0x5176fd2f
.word 0x988fcc67, 0x8eddc1c0, 0x0f1ef2f6, 0xc2905c45, 0xdf240f48, 0x12af7a81, 0x74be75a6, 0xbbac822d
.word 0xd79238d9, 0x91e7ee57, 0xd1d96cc5, 0xdbe21af1, 0x1ad766a5, 0xdba99dd9, 0x5171cdb9, 0x2c6f695d
.word 0xcf9e8720, 0x22de6c4b, 0x29e0424d, 0x928dd6ff, 0x9cc6e52b, 0xc0cbd376, 0x881287d4, 0x0c3dfa56
.word 0x59567c60, 0x01d87313, 0x76601afe, 0x8c659394, 0x083869e5, 0xe59334f3, 0xb06a74a4, 0xd8fff049
.word 0xc9ccc71d, 0xac8721ac, 0x6de9b3d6, 0xbc1ae5f7, 0x595e946d, 0xdb839064, 0x747ba025, 0x60e01066
.word 0x7eba4aa8, 0x9b3a4f44, 0xd17fce47, 0xa747b6bc, 0x9813e947, 0x9679c3e7, 0x64341329, 0x0d04a08c
.word 0x601f1d01, 0x1a1acd35, 0x60cac882, 0xbf4a8282, 0x39640bbb, 0xd9994817, 0x5213d7aa, 0x389d1b9c
.word 0xc002af22, 0xe5bd6c88, 0x067172c8, 0x2383e299, 0x391b1230, 0x5167b749, 0x55cc9278, 0x91c6747a
.word 0x231270dd, 0x09eaac28, 0x572bf2ff, 0x782b7a3b, 0x87aa1424, 0xdf0dbe4d, 0x2ea86048, 0x5756b79a
.word 0x51f907b0, 0x51582f61, 0x58ae21a8, 0xec55f9a9, 0x4f9557a3, 0x06ca620b, 0x5170e425, 0x7327b0bd
.word 0xd325f045, 0xac4fb902, 0x4ca092c1, 0x9e57b8c8, 0x0ce7607c, 0xaea7d277, 0xd588f3b4, 0xea664761
.word 0x149e3fd1, 0xa51170f5, 0x806a67de, 0x223344c3, 0xd6650609, 0x65fc79d8, 0xb3f7d78b, 0xd5d59d07
.word 0x993291e3, 0x5d44a8d5, 0x370755d2, 0x5d9445a7, 0x0b4e0a2b, 0x083e3c11, 0xf74d8c90, 0x08d6b2e0
.zero 7168
mem_region_end:
