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
  li x26, 0x0000000a0029a002
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
  fsrmi 1
  csrwi fflags, 0
  li x1, 0x71c94ddd52502f21
  li x2, 0x6228f2c1db3ba13f
  li x3, 0x032fba8f4a82006f
  li x4, 0x8b6f5a99e6285499
  li x5, 0x97339b90c5322277
  li x6, 0xa591c54f046585f4
  li x7, 0xde128a896d0794f4
  li x8, 0x0a2484f757596550
  li x9, 0x602dc7a1efc2af73
  li x10, 0x028bc7bf2a4a5e09
  li x11, 0xf39d77c22598691a
  li x12, 0xab6abeed37223ec1
  li x13, 0xc2d94c2352ea5ab4
  li x14, 0xcbe1d81260964373
  li x15, 0x307aad2667c31243
  li x16, 0xe9219ea603b100da
  li x17, 0xfc27a481f1dcd99b
  li x18, 0xfe52cb27d77cf5b8
  li x19, 0xacaf2d43f200a599
  li x20, 0x18b55a3bcf5b99cf
  li x21, 0xaae215ded83714ad
  li x22, 0x4a1268f14a80f399
  li x23, 0x39b44213455c1a2d
  li x24, 0x3d31656549b1e442
  li x25, 0xcceaf70ec4b823cc
  li x26, 0x696d00864804b78f
  li x27, 0xcf7a337d1bfe731c
  li x28, 0x727f519d3f0b4ae9
  li x29, 0x6ee1e66f7e7c9b9e
  li x30, 0x9379b8d6c3d9240e
  li x31, 0xec0c976be6ec413b
  li x5, 0x4e02ca655f924333
  fmv.w.x f0, x5
  li x5, 0xa7084a8290cf7abb
  fmv.d.x f1, x5
  li x5, 0xe74d5c03720f6482
  fmv.d.x f2, x5
  li x5, 0x28f40abc02f2289e
  fmv.w.x f3, x5
  li x5, 0xe8bd0c19f3607765
  fmv.w.x f4, x5
  li x5, 0x47d8b8b0c2aaf078
  fmv.w.x f5, x5
  li x5, 0xded961ae38268da0
  fmv.w.x f6, x5
  li x5, 0x79638fbdbf88a27c
  fmv.d.x f7, x5
  li x5, 0xaae7b18b5792e690
  fmv.d.x f8, x5
  li x5, 0x821c4dc6c1555b4f
  fmv.w.x f9, x5
  li x5, 0x60bfd72b12ac73ac
  fmv.w.x f10, x5
  li x5, 0xb8a2444a6469f816
  fmv.w.x f11, x5
  li x5, 0x768e18b58735638a
  fmv.d.x f12, x5
  li x5, 0x46e18c773d9ba8df
  fmv.d.x f13, x5
  li x5, 0x4aa7b2ecd56eae35
  fmv.w.x f14, x5
  li x5, 0x8b5f2fd4ba4cdff6
  fmv.d.x f15, x5
  li x5, 0x72c5c50aafbf6e01
  fmv.d.x f16, x5
  li x5, 0x830908f0be2ef55d
  fmv.w.x f17, x5
  li x5, 0xef77870de7a8baa8
  fmv.d.x f18, x5
  li x5, 0x6b4e6ca66345206c
  fmv.d.x f19, x5
  li x5, 0x1dc495629b4d004a
  fmv.w.x f20, x5
  li x5, 0x31cd2de88b3f237c
  fmv.d.x f21, x5
  li x5, 0x1ed54bcafdd74bf4
  fmv.d.x f22, x5
  li x5, 0x02d61cc5eef04e87
  fmv.d.x f23, x5
  li x5, 0x1e26fd7002b045f1
  fmv.w.x f24, x5
  li x5, 0x20ba1273a338197a
  fmv.d.x f25, x5
  li x5, 0xdf9b914d068ff5f9
  fmv.w.x f26, x5
  li x5, 0xe836d9f9b281ba34
  fmv.d.x f27, x5
  li x5, 0x8f2c1bd3a3d4a994
  fmv.w.x f28, x5
  li x5, 0xe8fd1abba4cad63e
  fmv.d.x f29, x5
  li x5, 0x9214e40e88d75d5e
  fmv.w.x f30, x5
  li x5, 0xfa141ff0a0c724cf
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
  sraiw a6, a6, 0
  mulw a4, a4, a6
  fcvt.lu.d a7, fa1, dyn
  srlw s9, a1, a7
  sltu s8, s8, t4
  fsw ft4, -1708(t6)
  fcvt.s.l fs4, a1, dyn
  amoxor.w.aqrl s2, s9, (t6)
  divu s4, s2, s4
  fclass.d s0, fa2
  sltu t2, t2, s9
  divuw s8, s2, s4
  lb s10, 2022(t6)
  fcvt.l.s tp, fs4, dyn
  fsw fs4, -812(t6)
  remw s3, s8, s3
  fadd.d fa3, fs4, fa3, dyn
  fcvt.s.lu fs1, t2, dyn
  sraiw s4, s10, 0
  amoor.d a6, s4, (t6)
  fsd fs1, 552(t6)
  srai t0, s10, 0
  fsw ft0, -1888(t6)
  rem s5, a6, a6
  fmv.x.d s1, ft11
  srli a4, s1, 20
  fmadd.d ft1, ft1, fa3, ft1, dyn
  auipc s7, 0
  fsw fa3, -1168(t6)
  flt.d s3, fs1, fa3
  divw a6, s7, a6
  fcvt.lu.d s11, ft7, dyn
  div s5, s11, a4
  amoxor.w.aqrl s10, a6, (t6)
  fsd fs4, -40(t6)
  remw sp, a1, s10
  sc.d.rl s0, s5, (t6)
  amomin.w.aqrl a3, s0, (t6)
  fcvt.lu.d s5, ft1, dyn
  mulw a4, s0, s5
  remuw a7, a4, a5
  srli s4, a7, 1
  amoor.w s4, s5, (t6)
  lr.w.aq a3, (t6)
  fmul.d fa1, fs1, fs4, dyn
  remu s2, t3, s2
  amoadd.w.rl s8, s4, (t6)
  amoxor.d.aqrl a1, a1, (t6)
  fmv.d.x ft2, s2
  fcvt.d.w fs8, tp
  remuw s6, s6, s2
  fcvt.s.l ft8, s4, dyn
  lbu s0, -1686(t6)
  fcvt.d.lu fa3, s4, dyn
  fcvt.d.lu fs0, a1, dyn
  amoadd.w.aq t3, t3, (t6)
  fmsub.d ft11, fa3, ft8, fa4, dyn
  or a0, t3, s6
  remuw a5, a0, a1
  flw fa3, 1772(t6)
  amomin.w s3, s6, (t6)
  amomin.w.aqrl t4, t4, (t6)
  amoadd.d.rl a3, t4, (t6)
  fcvt.l.d t3, ft2, dyn
  mulhu s2, a5, s3
  fcvt.l.s s9, fs0, dyn
  sllw s10, s10, s9
  divuw a7, s3, a3
  fsw fs9, -896(t6)
  fcvt.l.s a5, ft11, dyn
  mul s6, s2, a5
  amominu.w s1, a3, (t6)
  auipc s10, 79778
  remuw s3, a4, s1
  lui s2, 1048575
  mulw t2, s5, s2
  amomax.d.aqrl t3, t3, (t6)
  lw a6, -1472(t6)
  fcvt.s.l fs8, s10, dyn
  li s11, 3
  bwd_0:
  amoxor.w.rl a3, t3, (t6)
  fcvt.lu.d gp, ft10, dyn
  subw tp, tp, s2
  addi s11, s11, -1
  bne s11, zero, bwd_0
  fcvt.s.l fs0, t3, dyn
  addiw t4, s11, 2047
  srli s6, gp, 37
  fcvt.lu.s s0, fs0, dyn
  amomin.d.rl a5, tp, (t6)
  sll s10, s11, a5
  sraw a2, s0, s6
  nop
  amomin.w s7, s7, (t6)
  amomax.w.aq a1, gp, (t6)
  fmsub.d ft10, fs9, fa2, fa0, dyn
  sraw t4, a5, t4
  mulhu t1, a2, t4
  remw gp, sp, a1
  mulw ra, t1, ra
  divuw s7, gp, t1
  add a3, t1, s0
  div a0, s3, t1
  fcvt.l.d a5, fa0, dyn
  amoor.d tp, s7, (t6)
  fclass.d s3, ft4
  fcvt.l.d t3, fs9, dyn
  mulhu s6, a6, s3
  amoadd.d.rl a5, s6, (t6)
  amomax.w sp, sp, (t6)
  amomax.d.rl s11, a6, (t6)
  amoand.w.aq s8, t3, (t6)
  addw s4, a5, s11
  fcvt.s.l fs4, s8, dyn
  rem t2, s4, s9
  divuw s2, t2, s8
  fsub.d fs9, ft10, fs4, dyn
  fmin.d fs6, ft10, fa5
  mulhsu ra, s11, t2
  fcvt.l.d a0, fs9, dyn
  bltu ra, t2, . + 20
  rem zero, a0, t1
  flw fa3, 324(t6)
  fsub.d fa4, ft3, fs11, dyn
  remuw s9, s0, zero
  fwd_0:
  amoor.w s11, s11, (t6)
  andi s5, s5, -1
  amomin.w.aqrl t2, s9, (t6)
  mulw s6, s6, sp
  amomin.d.rl a2, a2, (t6)
  amoswap.d.aqrl a6, s6, (t6)
  amomin.w.rl a7, a7, (t6)
  bge a7, s6, . + 24
  slti a0, s6, -2048
  fcvt.d.s fs2, fs4
  fmax.d fs2, fa3, fs4
  fcvt.d.lu ft4, t2, dyn
  subw a1, a1, a1
  fwd_1:
  fcvt.wu.d s2, fa3, dyn
  fcvt.lu.d s8, fs6, dyn
  amomax.d.rl a1, s5, (t6)
  divuw t1, a1, sp
  fmadd.d fs4, fa4, fa6, fa4, dyn
  amominu.w a5, s8, (t6)
  ori t2, s5, 1696
  divuw s4, s5, s4
  fsw fs6, -1944(t6)
  fld fa2, -1528(t6)
  divuw s1, s1, t2
  amomax.d zero, s1, (t6)
  sltiu s6, s1, 1
  fmv.d.x fs5, s6
  sc.d.aqrl s4, a5, (t6)
  divuw a0, a0, s6
  sraw a7, a7, a0
  amoor.w.aqrl s8, zero, (t6)
  fsw fs2, -260(t6)
  mulw s9, t0, s8
  fcvt.l.d s5, ft4, dyn
  fcvt.l.s zero, fs2, dyn
  fsw fs5, 220(t6)
  fcvt.l.s a0, fs5, dyn
  srliw s11, a0, 21
  amomax.d.aqrl sp, t0, (t6)
  mulhu a7, sp, s11
  amoswap.w.aq a4, a2, (t6)
  amoswap.w s8, s11, (t6)
  fcvt.d.l fs8, a4, dyn
  fmax.d ft10, ft4, fs10
  fsw ft3, 1448(t6)
  fcvt.l.s s9, ft4, dyn
  ebreak
  divu a6, t1, s2
  fcvt.d.l ft6, t2, dyn
  fsw fs11, 1696(t6)
  slti a6, t3, 0
  fcvt.lu.d gp, fs11, dyn
  amoxor.w.rl sp, a7, (t6)
  slti t0, sp, 1460
  sraiw s6, t0, 18
  sd s4, 1992(t6)
  srai s5, s9, 23
  srai s8, sp, 0
  fcvt.lu.s t1, fs1, dyn
  remw ra, s5, t1
  fcvt.lu.d s11, fs10, dyn
  sllw s3, ra, t1
  fcvt.d.lu fs6, t1, dyn
  fcvt.l.d a0, fa6, dyn
  fmv.d.x fs9, s0
  rem tp, a3, ra
  fcvt.l.s s2, fa7, dyn
  fmv.x.d zero, ft4
  amoand.d.rl a3, a0, (t6)
  fcvt.s.lu ft3, tp, dyn
  fsw ft8, -564(t6)
  addi tp, a3, 2047
  sd tp, -1280(t6)
  slliw s11, a3, 19
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
.word 0xe634fc7f, 0xad1040de, 0xb340a8c3, 0xdc0dc74a, 0x82f231d1, 0xfaece433, 0xfbe3862f, 0x40b87fca
.section .mem_region, "aw", @progbits
.align 4
mem_region:
.word 0x8d2ef4bf, 0x69898712, 0x77251465, 0xdf7599bb, 0xa38c9eda, 0xd4f55bdf, 0xb258506d, 0xaa2cc44d
.word 0x407f5ba1, 0xf7ccb352, 0xd01c9ba8, 0x4bb276bb, 0x4e48bed6, 0x369db19d, 0x2132d56d, 0x85ce3366
.word 0x5753db02, 0x6f6f1aa6, 0xfc2ffd64, 0x3dba500e, 0x1b0cb5f1, 0x7008f89f, 0x9b0f9c43, 0x56cc7bf4
.word 0xc8da25fa, 0x5c36d592, 0xebbc4304, 0x81b56837, 0x9fd4e8b9, 0x138d5848, 0x5bf0e752, 0xc34e498f
.word 0x4ddb3b2b, 0xb395cafa, 0x27e486a4, 0x4a5c9d96, 0xa2a5a3dd, 0x5f46aad8, 0xf7b58a2c, 0x9c3cc7cd
.word 0x71579c94, 0x61e51a80, 0x468d0af0, 0x19c87890, 0x5d4312f3, 0x3f5bbec2, 0x3c657e00, 0x2e038a23
.word 0x83344f1a, 0x84f0d642, 0x1e8d0f54, 0xe51b0f78, 0x87d9dafa, 0x4ecd9520, 0xcda4571f, 0x85ed06e2
.word 0x07bc90c1, 0x355c523d, 0x8fe027e4, 0x551d3478, 0x708f7dd6, 0x52ed66f7, 0xfb8fc36c, 0x0852fc23
.word 0x38f4ae6e, 0x029a86c8, 0xad5e331a, 0xad4eb705, 0x99d3cc91, 0x9778a956, 0xcbd2356d, 0x7d780278
.word 0xdd3e4865, 0x6b5914b6, 0x63f2d1e6, 0x587a6074, 0x27aa44ea, 0x6b67c8e2, 0xbaec1cc8, 0x2d5db087
.word 0x98a46739, 0x63956d37, 0x5f052483, 0x67faec1e, 0x1e47cdf6, 0x7cd4b08a, 0x3f0a612c, 0xb295ea9e
.word 0xb4222866, 0x97219eb9, 0xa2952372, 0xce357244, 0xb3c6e609, 0x9a33c270, 0x7b3e8288, 0x67034c74
.word 0x288aa2ca, 0x3967a785, 0x732789c7, 0x83f92092, 0x6a03e432, 0x621aad42, 0xa36e7b02, 0xf707795e
.word 0x146b6206, 0x564df5b1, 0x0f0d6232, 0x51bdf087, 0xddcfc954, 0x5777c499, 0xe74a5910, 0xa041e23d
.word 0x005aa299, 0xe70e1c83, 0x24c2cdc3, 0x2b4dd73e, 0xaf331cf7, 0xf0a07125, 0x212844a6, 0xab603216
.word 0xd53abd82, 0xc583a800, 0x71407b6a, 0xa9fc195b, 0x044f8743, 0xfccc9acb, 0xbdbd8a9a, 0xdc281897
.word 0xbf051b81, 0xdc8705ee, 0xfb3cc798, 0xb24b1d92, 0xcd44a1be, 0xc6bd1eb9, 0x2ec9f684, 0xfadf7dfa
.word 0xbc9b29cb, 0xf873e68b, 0x319343a4, 0x9b056bbf, 0xd02c8806, 0xba187141, 0xa5b231d3, 0x9efec871
.word 0xa8bbb44e, 0xb6219cc9, 0x190d744e, 0x64dc6012, 0x15b1ffa3, 0xcf9e547b, 0x595dec1c, 0xe84f9d5d
.word 0x2baccbe0, 0x8ce179f1, 0x5c048eed, 0xad7cf8d6, 0xb51ba371, 0x4b2b4968, 0x6226b551, 0x9c586270
.word 0xa88c3468, 0x942cad3c, 0x059dd98c, 0x41310eda, 0xee9a74af, 0x61b09040, 0x84f37ccc, 0x9e883f29
.word 0x62d004d8, 0xf81af948, 0xf37d40d3, 0x8c16d229, 0xdcbdd1a1, 0x571e9211, 0xcc8726a0, 0x805dbf48
.word 0x9c0e775e, 0x2426b863, 0x00432a14, 0x18e05d29, 0x95701afc, 0x4b6f0c5f, 0x79460c8d, 0x52c04657
.word 0x73a800d5, 0x6b8fc2b4, 0x923cb34a, 0xc1dd45d6, 0x422edd6e, 0x5ebaedc1, 0x415c0e09, 0x14841046
.word 0x088ea4ed, 0xc65ac9ca, 0x1b160cb4, 0x5e4a3c3f, 0x9764adad, 0x496fe36d, 0x457af659, 0x8011651d
.word 0x1671cc79, 0xa4f402b7, 0x57fa3e4f, 0xd79ac427, 0x34a411f0, 0x8c8e9368, 0xea5afd2d, 0x9f63476e
.word 0x74b9ba50, 0xb7d3b8d4, 0x595d2598, 0x00acc3f4, 0x119aaead, 0xb5cfea2c, 0xbd91b1f8, 0xa81a9398
.word 0x1e96d0bb, 0x80b96f7f, 0xb2d62db6, 0xdd692556, 0x0c15af80, 0x24d3f8d8, 0x8e3dce7d, 0xefd0ac74
.word 0xe691316e, 0xf1d8c01f, 0xe288e459, 0x3fde236f, 0x8565b24e, 0xc307733f, 0xcc3bee43, 0xa4233c8b
.word 0x543d03a5, 0xa3fa82a1, 0xc2ccfd9e, 0x6d0f986f, 0x773022cc, 0x2bdec711, 0xe360ff2d, 0x18b4863b
.word 0xf9b0a8da, 0x29894fbc, 0x55f185df, 0x5dc66e5e, 0x41af0ef6, 0x3c6c7b41, 0xa2f1bbab, 0x3e58dbeb
.word 0xac8a0a38, 0xb8c5bb6b, 0xc18fece6, 0x67ce5efc, 0x3d756149, 0xbfa86155, 0xc30f5607, 0xf9494b35
.zero 7168
mem_region_end:
