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
  li x26, 0x0000000a004b40a8
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
  li x1, 0x6fa36c91796f6d49
  li x2, 0x0544e2a7353ffc8d
  li x3, 0x06042668d33611ae
  li x4, 0x5c06f207c39a12fc
  li x5, 0xb720babe405cf2e5
  li x6, 0x13d50ef42c3757d8
  li x7, 0x412271fa57ab495f
  li x8, 0x635d25c457d9d51a
  li x9, 0x4904251e4382fd1c
  li x10, 0x214f4df2dd1979d9
  li x11, 0xff69304ddc14cf12
  li x12, 0x8a6fd1ac49ed8337
  li x13, 0xd82ce73238921900
  li x14, 0xceab30ac466d9688
  li x15, 0x1f986d3406451020
  li x16, 0x166d8c045c3a1a0c
  li x17, 0xb06575957caa66f9
  li x18, 0xc68e540b680de377
  li x19, 0x1cc81869618bae89
  li x20, 0xdbdc4d3ed1ec120b
  li x21, 0x07d3f16510be3de9
  li x22, 0x8c10cc85ad3a78c1
  li x23, 0x24386e9558ae0d56
  li x24, 0x3a830a6c5dc0f093
  li x25, 0x1aa877392f606724
  li x26, 0xf4c55694ab804de7
  li x27, 0x362a99e54a257ac3
  li x28, 0xdc3c7411464ebee7
  li x29, 0xfddad71b6b5d71b7
  li x30, 0xd6b49f196ab8a625
  li x31, 0xbb1bf4e3868a0cee
  li x5, 0x1fd7cd70c2126b36
  fmv.d.x f0, x5
  li x5, 0x5c89b04bf3c40592
  fmv.w.x f1, x5
  li x5, 0x892107d8a3e1afd7
  fmv.w.x f2, x5
  li x5, 0x9a9c767d86139576
  fmv.d.x f3, x5
  li x5, 0x1e5bed2333efa513
  fmv.d.x f4, x5
  li x5, 0x3e3f5a1d1b11ba38
  fmv.w.x f5, x5
  li x5, 0x3803805033bc7372
  fmv.w.x f6, x5
  li x5, 0x73937330c1fc6e11
  fmv.d.x f7, x5
  li x5, 0xdf0d8bd21b8a902a
  fmv.w.x f8, x5
  li x5, 0x8eb9ec4071f46243
  fmv.d.x f9, x5
  li x5, 0x738010d22e50c6a1
  fmv.d.x f10, x5
  li x5, 0x28c17d43fa7eb6cb
  fmv.w.x f11, x5
  li x5, 0xae14e636c0fe20ea
  fmv.w.x f12, x5
  li x5, 0xb5cfe7af05103f91
  fmv.d.x f13, x5
  li x5, 0x1dbf677cb899bd4e
  fmv.d.x f14, x5
  li x5, 0x61ce8236f0184eec
  fmv.w.x f15, x5
  li x5, 0x2dc2807f707c5f78
  fmv.w.x f16, x5
  li x5, 0x2faf6bc97b3d7fc5
  fmv.d.x f17, x5
  li x5, 0x8daa8cf1fd8a9c01
  fmv.d.x f18, x5
  li x5, 0x56dcb08a4a93e75d
  fmv.d.x f19, x5
  li x5, 0xd9c5900ddb147aa0
  fmv.w.x f20, x5
  li x5, 0x98e472b97ec85562
  fmv.d.x f21, x5
  li x5, 0x4c9eefa982e84eb5
  fmv.d.x f22, x5
  li x5, 0xaca7da9e658e2dde
  fmv.w.x f23, x5
  li x5, 0xa44dd9eaedbcfe80
  fmv.w.x f24, x5
  li x5, 0xeebe6140113d4f20
  fmv.w.x f25, x5
  li x5, 0xaafaf95bee53fd07
  fmv.d.x f26, x5
  li x5, 0x6cd58b0020d9733e
  fmv.w.x f27, x5
  li x5, 0x1b4384a6bb35343b
  fmv.d.x f28, x5
  li x5, 0xd7f14ed53b72eb94
  fmv.w.x f29, x5
  li x5, 0x41556e64d6b606de
  fmv.w.x f30, x5
  li x5, 0x6aa289f3ef4aa20b
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
  fcvt.lu.s sp, ft0, dyn
  fcvt.s.lu fs1, sp, dyn
  fcvt.lu.s t1, fs1, dyn
  srai t0, t0, 1
  fmv.x.d a4, fs1
  mulw tp, a4, t1
  fcvt.d.lu fa3, sp, dyn
  amomaxu.d.aqrl a7, a4, (t6)
  fcvt.d.l ft6, sp, dyn
  fcvt.s.lu fa7, t1, dyn
  flw ft4, -868(t6)
  fcvt.d.l ft1, t0, dyn
  mulhu s1, a4, tp
  fcvt.l.s s9, ft1, dyn
  fsgnjx.d fs6, fa3, ft1
  amomaxu.d.rl s4, s4, (t6)
  remu ra, s4, tp
  fcvt.s.lu ft1, s4, dyn
  amomax.d.aqrl t3, s1, (t6)
  fcvt.l.d s11, ft6, dyn
  remuw a7, t3, s11
  auipc s8, 767050
  fcvt.lu.s s9, fa6, dyn
  addi s5, s5, 1
  fcvt.d.lu ft3, s8, dyn
  fcvt.d.wu ft8, s8
  bge t0, a7, . + 28
  fcvt.d.l ft0, s1, dyn
  lb sp, 1753(t6)
  sub s0, s9, a7
  fcvt.s.l ft1, s0, dyn
  fle.d t2, ft0, ft6
  fcvt.d.wu fa6, t2
  fwd_0:
  fcvt.lu.d t0, fs6, dyn
  fcvt.l.s tp, fs7, dyn
  fcvt.d.lu ft8, t2, dyn
  fnmadd.d ft6, ft8, fs7, ft8, dyn
  divu s2, sp, tp
  srlw gp, s11, s0
  fcvt.s.d ft1, ft6, dyn
  fcvt.lu.s s6, ft6, dyn
  flt.d s5, ft6, fs7
  mulw a2, s6, s6
  amomax.w.aqrl t1, a2, (t6)
  fmv.d.x fa5, s5
  fcvt.lu.s s10, fs5, dyn
  li s11, 1
  bwd_0:
  amoxor.d.aqrl ra, s10, (t6)
  flw fs6, 100(t6)
  amomin.w.aq a3, t4, (t6)
  sraiw s6, sp, 15
  slliw s9, s6, 31
  addi s11, s11, -1
  bne s11, zero, bwd_0
  amomin.w.rl s3, ra, (t6)
  fsw ft1, 556(t6)
  mulhu sp, s6, a7
  fmsub.d fa3, ft8, fa5, fa7, dyn
  fmv.d.x fs11, a1
  fcvt.s.l fa5, a4, dyn
  sraiw a2, s3, 0
  fcvt.s.lu fa3, a1, dyn
  lr.w.aqrl s2, (t6)
  subw t1, s2, a5
  fcvt.lu.s a4, ft1, dyn
  lb a7, -1538(t6)
  fcvt.w.d s3, fa7, dyn
  srli s11, a4, 31
  fmv.x.d a5, ft6
  fcvt.lu.d a0, fa5, dyn
  fsw fs9, 1892(t6)
  fsw fs11, -828(t6)
  fcvt.lu.d s8, fs11, dyn
  amoor.d.rl sp, s10, (t6)
  auipc a6, 0
  addi a6, a6, 40
  jalr a7, 0(a6)
  ori zero, sp, 1
  remu sp, a7, a5
  remuw t4, a0, t4
  flw fs10, 540(t6)
  fcvt.s.l fa5, sp, dyn
  amoxor.d.aq t3, s8, (t6)
  lw a5, 772(t6)
  fwd_1:
  amomax.w s3, a5, (t6)
  sllw a4, t3, a5
  fcvt.s.l ft6, s3, dyn
  amomaxu.w.rl sp, sp, (t6)
  fcvt.l.s s10, ft6, dyn
  fmax.d ft5, fs11, fa7
  addw t2, s11, s3
  fcvt.lu.d a2, fs1, dyn
  add tp, t0, gp
  amoor.w.aqrl s6, s10, (t6)
  fcvt.l.s s2, fs11, dyn
  amomax.d.aqrl gp, s10, (t6)
  amomax.w.aqrl t4, tp, (t6)
  fcvt.d.l fs1, t2, dyn
  ori a4, t2, 1
  sra a5, t4, a5
  fle.d s2, ft10, fs6
  amomaxu.w.rl t0, t0, (t6)
  fsw ft10, -1004(t6)
  div a5, a0, a0
  addi s7, s7, -1298
  amomaxu.d s8, s8, (t6)
  amoand.d ra, t0, (t6)
  sc.w.aq s11, a5, (t6)
  sra a1, s8, ra
  fcvt.l.s s6, fa6, dyn
  fmv.x.d t0, ft5
  fcvt.s.l ft9, t0, dyn
  sraiw t1, a0, 4
  fsqrt.d fs0, ft9, dyn
  amoswap.d.rl s0, a0, (t6)
  and a6, t0, s11
  mul s11, s6, s11
  divw t3, t1, t3
  bltu a6, a5, . + 36
  mulhsu t4, s11, t1
  flw fs5, -1824(t6)
  flw fs3, 776(t6)
  mulhu s9, a6, s11
  mulw sp, s9, sp
  fcvt.l.d s7, fs0, dyn
  rem tp, s9, s9
  fcvt.lu.d s6, fs5, dyn
  fwd_2:
  fcvt.l.d s10, fs9, dyn
  amoor.w a6, a6, (t6)
  li s2, -549755813888
  fmv.d.x fs4, s6
  lr.d.aqrl a0, (t6)
  fcvt.s.lu ft3, tp, dyn
  divuw t0, s10, s2
  fcvt.l.s a7, fa5, dyn
  fcvt.l.d s4, ft9, dyn
  amoxor.w.aqrl a5, s4, (t6)
  sra s11, s11, a5
  mul sp, a5, a7
  mulhu a3, s4, sp
  remw s7, a5, a6
  sraw ra, s11, ra
  srli s9, s1, 60
  fcvt.l.s s8, fa7, dyn
  sc.w s4, s8, (t6)
  amomin.d.aqrl s11, s8, (t6)
  sraw s0, s6, s0
  fcvt.w.d a0, fa5, dyn
  divu a1, s0, s4
  beq a1, s11, . + 32
  fcvt.d.lu fa7, a1, dyn
  fcvt.s.lu fs9, a1, dyn
  flt.d a0, fs3, fs7
  flt.d t4, fa7, fs7
  mul gp, a1, a0
  div sp, a0, a0
  slliw t2, gp, 0
  fwd_3:
  fsw fa7, -1644(t6)
  sc.d.aq a4, t0, (t6)
  feq.d tp, fs9, fs9
  divw a2, tp, a2
  mulhsu ra, ra, s11
  fsw fa6, -1240(t6)
  mul s8, ra, a2
  fcvt.d.l fs1, s2, dyn
  srl gp, a2, s8
  mul s4, a4, s4
  fcvt.lu.d a1, fs9, dyn
  sub t4, ra, s8
  fcvt.lu.d sp, fa6, dyn
  fmadd.d ft1, fs3, fa6, fs6, dyn
  fsub.d fa4, fs2, fa6, dyn
  subw s5, tp, s7
  fcvt.s.l ft4, s5, dyn
  addw t4, t1, zero
  div a3, a3, t1
  srli a2, a3, 0
  amoswap.d.rl sp, a2, (t6)
  remuw t3, a3, sp
  amomaxu.d.aq t2, a2, (t6)
  fcvt.d.l ft0, a2, dyn
  amoadd.d.aqrl ra, a3, (t6)
  or s1, t3, a4
  fcvt.lu.s a0, ft0, dyn
  fadd.d ft1, fs7, fa5, dyn
  sc.w.rl s7, tp, (t6)
  remuw s1, s10, s1
  remw t2, s10, s1
  fld fa6, -1008(t6)
  amomin.d.aq s8, s10, (t6)
  fsub.d fs11, fs9, fs0, dyn
  fcvt.lu.d a0, fa1, dyn
  beq s1, s9, . + 24
  lwu t0, -1260(t6)
  amomin.w.aqrl a4, t2, (t6)
  fle.d s9, fs11, fs4
  fcvt.d.lu fs2, s8, dyn
  ebreak
  fwd_4:
  fcvt.l.d s3, fs4, dyn
  fcvt.s.l fs9, a2, dyn
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
.word 0x4b3928a0, 0xaef9ab18, 0x235e5865, 0x7540adae, 0x1b589d5f, 0xe55085c2, 0x2f5aad2e, 0xddb99cf3
.section .mem_region, "aw", @progbits
.align 4
mem_region:
.word 0x0462d698, 0x11f4668f, 0x6170d5ce, 0x6f026df7, 0x15b13593, 0x9429064b, 0x0cef2a87, 0x9d4aa0e3
.word 0x4adbcad5, 0x935ec286, 0x9bb1f2e1, 0x7a73a5c6, 0x855e9c2d, 0x8dd8e865, 0x44687b8c, 0xe91d35ed
.word 0xa9bb454e, 0xd9219c1c, 0xc13eb234, 0xbc7406b0, 0x788283cd, 0x2e554c5f, 0xe2cf5f42, 0xab9a5f2a
.word 0x8baafe57, 0xcc64723e, 0xf44b347e, 0xede10711, 0xed0f0a09, 0x9b49832a, 0x274dd893, 0xa94aaaea
.word 0xbbe187a0, 0xaaca66c1, 0x4e3711ae, 0xa440fa23, 0x77d7c1e0, 0x8e1851e4, 0xa6f9be72, 0xd82353b6
.word 0x067a6578, 0x0731ca10, 0x31602314, 0x7b0c4060, 0x437e91b1, 0x262422a3, 0x9079806b, 0x1e0793ab
.word 0x74ccf234, 0xf5c2e683, 0x70a2a1e3, 0x85f923a2, 0x6a059968, 0x54c91f2d, 0xd4823144, 0xcdac2bd9
.word 0x55cf6404, 0xeae74386, 0xca82f97e, 0x3ced066d, 0x1714995f, 0x070a6443, 0x15eada58, 0x074b37c0
.word 0x9c3ca999, 0x3c744817, 0x75d113fd, 0xd0780195, 0x9e3b79b1, 0x665871c6, 0x270f2b70, 0x7f5e383e
.word 0xa94e9152, 0xa2a9a90e, 0xd1729f74, 0x5fa382f0, 0x038ef8ae, 0xe88fda07, 0x8444944a, 0xc53d27a4
.word 0x5beb0cf7, 0xae1fd19e, 0x28d72fbb, 0x0ef8c6d8, 0x1cc024ea, 0x7bb546b2, 0x93704bf3, 0x74e434ec
.word 0xd9946b77, 0x281e28db, 0x52bda147, 0x3a70ff6d, 0x45ba1bf6, 0xb8ed61e9, 0x3a1bea94, 0x3fb3ca2d
.word 0x3c71a5bd, 0x7f2c1ae8, 0x27b81e4f, 0x646f1d86, 0x3bbdb981, 0xf1af8e92, 0xa102481f, 0x9ab9b0ec
.word 0x768f9015, 0x2fc1581a, 0xae2a06e3, 0x0681f277, 0x2fb506ed, 0x7f39b54d, 0x49c51812, 0xc3daec15
.word 0xfa3b1672, 0xaf6c2a6e, 0x05a2e888, 0x45e1c529, 0x165c7ec0, 0x501f1acf, 0xf06b621e, 0xab7d4cc1
.word 0x549885a4, 0xa60f3fd9, 0x7caba3b5, 0x31e399fb, 0x41d01083, 0xfe88ae80, 0x3a481d2d, 0x0963d750
.word 0x0c2a8386, 0x6b4ea98f, 0x20532653, 0x63562969, 0x0aa13ac5, 0x2fe29e44, 0xddd8b29f, 0x4717b6a9
.word 0xfa47a29d, 0x469b49c3, 0x945da546, 0x14011613, 0xd58d4a9c, 0x30b13df5, 0x42cb88b5, 0xa9024b9a
.word 0xd0a9db10, 0xf6437c57, 0xae0e7dab, 0xcc09c188, 0x1956f93a, 0xaf86dccd, 0xe781ae8a, 0xd85a7899
.word 0xfd7b2f00, 0xb3aabd03, 0x01be80f5, 0x515e1ead, 0x174ca574, 0xd35f4f46, 0xb7fff0dd, 0xdc7d5e24
.word 0x66c28b82, 0xb9e0af1e, 0xc2bff85d, 0xb93a58bd, 0x7dfabf37, 0x52d9ec7c, 0x38a6cec7, 0x4b80aa97
.word 0xb3737b6e, 0xc10efd9e, 0x17eea913, 0xe278d842, 0x94927f4d, 0xe81281c3, 0xdc064793, 0x3796cbb2
.word 0x60e01dac, 0xa37dceca, 0x935a89e9, 0xe0c98e6f, 0xb6dd877d, 0xbc6a7558, 0x2624a4aa, 0x6a058cbc
.word 0xd47713fb, 0x47409d4e, 0x94e6798a, 0xd1cbb0e6, 0xd9d4fef4, 0x5c4b9f5f, 0x3b672ce8, 0x51270b99
.word 0x91def88d, 0xadee9b77, 0x79714a87, 0x9b470164, 0x1a74367a, 0x9fd51f02, 0x04981928, 0x19c38e34
.word 0x3a039aa1, 0x99ef31d8, 0x6e208529, 0xc7a5dc15, 0xb6efa6ea, 0x5a479511, 0x1aaeccf3, 0xbac3efa8
.word 0x613dff51, 0x61e13597, 0x366c38c9, 0x34c48d77, 0x17124598, 0x72699009, 0xb53b8ffd, 0x94744cff
.word 0x2ae9c3d4, 0x7fa00b39, 0xbc36c229, 0xdbc3b201, 0x73370a45, 0x8cac6033, 0x2c4093d3, 0x35396b3d
.word 0x4569bf4a, 0xe2523f16, 0x734b79b3, 0xa28dba41, 0x71324a9f, 0x86e6215e, 0xf92fe6af, 0x9ee47936
.word 0x93e316a4, 0xf6121be3, 0xf8a7652d, 0x646e971a, 0x6db4dbe7, 0x41e22939, 0x1caad817, 0x314c273a
.word 0x33653cfc, 0x4859e84d, 0xb5be08e5, 0x6910c3bb, 0xdc62e18f, 0xdc4996ce, 0xd8908315, 0x5c81cd6b
.word 0x4181ebbd, 0x041d02e3, 0x681aa357, 0x81ca5e12, 0x7ad00e99, 0x17536b12, 0xfc368bb9, 0xa818e617
.zero 7168
mem_region_end:
