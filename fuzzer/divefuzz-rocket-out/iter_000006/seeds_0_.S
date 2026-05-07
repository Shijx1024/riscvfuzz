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
  li x26, 0x0000000a003dc020
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
  fsrmi 2
  csrwi fflags, 0
  li x1, 0xbf1b6101f25828d8
  li x2, 0xdbdacc81d6807779
  li x3, 0xa7451250bd580ce6
  li x4, 0x5560090d7c344064
  li x5, 0x2334b95f6d930ddc
  li x6, 0xe4b6dafd9433e5f8
  li x7, 0x9c8c2572c6a4df74
  li x8, 0x1868314174bddb8b
  li x9, 0x7954dd19984e3157
  li x10, 0x46915f481254dafb
  li x11, 0x03768cb58f15d370
  li x12, 0xcbd9dde86c0c737f
  li x13, 0xc9f4a8f42b6f47b6
  li x14, 0xa32ba22a41a8f54d
  li x15, 0xb944d250f875d94f
  li x16, 0xa0a9b3a28f07e526
  li x17, 0x8ac493027b8267b7
  li x18, 0x1cda08f9b8b8eb3d
  li x19, 0x46cff1e2c73b2457
  li x20, 0x7da00794965e707e
  li x21, 0x16375d9172f16d2d
  li x22, 0x79f85d9c83cf34cc
  li x23, 0x3a8f53dc556049ab
  li x24, 0x4ad543febd685e07
  li x25, 0x66616881e3bee35b
  li x26, 0xcf2bda04c8d896a4
  li x27, 0x5924cc2e140c7086
  li x28, 0xdb667bc08f5215a6
  li x29, 0x38f5f8aa902c0f75
  li x30, 0xc1fa5ccaeb0fd1e5
  li x31, 0x496b69aa6993e931
  li x5, 0xe9f4490e52785d61
  fmv.d.x f0, x5
  li x5, 0x586f3352f2ba5dae
  fmv.w.x f1, x5
  li x5, 0xa1155bb17848cbdc
  fmv.d.x f2, x5
  li x5, 0x3a82c60571483abf
  fmv.d.x f3, x5
  li x5, 0xfed388cc26af6c55
  fmv.d.x f4, x5
  li x5, 0x39673b93e58bbb5c
  fmv.w.x f5, x5
  li x5, 0x9d8668205cd7502e
  fmv.d.x f6, x5
  li x5, 0x3fe604b3620a2af6
  fmv.w.x f7, x5
  li x5, 0x3c4fe00c772d5347
  fmv.d.x f8, x5
  li x5, 0xffb74b17d21b8fd2
  fmv.d.x f9, x5
  li x5, 0xba4895b53037875b
  fmv.w.x f10, x5
  li x5, 0x9e111cc937d04f4e
  fmv.d.x f11, x5
  li x5, 0x18cb165652c17183
  fmv.d.x f12, x5
  li x5, 0xcd2d1b114cfa841b
  fmv.d.x f13, x5
  li x5, 0xfe584827ed22c6c7
  fmv.d.x f14, x5
  li x5, 0x72b3c9124c4991e7
  fmv.d.x f15, x5
  li x5, 0x0172339e5b8d01fb
  fmv.d.x f16, x5
  li x5, 0x5a0965105e02cb72
  fmv.w.x f17, x5
  li x5, 0x87df026881fb0001
  fmv.w.x f18, x5
  li x5, 0x047352b7c3001f23
  fmv.d.x f19, x5
  li x5, 0xc9f2a043f2b395a6
  fmv.d.x f20, x5
  li x5, 0x8eb3052bb998c6bd
  fmv.d.x f21, x5
  li x5, 0x7370ece28b881e10
  fmv.d.x f22, x5
  li x5, 0x9619d71ea621b113
  fmv.d.x f23, x5
  li x5, 0x04471ee97afc468a
  fmv.w.x f24, x5
  li x5, 0xbcae96071c3f64a3
  fmv.d.x f25, x5
  li x5, 0xa89e5458a3e55fe4
  fmv.d.x f26, x5
  li x5, 0xfae75beb76159e3e
  fmv.d.x f27, x5
  li x5, 0xcef880e0b99e41b2
  fmv.w.x f28, x5
  li x5, 0x1ea7a8b621760ab0
  fmv.w.x f29, x5
  li x5, 0x404f76c5fa6f6092
  fmv.w.x f30, x5
  li x5, 0x36745d903829884f
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
  bgeu a6, a0, . + 28
  srliw s10, s1, 31
  fmadd.d fs5, fs5, fs5, fs5, dyn
  flw fa5, -1456(t6)
  amoor.d.rl a4, s10, (t6)
  divw a1, a1, s10
  lui ra, 1048575
  fwd_0:
  amoadd.d.aq s2, ra, (t6)
  srliw s8, s10, 19
  fsub.d ft9, fs5, fa5, dyn
  amoswap.w.aq t4, s8, (t6)
  amoadd.d sp, s1, (t6)
  amoadd.d.aq a2, a2, (t6)
  flw fa2, -1560(t6)
  amomin.w.aqrl zero, a2, (t6)
  divw s10, zero, t4
  srai s9, sp, 21
  fcvt.lu.d s1, fa2, dyn
  fmv.x.d s2, ft9
  fcvt.l.s t3, fa5, dyn
  srl s1, zero, zero
  bne zero, s2, . + 16
  sraw a7, a4, a7
  fcvt.lu.s a3, fs1, dyn
  fmv.x.d sp, ft9
  fwd_1:
  divw ra, ra, t3
  srlw t4, t3, a3
  fcvt.l.s zero, fs6, dyn
  lr.d s11, (t6)
  amoadd.w.aq t2, t2, (t6)
  fmv.x.d gp, ft1
  subw t3, t3, s1
  beq zero, t3, . + 32
  remuw a1, t3, t3
  divw sp, a1, t2
  div t4, sp, gp
  fsqrt.d ft6, fs7, dyn
  amoadd.w.rl a0, sp, (t6)
  rem s10, s10, t4
  fmul.d ft10, fs7, ft6, dyn
  fwd_2:
  auipc a0, 0
  addi a0, a0, 36
  jalr s7, 0(a0)
  fcvt.lu.s t2, ft0, dyn
  lr.d.aqrl a7, (t6)
  mulhu a1, s5, s10
  amoxor.w.aq s9, s6, (t6)
  srai s9, s10, 0
  flw fs11, 524(t6)
  fwd_3:
  fcvt.s.l ft9, a7, dyn
  subw gp, a2, a1
  divw s6, s9, s9
  fld fs10, -1160(t6)
  fsgnjn.d ft0, fs10, fs9
  amoxor.w.aqrl a3, gp, (t6)
  mul a2, a3, gp
  fcvt.lu.d s1, ft4, dyn
  remuw s4, s4, s4
  srli zero, t0, 28
  remu s3, tp, s3
  divw gp, tp, s4
  divw a5, a6, tp
  amoswap.d s0, a0, (t6)
  sub a0, zero, a5
  divuw a6, s0, s0
  remuw a7, a7, a0
  fcvt.s.lu fs10, a5, dyn
  srai s6, s0, 1
  fcvt.s.l fs3, t4, dyn
  sd a6, 944(t6)
  amoxor.d s1, s6, (t6)
  amoadd.d.aq ra, ra, (t6)
  fcvt.l.s s0, fs8, dyn
  lhu a0, 1826(t6)
  slli t1, s1, 1
  mulw gp, a7, s3
  lb sp, 1564(t6)
  fmv.d.x fa1, sp
  fcvt.d.l fs11, a5, dyn
  divuw a2, t4, a2
  sd s5, 1064(t6)
  fcvt.s.lu fa7, gp, dyn
  fsd fa1, 96(t6)
  subw t3, a2, a0
  amomin.w.aqrl t0, gp, (t6)
  amomaxu.d a7, s8, (t6)
  fcvt.s.l fs8, t0, dyn
  mulhu s10, s11, t0
  fsw fa7, 0(t6)
  mulhsu a3, s10, s10
  sltu s4, t0, t3
  fmul.d fa2, fa2, fa7, dyn
  sllw t4, a7, s10
  fmv.d.x fa4, t0
  rem t2, a3, s10
  lr.w.aq a0, (t6)
  fcvt.s.lu ft11, s5, dyn
  fcvt.d.l ft2, a4, dyn
  sraiw a6, s11, 0
  fdiv.d fs8, ft0, fs8, dyn
  flt.d s6, ft11, ft0
  divw gp, t3, s11
  slt s10, a6, gp
  srli s0, s3, 11
  fcvt.l.s t4, fs9, dyn
  srlw t0, s0, t0
  mulw s4, s10, t0
  fsub.d ft10, fs2, ft10, dyn
  auipc t3, 0
  addi t3, t3, 44
  jalr s6, 0(t3)
  ld a5, 312(t6)
  fcvt.s.l ft11, s0, dyn
  xor t0, t4, t0
  amomax.d.aqrl a2, t0, (t6)
  amoand.d.rl a0, a0, (t6)
  flw fa2, 572(t6)
  lw s0, -1348(t6)
  fcvt.s.lu ft9, a2, dyn
  fwd_4:
  amoand.d s7, s7, (t6)
  fsw fs10, -460(t6)
  fsw ft4, 1280(t6)
  fsw fs9, 180(t6)
  fnmsub.d ft5, fs9, fs9, ft5, dyn
  fmadd.d fa4, fs8, fs5, ft3, dyn
  sc.w a6, a6, (t6)
  fmv.x.d s10, fs9
  remw tp, s10, s2
  amoswap.w s8, t3, (t6)
  sc.w.aqrl s0, s0, (t6)
  fcvt.d.lu fa2, s0, dyn
  fcvt.l.s s7, fa2, dyn
  fcvt.s.d ft10, fa0, dyn
  fsw fa0, 668(t6)
  fcvt.w.d a5, fa7, dyn
  fsw ft8, 144(t6)
  amoswap.w.rl a1, s8, (t6)
  fclass.d ra, ft8
  fmv.x.d t3, ft2
  sraiw s0, ra, 0
  xor gp, s0, t3
  jal s5, . + 20
  mulw a7, a7, s5
  subw a1, a4, a1
  amoand.w.aqrl t2, s5, (t6)
  remuw tp, a1, a1
  fwd_5:
  fcvt.l.s a3, ft4, dyn
  amomax.w a0, a3, (t6)
  fmv.x.d sp, ft8
  fcvt.d.lu ft9, sp, dyn
  lr.d.aqrl a5, (t6)
  fcvt.l.s t2, fs2, dyn
  fsqrt.d ft11, fs2, dyn
  fsw fs2, -108(t6)
  remw a7, s8, a0
  fle.d a7, ft6, ft4
  divu t4, a5, a0
  fcvt.s.l ft5, sp, dyn
  auipc a7, 0
  addi a7, a7, 40
  jalr a3, 0(a7)
  mulw a6, a1, s0
  remw s7, s7, t4
  fcvt.s.l ft0, s7, dyn
  sll s11, s11, s3
  srlw s2, a3, s2
  srli s10, a6, 0
  amoxor.d.aqrl s1, s10, (t6)
  fwd_6:
  fmv.x.d t4, ft0
  fcvt.l.s s8, fs5, dyn
  div s3, s5, s8
  remuw a0, s3, s0
  bge s0, a3, . + 32
  fcvt.d.l ft7, s1, dyn
  fmv.d.x fs8, t4
  fmv.x.d gp, ft7
  srli a1, a5, 63
  remuw s1, s3, s1
  amoxor.d.aqrl s4, s4, (t6)
  remw a7, gp, zero
  fwd_7:
  sc.d.aqrl s4, a4, (t6)
  lr.w.rl t4, (t6)
  bge s11, s4, . + 40
  li s2, -317646552780
  fmax.d fs0, fs8, fs1
  amoand.w.rl s8, s8, (t6)
  addiw s0, s4, -2048
  fsgnj.d fs3, fs0, ft0
  fcvt.d.l ft4, a7, dyn
  fwd_8:
  amomin.d.rl s6, t4, (t6)
  fcvt.d.l fs10, s8, dyn
  amoswap.d.rl a7, s0, (t6)
  fsw fs7, 1828(t6)
  srli s7, a7, 0
  lui a0, 489707
  lui t1, 1
  fcvt.s.l ft11, a0, dyn
  remuw s10, a0, s7
  fsd fs10, -1832(t6)
  amoor.w.aq t0, t0, (t6)
  sc.w s5, zero, (t6)
  amoxor.d.aq a7, a5, (t6)
  auipc a1, 1048575
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
.word 0x30a06386, 0x1b6ebbd6, 0x60b10e8d, 0x84420d5c, 0xa7ea6b20, 0xd1cd7779, 0x69369997, 0xe8e16f1e
.section .mem_region, "aw", @progbits
.align 4
mem_region:
.word 0xb02ef5b0, 0xd296b56f, 0x859e88ea, 0x2aafbf22, 0x13a00e8c, 0x52d8c9a4, 0xda2f8ece, 0xdaa2d1e2
.word 0xe7a28ce3, 0x4e92ded1, 0x31abe865, 0xad6810ab, 0x71b0f53f, 0xe22b9b7c, 0xc51a92e8, 0x1fcf039d
.word 0x12c3ab9e, 0xfa536d11, 0x5b678d73, 0x99a4e32f, 0x32a9e60c, 0x26665b08, 0x17025b6c, 0xe9903f13
.word 0xe7415c6a, 0xd05b207c, 0x9314725e, 0xd57faa29, 0x7a2df02e, 0x30c9a637, 0xa6a7e181, 0x594db0aa
.word 0x766ee463, 0xfee01e6d, 0x03c4deb2, 0x3fb7dc2b, 0xdcd6e8ea, 0xabf0f5f5, 0x9d3f34a9, 0x23114540
.word 0x7b535013, 0xa15cdcbb, 0xf311cf24, 0xdc5698a1, 0xb0fabcc9, 0xc9ed2146, 0x9672d1e2, 0x25af6a8d
.word 0x5f82f6c6, 0xf0e08ab3, 0xa7eb3453, 0x25d9a66d, 0x990dae50, 0x53122ed8, 0x8f5be474, 0xafaa4485
.word 0x2a651652, 0x80d1a6d6, 0x4abb3d5f, 0x2bd8d85e, 0x35ea220a, 0x6ac2ad02, 0xe8f969fe, 0x5bb6f314
.word 0xd350fcb2, 0xf6aeca33, 0x335e7738, 0x9199cf16, 0x737cd666, 0xb6922677, 0x30d4c0fc, 0x96f6b311
.word 0xdff96451, 0x988f0721, 0xdfb88b1b, 0x34a0a0c9, 0xb51f9dc8, 0x2205c57d, 0xf2105e1e, 0x6ff6d443
.word 0xe5c867ee, 0xb3b07500, 0x475e84a8, 0xb742a875, 0x00d3b398, 0x59dbff0c, 0x0ff38396, 0x6abd3795
.word 0x970dc3af, 0x167dcfd7, 0x9933f4f6, 0xe2148913, 0x584ebc80, 0xfda0723b, 0xf216307c, 0x3253f810
.word 0xe8c59a5f, 0xe51860d6, 0xad9d2a5e, 0x4b6675f9, 0x62668671, 0x81bd4b6a, 0xdac30285, 0x8c89772d
.word 0x7cd32141, 0x33df3738, 0xc6b81892, 0x4c864064, 0xe2174b02, 0x85617cdf, 0x8d8ee2a0, 0x4456a537
.word 0x3526fb3f, 0x81199713, 0x1a15e790, 0x9788644a, 0x41323fdf, 0x568bc2b1, 0x9d941886, 0x3389c9d2
.word 0x4c091af0, 0x50c39b34, 0x15a76cc0, 0x1b62a084, 0x5f8eaa2b, 0x7cc75cbd, 0xfe969dab, 0x95fd1eaf
.word 0x18eb8280, 0x5bac42e9, 0x68b028e2, 0x4f87d7b6, 0x321cd2cf, 0x0306ce72, 0x97ac5b8b, 0xbd43f543
.word 0xfcbee865, 0x43212a50, 0x2ba6bf93, 0x7582e08e, 0x717417f3, 0xf45da699, 0x1ad91357, 0xeb65e13a
.word 0xf4a56af5, 0x7ea46565, 0x266cae02, 0x30f0498b, 0x88aac23b, 0xbc1fc6c6, 0x06f93973, 0xb9cde719
.word 0xe6cd19da, 0x7d202ef3, 0x5cd50985, 0xbfb98cb8, 0xb84df44f, 0x7fdbdd61, 0x7ebf13a9, 0x7fe53a74
.word 0x287c62cb, 0xb8826cf2, 0x8f9c5c1b, 0x737d2bf0, 0x11017f5f, 0x2b6e57b2, 0x2e0a90cc, 0x4c0c4a88
.word 0x8ef955c9, 0xcbd175e0, 0x5db08bea, 0x6da737f6, 0xcff886f6, 0xcaa06cae, 0xddc9ff16, 0x9c03ae8d
.word 0x2a336178, 0xdc134792, 0x2d6926fd, 0x2f47e8ba, 0x896e8cb5, 0x18f0bf7e, 0xf37691b8, 0x6e2b7e84
.word 0x5a193c56, 0x12fb7b7e, 0x3447105f, 0xcf17eba8, 0xa738eb04, 0x69fbd145, 0xd0176a93, 0x27d3fc31
.word 0x10fad3ab, 0xfcb508d0, 0x7e050de9, 0x72533dff, 0xbee10e08, 0xdc2833c7, 0xe81f38a3, 0xaab85bd9
.word 0x190740e3, 0xd44bcc75, 0xb892241a, 0x7575650a, 0x71ce9313, 0x666658e2, 0xc779d260, 0x8c9d014c
.word 0x72b01e2f, 0xacefb3dc, 0x7d4a703f, 0x54c50a2c, 0xc33309f2, 0x964269ea, 0x41b2d674, 0x369c7386
.word 0x88a47e31, 0xccb0e659, 0x71bbac41, 0xee26a7c4, 0x89d59999, 0xe3c345de, 0xad73c58c, 0x520b6408
.word 0x90c9b0c6, 0x043578ae, 0x1fb788da, 0x4111973a, 0xe0e6d6e4, 0x62c5527a, 0xcd8a3c7c, 0xa0c25937
.word 0x01907127, 0x621f378d, 0xcf85625f, 0xb58c200d, 0x15770ba6, 0xf7fe1302, 0xdce32b5c, 0xa002cdb0
.word 0x7a215b82, 0x7bb9f959, 0x43edd2b5, 0x911054d7, 0x18a0e2f4, 0x5cef6a63, 0xb3027149, 0x94b4fcd2
.word 0x2204da31, 0xbbd32087, 0x666962f1, 0x14cc3a5e, 0x46ac8921, 0xf83fcbfd, 0xe512cfe6, 0x0553e505
.zero 7168
mem_region_end:
