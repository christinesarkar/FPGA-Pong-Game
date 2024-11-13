set_global_assignment -entity "my_altpll" -library "lib_my_altpll" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "my_altpll" -library "lib_my_altpll" -name IP_TOOL_VERSION "22.1"
set_global_assignment -entity "my_altpll" -library "lib_my_altpll" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_my_altpll" -name SPD_FILE [file join $::quartus(sip_path) "my_altpll.spd"]

set_global_assignment -library "lib_my_altpll" -name MISC_FILE [file join $::quartus(sip_path) "my_altpll_sim/my_altpll.vho"]
