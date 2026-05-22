##################################################################
# Board PID # Board Name       # PRODUCT # Note
##################################################################
# TL_C5-V4  # TP-LINK Archer C5 V4  # MT7620  #
##################################################################

CFLAGS += -DBOARD_ARCHER_C5 -DVENDOR_TPLINK
BOARD_NUM_USB_PORTS=0

### TP-LINK firmware description ###
TPLINK_HWID=0x04DA857C
TPLINK_HWREV=0x0C000600
TPLINK_HWREVADD=0x04000000
TPLINK_FLASHLAYOUT=8Mmtk
TPLINK_HVERSION=3
