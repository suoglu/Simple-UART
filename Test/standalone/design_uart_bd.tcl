
################################################################
# This is a generated script based on design: design_uart_bd
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2020.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_uart_bd_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# board, uart_clk_gen, uart_clk_gen, uart_rx, uart_tx

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a35tcpg236-1
   set_property BOARD_PART digilentinc.com:basys3:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_uart_bd

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
board\
uart_clk_gen\
uart_clk_gen\
uart_rx\
uart_tx\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set an [ create_bd_port -dir O -from 3 -to 0 an ]
  set baseClock_freq [ create_bd_port -dir I baseClock_freq ]
  set btnD [ create_bd_port -dir I btnD ]
  set btnR [ create_bd_port -dir I btnR ]
  set btnU [ create_bd_port -dir I btnU ]
  set clk [ create_bd_port -dir I -type clk -freq_hz 100000000 clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_RESET {rst} \
 ] $clk
  set divRatio [ create_bd_port -dir I -from 2 -to 0 divRatio ]
  set newData [ create_bd_port -dir O newData ]
  set parity_en [ create_bd_port -dir I parity_en ]
  set parity_mode [ create_bd_port -dir I -from 1 -to 0 parity_mode ]
  set ready_rx [ create_bd_port -dir O ready_rx ]
  set ready_tx [ create_bd_port -dir O ready_tx ]
  set rst [ create_bd_port -dir I -type rst rst ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $rst
  set rx [ create_bd_port -dir I rx ]
  set seg [ create_bd_port -dir O -from 6 -to 0 seg ]
  set sw [ create_bd_port -dir I -from 7 -to 0 sw ]
  set tx [ create_bd_port -dir O tx ]
  set valid [ create_bd_port -dir O valid ]

  # Create instance: board_0, and set properties
  set block_name board
  set block_cell_name board_0
  if { [catch {set board_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $board_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: uart_clk_gen_0, and set properties
  set block_name uart_clk_gen
  set block_cell_name uart_clk_gen_0
  if { [catch {set uart_clk_gen_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $uart_clk_gen_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: uart_clk_gen_rx, and set properties
  set block_name uart_clk_gen
  set block_cell_name uart_clk_gen_rx
  if { [catch {set uart_clk_gen_rx [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $uart_clk_gen_rx eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: uart_rx_0, and set properties
  set block_name uart_rx
  set block_cell_name uart_rx_0
  if { [catch {set uart_rx_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $uart_rx_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: uart_tx_0, and set properties
  set block_name uart_tx
  set block_cell_name uart_tx_0
  if { [catch {set uart_tx_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $uart_tx_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create port connections
  connect_bd_net -net baseClock_freq_1 [get_bd_ports baseClock_freq] [get_bd_pins uart_clk_gen_0/baseClock_freq] [get_bd_pins uart_clk_gen_rx/baseClock_freq]
  connect_bd_net -net board_0_an [get_bd_ports an] [get_bd_pins board_0/an]
  connect_bd_net -net board_0_data_i [get_bd_pins board_0/data_i] [get_bd_pins uart_tx_0/data]
  connect_bd_net -net board_0_data_size [get_bd_pins board_0/data_size] [get_bd_pins uart_rx_0/data_size] [get_bd_pins uart_tx_0/data_size]
  connect_bd_net -net board_0_seg [get_bd_ports seg] [get_bd_pins board_0/seg]
  connect_bd_net -net board_0_send [get_bd_pins board_0/send] [get_bd_pins uart_tx_0/send]
  connect_bd_net -net board_0_stop_bit_size [get_bd_pins board_0/stop_bit_size] [get_bd_pins uart_tx_0/stop_bit_size]
  connect_bd_net -net btnD_1 [get_bd_ports btnD] [get_bd_pins board_0/btnD]
  connect_bd_net -net btnR_1 [get_bd_ports btnR] [get_bd_pins board_0/btnR]
  connect_bd_net -net btnU_1 [get_bd_ports btnU] [get_bd_pins board_0/btnU]
  connect_bd_net -net clk_1 [get_bd_ports clk] [get_bd_pins board_0/clk] [get_bd_pins uart_clk_gen_0/clk] [get_bd_pins uart_clk_gen_rx/clk] [get_bd_pins uart_rx_0/clk] [get_bd_pins uart_tx_0/clk]
  connect_bd_net -net divRatio_1 [get_bd_ports divRatio] [get_bd_pins uart_clk_gen_0/divRatio] [get_bd_pins uart_clk_gen_rx/divRatio]
  connect_bd_net -net parity_en_1 [get_bd_ports parity_en] [get_bd_pins uart_rx_0/parity_en] [get_bd_pins uart_tx_0/parity_en]
  connect_bd_net -net parity_mode_1 [get_bd_ports parity_mode] [get_bd_pins uart_rx_0/parity_mode] [get_bd_pins uart_tx_0/parity_mode]
  connect_bd_net -net rst_1 [get_bd_ports rst] [get_bd_pins board_0/rst] [get_bd_pins uart_clk_gen_0/rst] [get_bd_pins uart_clk_gen_rx/rst] [get_bd_pins uart_rx_0/rst] [get_bd_pins uart_tx_0/rst]
  connect_bd_net -net rx_1 [get_bd_ports rx] [get_bd_pins uart_rx_0/rx]
  connect_bd_net -net sw_1 [get_bd_ports sw] [get_bd_pins board_0/sw]
  connect_bd_net -net uart_clk_gen_0_clk_uart [get_bd_pins uart_clk_gen_rx/clk_uart] [get_bd_pins uart_rx_0/clk_uart]
  connect_bd_net -net uart_clk_gen_0_clk_uart1 [get_bd_pins uart_clk_gen_0/clk_uart] [get_bd_pins uart_tx_0/clk_uart]
  connect_bd_net -net uart_rx_0_data [get_bd_pins board_0/data_o] [get_bd_pins uart_rx_0/data]
  connect_bd_net -net uart_rx_0_newData [get_bd_ports newData] [get_bd_pins uart_rx_0/newData]
  connect_bd_net -net uart_rx_0_ready [get_bd_ports ready_rx] [get_bd_pins uart_rx_0/ready]
  connect_bd_net -net uart_rx_0_uart_enable [get_bd_pins uart_clk_gen_rx/en] [get_bd_pins uart_rx_0/uart_enable]
  connect_bd_net -net uart_rx_0_valid [get_bd_ports valid] [get_bd_pins uart_rx_0/valid]
  connect_bd_net -net uart_tx_0_ready [get_bd_ports ready_tx] [get_bd_pins uart_tx_0/ready]
  connect_bd_net -net uart_tx_0_tx [get_bd_ports tx] [get_bd_pins uart_tx_0/tx]
  connect_bd_net -net uart_tx_0_uart_enable [get_bd_pins uart_clk_gen_0/en] [get_bd_pins uart_tx_0/uart_enable]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


