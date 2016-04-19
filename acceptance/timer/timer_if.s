; This file is part of Mooneye GB.
; Copyright (C) 2014-2016 Joonas Javanainen <joonas.javanainen@gmail.com>
;
; Mooneye GB is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; Mooneye GB is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with Mooneye GB.  If not, see <http://www.gnu.org/licenses/>.

; This tests checks when the timer flag is set in the IF register and
; when the irq is actually taken.

; Verified results:
;   pass: MGB, CGB, AGS
;   fail: ?
;   not tested: DMG, SGB, SGB2, AGB

.incdir "../../common"
.include "common.s"

test:
  di
  xor a
  ld b,$fe
  ldh (<IE), a
  ldh (<IF), a
  ldh (<DIV), a
  ld a, b
  ldh (<TIMA), a
  ldh (<TMA),a
  ld a, %00000111 ; Start a 256 cycle times
  ldh (<TAC), a
test_round1:
  ld a,b
  ldh (<DIV),a
  ldh (<TIMA), a
  ldh (<DIV),a
  nops 64
  nops 61
  ldh a,(<IF)
  ld (round1),a

test_round2:
  xor a
  ldh (<IF),a
  ld a,b
  ldh (<TIMA), a
  ldh (<DIV),a
  ldh (<TIMA), a
  ldh (<DIV),a
  nops 64
  nops 62
  ldh a,(<IF)
  ld (round2),a

test_round3:
  xor a
  ldh (<IF),a
  ld a,b
  ldh (<TIMA), a
  ldh (<DIV),a
  ldh (<TIMA), a
  ldh (<DIV),a
  call wait_timer_irq
  di
  nops 45
  ld a,(TIMA)
  ld (round3),a

test_round4:
  xor a
  ldh (<IF),a
  ld a,b
  ldh (<TIMA), a
  ldh (<DIV),a
  ldh (<TIMA), a
  ldh (<DIV),a
  call wait_timer_irq
  di
  nops 46
  ld a,(TIMA)
  ld (round4),a

test_round5:
  xor a
  ldh (<IF),a
  ld a,b
  ldh (<TIMA), a
  ldh (<DIV),a
  ldh (<TIMA), a
  ldh (<DIV),a
  call wait_timer_irq_halt
  di
  nops 44
  ld a,(TIMA)
  ld (round5),a

test_round6:
  xor a
  ldh (<IF),a
  ld a,b
  ldh (<TIMA), a
  ldh (<DIV),a
  ldh (<TIMA), a
  ldh (<DIV),a
  call wait_timer_irq_halt
  di
  nops 45
  ld a,(TIMA)
  ld (round6),a

  ld a,(round1)
  ld d,a
  ld a,(round2)
  ld e,a
  ld a,(round3)
  ld h,a
  ld a,(round4)
  ld l,a
  ld a,(round5)
  ld b,a
  ld a,(round6)
  ld c,a

  save_results
  assert_b $fe
  assert_c $ff
  assert_d $e0
  assert_e $e4
  assert_h $fe
  assert_l $ff
  jp process_results

wait_timer_irq:
  ld a,INTR_TIMER
  ldh (<IE),a
  xor a
  ldh (<IF),a
  ei
  nops 1000
  test_failure_string "TIMER_IRQ"

wait_timer_irq_halt:
  ld a,INTR_TIMER
  ldh (<IE),a
  xor a
  ldh (<IF),a
  ei
  nop
  halt
  nop
  test_failure_string "TIMER_IRQ"

.org INTR_VEC_TIMER
  add sp,+2
  ret

.ramsection "Test-State" slot 2
  round1 db
  round2 db
  round3 db
  round4 db
  round5 db
  round6 db
  round7 db
  round8 db
.ends

