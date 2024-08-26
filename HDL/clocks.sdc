create_clock -name clk_clk -period 10.000 [get_ports {clk_clk}]

create_clock -name normal_clock -period 10.000 [get_nets {pll|sd1|wire_pll7_clk[0]}]
create_clock -name speed_clock -period 5.000 [get_nets {pll|sd1|wire_pll7_clk[1]}]