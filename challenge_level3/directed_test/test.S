# See LICENSE for license details.

#*****************************************************************************
# add.S
#-----------------------------------------------------------------------------
#
# Test add instruction.
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32M
RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Arithmetic tests
  #-------------------------------------------------------------

  # R-type instructions
  TEST_RR_OP( 2,  add, 0x0E05A279, 0x5ABFABA, 0x0859A7BF );
  TEST_RR_OP( 3,  and, 0x0009A2BA, 0x5ABFABA, 0x0859A7BF );
  TEST_RR_OP( 4,  or, 0x0DFBFFBF, 0x5ABFABA, 0x0859A7BF );
  TEST_RR_OP( 5,  sll, 0x00002222, 0x00001111, 0x00000001 );
  TEST_RR_OP( 6,  slt, 0x00000001, 0xcfffffff, 0x00000001 );
  TEST_RR_OP( 7,  sltu, 0x00000001, 0x00000001, 0xcfffffff );
  TEST_RR_OP( 8,  sra, 0xc0000000, 0x80000001, 0x00000001 );
  TEST_RR_OP( 9,  srl, 0x00001111, 0x00002222, 0x00000001 );
  TEST_RR_OP( 10,  sub, 0x2ADAD05, 0x0859A7BF, 0x5ABFABA );
  TEST_RR_OP( 11,  xor, 0xDF25D05, 0x5ABFABA, 0x0859A7BF );
  
  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
