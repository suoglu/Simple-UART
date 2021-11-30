# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {Main Page}]
  set_property tooltip {Main configurations and information} ${Page_0}
  #Adding Group
  set Basic_Information [ipgui::add_group $IPINST -name "Basic Information" -parent ${Page_0} -display_name {Information}]
  set_property tooltip {Basic Information} ${Basic_Information}
  ipgui::add_static_text $IPINST -name "Information Text" -parent ${Basic_Information} -text {UART core with dynamicially configurable UART configurations.}

  #Adding Group
  set Basic_Configurations [ipgui::add_group $IPINST -name "Basic Configurations" -parent ${Page_0}]
  set_property tooltip {Basic Configurations} ${Basic_Configurations}
  set AXI_CLOCK_PERIOD [ipgui::add_param $IPINST -name "AXI_CLOCK_PERIOD" -parent ${Basic_Configurations}]
  set_property tooltip {This is important to have correct baud rate} ${AXI_CLOCK_PERIOD}
  ipgui::add_param $IPINST -name "Tx_BUFFER_SIZE" -parent ${Basic_Configurations} -widget comboBox
  ipgui::add_param $IPINST -name "Rx_BUFFER_SIZE" -parent ${Basic_Configurations} -widget comboBox
  set ERROR_BUFFER [ipgui::add_param $IPINST -name "ERROR_BUFFER" -parent ${Basic_Configurations} -widget comboBox]
  set_property tooltip {Error Buffer for receiver} ${ERROR_BUFFER}


  #Adding Page
  set Register_Map [ipgui::add_page $IPINST -name "Register Map"]
  set_property tooltip {Register offsets and contents} ${Register_Map}
  #Adding Group
  set Transmitter [ipgui::add_group $IPINST -name "Transmitter" -parent ${Register_Map}]
  set_property tooltip {Registers related to transmitter fifo} ${Transmitter}
  set OFFSET_TX_BUFF [ipgui::add_param $IPINST -name "OFFSET_TX_BUFF" -parent ${Transmitter}]
  set_property tooltip {Offset of Transmitter Buffer} ${OFFSET_TX_BUFF}
  set OFFSET_TX_COUNT [ipgui::add_param $IPINST -name "OFFSET_TX_COUNT" -parent ${Transmitter}]
  set_property tooltip {Offset of Transmitter Buffer Element Counter} ${OFFSET_TX_COUNT}

  #Adding Group
  set Receiver [ipgui::add_group $IPINST -name "Receiver" -parent ${Register_Map}]
  set_property tooltip {Registers related to receiver fifo} ${Receiver}
  set OFFSET_RX_BUFF [ipgui::add_param $IPINST -name "OFFSET_RX_BUFF" -parent ${Receiver}]
  set_property tooltip {Offset of Receiver Buffer} ${OFFSET_RX_BUFF}
  ipgui::add_static_text $IPINST -name "Error buffers" -parent ${Receiver} -text {If error buffers included in the core. They are read from this address.}
  ipgui::add_static_text $IPINST -name "Error buffer addresses" -parent ${Receiver} -text {~ Receiver Buffer[8]: Frame error
~ Receiver Buffer[9]: Parity error}
  set OFFSET_RX_COUNT [ipgui::add_param $IPINST -name "OFFSET_RX_COUNT" -parent ${Receiver}]
  set_property tooltip {Offset of Receiver Buffer Element Counter} ${OFFSET_RX_COUNT}


  #Adding Page
  set Register_Map_(Config) [ipgui::add_page $IPINST -name "Register Map (Config)"]
  set_property tooltip {Register offsets and contents} ${Register_Map_(Config)}
  #Adding Group
  set Configuration_Register [ipgui::add_group $IPINST -name "Configuration Register" -parent ${Register_Map_(Config)}]
  set_property tooltip {Configuration Register} ${Configuration_Register}
  ipgui::add_static_text $IPINST -name "Configuration Bits" -parent ${Configuration_Register} -text {bit[15]  : Enable Transmitter Interrupt
bit[14]  : Enable Receiver Interrupt
bit[13]  : Software enable Error Buffer (only if included) 
bit[12]  : Blocking Transmitter
bit[11]  : Clear Receiver FIFO, self clearing
bit[10]  : Clear Transmitter FIFO, self clearing
bit[9]    : Base clock, see next page
bit[8:6] : Divison ratio, see next page
bit[5:4] : Parity mode (00 space, 01 mark, 10 even, 11 odd)
bit[3]    : Parity enable
bit[2]    : Data Size (0 7 bits, 1 8 bits)
bit[1]    : Stop bit size (0 1 bit, 1 2 bits)
bit[0]    : Eneble interrupts}
  set OFFSET_CONFIG [ipgui::add_param $IPINST -name "OFFSET_CONFIG" -parent ${Configuration_Register}]
  set_property tooltip {Offset for Configuration Register} ${OFFSET_CONFIG}
  ipgui::add_static_text $IPINST -name "Interrupts" -parent ${Configuration_Register} -text {To enable interrupts, both general interrupt register (bit[0]) and individual
 interrupt registers (bit[14] and/or bit[15]) should be enabled. }


  #Adding Page
  set Register_Map_(Stat) [ipgui::add_page $IPINST -name "Register Map (Stat)"]
  set_property tooltip {Register offsets and contents} ${Register_Map_(Stat)}
  #Adding Group
  set Status_Register [ipgui::add_group $IPINST -name "Status Register" -parent ${Register_Map_(Stat)}]
  set_property tooltip {Status Register} ${Status_Register}
  ipgui::add_static_text $IPINST -name "Status Bits" -parent ${Status_Register} -text {bit[7] : Error Buffer included
bit[6] : Overrun error/Data lost (Cleared after read)
bit[5] : Parity error (Cleared after read)
bit[4] : Frame error (Cleared after read)
bit[3] : Transmitter Buffer Full
bit[2] : Receiver Buffer Full
bit[1] : Transmitter Buffer Empty
bit[0] : Receiver Buffer Empty
Remaining bits are reserved and contain no data }
  set OFFSET_STATUS [ipgui::add_param $IPINST -name "OFFSET_STATUS" -parent ${Status_Register}]
  set_property tooltip {Offset of Status Register} ${OFFSET_STATUS}


  #Adding Page
  set Default_UART_Configurations [ipgui::add_page $IPINST -name "Default UART Configurations"]
  set_property tooltip {Default UART Configurations} ${Default_UART_Configurations}
  ipgui::add_static_text $IPINST -name "Reconfiguration" -parent ${Default_UART_Configurations} -text {After implementation, these can be reconfigured 
via configuration register,}
  #Adding Group
  set Package_Configurations [ipgui::add_group $IPINST -name "Package Configurations" -parent ${Default_UART_Configurations}]
  set_property tooltip {Package Configurations} ${Package_Configurations}
  ipgui::add_param $IPINST -name "DEFAULT_DATA_SIZE" -parent ${Package_Configurations} -widget comboBox
  set DEFAULT_STOP_BIT [ipgui::add_param $IPINST -name "DEFAULT_STOP_BIT" -parent ${Package_Configurations} -widget comboBox]
  set_property tooltip {Default Stop Bit Size} ${DEFAULT_STOP_BIT}
  set DEFAULT_PARTY_EN [ipgui::add_param $IPINST -name "DEFAULT_PARTY_EN" -parent ${Package_Configurations} -widget comboBox]
  set_property tooltip {Default Party} ${DEFAULT_PARTY_EN}
  set DEFAULT_PARTY [ipgui::add_param $IPINST -name "DEFAULT_PARTY" -parent ${Package_Configurations} -widget comboBox]
  set_property tooltip {Default Parity Mode} ${DEFAULT_PARTY}

  #Adding Group
  set Baud_rate_configutations [ipgui::add_group $IPINST -name "Baud rate configutations" -parent ${Default_UART_Configurations}]
  set_property tooltip {Baud rate configutations} ${Baud_rate_configutations}
  set DEFAULT_BASECLK [ipgui::add_param $IPINST -name "DEFAULT_BASECLK" -parent ${Baud_rate_configutations} -widget comboBox]
  set_property tooltip {460,8 kHz (1) or 76,8 kHz (0)} ${DEFAULT_BASECLK}
  set DEFAULT_DIVRATIO [ipgui::add_param $IPINST -name "DEFAULT_DIVRATIO" -parent ${Baud_rate_configutations}]
  set_property tooltip {Base clock will be divided by this power of 2} ${DEFAULT_DIVRATIO}
  #Adding Group
  set Example_Baud_Rates [ipgui::add_group $IPINST -name "Example Baud Rates" -parent ${Baud_rate_configutations} -display_name {Some Example Configurations}]
  ipgui::add_static_text $IPINST -name "Example baud rates" -parent ${Example_Baud_Rates} -text {115.2k : 460,8 kHz and 2
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

proc update_PARAM_VALUE.OFFSET_TX_BUFF { PARAM_VALUE.OFFSET_TX_BUFF } {
	# Procedure called to update OFFSET_TX_BUFF when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OFFSET_TX_BUFF { PARAM_VALUE.OFFSET_TX_BUFF } {
	# Procedure called to validate OFFSET_TX_BUFF
	return true
}

proc update_PARAM_VALUE.OFFSET_TX_COUNT { PARAM_VALUE.OFFSET_TX_COUNT } {
	# Procedure called to update OFFSET_TX_COUNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OFFSET_TX_COUNT { PARAM_VALUE.OFFSET_TX_COUNT } {
	# Procedure called to validate OFFSET_TX_COUNT
	return true
}

proc update_PARAM_VALUE.Rx_BUFFER_SIZE { PARAM_VALUE.Rx_BUFFER_SIZE } {
	# Procedure called to update Rx_BUFFER_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Rx_BUFFER_SIZE { PARAM_VALUE.Rx_BUFFER_SIZE } {
	# Procedure called to validate Rx_BUFFER_SIZE
	return true
}

proc update_PARAM_VALUE.Tx_BUFFER_SIZE { PARAM_VALUE.Tx_BUFFER_SIZE } {
	# Procedure called to update Tx_BUFFER_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Tx_BUFFER_SIZE { PARAM_VALUE.Tx_BUFFER_SIZE } {
	# Procedure called to validate Tx_BUFFER_SIZE
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

proc update_MODELPARAM_VALUE.Tx_BUFFER_SIZE { MODELPARAM_VALUE.Tx_BUFFER_SIZE PARAM_VALUE.Tx_BUFFER_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Tx_BUFFER_SIZE}] ${MODELPARAM_VALUE.Tx_BUFFER_SIZE}
}

proc update_MODELPARAM_VALUE.Rx_BUFFER_SIZE { MODELPARAM_VALUE.Rx_BUFFER_SIZE PARAM_VALUE.Rx_BUFFER_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Rx_BUFFER_SIZE}] ${MODELPARAM_VALUE.Rx_BUFFER_SIZE}
}

proc update_MODELPARAM_VALUE.ERROR_BUFFER { MODELPARAM_VALUE.ERROR_BUFFER PARAM_VALUE.ERROR_BUFFER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ERROR_BUFFER}] ${MODELPARAM_VALUE.ERROR_BUFFER}
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

proc update_MODELPARAM_VALUE.OFFSET_TX_BUFF { MODELPARAM_VALUE.OFFSET_TX_BUFF PARAM_VALUE.OFFSET_TX_BUFF } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OFFSET_TX_BUFF}] ${MODELPARAM_VALUE.OFFSET_TX_BUFF}
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

proc update_MODELPARAM_VALUE.OFFSET_TX_COUNT { MODELPARAM_VALUE.OFFSET_TX_COUNT PARAM_VALUE.OFFSET_TX_COUNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OFFSET_TX_COUNT}] ${MODELPARAM_VALUE.OFFSET_TX_COUNT}
}

