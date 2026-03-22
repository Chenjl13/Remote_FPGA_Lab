

COMPONENT bitstream_ram
  PORT (
    wr_data : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    wr_addr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    wr_rst : IN STD_LOGIC;
    rd_addr : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    rd_data : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
    rd_clk : IN STD_LOGIC;
    rd_oce : IN STD_LOGIC;
    rd_rst : IN STD_LOGIC
  );
END COMPONENT;


the_instance_name : bitstream_ram
  PORT MAP (
    wr_data => wr_data,
    wr_addr => wr_addr,
    wr_en => wr_en,
    wr_clk => wr_clk,
    wr_rst => wr_rst,
    rd_addr => rd_addr,
    rd_data => rd_data,
    rd_clk => rd_clk,
    rd_oce => rd_oce,
    rd_rst => rd_rst
  );
