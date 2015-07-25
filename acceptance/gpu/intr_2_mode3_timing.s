; Tests how long does it take to get from STAT=mode2 interrupt to mode3
; No sprites, scroll, or window

.incdir "../../common"
.include "common.s"

.macro clear_interrupts
  xor a
  ld_ff_a IF
.endm

.macro wait_mode ARGS mode
- ld_a_ff STAT
  and $03
  cp mode
  jr nz, -
.endm

  di
  wait_vblank
  ld hl, STAT
  ld a, INTR_STAT
  ld_ff_a IE

.macro test_iter ARGS delay
  call setup_and_wait_mode2
  nops delay
  ld b, $00
- inc b
  ld a, (hl)
  and $03
  cp $03
  jr nz, -
.endm

  test_iter 3
  ld d, b
  test_iter 2
  ld e, b
  save_results
  assert_d $01
  assert_e $02
  jp process_results

setup_and_wait_mode2:
  wait_ly $42
  wait_mode $00
  wait_mode $03
  ld a, %00100000
  ld_ff_a STAT
  clear_interrupts
  ei

  halt
  nop
  jp fail_halt

fail_halt:
  test_failure_string "FAIL: HALT"

.org INTR_VEC_STAT
  add sp,+2
  ret
