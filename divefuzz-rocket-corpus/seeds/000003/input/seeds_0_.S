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
  li x26, 0x0000000a002ae108
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
  li x1, 0xfd92e2f58d0a9442
  li x2, 0xeb737443cdcb6931
  li x3, 0x9adbfb5370738600
  li x4, 0xfb0918d9e1591d01
  li x5, 0xff3045a21aa2496f
  li x6, 0x434f588ac05f9ce9
  li x7, 0x6895c447a6dfff6f
  li x8, 0xe8f2f0398cce652e
  li x9, 0x0ecdf494bcecef40
  li x10, 0x944045aadec19d0e
  li x11, 0x6e46e0b544e785a4
  li x12, 0x370f8625795630af
  li x13, 0xb331a86482071ed3
  li x14, 0x034362dcf52fe834
  li x15, 0x50d56550017ccfb3
  li x16, 0x9997695d161d81ee
  li x17, 0xb4dc721ebd0a8a52
  li x18, 0x9f68442fe6fe1b4a
  li x19, 0x4cdd2c9015624b1a
  li x20, 0xe69834215acbeed6
  li x21, 0xc82a8e618884643d
  li x22, 0x3df1991583a59031
  li x23, 0x20fb64d0754926c9
  li x24, 0x460cb12ce2377af5
  li x25, 0x3e67efc8fdb9e1a4
  li x26, 0xc61243388921cc99
  li x27, 0xc858da041cb55246
  li x28, 0xeff95a843f223d12
  li x29, 0xc997a88c99af23de
  li x30, 0xe545ce091b1ce406
  li x31, 0xb8ef79d9483a447d
  li x5, 0xcea48ab4526b291f
  fmv.w.x f0, x5
  li x5, 0xa973f75e36529294
  fmv.w.x f1, x5
  li x5, 0xe9d6f2036f451e3d
  fmv.w.x f2, x5
  li x5, 0x9a42a3628bdcde5c
  fmv.w.x f3, x5
  li x5, 0x510b433ea98de4bb
  fmv.w.x f4, x5
  li x5, 0xee5f321ce2099066
  fmv.d.x f5, x5
  li x5, 0xf3716d425611562e
  fmv.w.x f6, x5
  li x5, 0x8a7386d783090900
  fmv.w.x f7, x5
  li x5, 0xcec3021769106825
  fmv.d.x f8, x5
  li x5, 0x1b932c1191dbd4e0
  fmv.w.x f9, x5
  li x5, 0x238fe11767856985
  fmv.d.x f10, x5
  li x5, 0xfb78ecd6b580f3c4
  fmv.w.x f11, x5
  li x5, 0x3bebc5cc297f1c13
  fmv.d.x f12, x5
  li x5, 0x73ac2168f6c2cf29
  fmv.d.x f13, x5
  li x5, 0xcd54bf54981e5340
  fmv.w.x f14, x5
  li x5, 0x7a0ccb349975edd7
  fmv.w.x f15, x5
  li x5, 0xceddfd1cca3115a4
  fmv.d.x f16, x5
  li x5, 0x6d2ed35e66c29fa8
  fmv.w.x f17, x5
  li x5, 0x9dc656e49376e9fd
  fmv.d.x f18, x5
  li x5, 0x7cc4bd48aaedc7ef
  fmv.d.x f19, x5
  li x5, 0x6d59fd51523eef3a
  fmv.w.x f20, x5
  li x5, 0xb5c69f132c244a0d
  fmv.d.x f21, x5
  li x5, 0xd3894e60e65c6338
  fmv.d.x f22, x5
  li x5, 0x0a8ad3552b9d0778
  fmv.w.x f23, x5
  li x5, 0xee6515b46f834e9b
  fmv.d.x f24, x5
  li x5, 0x96c9ff699ff601c0
  fmv.w.x f25, x5
  li x5, 0x354c7c8e6bacd810
  fmv.w.x f26, x5
  li x5, 0x0d3576f5a476fb4b
  fmv.w.x f27, x5
  li x5, 0x9e9b44db280d9d63
  fmv.d.x f28, x5
  li x5, 0x0e95551a73352c8c
  fmv.w.x f29, x5
  li x5, 0x1c410bdbc070fac4
  fmv.d.x f30, x5
  li x5, 0x24d9a1edc5d09048
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
  fcvt.d.lu ft9, s8, dyn
  subw s3, s3, s6
  mulhu a0, a0, a0
  sw s3, 1064(t6)
  fsd ft9, 680(t6)
  lbu tp, -1498(t6)
  fld ft4, -792(t6)
  fsw ft4, 1844(t6)
  xor a7, s0, tp
  sc.d.aq zero, s3, (t6)
  fmv.x.d a3, ft4
  flw fs3, 1700(t6)
  amomin.d.aq a0, tp, (t6)
  lwu ra, -644(t6)
  mulhu t1, sp, a3
  fcvt.s.d fs6, ft6, dyn
  remuw a1, a4, zero
  mul s5, gp, s5
  divw s11, s11, s5
  mulw s6, t4, t1
  mulhu s10, s6, gp
  fclass.d t4, ft9
  fcvt.w.d a7, ft6, dyn
  fsw fa5, -1048(t6)
  fcvt.l.s a1, fs2, dyn
  fmv.x.d a7, fa5
  mul a5, a1, a1
  fcvt.l.s s11, fa5, dyn
  fcvt.lu.s s8, fa5, dyn
  fcvt.d.l fs9, a5, dyn
  fcvt.lu.d t3, fs6, dyn
  subw s3, s11, s3
  divw a6, a6, s3
  fnmsub.d ft1, ft6, fa1, ft6, dyn
  fmul.d fs4, ft6, fs9, dyn
  fcvt.s.d ft4, ft4, dyn
  remuw a2, t3, a2
  fcvt.d.lu ft11, t3, dyn
  sc.w a5, t3, (t6)
  divw s7, t3, s7
  amomaxu.d s6, t0, (t6)
  remu s1, s6, a6
  fcvt.s.l ft7, a5, dyn
  amoand.w.aqrl gp, gp, (t6)
  fsw fs5, -868(t6)
  fsw fs4, 1780(t6)
  fmv.d.x fa4, a2
  amomaxu.w.aqrl t0, gp, (t6)
  divw tp, t0, s1
  fcvt.d.lu fs1, sp, dyn
  fcvt.l.s s10, ft6, dyn
  fadd.d fa4, fa7, ft7, dyn
  divuw t0, t3, t0
  ld s2, 1136(t6)
  fcvt.s.lu ft9, s2, dyn
  amomaxu.d.aqrl zero, t0, (t6)
  slt a5, zero, a5
  fsgnjx.d ft2, fs3, ft2
  mul sp, t0, a5
  amoswap.w a1, sp, (t6)
  slt a5, a5, a1
  fsw ft7, -1756(t6)
  fcvt.s.lu fs2, sp, dyn
  fcvt.lu.s s5, ft8, dyn
  fmin.d ft0, fs2, ft1
  amomax.w.aqrl s7, s5, (t6)
  div a6, sp, a5
  divw ra, s7, a6
  fsgnj.d fa1, ft8, ft3
  srai a3, a7, 21
  fcvt.s.lu fs7, a6, dyn
  fcvt.d.lu fa7, a4, dyn
  amoxor.d t0, s1, (t6)
  fcvt.l.s a2, ft3, dyn
  div s4, s4, ra
  mulhu a0, s9, t3
  fcvt.lu.s a7, fs7, dyn
  mulhu s3, s7, s4
  fcvt.s.l fs2, a0, dyn
  srlw a6, a7, a0
  fmv.d.x ft9, a0
  remw s5, s2, t4
  lr.w t0, (t6)
  srl s9, s5, s3
  jal gp, . + 32
  subw s0, a6, a0
  sraiw a3, sp, 0
  slliw tp, tp, 23
  fmax.d fa3, fa3, fs9
  amoadd.w.aq a6, t1, (t6)
  amominu.d.rl s5, gp, (t6)
  sc.w.aqrl s10, t2, (t6)
  fwd_0:
  sh s5, 1850(t6)
  fcvt.l.s s2, ft7, dyn
  fcvt.l.s s0, ft0, dyn
  fsqrt.d ft6, fa4, dyn
  sc.d.aq zero, s10, (t6)
  amomin.d.aq t4, s0, (t6)
  bge s2, s10, . + 20
  fmax.d fs9, ft0, fs5
  fsqrt.d ft1, fa3, dyn
  amomin.w.aq zero, s1, (t6)
  fence
  fwd_1:
  fcvt.l.d s7, ft6, dyn
  divu s5, zero, s0
  fadd.d fa2, ft7, ft7, dyn
  remu a0, t4, s7
  fsd fa2, -1440(t6)
  mulw s0, s2, a2
  amoxor.w.aqrl a3, a3, (t6)
  amoor.w.aqrl a7, a7, (t6)
  fcvt.s.lu fs6, a7, dyn
  fcvt.lu.s a5, ft10, dyn
  amominu.w.rl a4, gp, (t6)
  blt a4, a4, . + 20
  fmv.x.d gp, ft10
  sc.d.aqrl a0, t4, (t6)
  divw s8, s8, s8
  fcvt.s.lu fs3, a0, dyn
  fwd_2:
  beq a5, a0, . + 28
  fcvt.d.l ft4, a4, dyn
  remw s5, s9, s6
  srl sp, gp, a0
  amomaxu.d.aqrl t2, s5, (t6)
  mulhu s1, sp, t3
  fcvt.lu.s t4, ft9, dyn
  fwd_3:
  sraiw s6, sp, 0
  mulw s8, gp, t4
  remw t3, a1, s6
  mulw a2, zero, s6
  sc.w.aq a4, t3, (t6)
  divu tp, tp, s8
  amomax.w.aqrl gp, gp, (t6)
  fsw fs8, 644(t6)
  subw s8, zero, zero
  amomax.w.aq s5, s3, (t6)
  fmsub.d fs9, fa2, fa5, fs9, dyn
  amoadd.d.aqrl s7, s8, (t6)
  addw t2, s5, tp
  fmul.d fs7, fs4, fs6, dyn
  fcvt.l.d t0, fs8, dyn
  fcvt.d.l ft0, gp, dyn
  sw s7, -1368(t6)
  amomax.w.aqrl t4, t2, (t6)
  fcvt.d.s fs11, fa7
  fcvt.s.lu fa3, s6, dyn
  fcvt.lu.s s8, fs11, dyn
  beq s8, t4, . + 28
  slli a3, s0, 1
  mulhu a7, a3, a3
  amoswap.w.aq t3, t3, (t6)
  fcvt.l.d a2, fa5, dyn
  mulw s7, t3, a3
  fcvt.l.s a5, fs5, dyn
  fwd_4:
  fcvt.lu.s s9, fa0, dyn
  fmv.x.d s1, fs5
  lh s6, 266(t6)
  li a3, -1
  fcvt.d.wu ft4, s1
  flt.d zero, fa7, fa3
  fcvt.l.s s4, fa1, dyn
  div a7, s1, s8
  amoadd.w.aq tp, a3, (t6)
  fcvt.l.d a4, fs3, dyn
  fcvt.s.l ft9, a3, dyn
  slliw s0, tp, 1
  lui a2, 0
  fcvt.s.lu fa5, s0, dyn
  fcvt.s.l fs9, tp, dyn
  sc.d.aqrl s5, a4, (t6)
  sllw a0, tp, s11
  divw s1, s1, a0
  srliw t0, a0, 29
  fcvt.l.d a7, fa3, dyn
  divuw gp, s4, a7
  amomax.d.aqrl zero, a7, (t6)
  fmax.d fs4, fa3, fa3
  srli s3, t0, 1
  lr.w.rl a1, (t6)
  fdiv.d ft8, fs10, fa6, dyn
  fcvt.lu.s s5, fa6, dyn
  sc.d.rl s11, ra, (t6)
  ecall
  fsw fs1, -1580(t6)
  fsw fa3, -244(t6)
  remuw a0, a2, a1
  fmin.d fs11, fa6, fs5
  amominu.d.aq a5, s11, (t6)
  fcvt.s.d fs8, ft9, dyn
  sllw sp, sp, s11
  fcvt.l.d gp, ft3, dyn
  mulhsu t3, t4, s8
  remuw s2, s5, a3
  blt gp, gp, . + 36
  fmv.x.d tp, ft9
  remuw a6, s2, t0
  fsgnjn.d fs4, fa5, ft2
  srlw t1, a3, t0
  flw ft9, -644(t6)
  fcvt.lu.s s0, fs11, dyn
  flw fs9, -1812(t6)
  remu s11, tp, tp
  fwd_5:
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
.word 0x4ace6762, 0xfcf10f52, 0x2f19a9fc, 0x36420675, 0xddeacb94, 0x110ac316, 0xe416d3b5, 0x3b742f37
.section .mem_region, "aw", @progbits
.align 4
mem_region:
.word 0xbeaf3e8d, 0x8dc7f06b, 0x9da6d8f5, 0x1e4a5f03, 0x5ad010b9, 0x444c7b58, 0x1efde423, 0xa467ccba
.word 0x07ad7839, 0x34838411, 0x897bf0de, 0x79b6400f, 0x16d58732, 0x2b57d947, 0xfd73177c, 0xc9166cd3
.word 0xc05a1a47, 0xdc903dab, 0x0e68e445, 0x0a420a3f, 0xa57b6274, 0x8cd09e5d, 0x7a6e93d2, 0x8abcf122
.word 0x19e3b06a, 0x360ac9da, 0xc3c494f2, 0xa79d2a38, 0xbb824525, 0x22c00f13, 0x7bb12e2d, 0x54a2b5a9
.word 0xf3e620f3, 0x9b760145, 0xcc73c842, 0xd081fe2c, 0xfb081c98, 0x3210a144, 0xc05a0230, 0x52e3517d
.word 0x47244478, 0x90a813a1, 0xbe4f5972, 0x36075269, 0xabf1727f, 0x9947eb9a, 0x88119b0a, 0x111c1b98
.word 0xaf1cdd1d, 0x515d0ea6, 0xf2bdc51a, 0x06aba045, 0xf8b36934, 0x206117fc, 0x65bb9810, 0x6d655ba0
.word 0x87a4f072, 0x33d23264, 0x4a596b37, 0xcad8b5f6, 0x16872824, 0xd966e66e, 0xae42ec0a, 0x55476255
.word 0x7a069340, 0x974dda19, 0x7fce7844, 0xf6e4dbe6, 0x97fca08b, 0xd30ee455, 0xad83d755, 0xa4797eac
.word 0xfde529b3, 0xd240d932, 0x0b679e07, 0x3e88f47c, 0x354de021, 0xd77685dd, 0xd0eb17c7, 0xb57c0a94
.word 0x83e64035, 0x66867316, 0xa75bae64, 0xcd19af4b, 0x26902087, 0x4967517a, 0x96df5e34, 0x60a3f59f
.word 0x536cff27, 0xff82093f, 0xcdbfe645, 0xb0e4b9b9, 0xd1d080b4, 0xbc1fc270, 0x477ac8a9, 0x89882bf2
.word 0x9d134997, 0x48a2efe2, 0xfac629f3, 0x60f6e2cb, 0x90ae62e6, 0x347364c0, 0x4a85daa5, 0xa11ab274
.word 0xed605c83, 0x09f19db5, 0x4c34dea2, 0x311f621f, 0xb0f14929, 0x60208b69, 0xa06d6b87, 0x30dfc4a3
.word 0x19583704, 0x2ef092a0, 0x0d15be80, 0x50c02999, 0x765e1aa6, 0x53f6a766, 0x59a08fcb, 0x291b11b1
.word 0x7e23af4d, 0x233038a7, 0x82c5419b, 0x8caf31d9, 0x7f24c1c5, 0xeb59a3c7, 0x7e148d09, 0x98010b9e
.word 0x4cdd1191, 0x7e0eff67, 0x4abf864e, 0x5f33f8a2, 0x317e2451, 0xd55d3e12, 0xb0af49cc, 0x74683b54
.word 0x35493c93, 0xf0537e8a, 0x89822fab, 0x6175d0be, 0xe679f75a, 0xde64df4a, 0x747d10c2, 0xdac4d4a6
.word 0x2c55ee80, 0xf8a718d0, 0xd0bfe630, 0x6a85a717, 0x7a8610ad, 0xd3d9b3f6, 0xad9c2873, 0x3c55371d
.word 0x19073684, 0x87ed839e, 0x5876e854, 0x5dfa2298, 0xed49e907, 0x6d36def8, 0x943315ae, 0x64761d71
.word 0x9bbbf6e9, 0x0babd4c2, 0xf216a9b4, 0xbaad0efb, 0xbc15d389, 0xeb3d249b, 0xc369debb, 0x41481c6d
.word 0x27c791cf, 0xb223e16a, 0x7867bb02, 0x1e855b14, 0x22c024a0, 0x76c2bd57, 0x8cb6da05, 0xcbe2a0e0
.word 0x11130086, 0x8ce39e8f, 0x0902d404, 0x78d8b258, 0x6f9a813f, 0xa5a19e24, 0xb696a706, 0xf144af7c
.word 0x88016f48, 0x599e8c05, 0x47502b1c, 0x0e3f0e83, 0xd1f88a07, 0x48e5d3ec, 0x405757d6, 0xd5f6e48d
.word 0x3b098460, 0x06f84b1e, 0x1ca19433, 0x8df5705a, 0x17bdbcab, 0x5f858d5e, 0x1a094f82, 0xc8cd743d
.word 0xf6e1fd3a, 0xe2a32755, 0x33d02233, 0xdc018dfc, 0x283384e8, 0x74ee7778, 0xe4a5d945, 0xe00f0cbf
.word 0xf01f3c26, 0xbe1e0665, 0x15bf4f57, 0x81125f07, 0x559876dd, 0x431253d4, 0x3dd32d9a, 0xc7cbac95
.word 0x5d45aaaf, 0xa87e7a39, 0x15a88e6a, 0xa8cbd38e, 0x4dca6efd, 0x68394fcb, 0xb8911227, 0xa5336771
.word 0x3c686c38, 0x7a8f460a, 0xfc811cea, 0xc81e11ae, 0xcfb13b88, 0x2b09151a, 0x5d38357f, 0xee5e6706
.word 0xd9d9b096, 0x957902d6, 0xdd13e2b4, 0x325602a9, 0xeb995f96, 0x5e32d3f7, 0xf688e1d0, 0xcf31f20c
.word 0x717120b9, 0xce0920fe, 0xb8dae54a, 0x117685eb, 0x63dfde20, 0x329106c2, 0xfa324c90, 0xe670c7fd
.word 0xc4a8f5cf, 0x38d9fcaa, 0xa55a86f9, 0x749753aa, 0xb6e73035, 0xfd31ad50, 0x67fd3975, 0xec4ced90
.zero 7168
mem_region_end:
