# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {Main Page}]
  set_property tooltip {Basic Customizations and information about core} ${Page_0}
  ipgui::add_static_text $IPINST -name "Information" -parent ${Page_0} -text {UART Receiver core with dynamicially configurable UART configurations.}
  ipgui::add_static_text $IPINST -name "Transmitter info" -parent ${Page_0} -text {Does not contain a transmitter.}
  #Adding Group
  set Basic_Configurations [ipgui::add_group $IPINST -name "Basic Configurations" -parent ${Page_0}]
  set_property tooltip {Basic Configurations} ${Basic_Configurations}
  set AXI_CLOCK_PERIOD [ipgui::add_param $IPINST -name "AXI_CLOCK_PERIOD" -parent ${Basic_Configurations}]
  set_property tooltip {This is important to have correct baud rate} ${AXI_CLOCK_PERIOD}
  ipgui::add_param $IPINST -name "BUFFER_SIZE" -parent ${Basic_Configurations} -widget comboBox
  set ERROR_BUFFER [ipgui::add_param $IPINST -name "ERROR_BUFFER" -parent ${Basic_Configurations} -widget comboBox]
  set_property tooltip {Include Error Buffers for each transmisson, read via Rx data} ${ERROR_BUFFER}

  #Adding Group
  set Default_UART_Configurations [ipgui::add_group $IPINST -name "Default UART Configurations" -parent ${Page_0}]
  set_property tooltip {Default UART Configurations} ${Default_UART_Configurations}
  ipgui::add_param $IPINST -name "DEFAULT_DATA_SIZE" -parent ${Default_UART_Configurations} -widget comboBox
  ipgui::add_param $IPINST -name "DEFAULT_STOP_BIT" -parent ${Default_UART_Configurations} -widget comboBox
  set DEFAULT_PARTY_EN [ipgui::add_param $IPINST -name "DEFAULT_PARTY_EN" -parent ${Default_UART_Configurations} -widget comboBox]
  set_property tooltip {Party enable/disable} ${DEFAULT_PARTY_EN}
  ipgui::add_param $IPINST -name "DEFAULT_PARTY" -parent ${Default_UART_Configurations} -widget comboBox
  ipgui::add_static_text $IPINST -name "About baud rate" -parent ${Default_UART_Configurations} -text {Defaut baud rate configurations can be edited from the last page}
  ipgui::add_static_text $IPINST -name "Reconfiguration" -parent ${Default_UART_Configurations} -text {After implementation, these can be reconfigured 
via configuration register,}


  #Adding Page
  set Register_Contents [ipgui::add_page $IPINST -name "Register Contents"]
  set_property tooltip {Mapping of register contents} ${Register_Contents}
  #Adding Group
  set Rx_Buffer_&_Counter [ipgui::add_group $IPINST -name "Rx Buffer & Counter" -parent ${Register_Contents}]
  set_property tooltip {Rx Buffer and counter for the number of elements in the buffer} ${Rx_Buffer_&_Counter}
  set OFFSET_RX_BUFF [ipgui::add_param $IPINST -name "OFFSET_RX_BUFF" -parent ${Rx_Buffer_&_Counter}]
  set_property tooltip {Offset of Rx Buffer} ${OFFSET_RX_BUFF}
  ipgui::add_static_text $IPINST -name "Error Buffers" -parent ${Rx_Buffer_&_Counter} -text {If error buffers included in design. They are read from this address.}
  ipgui::add_static_text $IPINST -name "Error buffer addresses" -parent ${Rx_Buffer_&_Counter} -text {~ Rx Buffer[8]: Frame error
~ Rx Buffer[9]: Parity error}
  ipgui::add_param $IPINST -name "OFFSET_RX_COUNT" -parent ${Rx_Buffer_&_Counter}

  #Adding Group
  set Configurations_Register [ipgui::add_group $IPINST -name "Configurations Register" -parent ${Register_Contents}]
  set_property tooltip {Configurations of the core} ${Configurations_Register}
  set OFFSET_CONFIG [ipgui::add_param $IPINST -name "OFFSET_CONFIG" -parent ${Configurations_Register}]
  set_property tooltip {Configurations of the core} ${OFFSET_CONFIG}
  ipgui::add_static_text $IPINST -name "Configuration Bits" -parent ${Configurations_Register} -text {bit[11]  : Software enable Error Buffer (only if included) 
bit[10]  : Clear Tx FIFO, self clearing
bit[9]    : Base clock, see next page
bit[8:6] : Divison ratio, see next page
bit[5:4] : Parity mode (00 space, 01 mark, 10 even, 11 odd)
bit[3]    : Parity enable
bit[2]    : Data Size (0 7 bits, 1 8 bits)
bit[1]    : Stop bit size (0 1 bit, 1 2 bits)
bit[0]    : Eneble interrupt}

  #Adding Group
  set Status_Register [ipgui::add_group $IPINST -name "Status Register" -parent ${Register_Contents}]
  set_property tooltip {Core status} ${Status_Register}
  set OFFSET_STATUS [ipgui::add_param $IPINST -name "OFFSET_STATUS" -parent ${Status_Register}]
  set_property tooltip {Core Status} ${OFFSET_STATUS}
  ipgui::add_static_text $IPINST -name "Status Bits" -parent ${Status_Register} -text {bit[5] : Error Buffer included
bit[4] : Overrun error/Data lost (Cleared after read)
bit[3] : Parity error (Cleared after read)
bit[2] : Frame error (Cleared after read)
bit[1] : Tx Buffer Full
bit[0] : Tx Buffer Empty
Remaining bits are reserved and contain no data }


  #Adding Page
  set UART_Baud_Rate_Configurations [ipgui::add_page $IPINST -name "UART Baud Rate Configurations"]
  set_property tooltip {Registers related to UART configurations} ${UART_Baud_Rate_Configurations}
  set DEFAULT_BASECLK [ipgui::add_param $IPINST -name "DEFAULT_BASECLK" -parent ${UART_Baud_Rate_Configurations} -widget comboBox]
  set_property tooltip {460,8 kHz (1) or 76,8 kHz (0)} ${DEFAULT_BASECLK}
  set DEFAULT_DIVRATIO [ipgui::add_param $IPINST -name "DEFAULT_DIVRATIO" -parent ${UART_Baud_Rate_Configurations}]
  set_property tooltip {Base clock will be divided by this power of 2} ${DEFAULT_DIVRATIO}
  #Adding Group
  set Some_example_configurations [ipgui::add_group $IPINST -name "Some example configurations" -parent ${UART_Baud_Rate_Configurations}]
  set_property tooltip {Examples for some of the Common Baud rates} ${Some_example_configurations}
  ipgui::add_static_text $IPINST -name "Example Baud rates" -parent ${Some_example_configurations} -text {115.2k : 460,8 kHz and 2
9600    : 76,92 kHz and 3
}



}

proc update_PARAM_VALUE.AXI_CLOCK_PERIOD { PARAM_VALUE.AXI_CLOCK_PERIOD } {
	# Procedure called to update AXI_CLOCK_PERIOD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_CLOCK_PERIOD { PARAM_VALUE.AXI_CLOCK_PERIOD } {
	# Procedure called to validate AXI_CLOCK_PERIOD
	return true
}

proc update_PARAM_VALUE.BUFFER_SIZE { PARAM_VALUE.BUFFER_SIZE } {
	# Procedure called to update BUFFER_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BUFFER_SIZE { PARAM_VALUE.BUFFER_SIZE } {
	# Procedure called to validate BUFFER_SIZE
	return true
}

proc update_PARAM_VALUE.DEFAULT_BASECLK { PARAM_VALUE.DEFAULT_BASECLK } {
	# Procedure called to update DEFAULT_BASECLK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_BASECLK { PARAM_VALUE.DEFAULT_BASECLK } {
	# Procedure called to validate DEFAULT_BASECLK
	return true
}

proc update_PARAM_VALUE.DEFAULT_DATA_SIZE { PARAM_VALUE.DEFAULT_DATA_SIZE } {
	# Procedure called to update DEFAULT_DATA_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_DATA_SIZE { PARAM_VALUE.DEFAULT_DATA_SIZE } {
	# Procedure called to validate DEFAULT_DATA_SIZE
	return true
}

proc update_PARAM_VALUE.DEFAULT_DIVRATIO { PARAM_VALUE.DEFAULT_DIVRATIO } {
	# Procedure called to update DEFAULT_DIVRATIO when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_DIVRATIO { PARAM_VALUE.DEFAULT_DIVRATIO } {
	# Procedure called to validate DEFAULT_DIVRATIO
	return true
}

proc update_PARAM_VALUE.DEFAULT_PARTY { PARAM_VALUE.DEFAULT_PARTY } {
	# Procedure called to update DEFAULT_PARTY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_PARTY { PARAM_VALUE.DEFAULT_PARTY } {
	# Procedure called to validate DEFAULT_PARTY
	return true
}

proc update_PARAM_VALUE.DEFAULT_PARTY_EN { PARAM_VALUE.DEFAULT_PARTY_EN } {
	# Procedure called to update DEFAULT_PARTY_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_PARTY_EN { PARAM_VALUE.DEFAULT_PARTY_EN } {
	# Procedure called to validate DEFAULT_PARTY_EN
	return true
}

proc update_PARAM_VALUE.DEFAULT_STOP_BIT { PARAM_VALUE.DEFAULT_STOP_BIT } {
	# Procedure called to update DEFAULT_STOP_BIT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_STOP_BIT { PARAM_VALUE.DEFAULT_STOP_BIT } {
	# Procedure called to validate DEFAULT_STOP_BIT
	return true
}

proc update_PARAM_VALUE.ERROR_BUFFER { PARAM_VALUE.ERROR_BUFFER } {
	# Procedure called to update ERROR_BUFFER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ERROR_BUFFER { PARAM_VALUE.ERROR_BUFFER } {
	# Procedure called to validate ERROR_BUFFER
	return true
}

proc update_PARAM_VALUE.OFFSET_CONFIG { PARAM_VALUE.OFFSET_CONFIG } {
	# Procedure called to update OFFSET_CONFIG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OFFSET_CONFIG { PARAM_VALUE.OFFSET_CONFIG } {
	# Procedure called to validate OFFSET_CONFIG
	return true
}

proc update_PARAM_VALUE.OFFSET_RX_BUFF { PARAM_VALUE.OFFSET_RX_BUFF } {
	# Procedure called to update OFFSET_RX_BUFF when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OFFSET_RX_BUFF { PARAM_VALUE.OFFSET_RX_BUFF } {
	# Procedure called to validate OFFSET_RX_BUFF
	return true
}

proc update_PARAM_VALUE.OFFSET_RX_COUNT { PARAM_VALUE.OFFSET_RX_COUNT } {
	# Procedure called to update OFFSET_RX_COUNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OFFSET_RX_COUNT { PARAM_VALUE.OFFSET_RX_COUNT } {
	# Procedure called to validate OFFSET_RX_COUNT
	return true
}

proc update_PARAM_VALUE.OFFSET_STATUS { PARAM_VALUE.OFFSET_STATUS } {
	# Procedure called to update OFFSET_STATUS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OFFSET_STATUS { PARAM_VALUE.OFFSET_STATUS } {
	# Procedure called to validate OFFSET_STATUS
	return true
}

proc update_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to update C_S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_BASEADDR { PARAM_VALUE.C_S_AXI_BASEADDR } {
	# Procedure called to update C_S_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_BASEADDR { PARAM_VALUE.C_S_AXI_BASEADDR } {
	# Procedure called to validate C_S_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S_AXI_HIGHADDR { PARAM_VALUE.C_S_AXI_HIGHADDR } {
	# Procedure called to update C_S_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_HIGHADDR { PARAM_VALUE.C_S_AXI_HIGHADDR } {
	# Procedure called to validate C_S_AXI_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.BUFFER_SIZE { MODELPARAM_VALUE.BUFFER_SIZE PARAM_VALUE.BUFFER_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BUFFER_SIZE}] ${MODELPARAM_VALUE.BUFFER_SIZE}
}

