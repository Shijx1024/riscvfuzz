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
  li x26, 0x0000000a0076c980
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
  li x1, 0xe0da7fe7ae838663
  li x2, 0x4cc9b8d7caadb8aa
  li x3, 0x8219c09579740e98
  li x4, 0x18ff82ee501d24d0
  li x5, 0x72ef6e1605e1d54b
  li x6, 0xd86624a2a399e685
  li x7, 0xc41e87beed918dc9
  li x8, 0x9b94c3472e81eddd
  li x9, 0x1137028cdea02b38
  li x10, 0x45987a31ad62ec5f
  li x11, 0xd2c328a9b304aff0
  li x12, 0x171f05f4ab7a35f9
  li x13, 0x34dc5b548fb359f4
  li x14, 0xa5a87c9345f35c12
  li x15, 0x88677698cbfbff3e
  li x16, 0x8afcc3aca62e6682
  li x17, 0xcc8562423e10a04c
  li x18, 0x57ed3912378d77c2
  li x19, 0x37f9c5e6bb56b73e
  li x20, 0x5cfc8d3caa59dca8
  li x21, 0x804d6b72904c803a
  li x22, 0x1dec16d1bccd0810
  li x23, 0xab6a571c02b7c489
  li x24, 0xace68f9825a5a4b1
  li x25, 0xdcb107c5294c439d
  li x26, 0x558a383bbbb08a02
  li x27, 0x622831fe773eb53c
  li x28, 0xb29df633672b1d57
  li x29, 0xf55f3d49eeea4fcd
  li x30, 0x226a8d8f7aa0be81
  li x31, 0xf4b48b1e014dc82d
  li x5, 0x4d13a5912779a3b9
  fmv.d.x f0, x5
  li x5, 0x7e9b3722e8bae86d
  fmv.d.x f1, x5
  li x5, 0xc5b4218bf9c9ad6a
  fmv.w.x f2, x5
  li x5, 0xa59036368f0eefeb
  fmv.d.x f3, x5
  li x5, 0xf06d3f853a303e5b
  fmv.d.x f4, x5
  li x5, 0xca0345b350aa0b1e
  fmv.w.x f5, x5
  li x5, 0xd481e27db361d510
  fmv.w.x f6, x5
  li x5, 0xe541c6305ca12f4e
  fmv.w.x f7, x5
  li x5, 0x80ee097c9eb4e167
  fmv.w.x f8, x5
  li x5, 0xd3e1431e47cfa611
  fmv.d.x f9, x5
  li x5, 0xfdb356dc605484c4
  fmv.w.x f10, x5
  li x5, 0x93774e64bf18f0fa
  fmv.d.x f11, x5
  li x5, 0x012a00f701d9d544
  fmv.d.x f12, x5
  li x5, 0x98687dadd4abad65
  fmv.w.x f13, x5
  li x5, 0x3cb37f77bb6c2652
  fmv.w.x f14, x5
  li x5, 0x3e510ec37fb999bf
  fmv.w.x f15, x5
  li x5, 0x2bdf64ce815c8f32
  fmv.w.x f16, x5
  li x5, 0xfe1f931811542449
  fmv.d.x f17, x5
  li x5, 0xc2eef1ed35ebeba0
  fmv.w.x f18, x5
  li x5, 0x1ebe841f567bae77
  fmv.w.x f19, x5
  li x5, 0x4262cdf18d1951c3
  fmv.w.x f20, x5
  li x5, 0xd2b7313ec2ae9c66
  fmv.w.x f21, x5
  li x5, 0xd25bee1562c09a3e
  fmv.d.x f22, x5
  li x5, 0xae607f6cf04fd982
  fmv.d.x f23, x5
  li x5, 0xad7b4747794f61f5
  fmv.w.x f24, x5
  li x5, 0xc5d530471409ef79
  fmv.w.x f25, x5
  li x5, 0x84f3cdc87d75d49c
  fmv.d.x f26, x5
  li x5, 0xe424186bbad7c050
  fmv.d.x f27, x5
  li x5, 0x9da7ca6c15e056c8
  fmv.d.x f28, x5
  li x5, 0xd908932a6f7b3680
  fmv.w.x f29, x5
  li x5, 0x0700c4cd735891b8
  fmv.w.x f30, x5
  li x5, 0x4989c605c5a37edf
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
  amomin.w s3, s6, (t6)
  fsgnjx.d fa0, fs9, fa0
  div a4, a4, a4
  divuw s8, s8, s11
  fcvt.l.s s4, fs5, dyn
  rem a7, s3, a7
  lh zero, 478(t6)
  srliw a2, zero, 1
  srai s0, ra, 0
  fcvt.lu.s s11, fa0, dyn
  fsw fa0, 1268(t6)
  lbu a4, -527(t6)
  fcvt.lu.s gp, fs10, dyn
  auipc t2, 795630
  fcvt.s.l ft7, a6, dyn
  ld s10, -1840(t6)
  addi s11, s10, -2048
  and zero, zero, s9
  fcvt.lu.d a5, fa0, dyn
  amomin.d.aq t3, s9, (t6)
  remu a7, t3, zero
  amominu.d.aqrl a1, a1, (t6)
  sub s0, a5, zero
  fcvt.s.l ft2, a7, dyn
  sc.d s10, t3, (t6)
  fcvt.d.lu fs3, a1, dyn
  fld fa1, 1160(t6)
  mul ra, s5, ra
  divuw a2, a7, a2
  fcvt.d.lu ft1, a0, dyn
  remu t4, ra, t4
  amoand.d.aqrl a5, s2, (t6)
  fcvt.l.d a6, ft1, dyn
  amoswap.d.aq a4, s3, (t6)
  fcvt.d.l fs5, a7, dyn
  fcvt.s.lu ft7, a6, dyn
  fcvt.lu.s s11, ft7, dyn
  fcvt.s.l ft10, a6, dyn
  fcvt.l.d ra, ft5, dyn
  fsub.d fs2, ft11, ft10, dyn
  fsw ft11, 828(t6)
  mulhsu tp, s5, a4
  fmv.x.d s4, fs10
  srliw t3, t3, 31
  divuw zero, ra, s4
  amoswap.d.aqrl sp, tp, (t6)
  remw a1, a1, a1
  fcvt.lu.s a0, fs5, dyn
  fmv.x.d s11, fs6
  mulhsu t0, a1, a0
  fcvt.s.l ft6, s10, dyn
  lwu a4, -376(t6)
  fcvt.lu.s tp, ft6, dyn
  remu t4, t2, s11
  srliw s2, s10, 15
  fcvt.d.lu ft2, t4, dyn
  mulhsu ra, ra, tp
  slti a2, t4, 0
  slliw t2, tp, 2
  amomin.d.aqrl s0, s10, (t6)
  div s7, s7, ra
  fcvt.lu.s t4, ft11, dyn
  slliw t2, s5, 11
  amomax.w.aqrl s1, s7, (t6)
  divw a4, t4, s1
  sllw a6, s1, s7
  bne a4, s5, . + 32
  divu gp, t4, a4
  fcvt.l.s a1, ft7, dyn
  amoswap.d.aq t1, gp, (t6)
  fmsub.d ft3, ft6, ft11, fs0, dyn
  subw a3, a1, gp
  fcvt.s.l ft9, a6, dyn
  sra s11, a3, a1
  fwd_0:
  mulw a5, a3, s4
  fmax.d fs8, ft3, ft9
  amoand.d.aq gp, gp, (t6)
  xori t3, s8, 2047
  subw s4, gp, a5
  amoxor.w.rl sp, s4, (t6)
  fcvt.lu.s s1, fs8, dyn
  sra s10, s4, s4
  mul a5, s4, a5
  remu ra, s4, sp
  fsw ft9, -1828(t6)
  fsgnjn.d ft1, fs8, ft6
  fmv.x.d s4, ft9
  fcvt.l.s s10, fs6, dyn
  srli t2, t1, 0
  xori a4, a7, 130
  fcvt.s.lu fa7, a7, dyn
  amomin.d.rl a2, t1, (t6)
  mulhu t0, s1, s10
  slliw a2, t0, 22
  fcvt.d.w fa1, t2
  srli a6, a6, 29
  amoadd.w a0, a0, (t6)
  amominu.d.aqrl t1, a4, (t6)
  fcvt.d.l ft7, a0, dyn
  fcvt.s.lu fs6, a3, dyn
  fcvt.l.s s7, ft6, dyn
  fcvt.d.s ft7, ft0
  amoor.w.aq a1, a2, (t6)
  divuw s11, a6, a6
  amoswap.w.aq s10, a1, (t6)
  andi s9, s9, -1
  mulw a0, s7, ra
  fcvt.l.d t0, fa3, dyn
  mulhsu s6, s11, s11
  sc.w.rl a5, s9, (t6)
  fcvt.d.l fa5, a5, dyn
  fcvt.l.s s5, fa2, dyn
  mul t4, a5, a5
  fsw fa4, 1716(t6)
  fcvt.lu.s t1, fa7, dyn
  fsw fs10, -1252(t6)
  fmv.d.x ft4, t4
  fcvt.d.s fs10, ft11
  lui a7, 752098
  xor s9, a7, s6
  beq a4, s5, . + 28
  srliw a3, s11, 0
  amomax.w.rl t2, s5, (t6)
  fcvt.d.l fs4, s2, dyn
  srliw s6, sp, 0
  amominu.w.rl t1, s5, (t6)
  amominu.d.aqrl a2, s5, (t6)
  fwd_1:
  mulhsu a2, t3, s6
  fcvt.lu.s a1, fa4, dyn
  amomin.w.aq s7, s7, (t6)
  fcvt.lu.s a0, ft2, dyn
  amoand.d.aq a3, a5, (t6)
  fmv.d.x fs5, a3
  lr.d.aqrl s11, (t6)
  fsw ft1, 1296(t6)
  amoxor.w.aqrl a5, a5, (t6)
  fsw fs5, -680(t6)
  sraiw gp, s11, 0
  divw s3, gp, gp
  fcvt.l.d a0, fs4, dyn
  mulw zero, s11, s11
  fsgnjx.d fs1, fa0, fs1
  fsw fa3, -1832(t6)
  divw a3, a3, s9
  fcvt.s.l fa7, s0, dyn
  remuw s7, zero, zero
  fcvt.d.lu fs1, s11, dyn
  fcvt.s.lu ft8, s3, dyn
  amomax.d.aqrl s2, s9, (t6)
  fsw ft8, -1284(t6)
  lr.w.rl t4, (t6)
  fcvt.d.w ft3, t2
  amomax.d.aqrl tp, a4, (t6)
  fmv.x.d s4, ft8
  remuw ra, s4, t4
  sraw ra, s4, s0
  fmv.d.x ft11, tp
  rem a0, ra, s2
  amominu.d.rl a4, t4, (t6)
  amoand.w.rl t3, s4, (t6)
  divuw a3, a5, t3
  sllw s7, t3, t3
  mulw ra, t3, ra
  flt.d t1, fa7, ft7
  flt.d s11, fs3, fs1
  remw tp, ra, tp
  addw s11, t1, t1
  sd ra, 1536(t6)
  rem s0, tp, s7
  amomin.d.rl s1, t1, (t6)
  amomax.w.aqrl t3, t3, (t6)
  remuw s3, s11, tp
  fsgnj.d fs0, fa7, ft0
  remuw s10, s10, s3
  fsw fs6, 552(t6)
  fcvt.s.l fs3, s10, dyn
  fcvt.l.d s7, fs3, dyn
  amoor.d a4, t2, (t6)
  divuw t2, s10, s3
  slti a1, s3, -573
  amoxor.w.aq a7, s10, (t6)
  divu a4, s8, a1
  fcvt.s.lu ft5, s10, dyn
  sllw a5, a5, a5
  amomax.d.aq a7, a5, (t6)
  fcvt.d.wu fs2, a5
  addw sp, a4, a7
  auipc s10, 270407
  fcvt.lu.s t0, fa6, dyn
  sc.d.aqrl a1, s10, (t6)
  fsgnjx.d ft11, fs4, ft11
  amoxor.w.rl t3, t0, (t6)
  fmsub.d ft3, ft8, fs4, ft3, dyn
  divw s10, t4, s10
  lb s5, -1598(t6)
  amominu.w.rl s3, t4, (t6)
  amomaxu.w a2, sp, (t6)
  divuw s7, s1, s10
  amoswap.d ra, a1, (t6)
  sltiu a7, s5, -2048
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
.word 0x1c7fc03a, 0x8086b2a9, 0x2e942cf5, 0xe81f1ad2, 0xe1817270, 0xa8c0c5e1, 0xce76a7dc, 0xd3a74ed4
.section .mem_region, "aw", @progbits
.align 4
mem_region:
.word 0x9f961746, 0x13aef85a, 0xd97b1669, 0x0a511e5a, 0x2ab455b7, 0x4e2a6fbb, 0xebab10f9, 0x6b0e8ba2
.word 0x247374fa, 0x9e26d03d, 0xdef4d91d, 0xfb71e9c6, 0x77c430c5, 0x8bb8d6f0, 0x4956e748, 0x347084b3
.word 0xd03d74e4, 0xdbc86612, 0x8eca8a43, 0x91234c9f, 0x4e45cb77, 0x7ba32018, 0x396a30ba, 0xfc8a3904
.word 0xd7ca35ff, 0x0ef8ff2b, 0x691f067c, 0xe94e2443, 0x03296970, 0xaba1a834, 0xa0a4b3bb, 0x10403405
.word 0x1b84a73e, 0xc78872db, 0xfb2dbde8, 0xdb6eb3e8, 0x383a74c2, 0xf950bac9, 0x12f2ff3c, 0x5bbd5f59
.word 0x4bd4c018, 0x3a40f021, 0x8ead5a28, 0x448befca, 0x31691293, 0x51cd35c9, 0xb68621fb, 0x1fca75c3
.word 0x89f24d28, 0x2d51899f, 0xc1aa76a5, 0x94edfa92, 0xba7f3b85, 0x9ecadbf6, 0xa60c0ff6, 0x1f7474f8
.word 0x20328895, 0x50d7b8b6, 0x7a003a0b, 0x44b84070, 0x4581ae3b, 0x5490b71d, 0x9ed10c0e, 0x9010d59d
.word 0xc635120c, 0x587b446c, 0x7c9e1a83, 0x2399980c, 0xdda86dc4, 0xe8acd890, 0x126f76c7, 0x6da42239
.word 0x0be69a59, 0x86474385, 0xd901208b, 0x6e4b17e6, 0xaa709346, 0x8586e543, 0xc5855480, 0x71f41dc7
.word 0xba36dbcc, 0xacdcd7d7, 0x0302e08b, 0xa4ccec3f, 0xf5d9f51f, 0x3736c62a, 0x3dd457a6, 0x89555477
.word 0xfac74dfa, 0xe9bbcb6f, 0x15483af7, 0x646363d8, 0xcbd81a1c, 0x73000bc3, 0xe231589d, 0xed1e0f78
.word 0xcc874eac, 0x574ed8b6, 0xdc074d60, 0x0d17ee67, 0x2f912ee1, 0xf7a1f82d, 0x2f2eaa03, 0xec2ee870
.word 0x394ec859, 0xcb5fe9e2, 0xb3582ed2, 0xdfb477c8, 0x3289889e, 0xd2ed020b, 0xe5c5864e, 0xb0e616ba
.word 0x4bc35393, 0xc70592ef, 0x92256ef3, 0xef4dfd0d, 0x800d7c31, 0x273228f1, 0x2e3f1120, 0xfe1ca678
.word 0x146a7a5b, 0x29e4b5e4, 0x0605c6ed, 0x4c25d20b, 0xf5994508, 0x29c0d116, 0xf052cad6, 0xf0081b6a
.word 0x4c92a29e, 0xb2b77462, 0xf2934a7e, 0x1226fc4f, 0xd17a19f7, 0x0a8f5cb8, 0x2fb984db, 0x05e939cb
.word 0x70435826, 0x2a392f99, 0xd59c913c, 0x07e6bae5, 0x92e20764, 0x912abbc4, 0x113795fa, 0x27b04673
.word 0xc50334d8, 0x06e148d7, 0xacde7cf5, 0x09f11246, 0x13eedcd8, 0xeb7a355a, 0xcbbfbb61, 0x757fffbe
.word 0x214baf54, 0x30be4d08, 0x2f5a6671, 0xa88cb953, 0x6b7f3120, 0xe940238d, 0x4966690d, 0xacd4f751
.word 0x33558539, 0xddd8e1d6, 0xe71f4b0d, 0x39741ada, 0x89be5422, 0xdc77ad64, 0xe3d686ad, 0x5ac11a3d
.word 0xe068a281, 0xa16849b4, 0x52bf70b9, 0x5d8869f6, 0xdc60f101, 0x5758472e, 0xa82ccb43, 0x3360053a
.word 0xb0f6e011, 0x426ad241, 0xf2eb057e, 0x863c17c3, 0xcfbd0784, 0x8a65fc43, 0x0d8969ba, 0x5a831cdf
.word 0x09aa5513, 0xb7da1c52, 0xd4cdcf05, 0x5f818fe8, 0xedfb96ad, 0x266faafd, 0x259f7adc, 0xe96023fa
.word 0x1ec874d8, 0x693c3b64, 0x6f9cc106, 0x40876476, 0x4e99f152, 0xebb8328b, 0x09c6afea, 0x56e0c7db
.word 0x88114972, 0xc6f9bb8b, 0x34ba264d, 0x35130f8c, 0xb0d9b539, 0x43c9ec75, 0xc5c9603f, 0x4c490183
.word 0xcf8707cc, 0x72af5ca5, 0xd63723a3, 0x800e7f5b, 0xc67c36f0, 0x0220e0cc, 0x2c353b9f, 0x02e7c9ad
.word 0x1dfc2ba2, 0x63777a12, 0x64bc6f83, 0x5427245a, 0x06886cbf, 0xf5e3256b, 0xd848ef90, 0xc82ddfe9
.word 0x2b7aa936, 0x172f1a93, 0x23b81ef8, 0x09fb5daf, 0x098492c0, 0xab14c04d, 0x204ee9a1, 0xc76cde9f
.word 0x9f0a4e66, 0x410791e9, 0x727ad80d, 0x1f76d889, 0x792abbc2, 0xe626a96c, 0x272aab82, 0x5de0467b
.word 0x4ebb4241, 0xea633c5f, 0xcb4c75b4, 0x5b157ad5, 0x99d014b7, 0xaaa54a72, 0x9b72dda2, 0x12a0f591
.word 0x2c892ec6, 0x7c6c141c, 0x38fcdb57, 0x3f5568ed, 0xeb16a1f2, 0x400bcab1, 0xeeb4cefa, 0x21d062af
.zero 7168
mem_region_end:
