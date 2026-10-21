# SPDX-License-Identifier: BSD-2-Clause

flavor_dts_file-MP13 = stm32mp135d-oddesey-mx.dts
flavorlist-MP13 += $(flavor_dts_file-MP13)
flavorlist-no_cryp += $(flavor_dts_file-MP13)
CFG_DRAM_SIZE = 0x20000000
