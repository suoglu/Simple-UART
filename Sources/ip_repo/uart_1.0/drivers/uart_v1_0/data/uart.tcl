

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "uart" "NUM_INSTANCES" "DEVICE_ID"  "C_S_AXI_BASEADDR" "C_S_AXI_HIGHADDR" "Tx_BUFFER_SIZE" "Rx_BUFFER_SIZE" "ERROR_BUFFER" "OFFSET_RX_BUFF" "OFFSET_TX_BUFF" "OFFSET_CONFIG" "OFFSET_STATUS" "OFFSET_RX_COUNT" "OFFSET_TX_COUNT"
}
