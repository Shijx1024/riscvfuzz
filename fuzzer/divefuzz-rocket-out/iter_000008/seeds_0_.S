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
  li x26, 0x0000000a002061a2
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
  li x1, 0xfd60a112aa6567ad
  li x2, 0xe07e1c2064ad0d4d
  li x3, 0x6a1b940ce8ecab55
  li x4, 0x2e5d045015e28843
  li x5, 0xbc696e91a3715d0f
  li x6, 0xae4b6f02391aa351
  li x7, 0xfb8047e26a9a4dd7
  li x8, 0xd7cd3b3739f75917
  li x9, 0x98f154acff912c39
  li x10, 0x5058a4371099199b
  li x11, 0x74f79c04c2c7c648
  li x12, 0xce94695dadabc821
  li x13, 0xcc253ed438866358
  li x14, 0xb021a27419e48b4d
  li x15, 0xab52182d6a92f958
  li x16, 0x6bfcfcf163fef165
  li x17, 0xf53ccf1645175aad
  li x18, 0x4eed5767dd3946bc
  li x19, 0x405fca83513ca59b
  li x20, 0x8b2352274e827338
  li x21, 0xce97490e4c201431
  li x22, 0x5eb2daa5e3724ad4
  li x23, 0x21b3dc175e7383a2
  li x24, 0x796bfd9954c0cf91
  li x25, 0xd24ef9f43e8454cf
  li x26, 0x0a93cc4fdce7e98f
  li x27, 0x44515ad41a59aac2
  li x28, 0x4c6799083a59c462
  li x29, 0x50afe352aec1aa92
  li x30, 0xa08b9181f385dcad
  li x31, 0x4edef1533c64eb9b
  li x5, 0x5d2f5da5afb0306c
  fmv.w.x f0, x5
  li x5, 0x0bc7dcaba897736c
  fmv.w.x f1, x5
  li x5, 0xacf9609d103ae4a1
  fmv.d.x f2, x5
  li x5, 0xf952c676a291c9aa
  fmv.d.x f3, x5
  li x5, 0x2a37ca1988d4dd2b
  fmv.d.x f4, x5
  li x5, 0x80ad127948730728
  fmv.d.x f5, x5
  li x5, 0x1bda43aeb354b440
  fmv.d.x f6, x5
  li x5, 0xdb977296659bbf91
  fmv.w.x f7, x5
  li x5, 0xc687b0442d7d3389
  fmv.w.x f8, x5
  li x5, 0x1fd43da7afc4e4d4
  fmv.d.x f9, x5
  li x5, 0x72f1e86814896460
  fmv.d.x f10, x5
  li x5, 0xca3e64c772926e04
  fmv.w.x f11, x5
  li x5, 0x3268909bbeaa4d70
  fmv.w.x f12, x5
  li x5, 0xc6a2a668c2676f66
  fmv.w.x f13, x5
  li x5, 0x6e929aa661ceed59
  fmv.d.x f14, x5
  li x5, 0x12dde27c6abf3a81
  fmv.d.x f15, x5
  li x5, 0x1c96093e338ad0b4
  fmv.d.x f16, x5
  li x5, 0x137f039e40a1db0c
  fmv.w.x f17, x5
  li x5, 0xa8dd75948e86eae0
  fmv.d.x f18, x5
  li x5, 0xcfe64197ab84f0e1
  fmv.w.x f19, x5
  li x5, 0x918d1cfb29b42ecd
  fmv.w.x f20, x5
  li x5, 0x97ac5d7a60a1e023
  fmv.w.x f21, x5
  li x5, 0x0e2f1e4d35715a08
  fmv.d.x f22, x5
  li x5, 0xcac667b8a333ab6c
  fmv.d.x f23, x5
  li x5, 0x5ef13797ba358a95
  fmv.w.x f24, x5
  li x5, 0xd44e6e0f039a3dc8
  fmv.w.x f25, x5
  li x5, 0x3b320a816ff6aa2d
  fmv.d.x f26, x5
  li x5, 0x219db66ae6952697
  fmv.d.x f27, x5
  li x5, 0xe2d2a35b53ab934a
  fmv.w.x f28, x5
  li x5, 0x73d6ea226860dc26
  fmv.d.x f29, x5
  li x5, 0xc1f54a65930d11ec
  fmv.d.x f30, x5
  li x5, 0x689c97a4eb8d4a3f
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
  fcvt.d.lu ft4, s5, dyn
  mulw a2, a2, a2
  fsgnj.d ft9, ft4, ft4
  fsgnjx.d fa4, ft9, ft3
  lb s3, 1594(t6)
  amomaxu.d a3, zero, (t6)
  fmv.d.x ft1, zero
  subw tp, a3, a3
  fcvt.wu.d gp, fa4, dyn
  sra a3, s3, s3
  fmv.x.d s8, fa4
  fsgnj.d fa1, fa1, ft4
  fsgnjn.d fa2, fs2, fa4
  fcvt.d.l fs5, s8, dyn
  sh s3, 728(t6)
  fcvt.s.lu fs9, gp, dyn
  fcvt.d.l fa4, a2, dyn
  divuw s1, gp, s8
  divu t1, s1, s8
  fcvt.l.s s10, fa1, dyn
  mul a4, t1, s8
  fle.d t0, fs9, fa2
  sraiw s6, a4, 1
  flw ft5, -524(t6)
  amoor.w ra, t1, (t6)
  ecall
  sub a2, s10, gp
  div s11, s5, s11
  div s9, s11, a2
  fcvt.lu.s s5, fa0, dyn
  amoadd.w.rl tp, tp, (t6)
  amoswap.d t2, s11, (t6)
  slli s7, s7, 24
  subw s2, s2, t1
  fmv.d.x fs9, s2
  fmv.x.d ra, ft0
  remuw a1, a7, zero
  fsw fs8, -164(t6)
  or t1, t1, ra
  fence
  fcvt.d.lu fs3, s7, dyn
  fcvt.s.d ft6, ft9, dyn
  remu s10, a1, tp
  sc.d.aqrl a6, s10, (t6)
  fcvt.l.d s0, ft8, dyn
  fcvt.lu.s s10, ft6, dyn
  fsw ft6, 112(t6)
  remw s1, s0, tp
  amoswap.d.rl s5, s5, (t6)
  amomax.d.rl gp, s10, (t6)
  sc.w.aq tp, s1, (t6)
  sd s0, 1624(t6)
  fcvt.lu.s a3, ft0, dyn
  amoor.w.rl s0, t2, (t6)
  fcvt.s.lu ft6, s0, dyn
  fcvt.d.l fs11, s1, dyn
  remw s11, a3, tp
  lbu s6, -1776(t6)
  amoor.w.rl s2, s2, (t6)
  fsw ft1, -352(t6)
  fsw fs4, 1672(t6)
  fcvt.d.lu fs10, a2, dyn
  sraw a3, s2, t3
  fcvt.l.s a7, fs11, dyn
  sh a6, 1434(t6)
  mulw zero, t0, s4
  fcvt.l.s s11, ft0, dyn
  amominu.w.rl s8, s11, (t6)
  fcvt.s.lu fs3, tp, dyn
  srai s3, a7, 63
  amomax.w.aqrl gp, s10, (t6)
  auipc t0, 0
  fcvt.s.l ft8, s3, dyn
  mulw a1, a6, s8
  fcvt.l.d a3, ft11, dyn
  amoadd.d.aq zero, zero, (t6)
  remw s9, tp, t0
  remu t1, gp, zero
  amomax.d.rl t4, a3, (t6)
  andi s2, a4, 1917
  ld s3, 656(t6)
  sra s1, t1, s2
  srai a5, a6, 24
  fcvt.l.s zero, fs6, dyn
  lr.w.aq s2, (t6)
  amomin.d t4, s1, (t6)
  fsgnjx.d ft3, fs11, ft8
  fcvt.lu.d s4, fs6, dyn
  fsw fs6, 1760(t6)
  remuw tp, s8, zero
  divuw ra, ra, ra
  bgeu tp, s7, . + 28
  divw a5, s4, tp
  sra s6, a5, a5
  flw fs6, -800(t6)
  amomax.w.aq t2, s7, (t6)
  div s4, a5, a5
  fclass.d a2, fa4
  fwd_0:
  fsgnj.d fa5, ft0, fs10
  lwu a0, -228(t6)
  amominu.d.rl s10, s6, (t6)
  fcvt.d.w ft11, t2
  amomaxu.w.aqrl s5, a2, (t6)
  amoand.w sp, s10, (t6)
  fcvt.lu.d s5, ft4, dyn
  fcvt.d.lu ft4, s5, dyn
  amoadd.w.aqrl s10, s3, (t6)
  amomaxu.w.aq s7, sp, (t6)
  fcvt.wu.d a4, fs2, dyn
  sc.d t4, s10, (t6)
  remw t1, ra, s1
  amoadd.w.rl s6, s0, (t6)
  fmv.d.x fs10, t1
  div zero, zero, t1
  amoor.d.rl s0, tp, (t6)
  mulw t2, s0, ra
  remuw a5, a5, a5
  fcvt.lu.d t4, fa2, dyn
  rem s10, s10, s9
  mulhsu s8, a5, s8
  divw s7, s10, t2
  fmul.d ft10, fs8, fa5, dyn
  fcvt.l.s s5, fs0, dyn
  amoand.d.aqrl t0, tp, (t6)
  fsw ft4, -248(t6)
  mulhu sp, gp, gp
  li s11, 3
  bwd_0:
  flw fs9, -912(t6)
  flw ft9, 1164(t6)
  sltu t1, s5, t0
  amominu.w.aqrl s7, t0, (t6)
  addi s11, s11, -1
  bne s11, zero, bwd_0
  fcvt.lu.s tp, fa2, dyn
  fcvt.l.s s1, ft4, dyn
  fmv.d.x fa3, a2
  sd ra, 72(t6)
  fsw fs3, 708(t6)
  remu a0, a2, ra
  fcvt.s.l ft3, a1, dyn
  fsgnjx.d fa2, fa1, fa2
  jal a5, . + 28
  feq.d a4, fa2, ft11
  sraw a3, a5, a4
  lr.d.aq gp, (t6)
  xor tp, a0, sp
  sc.w.aqrl s0, a0, (t6)
  mulw s4, s4, a3
  fwd_1:
  remuw s5, gp, a3
  amoxor.d.aq s5, s4, (t6)
  div a7, t0, s4
  fcvt.lu.s ra, fa2, dyn
  jal a2, . + 36
  fcvt.d.l ft7, s0, dyn
  amomax.d.rl s7, s7, (t6)
  amoadd.d.rl t3, s5, (t6)
  ebreak
  mulhsu t2, t2, a2
  amomax.d.aqrl a5, t2, (t6)
  remuw a6, a6, t2
  srai a7, s1, 47
  fwd_2:
  mulhsu t2, a6, s9
  fsw fa7, 1476(t6)
  fmsub.d fs4, ft10, ft6, ft11, dyn
  amoor.w.aq a1, t3, (t6)
  fsw fa2, -1108(t6)
  amomin.d.rl s7, a6, (t6)
  fcvt.s.l fs0, a5, dyn
  remw ra, t2, s7
  sc.w.aqrl t1, s7, (t6)
  fcvt.w.d gp, ft7, dyn
  subw a1, s5, s7
  fmv.d.x fs6, a5
  srai a6, t1, 2
  fcvt.d.lu fs5, t4, dyn
  divw s8, s10, a4
  fcvt.d.l ft1, t4, dyn
  amominu.w.rl s4, a2, (t6)
  amoadd.d.aqrl a6, t2, (t6)
  sllw s1, zero, s0
  fcvt.lu.s s8, fs6, dyn
  srlw s11, a6, s8
  fcvt.l.s tp, fs6, dyn
  fcvt.d.lu ft7, s11, dyn
  blt s8, a5, . + 36
  fcvt.d.l fs1, s11, dyn
  ld a1, -1056(t6)
  sc.d.rl s6, t3, (t6)
  remw t3, s8, t3
  amoswap.w.aqrl t0, t3, (t6)
  slti a2, t0, 1
  mul sp, a2, a1
  lui s8, 1048575
  fwd_3:
  amoswap.d.aqrl a0, a5, (t6)
  fcvt.l.d s3, fs5, dyn
  sll s6, s8, s3
  fclass.d s1, fs5
  mulhu a7, s3, s1
  fcvt.l.d a4, fs7, dyn
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
.word 0xed38511e, 0xc03dab38, 0xe58bf580, 0xd96ebb4e, 0xcdba3052, 0xf5ab52ef, 0x731bebc3, 0x8d4bce87
.section .mem_region, "aw", @progbits
.align 4
mem_region:
.word 0xa03ea69a, 0xd80b81c6, 0xcb6b3412, 0x5192df4f, 0xef0e8e12, 0x21015258, 0x28ec67c7, 0x00cdee2e
.word 0xa9916b65, 0x83842a3b, 0xadaac4d6, 0xedf64104, 0x9d86544d, 0xb0620f9d, 0x74cef190, 0xcbe1a222
.word 0xba8f51db, 0x07e90b84, 0xf45143c4, 0xa742db9d, 0xb7b2383f, 0xcd0fa2d6, 0xa29b0efc, 0xd076a56b
.word 0xf23d63f9, 0x54106a83, 0x359775e4, 0xd45d029d, 0x5c630764, 0x586cca3d, 0x07f79bc1, 0x1d9c9a51
.word 0x8e2f140d, 0xfb58a0bd, 0x11f7efa7, 0x39decd14, 0x46dff25e, 0x64457d0f, 0x3b71f536, 0x205636b6
.word 0x5e7cff6b, 0x63706c02, 0x4b7208ca, 0x2e4312e2, 0x46f6f018, 0x2ba6454d, 0x0fb12403, 0xed7acde5
.word 0x3b7aa03a, 0x5552dad8, 0x00bea700, 0x1ef9a33f, 0x6e5dd501, 0x9e00fe99, 0x2804dc32, 0xe00398db
.word 0xca72a67c, 0xad92f096, 0xf48cadb4, 0xcbda88a7, 0xf6ce970b, 0x930cf560, 0xaec1a30d, 0x3856ffee
.word 0x913a71fc, 0x354e5936, 0x4c818694, 0xdf69921c, 0xe39bae1c, 0x4d5fb564, 0x39f1747a, 0xdc42d293
.word 0xeab04b09, 0x80ce54ae, 0xf5c47cd2, 0xe6870deb, 0xc8860f03, 0xec59c530, 0x30d02999, 0x684ea8ca
.word 0x8dbd7823, 0x3e415756, 0xfb0e42ef, 0x586ca148, 0x3fa56012, 0x62b2e23d, 0x6e8a7ec5, 0xa35a5090
.word 0xa33cce24, 0x0af8db64, 0x19644bc9, 0x5d63a75d, 0xbb8b6d55, 0x1fe51dc7, 0xa3e57c5f, 0x4b0c2770
.word 0x59dc7f12, 0xfade3d78, 0x723b4629, 0x7d66d726, 0x4e1f8837, 0xd1bc53fe, 0xd16877e3, 0x2feb7dc2
.word 0x1342165f, 0xcad6b824, 0x1a18daf5, 0xdc0eb563, 0xf1628112, 0xd6f8041e, 0x3780a76f, 0x0daf5090
.word 0xb4724da7, 0xb08bd69b, 0x1ea575bb, 0xce84bd8f, 0xbc0dccdc, 0xc8c248b8, 0xa29ed84f, 0x3d179d32
.word 0xa54f7057, 0xcfe217cc, 0x37a0fbe1, 0x05768faa, 0x465e2028, 0x0736ed14, 0xe7afe099, 0xba7144d8
.word 0x58a171ed, 0x2bf8dfdb, 0x118c3282, 0x4a46f0cf, 0xfee13387, 0x9abaefdf, 0x2140212c, 0x864ead18
.word 0x98f0f73e, 0xccbb4639, 0x502fa106, 0x0e3cef49, 0x208b9c81, 0xa4e811ec, 0x391d1380, 0x61039452
.word 0xf564a1eb, 0x815f106e, 0x84537e07, 0xc5290736, 0x7a9e3686, 0xd709885a, 0x7b138a98, 0x7817bfeb
.word 0xa8657dbb, 0x9cbbe487, 0xa6811a99, 0x5ae5c778, 0x62cb3ab9, 0x6f84bd4b, 0x9e83bf57, 0x0a439ba7
.word 0x45012cc4, 0x4a9b8dbc, 0x37cc41e1, 0xf79d7d9e, 0x065c8b97, 0x55f30e5d, 0x1c2088ca, 0x305407fd
.word 0x413dcfbd, 0x9ad98f6f, 0x3f791215, 0x9671da7a, 0xc7d1f85e, 0xd10d1d90, 0xb770af15, 0x92cb6521
.word 0x02a63c55, 0x3c4d82e4, 0x1ac62a2f, 0xa702f3a0, 0x4f2b81c6, 0x57a1bca8, 0xf34fa7ab, 0x5b83a58d
.word 0x331d3f74, 0xefc89046, 0x0f9eede0, 0xa185c90a, 0x484fb9a6, 0xe97655f0, 0x1576f788, 0x51828f6d
.word 0x84c8ed86, 0xb533005e, 0xa60238e1, 0x40e4fcb6, 0x7b2d7847, 0xd764a6fe, 0xd3e9df94, 0x25f833b5
.word 0x8752e391, 0xf1e98403, 0x46133303, 0x60f15b4a, 0x6c76a117, 0xca24ae65, 0x9f49a81c, 0xbff73ef0
.word 0x076b89f2, 0xe286ad3b, 0xf1bcf58f, 0xb53914e2, 0x8311f504, 0xbb89fea8, 0xcbd30f0f, 0x63a0a72a
.word 0x754163b6, 0x48ef3409, 0x058d349e, 0xf6750712, 0x2bc792b9, 0xd0d3846d, 0xa49aea38, 0x027822ff
.word 0x0dcac4ce, 0xdbb7ec78, 0x813525b6, 0xf97db778, 0xb134ae98, 0x64ee9394, 0xaf7ee981, 0x2335b948
.word 0x32880839, 0xa404feb9, 0x4c06bca7, 0xe2669f70, 0x3307ed72, 0x8ff5121f, 0xaf9b6c42, 0x43c9b3e1
.word 0x2a33cb15, 0x507bd664, 0x8bb177e1, 0x83c740cd, 0xa3a674ee, 0x4a16d846, 0x932bc1a9, 0xeb09a7b2
.word 0x42899ce7, 0x7b1d0730, 0xfb843aea, 0xae521136, 0xa210ac08, 0x425f99dc, 0x3a14ba69, 0x694b4d27
.zero 7168
mem_region_end:
