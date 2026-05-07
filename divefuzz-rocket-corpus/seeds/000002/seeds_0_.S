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
  li x26, 0x0000000a0059e1a0
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
  li x1, 0x830c6a8101fc9dc2
  li x2, 0x6866b5c74f7987c8
  li x3, 0x1066a341f9ae507b
  li x4, 0x96ced5bebb048845
  li x5, 0x59e13c27b3a88c09
  li x6, 0x0808218a892c1371
  li x7, 0xf4d4980eec7368b7
  li x8, 0xac86e71bca3bc162
  li x9, 0x45f2adba6b05d5b4
  li x10, 0x715a5d3315d0c01b
  li x11, 0x106004c3623334bf
  li x12, 0xee4b7b01322a56a2
  li x13, 0x571503bc8be15c7e
  li x14, 0x0bd74aff640b352c
  li x15, 0x346959b1403f4f31
  li x16, 0xd1ff28efa5d086df
  li x17, 0x02a76a3daf2f4d29
  li x18, 0xeb9446daa2080a4c
  li x19, 0xe1fd9a25033ebadb
  li x20, 0x330239d4703818db
  li x21, 0x8c44c468b621332e
  li x22, 0x51e566722614fb81
  li x23, 0xd2151fe962dc9b92
  li x24, 0xe45abeaf54a33a98
  li x25, 0x43688dea70862fbb
  li x26, 0x6593ab469acac27d
  li x27, 0x1a3012ce303533d6
  li x28, 0x21e494083b68b6f9
  li x29, 0x606082e8b455c444
  li x30, 0x92038375de618b02
  li x31, 0xb451aa543ac9527e
  li x5, 0x909aa6b2ee15cdbf
  fmv.d.x f0, x5
  li x5, 0xea622e436cf47d92
  fmv.w.x f1, x5
  li x5, 0x6c00c1aac4095e0a
  fmv.d.x f2, x5
  li x5, 0xd333d579495eae2f
  fmv.w.x f3, x5
  li x5, 0xc32d47e9efcb2e15
  fmv.w.x f4, x5
  li x5, 0xf12c9a46b20f291b
  fmv.w.x f5, x5
  li x5, 0xc44091e7934a414d
  fmv.d.x f6, x5
  li x5, 0x788b670e00fd1f7f
  fmv.w.x f7, x5
  li x5, 0xa50fb2c149aad9f9
  fmv.d.x f8, x5
  li x5, 0x856052a76038c173
  fmv.d.x f9, x5
  li x5, 0xdf8fa2c9184fac5f
  fmv.w.x f10, x5
  li x5, 0xbcda5b3ddecc5504
  fmv.d.x f11, x5
  li x5, 0x51e12a6aeb8a3998
  fmv.w.x f12, x5
  li x5, 0x41c71e402292f3c7
  fmv.w.x f13, x5
  li x5, 0x6f45cdb70dbe4592
  fmv.d.x f14, x5
  li x5, 0xc148402d5507392b
  fmv.d.x f15, x5
  li x5, 0x41594e8a478c8b69
  fmv.d.x f16, x5
  li x5, 0x9e21370c4b254620
  fmv.d.x f17, x5
  li x5, 0x977ea1cac2c6ef50
  fmv.d.x f18, x5
  li x5, 0x83c79969d9ce2251
  fmv.w.x f19, x5
  li x5, 0x70b5ba5b2d0f070f
  fmv.d.x f20, x5
  li x5, 0xd8422c62ac5b5001
  fmv.w.x f21, x5
  li x5, 0x6a88377fc94ae208
  fmv.d.x f22, x5
  li x5, 0x2390a8636c2a7cef
  fmv.d.x f23, x5
  li x5, 0x63a1b3b0b38c72dd
  fmv.d.x f24, x5
  li x5, 0x15e7b9fdbae2b8d0
  fmv.w.x f25, x5
  li x5, 0x4879cbd28779b27e
  fmv.d.x f26, x5
  li x5, 0x5e750ada0af4ab7a
  fmv.d.x f27, x5
  li x5, 0x12fa4aa8d4842c9e
  fmv.w.x f28, x5
  li x5, 0xe0bf9e8ee46c340b
  fmv.w.x f29, x5
  li x5, 0x28f040d386afb8c5
  fmv.w.x f30, x5
  li x5, 0x8c47e0de6c8d4808
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
  beq a5, a4, . + 32
  mul s10, s10, s0
  fcvt.lu.s tp, fs4, dyn
  fsgnjn.d ft10, ft10, ft10
  mulw s3, s10, s10
  sraw t2, s0, s3
  srli a3, s10, 6
  srl t0, ra, a3
  fwd_0:
  mulhu sp, sp, t2
  fcvt.d.lu ft6, a2, dyn
  srli tp, s9, 0
  fcvt.l.s s3, ft10, dyn
  flw fs11, -1120(t6)
  sra a0, s6, s3
  lr.d.aqrl s1, (t6)
  amoxor.w.aq a5, s3, (t6)
  fsw ft10, -840(t6)
  fsw fs11, -1268(t6)
  fcvt.s.lu fs10, s1, dyn
  fcvt.s.l fa5, tp, dyn
  mulw gp, s1, tp
  rem ra, gp, s1
  remw a2, s6, s1
  fsw fa6, 1872(t6)
  divu a0, s10, a2
  fmv.x.d tp, ft6
  sc.d t4, ra, (t6)
  srai t0, t4, 63
  fmin.d ft8, fs11, fs10
  fmax.d fa7, fa6, fs11
  div s0, ra, t2
  fmv.x.d s6, ft0
  mul s4, s0, a6
  li s11, 4
  bwd_0:
  amominu.d.rl tp, s11, (t6)
  fcvt.s.lu fs8, s4, dyn
  flw fs5, 296(t6)
  slliw gp, tp, 31
  addi s11, s11, -1
  bne s11, zero, bwd_0
  mulhu a1, s6, s6
  fcvt.s.l fs1, s11, dyn
  amoand.w.aqrl a5, a1, (t6)
  addw sp, a2, a5
  fsw fa0, -1792(t6)
  fcvt.s.d fs6, ft8, dyn
  sc.d t3, sp, (t6)
  srlw a0, sp, sp
  divuw a0, a6, a2
  beq a5, sp, . + 24
  fcvt.d.lu ft7, a2, dyn
  fcvt.lu.s s6, fs8, dyn
  sraiw t0, sp, 24
  fmadd.d ft8, fs6, fs6, fs8, dyn
  ld s9, 1016(t6)
  fwd_1:
  sc.w.rl gp, s2, (t6)
  lwu s7, -588(t6)
  fcvt.l.s sp, fs8, dyn
  fcvt.d.s ft4, fs1
  sc.w.rl s0, s7, (t6)
  lw ra, -1084(t6)
  fcvt.wu.d a0, fa7, dyn
  mul a2, a2, s0
  sc.w s8, a6, (t6)
  fcvt.s.lu fs9, s8, dyn
  fmv.d.x fs3, t4
  divu t1, a1, t4
  mul a4, a1, a2
  sc.w s9, a2, (t6)
  amoor.w.aqrl t0, t4, (t6)
  remu a4, t1, s9
  srai a0, t1, 0
  fcvt.s.l fs1, s9, dyn
  mulw gp, a4, s9
  fmv.x.d a5, fs1
  beq gp, a0, . + 32
  amomaxu.d.aqrl s2, a5, (t6)
  fcvt.d.lu fs1, a0, dyn
  sraw s4, a5, t0
  flw fa3, -644(t6)
  subw s10, s10, s11
  fcvt.l.s t0, fs8, dyn
  flw fs6, 1240(t6)
  fwd_2:
  lb s11, 1403(t6)
  sd s10, -104(t6)
  amominu.d.aqrl ra, s7, (t6)
  amomin.d ra, ra, (t6)
  amoadd.w s2, ra, (t6)
  fdiv.d ft1, fa3, fs3, dyn
  fcvt.s.d fa5, fs4, dyn
  divw s2, ra, t2
  addw zero, s0, s8
  sd zero, -1088(t6)
  fmv.x.d s2, fs4
  fcvt.s.lu fa2, a3, dyn
  fld ft9, 144(t6)
  fmv.d.x fs4, t3
  bgeu t3, a0, . + 28
  fnmsub.d ft6, fs4, ft4, ft6, dyn
  mul s8, gp, gp
  fcvt.d.lu ft5, a0, dyn
  fcvt.l.d s3, ft4, dyn
  fcvt.s.l ft9, a3, dyn
  lbu a7, 1778(t6)
  fwd_3:
  divuw t3, a6, a7
  fcvt.l.s t4, ft9, dyn
  amoadd.d.aqrl a3, a5, (t6)
  remuw a0, t4, a3
  divuw s2, gp, s2
  mulw t3, s6, a1
  fmul.d fa4, fa2, fa2, dyn
  slli a5, s7, 0
  amoor.w.aqrl t2, t2, (t6)
  fcvt.lu.d a6, fs10, dyn
  fcvt.l.s a7, ft3, dyn
  div s1, a7, zero
  fcvt.s.lu fs11, s1, dyn
  amomin.w.aqrl t4, t4, (t6)
  fsgnjx.d ft7, fs11, fs11
  mulhsu s5, t4, a7
  amoand.w.aq ra, s1, (t6)
  divu t1, s5, s5
  amoadd.d.aqrl s4, s1, (t6)
  divu a4, s4, s4
  fsgnjn.d fa2, ft7, fa2
  fsd ft7, 1136(t6)
  mulw s10, s0, a7
  divu a6, a1, a2
  sltu a0, s4, s11
  divw s9, s9, a1
  mulw a6, t1, t4
  fcvt.d.l fa3, t0, dyn
  remw s1, t4, t0
  mulhu s11, s9, t2
  and a0, a0, s8
  fcvt.lu.s t4, fs2, dyn
  mulw a2, s5, s1
  fcvt.l.s t0, ft2, dyn
  amomaxu.d.rl t1, t0, (t6)
  sb zero, 1116(t6)
  addw a6, t1, s9
  flt.d s1, fs2, fa4
  divw a5, s1, a6
  amoand.d.aqrl ra, s4, (t6)
  amomin.d.aqrl s7, s7, (t6)
  fcvt.wu.d a4, ft2, dyn
  fcvt.s.lu fs5, a6, dyn
  mulw gp, s7, t2
  fcvt.lu.d s11, fs2, dyn
  amoor.d.aq s4, s11, (t6)
  subw sp, s4, s5
  sw a6, 136(t6)
  amomin.w s5, s5, (t6)
  mul t2, t3, s5
  fcvt.s.lu fs8, s5, dyn
  slli t4, s5, 0
  fmv.x.d a1, ft9
  amomin.d s1, a1, (t6)
  fcvt.l.d s9, ft11, dyn
  fcvt.lu.d s2, ft6, dyn
  sll s10, s1, s1
  divu a0, a1, s9
  divw s8, s1, s2
  mulhu s0, s8, s2
  fcvt.s.lu fa3, s10, dyn
  sraw a3, s10, s0
  ori s11, s0, -115
  fmv.x.d a2, fa2
  remuw s3, s8, a2
  addw s9, a2, a3
  fcvt.l.d a0, ft2, dyn
  mulw t2, a0, t1
  mul t4, t4, a2
  fmv.x.d s2, fs4
  fcvt.d.l ft9, s2, dyn
  amoand.w.aqrl s6, t4, (t6)
  sub s9, s6, a1
  amoxor.w s7, t4, (t6)
  fcvt.l.d gp, ft7, dyn
  sll zero, gp, gp
  amoswap.w.aqrl a7, a5, (t6)
  mulw a2, a2, s7
  remuw s6, a7, a7
  sraiw s7, zero, 23
  mulhu s6, gp, t3
  remuw s9, a6, s4
  sc.d.rl s8, a7, (t6)
  fcvt.s.l ft8, t0, dyn
  fcvt.lu.d sp, ft8, dyn
  remw t2, s6, sp
  divuw s4, s4, s6
  addw a4, s4, s4
  amoor.d.rl a2, a2, (t6)
  divuw t3, t3, sp
  addw s10, t2, s4
  amoand.w.rl a1, a4, (t6)
  fsqrt.d fa2, fa6, dyn
  fsgnj.d fs5, ft7, ft2
  div s1, gp, a6
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
.word 0x7773146b, 0xf9c68632, 0xde7aac2c, 0x80bdb6f8, 0x224dce43, 0x5f7c8833, 0xb4c9bc07, 0xd77cc59b
.section .mem_region, "aw", @progbits
.align 4
mem_region:
.word 0x832410ef, 0xc8f7c44e, 0x08e18a1a, 0x293b090c, 0xf6b50f54, 0x96a9cca1, 0x8842ba47, 0x6fa6c5d8
.word 0xac338b2c, 0xf330f177, 0x5ac3078d, 0x6ed85225, 0xd8941c5b, 0x650a7848, 0x33ffb17f, 0xf56c7749
.word 0x2605e204, 0x4a0dea90, 0xf715d402, 0xf4b3195c, 0x4cb48e30, 0xf24167c0, 0x3a70ee01, 0x17fc984e
.word 0x88a1efad, 0x579345e1, 0x0613e538, 0x795fb8cb, 0x430c3c3f, 0x78bbb33b, 0xf1c6ddcb, 0xf839ae70
.word 0xe21846c9, 0xf6f0984e, 0xe899cae0, 0x5035f3c0, 0xf144cb0f, 0xd5c92624, 0xe0c33207, 0x7eb4edf4
.word 0xc900ded1, 0xb124479d, 0xccfe40fd, 0xe6d2200e, 0x1ce7ee7e, 0xff8ca4d8, 0xee72eb25, 0x305a099a
.word 0x2c235294, 0x73d9636c, 0xa8646dfc, 0x9669f903, 0x8ca37c42, 0xce22f184, 0x62b81028, 0x9e23725c
.word 0x06d32048, 0xf24c1d10, 0x0a8f493b, 0x94d3ead6, 0x6b9b6242, 0x7c95c0e3, 0xe63cd9c1, 0x79cabe10
.word 0x2b86c97c, 0xa44d2c1f, 0x3f3d2bf7, 0x6e07cfeb, 0xae45f6d5, 0x2230c7c7, 0xeba7753b, 0x483e24e8
.word 0x36c8aeb7, 0xc9f634db, 0xdec71718, 0x258dd1b6, 0x93b7484e, 0x7da35454, 0x979e2d15, 0x6905db3e
.word 0xd1a300bc, 0x60bfa9f8, 0x1709f9ea, 0x21407c89, 0xae4b7e70, 0xafd298d3, 0xef3f32ee, 0x7253499f
.word 0xb5397220, 0x3c5d3abb, 0xe8562d9d, 0x5c6703d6, 0xd089aef6, 0xeb05b50c, 0xa1e69de7, 0x3a2281eb
.word 0x8f541ac4, 0x4860fb23, 0xfcdfd943, 0x091913bf, 0xeafbf54d, 0xb0aa13a9, 0xbb57d3c0, 0x92dd3d4d
.word 0x390c528e, 0x3d8d532c, 0x9e7ff27a, 0x3f33eba1, 0xfa7598a8, 0x3cd74d5a, 0x36418725, 0x31e9f580
.word 0x7cf511ec, 0x70fba26a, 0x28233150, 0x002ae256, 0x4e957782, 0xda097fb6, 0xd881b290, 0x21aeab1e
.word 0xfffef0e1, 0x89836bb7, 0xa2476f07, 0xd3090bea, 0x2ddbfe9f, 0x9daa4ebd, 0xeb51e18b, 0x11a9afc2
.word 0x62879cd6, 0x9dfd1652, 0xcd10bf36, 0x5a563eac, 0x96c20023, 0x514878d5, 0x2a926c35, 0xc50bdbe3
.word 0x4cac45b8, 0xfbf83dda, 0xf7c20d1e, 0x674bdcc8, 0x958e7557, 0x01498a0b, 0x4a111ec5, 0x55b96d35
.word 0x46bbf5d1, 0xfa0f43d0, 0xf003cb15, 0xc020aeb9, 0x06c5f138, 0x3d98d155, 0xe301a65f, 0x4db910bd
.word 0x3e765540, 0x15aa9373, 0xeacf5864, 0x7e7c16d2, 0x12d87d5b, 0xbb906f78, 0xa2528f8c, 0xffc821ee
.word 0x29fee132, 0x2a90720e, 0xf0778d8b, 0x5beae5c4, 0x54e3e48d, 0x2eb307ba, 0x3cd704bd, 0xb98f64d6
.word 0x4358102d, 0x5b9c3d68, 0xe2a12369, 0x716050eb, 0xd8ceefbb, 0xea80223d, 0x1de89b25, 0x8d9ec58d
.word 0xe4a4089e, 0x76e38c30, 0xd09b1bff, 0x29238ee6, 0xc9f7f73f, 0x7b3a31ea, 0xd15f0738, 0xa132eccf
.word 0x7bdc6f8a, 0x1213b066, 0x0a4d4787, 0xb9201b58, 0x225092e8, 0x8708e4e8, 0x68312afc, 0x4bc7c414
.word 0xb765a7e0, 0xe75e39ea, 0x29b2faa1, 0x496df4ca, 0xbaeff3a2, 0xf4861da4, 0x8ce97aca, 0x6cab5cf8
.word 0x19a30e44, 0x0e7fcedf, 0x8447edb7, 0xb506b7a3, 0x8c9ec42b, 0x4ad73159, 0xb4a8bedb, 0x7d084908
.word 0x831b9fe1, 0x40a83fec, 0x2d488a81, 0x5aa010a6, 0x92e82623, 0x561c5ec9, 0xf48a1538, 0xd1bd6ca5
.word 0xed267c11, 0x4d44c9fd, 0x9940c88f, 0xdc0543f2, 0x1725b800, 0xa8a2cde7, 0xe7389c1b, 0x4f97e365
.word 0xf6003b3a, 0xe4b6746e, 0xb3d9ac95, 0xaf6d7e11, 0xa35f5892, 0xfb9916c9, 0x0c05fe77, 0xe3da1f9b
.word 0x8b9ba5ba, 0x225ac1a0, 0x8ab3c8fd, 0xfca2aa60, 0x2d94cdad, 0x3170675f, 0x0f14569c, 0x9cd5e7ab
.word 0x5379569e, 0x147fbb2f, 0xd337ab23, 0xd83c9b79, 0x1efb9451, 0xd8a1c5d3, 0xf144b83f, 0x8ac84c2a
.word 0x0a211695, 0x9810c284, 0xbdf2a185, 0x8f3ddc80, 0x3490253f, 0xa02f6fe4, 0xb0d3649f, 0x10158d81
.zero 7168
mem_region_end:
