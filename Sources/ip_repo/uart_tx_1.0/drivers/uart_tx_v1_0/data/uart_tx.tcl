

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "uart_tx" "NUM_INSTANCES" "DEVICE_ID"  "C_S_AXI_BASEADDR" "C_S_AXI_HIGHADDR" "BUFFER_SIZE" "OFFSET_TX_BUFF" "OFFSET_CONFIG" "OFFSET_STATUS" "OFFSET_TX_COUNT"
}