proc update_MODELPARAM_VALUE.AXI_CLOCK_PERIOD { MODELPARAM_VALUE.AXI_CLOCK_PERIOD PARAM_VALUE.AXI_CLOCK_PERIOD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_CLOCK_PERIOD}] ${MODELPARAM_VALUE.AXI_CLOCK_PERIOD}
}

proc update_MODELPARAM_VALUE.DEFAULT_DATA_SIZE { MODELPARAM_VALUE.DEFAULT_DATA_SIZE PARAM_VALUE.DEFAULT_DATA_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_DATA_SIZE}] ${MODELPARAM_VALUE.DEFAULT_DATA_SIZE}
}

proc update_MODELPARAM_VALUE.DEFAULT_STOP_BIT { MODELPARAM_VALUE.DEFAULT_STOP_BIT PARAM_VALUE.DEFAULT_STOP_BIT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_STOP_BIT}] ${MODELPARAM_VALUE.DEFAULT_STOP_BIT}
}

proc update_MODELPARAM_VALUE.DEFAULT_PARTY_EN { MODELPARAM_VALUE.DEFAULT_PARTY_EN PARAM_VALUE.DEFAULT_PARTY_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_PARTY_EN}] ${MODELPARAM_VALUE.DEFAULT_PARTY_EN}
}

proc update_MODELPARAM_VALUE.DEFAULT_PARTY { MODELPARAM_VALUE.DEFAULT_PARTY PARAM_VALUE.DEFAULT_PARTY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_PARTY}] ${MODELPARAM_VALUE.DEFAULT_PARTY}
}

proc update_MODELPARAM_VALUE.DEFAULT_BASECLK { MODELPARAM_VALUE.DEFAULT_BASECLK PARAM_VALUE.DEFAULT_BASECLK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_BASECLK}] ${MODELPARAM_VALUE.DEFAULT_BASECLK}
}

proc update_MODELPARAM_VALUE.DEFAULT_DIVRATIO { MODELPARAM_VALUE.DEFAULT_DIVRATIO PARAM_VALUE.DEFAULT_DIVRATIO } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_DIVRATIO}] ${MODELPARAM_VALUE.DEFAULT_DIVRATIO}
}

proc update_MODELPARAM_VALUE.OFFSET_RX_BUFF { MODELPARAM_VALUE.OFFSET_RX_BUFF PARAM_VALUE.OFFSET_RX_BUFF } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OFFSET_RX_BUFF}] ${MODELPARAM_VALUE.OFFSET_RX_BUFF}
}

proc update_MODELPARAM_VALUE.OFFSET_CONFIG { MODELPARAM_VALUE.OFFSET_CONFIG PARAM_VALUE.OFFSET_CONFIG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OFFSET_CONFIG}] ${MODELPARAM_VALUE.OFFSET_CONFIG}
}

proc update_MODELPARAM_VALUE.OFFSET_STATUS { MODELPARAM_VALUE.OFFSET_STATUS PARAM_VALUE.OFFSET_STATUS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OFFSET_STATUS}] ${MODELPARAM_VALUE.OFFSET_STATUS}
}

proc update_MODELPARAM_VALUE.OFFSET_RX_COUNT { MODELPARAM_VALUE.OFFSET_RX_COUNT PARAM_VALUE.OFFSET_RX_COUNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OFFSET_RX_COUNT}] ${MODELPARAM_VALUE.OFFSET_RX_COUNT}
}

proc update_MODELPARAM_VALUE.ERROR_BUFFER { MODELPARAM_VALUE.ERROR_BUFFER PARAM_VALUE.ERROR_BUFFER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ERROR_BUFFER}] ${MODELPARAM_VALUE.ERROR_BUFFER}
}

