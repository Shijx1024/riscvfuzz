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
  li x26, 0x0000000a0047a1a0
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
  fsrmi 7
  csrwi fflags, 0
  li x1, 0x1e687d73866d246e
  li x2, 0xfa99ea6bc6e92432
  li x3, 0xcb25d1b15a090c8e
  li x4, 0x3ccad8eb16f2ca19
  li x5, 0x781246919289f613
  li x6, 0xccf67941b5b3a716
  li x7, 0x06ffa84dce971d2e
  li x8, 0x18166421ed6a0a7f
  li x9, 0x0e9c986dcdd4b624
  li x10, 0xc5549b3b1faacbb3
  li x11, 0xed05a1aef1b2aad3
  li x12, 0xb58416d4bd51546f
  li x13, 0x631d882876639097
  li x14, 0xcb8ea7fdf1fabc23
  li x15, 0x177d52fddd61b1e4
  li x16, 0xf2619e27a3d93714
  li x17, 0x966c8572d1de1963
  li x18, 0xe3fe3207661042bb
  li x19, 0x6ed1a87d2fb763fe
  li x20, 0x6c9076ef34f873d2
  li x21, 0x657071b667c05dfb
  li x22, 0xde7d8f560501de40
  li x23, 0xebcc4b4155eeb6e3
  li x24, 0x6da3c606a5b41370
  li x25, 0x00133561ce4d614c
  li x26, 0xda0e2a1e5a34b23a
  li x27, 0xff8846351ec5c6d3
  li x28, 0x49c5802ca6cc824e
  li x29, 0x4b971f2a7c4570e3
  li x30, 0xbbe2d9aff3a0fcca
  li x31, 0xa04b557808597314
  li x5, 0x093bfc3ed83159f9
  fmv.d.x f0, x5
  li x5, 0x6afb7b32a79659d8
  fmv.w.x f1, x5
  li x5, 0xff370486f5106037
  fmv.w.x f2, x5
  li x5, 0x7d5f65c64545bfc2
  fmv.d.x f3, x5
  li x5, 0x502d36e9b233e23f
  fmv.w.x f4, x5
  li x5, 0x9714b05278ee5af3
  fmv.d.x f5, x5
  li x5, 0x1b93bd02cf53d133
  fmv.w.x f6, x5
  li x5, 0x0663dd9bc82c45e1
  fmv.d.x f7, x5
  li x5, 0x423a7fe3ea6c8de0
  fmv.d.x f8, x5
  li x5, 0x25e62c65eab2e8ce
  fmv.d.x f9, x5
  li x5, 0x1d6e14d8f9966745
  fmv.d.x f10, x5
  li x5, 0x60d71c4ff4a8eaa8
  fmv.d.x f11, x5
  li x5, 0x45aa56d95605fc8e
  fmv.d.x f12, x5
  li x5, 0xb65f0ef6c4d8b014
  fmv.d.x f13, x5
  li x5, 0x233cdac82b4c9615
  fmv.d.x f14, x5
  li x5, 0x66a689228dd07f0d
  fmv.w.x f15, x5
  li x5, 0x26a6f40d4eaa8781
  fmv.w.x f16, x5
  li x5, 0x4be9d62322abd350
  fmv.d.x f17, x5
  li x5, 0x9ed7d2dc1a8d7fb5
  fmv.d.x f18, x5
  li x5, 0xc5157bcbd159e0fa
  fmv.d.x f19, x5
  li x5, 0xd0e7f64fedb875e5
  fmv.d.x f20, x5
  li x5, 0xf086ac3ab6000b78
  fmv.w.x f21, x5
  li x5, 0x9f65ba0392bb4bae
  fmv.d.x f22, x5
  li x5, 0x0ef552066087ea83
  fmv.w.x f23, x5
  li x5, 0x0100b1dac369ba05
  fmv.w.x f24, x5
  li x5, 0xe98468391b902d0c
  fmv.w.x f25, x5
  li x5, 0x92cafdcb96b87d83
  fmv.w.x f26, x5
  li x5, 0xa65fa374229cfc87
  fmv.w.x f27, x5
  li x5, 0xf2c720ad9ac2f5fe
  fmv.w.x f28, x5
  li x5, 0xc8bc3ba31ff351b8
  fmv.w.x f29, x5
  li x5, 0xab474a076d7bf83d
  fmv.d.x f30, x5
  li x5, 0x7ffff78b7668a1b5
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
  amoand.w s0, a6, (t6)
  amoxor.w.rl s11, a6, (t6)
  andi s8, a2, -1825
  fdiv.d fs8, fs8, fs8, dyn
  srlw t1, s2, s11
  amoor.d s3, s8, (t6)
  fmv.d.x ft9, s3
  divuw zero, s8, s1
  amoand.d.aq s7, a6, (t6)
  sraw s10, t3, a0
  feq.d gp, ft9, fs8
  remw tp, gp, s3
  fcvt.l.s t4, fs8, dyn
  sd sp, -112(t6)
  divw s2, t3, t4
  fcvt.l.d s4, ft9, dyn
  fsd fs8, -560(t6)
  amoand.w s6, a5, (t6)
  amoadd.w.rl s7, s6, (t6)
  fcvt.lu.s t1, ft9, dyn
  fmv.x.d s5, fs8
  blt s6, t1, . + 20
  mul a6, t1, s5
  flw ft11, 1428(t6)
  rem t2, s6, s5
  mul s4, t1, t2
  fwd_0:
  fmv.d.x ft3, t2
  fcvt.lu.s a7, fs6, dyn
  amoor.w.rl a4, a3, (t6)
  mulhu tp, s4, s9
  fcvt.d.lu fs0, s1, dyn
  mulhsu a1, tp, a4
  fcvt.l.s a4, fa7, dyn
  fcvt.lu.s a6, fs5, dyn
  amominu.d.rl s6, a7, (t6)
  fmv.d.x fs8, s6
  remuw s2, a4, s6
  fcvt.s.l fs6, a1, dyn
  fmv.d.x ft1, s7
  fcvt.l.d s1, ft1, dyn
  divw a0, s6, a6
  fmv.x.d zero, fs2
  fcvt.d.lu fs0, s7, dyn
  srliw s5, s5, 0
  amomax.d.rl s10, s1, (t6)
  fcvt.d.l fs6, a5, dyn
  blt s5, a5, . + 32
  fcvt.l.d s3, fs0, dyn
  remuw t0, s5, s10
  fcvt.s.l ft4, s2, dyn
  mul a7, s5, s2
  fcvt.w.d a3, fs6, dyn
  sc.w.rl a2, s10, (t6)
  sll t2, s3, t4
  fwd_1:
  amominu.d.rl s4, tp, (t6)
  fsw ft4, -1876(t6)
  fsw fs6, 1932(t6)
  amoor.w.rl sp, s2, (t6)
  fcvt.d.lu fa3, t2, dyn
  auipc s9, 0
  addi s9, s9, 36
  jalr ra, 0(s9)
  remuw s8, s8, sp
  divw s5, a7, sp
  flw fs5, 676(t6)
  fmv.x.d s0, fa4
  add a1, sp, s8
  amomaxu.w.aqrl s11, s11, (t6)
  fwd_2:
  remw s5, s5, s5
  amoxor.d.aqrl s8, s8, (t6)
  amoor.w.aqrl s9, t4, (t6)
  fsw fs8, -684(t6)
  sra a1, s5, s8
  amoswap.w a6, a6, (t6)
  div gp, gp, s8
  fmv.d.x ft2, s8
  amoxor.w.aq sp, t2, (t6)
  div s4, t0, t2
  fcvt.l.d a7, fa5, dyn
  fcvt.lu.d s6, fa3, dyn
  fsw ft0, 1340(t6)
  amomax.d s0, s4, (t6)
  divu a1, s0, s0
  fsw fa7, -1384(t6)
  amoor.d.rl s3, s6, (t6)
  srlw a6, s0, s8
  fcvt.s.l fa6, a1, dyn
  fsub.d ft2, fa7, fs0, dyn
  fcvt.d.l fa4, s4, dyn
  mulhu t4, tp, tp
  fcvt.l.s a5, ft2, dyn
  divw s0, a4, tp
  add s3, t4, s0
  amoswap.w.aqrl s2, tp, (t6)
  mulw a1, s2, t1
  fcvt.s.lu fa3, s2, dyn
  fcvt.lu.d gp, fa4, dyn
  slliw a0, a1, 0
  divu tp, a0, a1
  remu t4, a0, t2
  fmv.x.d s6, ft6
  fcvt.s.l ft3, s2, dyn
  fcvt.lu.d s2, fa7, dyn
  remuw s5, s5, a7
  fcvt.s.d fa4, ft7, dyn
  slli s10, s9, 11
  mulhsu s8, a3, s8
  jal s4, . + 20
  lr.d.aqrl tp, (t6)
  amomaxu.w.rl ra, s8, (t6)
  lwu s10, 1784(t6)
  amomax.d.aq a7, s10, (t6)
  fwd_3:
  amoadd.w.aq tp, s8, (t6)
  addw s11, s2, s10
  sraiw a1, ra, 0
  amomin.d.rl s6, s6, (t6)
  sh a0, -850(t6)
  fmv.d.x fs5, s10
  subw gp, zero, tp
  divuw a3, s6, s11
  divu s9, s9, s6
  fcvt.d.l fs3, s11, dyn
  amominu.d.aqrl s4, s4, (t6)
  sc.d.aq ra, s4, (t6)
  fcvt.l.s s6, ft3, dyn
  sd a5, -1688(t6)
  sc.d.rl a2, s6, (t6)
  slli t4, s4, 61
  amoswap.w t1, t3, (t6)
  amoor.d.aqrl zero, s10, (t6)
  divu s7, t1, t4
  mul a6, s7, a6
  amomax.w.rl s6, s6, (t6)
  sh a6, -976(t6)
  fcvt.l.s a7, ft11, dyn
  auipc ra, 167882
  fmv.x.d gp, fs5
  subw a5, a7, ra
  fcvt.s.lu ft10, gp, dyn
  srlw s6, gp, a6
  mulhu a0, s6, ra
  feq.d a3, fs3, ft11
  amoadd.w.aq s7, s6, (t6)
  fnmsub.d fs9, ft10, ft1, fs1, dyn
  slliw t4, s7, 31
  srli sp, a5, 0
  fcvt.s.l ft10, sp, dyn
  fcvt.d.l fs0, sp, dyn
  fcvt.s.lu fs2, zero, dyn
  remuw tp, tp, zero
  fmul.d fa0, fa0, fs3, dyn
  amoor.d.aqrl s1, s1, (t6)
  fcvt.d.l ft11, a7, dyn
  fcvt.l.d t1, fs9, dyn
  rem tp, a4, t3
  divw a5, t3, a5
  amoadd.w.rl s4, a5, (t6)
  fsw fa2, 176(t6)
  amoor.w.rl a1, a5, (t6)
  fld ft1, 1960(t6)
  fadd.d fs1, fa2, ft3, dyn
  fsgnj.d fs6, fs1, fs1
  remu a3, a2, s4
  ecall
  fcvt.d.l fs7, s4, dyn
  amomin.d.aq t0, sp, (t6)
  fmul.d fs6, fs1, fa3, dyn
  sltiu ra, a1, 0
  amominu.w a2, a3, (t6)
  amomaxu.w.aqrl a7, s1, (t6)
  fmsub.d fs8, fs7, fs6, fs6, dyn
  fcvt.lu.s s6, ft1, dyn
  divw s7, s7, gp
  or s8, a7, t1
  amominu.d.rl s7, s11, (t6)
  remuw s5, t1, s7
  fmax.d fa7, fs1, fs7
  amomax.d.rl ra, sp, (t6)
  divuw a1, s11, a1
  sc.w.aq a4, a3, (t6)
  fsd ft10, 712(t6)
  amominu.d.aqrl a6, ra, (t6)
  amomax.w s8, a3, (t6)
  mulw gp, ra, s8
  fsw ft10, -1800(t6)
  auipc s0, 0
  addi s0, s0, 24
  jalr t4, 0(s0)
  amomaxu.w.aq t2, a6, (t6)
  fmv.x.d s11, fs11
  lhu a2, 1122(t6)
  fwd_4:
  fcvt.l.s a2, fs1, dyn
  amoxor.w.aq s1, s1, (t6)
  fcvt.s.l fs7, a2, dyn
  fsw fs7, -1264(t6)
  addw gp, gp, tp
  fcvt.s.d fs8, fs8, dyn
  divw t4, t2, gp
  div s3, sp, t4
  divw a4, gp, gp
  addi t1, s3, 647
  fcvt.s.lu fs1, s6, dyn
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
.word 0x9b4082e3, 0x8e229bdd, 0x0db8f07b, 0x00427cfa, 0xd13ac5a8, 0x92cd09f6, 0x882ca2d1, 0x54b9e637
.section .mem_region, "aw", @progbits
.align 4
mem_region:
.word 0xfd1a89fc, 0xd6d8dd94, 0xcb84c609, 0x4d71ba2b, 0x0604c34b, 0x0fc823f8, 0xdd80be7a, 0xd2ad608a
.word 0xe54b01ce, 0x8f57f88b, 0x3a6cf1b7, 0x16d1680e, 0x29851f98, 0xdb9f5366, 0x2d6a423a, 0x8087e3b7
.word 0xbb624c70, 0xe8cb9f92, 0xe67403f9, 0xf21cf94a, 0xc9cb79be, 0xde606ec8, 0xcca934da, 0xacddede9
.word 0x6ab18349, 0x9a0ec05d, 0x87dbd595, 0x09c96085, 0xbc434dcc, 0x2de35aad, 0xe35011ef, 0xd0d702b7
.word 0xeed29a63, 0x78f07bd3, 0x13ef27c6, 0x6d4de043, 0xe0846ff0, 0xd4abc614, 0x8f72fdc2, 0x5038f820
.word 0x53854737, 0x08439e44, 0x517d447f, 0x9615ccdc, 0xcf378526, 0x07bf92bb, 0xc049b2be, 0x34c216ad
.word 0x2c02c10f, 0xdb219ede, 0x454d4db2, 0x7a82c1d5, 0x6c89b6e9, 0xe523474f, 0x202bf9d1, 0xbce9db07
.word 0xff857b34, 0xb01086eb, 0x2ad19323, 0x857db817, 0xd0f594e2, 0x3dbf5fe0, 0x689a0c27, 0x2ad25903
.word 0xba04ed3f, 0xf81533e3, 0xbd7b2d00, 0x6b3c63b1, 0xf9378bfc, 0x66b7e27f, 0x35675b98, 0x7f7f584c
.word 0x44c8d478, 0xd10dd631, 0xaee3126c, 0xdb8ea123, 0x8d264785, 0x5fadb10c, 0xc9dd3084, 0x458102ba
.word 0x4f8106ff, 0xb623ac27, 0x2ffd07cb, 0x7f320afe, 0xfc727b80, 0x93857f38, 0x681f7db9, 0x925a0ba2
.word 0x8c08cf85, 0xd5bff441, 0xafc7fe1e, 0x2d77527c, 0x18cfb818, 0x1449fb8f, 0x961c9f24, 0x4fcae100
.word 0xa845db4b, 0x727cbdad, 0x4f57a99e, 0x86fac3f3, 0xd78d2674, 0xd7fe3a01, 0xc0abb721, 0x330efbbd
.word 0xfd812e27, 0x46617ce8, 0xc6848884, 0xa1647b76, 0xcfc2c789, 0xcf205bff, 0xe478b899, 0xa1e1c6b8
.word 0x85cbd787, 0x8a3e3edb, 0x922beb00, 0x88918077, 0xe916d034, 0xaf279761, 0x5ec27194, 0xeb818836
.word 0xebf690e1, 0xc6d4bd67, 0xc4cec24c, 0xf71dda43, 0x228bffa8, 0x845d2bc6, 0xd2e12e3e, 0x990c82d7
.word 0x96683a22, 0x7f3cb0e1, 0x980a26be, 0x98397eb6, 0xa3ed81cb, 0xd5476116, 0x03849a21, 0xb1193c37
.word 0xc28334a8, 0x680d7f13, 0xa14b2b70, 0x40c96e14, 0x806c52c2, 0x52e01285, 0x67adb1df, 0x1778983d
.word 0x01342989, 0xd24f44a4, 0x6a0dbba3, 0x8d8731bd, 0xe79e42e3, 0x4b6f9f88, 0x3a58454f, 0x5eafb9c2
.word 0x4738f46d, 0xbba15f62, 0x5dc51704, 0xf5411c28, 0x5900ac12, 0xe4abd3ea, 0x8a4bd021, 0xd998ae8e
.word 0x27f62f1e, 0xad173e15, 0x426f35ea, 0xbb887142, 0x5f897910, 0x6265fba5, 0x7e13de5a, 0x9c46f004
.word 0x36c09d13, 0xad06b667, 0xb95543c0, 0xa427c675, 0xe8163c85, 0x9119a9ae, 0x08282764, 0xeb0b9130
.word 0x91bf2d69, 0x1635786b, 0x79612f1e, 0xe97a21bf, 0x1f2585d2, 0xa7a00ce2, 0xc69018ab, 0x142fa41f
.word 0x57ef241f, 0x1a823c06, 0x0f198c9a, 0xf04c0259, 0x00501a84, 0x71313c58, 0x017deab0, 0xa13e1597
.word 0x5085af59, 0xb1aee5fa, 0x61272209, 0x268187df, 0x23f58f51, 0x9902b193, 0x2fd3bd24, 0x43a6c3a8
.word 0x63dffcec, 0x0a87244c, 0x854f6975, 0x525e585e, 0x63fd4a95, 0x5294879e, 0xa901ad47, 0x96dfa663
.word 0xb76d5fde, 0xeb2cb326, 0x862f32d9, 0x4bf27939, 0x229d41c4, 0x64390a49, 0x6621ebac, 0xc23193fa
.word 0xb5d8b451, 0xf14ed4b5, 0x62b31789, 0xf22b1f37, 0xc4d66844, 0x00872100, 0x96bceefd, 0x4ba9b984
.word 0x46e13f3d, 0x003f52f4, 0x43884de8, 0xe0520016, 0xa2b59c64, 0x40c62f03, 0xc6606a4f, 0xcf1502f7
.word 0x0af4fb1e, 0x6b255ae8, 0xf9347d46, 0xd372b1dd, 0x886a25ff, 0x073cda44, 0x23b3b133, 0xa0bfa536
.word 0xf034a33c, 0x989e0cee, 0x26e2322e, 0xa0caa8dd, 0xf1a6850d, 0x58c6625e, 0xb876e6ad, 0xf3394fe8
.word 0x9281530c, 0x57bf3c3e, 0x1689e43a, 0x5dfba6b5, 0x3638f6eb, 0xd5fe2131, 0x99dbe666, 0x79d30c64
.zero 7168
mem_region_end:
