 -- Quartus Prime VHDL Template
-- Single port RAM with single read/write address 

library ieee;
use ieee.std_logic_1164.all;

entity DE10_TOP is
    port 
    (
        -------- CLOCKS --------------------
        FPGA_CLK1_50		: in 	std_logic;
        FPGA_CLK2_50		: in 	std_logic;
        FPGA_CLK3_50		: in	std_logic;
        -------- HDMI --------------------
        HDMI_I2C_SCL		: inout	std_logic;
        HDMI_I2C_SDA		: inout	std_logic;
        HDMI_I2S	        : inout	std_logic;
        HDMI_LRCLK	        : inout	std_logic;
        HDMI_MCLK		: inout	std_logic;
        HDMI_SCLK		: inout	std_logic;
        HDMI_TX_CLK		: out	std_logic;
        HDMI_TX_D		: out	std_logic_vector(23 downto 0);
        HDMI_TX_DE		: out	std_logic;
        HDMI_TX_HS		: out	std_logic;
        HDMI_TX_INT		: in	std_logic;
        HDMI_TX_VS		: out	std_logic;
------- HDMI --------------------
        HPS_CONV_USB_N		: inout	std_logic;
        HPS_DDR3_ADDR		: out	std_logic_vector(14 downto 0);
        HPS_DDR3_BA		: out	std_logic_vector(2 downto 0);
        HPS_DDR3_CAS_N		: out	std_logic;
        HPS_DDR3_CK_N		: out	std_logic;
        HPS_DDR3_CK_P		: out	std_logic;
        HPS_DDR3_CKE		: out	std_logic;
        HPS_DDR3_CS_N		: out	std_logic;
        HPS_DDR3_DM		: out	std_logic_vector(3 downto 0);
        HPS_DDR3_DQ		: inout	std_logic_vector(31 downto 0);
        HPS_DDR3_DQS_N		: inout	std_logic_vector(3 downto 0);
        HPS_DDR3_DQS_P		: inout	std_logic_vector(3 downto 0);
        HPS_DDR3_ODT		: out	std_logic;
        HPS_DDR3_RAS_N		: out	std_logic;
        HPS_DDR3_RESET_N	: out	std_logic;
        HPS_DDR3_RZQ		: in	std_logic;
        HPS_DDR3_WE_N		: out	std_logic;
        HPS_ENET_GTX_CLK	: out	std_logic;
        HPS_ENET_INT_N		: inout	std_logic;
        HPS_ENET_MDC		: out	std_logic;
        HPS_ENET_MDIO		: inout	std_logic;
        HPS_ENET_RX_CLK	        : in	std_logic;
        HPS_ENET_RX_DATA	: in	std_logic_vector(3 downto 0);
        HPS_ENET_RX_DV		: in	std_logic;
        HPS_ENET_TX_DATA	: out	std_logic_vector(3 downto 0);
        HPS_ENET_TX_EN		: out	std_logic;
        HPS_GSENSOR_INT	        : inout	std_logic;
        HPS_I2C0_SCLK		: inout	std_logic;
        HPS_I2C0_SDAT		: inout	std_logic;
        HPS_I2C1_SCLK		: inout	std_logic;
        HPS_I2C1_SDAT		: inout	std_logic;
        HPS_KEY			: inout	std_logic;
        HPS_LED			: inout	std_logic;
        HPS_LTC_GPIO		: inout	std_logic;
        HPS_SD_CLK		: out	std_logic;
        HPS_SD_CMD		: inout	std_logic;
        HPS_SD_DATA		: inout	std_logic_vector(3 downto 0);
        HPS_SPIM_CLK		: out	std_logic;
        HPS_SPIM_MISO		: in	std_logic;
        HPS_SPIM_MOSI		: out	std_logic;
        HPS_SPIM_SS		: inout	std_logic;
        HPS_UART_RX		: in	std_logic;
        HPS_UART_TX		: out	std_logic;
        HPS_USB_CLKOUT		: in	std_logic;
        HPS_USB_DATA		: inout	std_logic_vector(7 downto 0);
        HPS_USB_DIR		: in	std_logic;
        HPS_USB_NXT		: in	std_logic;
        HPS_USB_STP		: out	std_logic;
        
       
        ------- INPUT/OUTPUT --------------------
        HEY			: in	std_logic_vector(1 downto 0);
        HED			: out	std_logic_vector(7 downto 0);
        HW			: in	std_logic_vector(3 downto 0);
               	
        ------- ADC 			--------------------
        HDC_CONVST		: out	std_logic;
        HDC_SCK			: out	std_logic;
        HDC_SDI			: out	std_logic;
        HDC_SDO			: in	std_logic
    );
end DE10_TOP;

architecture rtl of DE10_TOP is
--=======================================================
--  REG/WIRE declarations
--=======================================================
  signal  hps_fpga_reset_n : std_logic;
  signal  fpga_debounced_buttons : std_logic_vector(1 downto 0);
  signal  fpga_led_internal : std_logic_vector(6 downto 0);
  signal  hps_cold_reset : std_logic;
  signal  hps_warm_reset : std_logic;
  signal  hps_debug_reset : std_logic;
  signal  stm_hw_events : std_logic_vector(27 downto 0) := (others => '0');
  signal  fpga_clk_50 : std_logic;
  signal  clk_65 : std_logic;
  signal  clk_130 : std_logic;
  signal hdmi_out : std_logic_vector(31 downto 0) := (others => '0');
  signal led_level : std_logic := '0';
  signal counter : integer  := 0;

  component vga_pll is
    port (
	refclk   : in  std_logic := '0'; --  refclk.clk
	rst      : in  std_logic := '0'; --   reset.reset
        outclk_0 : out std_logic;        -- outclk0.clk
	outclk_1 : out std_logic;        -- outclk1.clk
        locked   : out std_logic         --  locked.export
    );
  end component vga_pll;
 

  component I2C_HDMI_Config is
    port (
        iCLK : in std_logic;
        iRST_N : in std_logic;
        I2C_SCLK : out std_logic;
        I2C_SDAT : inout std_logic;
        HDMI_TX_INT : in std_logic;     
        READY : out std_logic
    );
  end component I2C_HDMI_Config;
 
  component soc_system is
        port (
            alt_vip_itc_0_clocked_video_vid_clk       : in    std_logic                     := 'X';             -- vid_clk
            alt_vip_itc_0_clocked_video_vid_data      : out   std_logic_vector(31 downto 0);                    -- vid_data
            alt_vip_itc_0_clocked_video_underflow     : out   std_logic;                                        -- underflow
            alt_vip_itc_0_clocked_video_vid_datavalid : out   std_logic;                                        -- vid_datavalid
            alt_vip_itc_0_clocked_video_vid_v_sync    : out   std_logic;                                        -- vid_v_sync
            alt_vip_itc_0_clocked_video_vid_h_sync    : out   std_logic;                                        -- vid_h_sync
            alt_vip_itc_0_clocked_video_vid_f         : out   std_logic;                                        -- vid_f
            alt_vip_itc_0_clocked_video_vid_h         : out   std_logic;                                        -- vid_h
            alt_vip_itc_0_clocked_video_vid_v         : out   std_logic;                                        -- vid_v
            button_pio_external_connection_export     : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- export
            clk_clk                                   : in    std_logic                     := 'X';             -- clk
            clk_130_clk                               : in    std_logic                     := 'X';             -- clk
            dipsw_pio_external_connection_export      : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- export
            hps_0_f2h_cold_reset_req_reset_n          : in    std_logic                     := 'X';             -- reset_n
            hps_0_f2h_debug_reset_req_reset_n         : in    std_logic                     := 'X';             -- reset_n
            hps_0_f2h_stm_hw_events_stm_hwevents      : in    std_logic_vector(27 downto 0) := (others => 'X'); -- stm_hwevents
            hps_0_f2h_warm_reset_req_reset_n          : in    std_logic                     := 'X';             -- reset_n
            hps_0_h2f_reset_reset_n                   : out   std_logic;                                        -- reset_n
            hps_0_hps_io_hps_io_emac1_inst_TX_CLK     : out   std_logic;                                        -- hps_io_emac1_inst_TX_CLK
            hps_0_hps_io_hps_io_emac1_inst_TXD0       : out   std_logic;                                        -- hps_io_emac1_inst_TXD0
            hps_0_hps_io_hps_io_emac1_inst_TXD1       : out   std_logic;                                        -- hps_io_emac1_inst_TXD1
            hps_0_hps_io_hps_io_emac1_inst_TXD2       : out   std_logic;                                        -- hps_io_emac1_inst_TXD2
            hps_0_hps_io_hps_io_emac1_inst_TXD3       : out   std_logic;                                        -- hps_io_emac1_inst_TXD3
            hps_0_hps_io_hps_io_emac1_inst_RXD0       : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD0
            hps_0_hps_io_hps_io_emac1_inst_MDIO       : inout std_logic                     := 'X';             -- hps_io_emac1_inst_MDIO
            hps_0_hps_io_hps_io_emac1_inst_MDC        : out   std_logic;                                        -- hps_io_emac1_inst_MDC
            hps_0_hps_io_hps_io_emac1_inst_RX_CTL     : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CTL
            hps_0_hps_io_hps_io_emac1_inst_TX_CTL     : out   std_logic;                                        -- hps_io_emac1_inst_TX_CTL
            hps_0_hps_io_hps_io_emac1_inst_RX_CLK     : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RX_CLK
            hps_0_hps_io_hps_io_emac1_inst_RXD1       : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD1
            hps_0_hps_io_hps_io_emac1_inst_RXD2       : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD2
            hps_0_hps_io_hps_io_emac1_inst_RXD3       : in    std_logic                     := 'X';             -- hps_io_emac1_inst_RXD3
            hps_0_hps_io_hps_io_sdio_inst_CMD         : inout std_logic                     := 'X';             -- hps_io_sdio_inst_CMD
            hps_0_hps_io_hps_io_sdio_inst_D0          : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D0
            hps_0_hps_io_hps_io_sdio_inst_D1          : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D1
            hps_0_hps_io_hps_io_sdio_inst_CLK         : out   std_logic;                                        -- hps_io_sdio_inst_CLK
            hps_0_hps_io_hps_io_sdio_inst_D2          : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D2
            hps_0_hps_io_hps_io_sdio_inst_D3          : inout std_logic                     := 'X';             -- hps_io_sdio_inst_D3
            hps_0_hps_io_hps_io_usb1_inst_D0          : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D0
            hps_0_hps_io_hps_io_usb1_inst_D1          : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D1
            hps_0_hps_io_hps_io_usb1_inst_D2          : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D2
            hps_0_hps_io_hps_io_usb1_inst_D3          : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D3
            hps_0_hps_io_hps_io_usb1_inst_D4          : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D4
            hps_0_hps_io_hps_io_usb1_inst_D5          : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D5
            hps_0_hps_io_hps_io_usb1_inst_D6          : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D6
            hps_0_hps_io_hps_io_usb1_inst_D7          : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D7
            hps_0_hps_io_hps_io_usb1_inst_CLK         : in    std_logic                     := 'X';             -- hps_io_usb1_inst_CLK
            hps_0_hps_io_hps_io_usb1_inst_STP         : out   std_logic;                                        -- hps_io_usb1_inst_STP
            hps_0_hps_io_hps_io_usb1_inst_DIR         : in    std_logic                     := 'X';             -- hps_io_usb1_inst_DIR
            hps_0_hps_io_hps_io_usb1_inst_NXT         : in    std_logic                     := 'X';             -- hps_io_usb1_inst_NXT
            hps_0_hps_io_hps_io_spim1_inst_CLK        : out   std_logic;                                        -- hps_io_spim1_inst_CLK
            hps_0_hps_io_hps_io_spim1_inst_MOSI       : out   std_logic;                                        -- hps_io_spim1_inst_MOSI
            hps_0_hps_io_hps_io_spim1_inst_MISO       : in    std_logic                     := 'X';             -- hps_io_spim1_inst_MISO
            hps_0_hps_io_hps_io_spim1_inst_SS0        : out   std_logic;                                        -- hps_io_spim1_inst_SS0
            hps_0_hps_io_hps_io_uart0_inst_RX         : in    std_logic                     := 'X';             -- hps_io_uart0_inst_RX
            hps_0_hps_io_hps_io_uart0_inst_TX         : out   std_logic;                                        -- hps_io_uart0_inst_TX
            hps_0_hps_io_hps_io_i2c0_inst_SDA         : inout std_logic                     := 'X';             -- hps_io_i2c0_inst_SDA
            hps_0_hps_io_hps_io_i2c0_inst_SCL         : inout std_logic                     := 'X';             -- hps_io_i2c0_inst_SCL
            hps_0_hps_io_hps_io_i2c1_inst_SDA         : inout std_logic                     := 'X';             -- hps_io_i2c1_inst_SDA
            hps_0_hps_io_hps_io_i2c1_inst_SCL         : inout std_logic                     := 'X';             -- hps_io_i2c1_inst_SCL
            hps_0_hps_io_hps_io_gpio_inst_GPIO09      : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO09
            hps_0_hps_io_hps_io_gpio_inst_GPIO35      : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO35
            hps_0_hps_io_hps_io_gpio_inst_GPIO40      : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO40
            hps_0_hps_io_hps_io_gpio_inst_GPIO53      : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO53
            hps_0_hps_io_hps_io_gpio_inst_GPIO54      : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO54
            hps_0_hps_io_hps_io_gpio_inst_GPIO61      : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO61
            led_pio_external_connection_export        : out   std_logic_vector(6 downto 0);                     -- export
            memory_mem_a                              : out   std_logic_vector(14 downto 0);                    -- mem_a
            memory_mem_ba                             : out   std_logic_vector(2 downto 0);                     -- mem_ba
            memory_mem_ck                             : out   std_logic;                                        -- mem_ck
            memory_mem_ck_n                           : out   std_logic;                                        -- mem_ck_n
            memory_mem_cke                            : out   std_logic;                                        -- mem_cke
            memory_mem_cs_n                           : out   std_logic;                                        -- mem_cs_n
            memory_mem_ras_n                          : out   std_logic;                                        -- mem_ras_n
            memory_mem_cas_n                          : out   std_logic;                                        -- mem_cas_n
            memory_mem_we_n                           : out   std_logic;                                        -- mem_we_n
            memory_mem_reset_n                        : out   std_logic;                                        -- mem_reset_n
            memory_mem_dq                             : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
            memory_mem_dqs                            : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs
            memory_mem_dqs_n                          : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_n
            memory_mem_odt                            : out   std_logic;                                        -- mem_odt
            memory_mem_dm                             : out   std_logic_vector(3 downto 0);                     -- mem_dm
            memory_oct_rzqin                          : in    std_logic                     := 'X';             -- oct_rzqin
            reset_reset_n                             : in    std_logic                     := 'X'              -- reset_n
        );
  end component soc_system;



  component debounce is 

    port (
        clk : in std_logic; 	
        reset_n: in std_logic; 	
        data_in : in std_logic_vector(1 downto 0); 	
        data_out : out std_logic_vector(1 downto 0)
    ); 
  end component debounce;
	 

  component hps_reset0 is
    port (
	fpga_clk_50 : in std_logic; 	
	hps_fpga_reset_n : in std_logic;
	hps_cold_reset : out std_logic;
	hps_warm_reset : out std_logic;
	hps_debug_reset : out std_logic
    );
  end component hps_reset0;

begin
    LED(7 downto 1) <= fpga_led_internal;
    fpga_clk_50 <= FPGA_CLK1_50;
    stm_hw_events(12 downto 0) <= SW & fpga_led_internal & fpga_debounced_buttons;



    process(fpga_clk_50, hps_fpga_reset_n)
		
    begin
        if (hps_fpga_reset_n = '0') then
            led_level <= '1';
            counter <= 0;
            LED(0) <= '0';
        elsif (rising_edge(fpga_clk_50)) then
            if(counter = 14999999) then
                led_level <= not led_level;
                counter <= 0;
	    else
	        counter <= counter + 1;
            end if;
            LED(0) <= led_level;
        end if;
    end process;
	
	
    HDMI_TX_CLK <= clk_65;
    HDMI_TX_D <= hdmi_out(23 downto 0);
	
    u0 : component soc_system
    port map (
    ---- HDMI
        alt_vip_itc_0_clocked_video_vid_clk       => clk_65,       --    alt_vip_itc_0_clocked_video.vid_clk
        alt_vip_itc_0_clocked_video_vid_data      => hdmi_out,     --                               .vid_data
        alt_vip_itc_0_clocked_video_underflow     => open,         --                               .underflow
        alt_vip_itc_0_clocked_video_vid_datavalid => HDMI_TX_DE,   --                               .vid_datavalid
        alt_vip_itc_0_clocked_video_vid_v_sync    => HDMI_TX_VS,   --                               .vid_v_sync
        alt_vip_itc_0_clocked_video_vid_h_sync    => HDMI_TX_HS,   --                               .vid_h_sync
        alt_vip_itc_0_clocked_video_vid_f         => open,         --                               .vid_f
        alt_vip_itc_0_clocked_video_vid_h         => open,         --                               .vid_h
        alt_vip_itc_0_clocked_video_vid_v         => open,         --                               .vid_v
            
        -- CLOCK
        clk_clk                                   => FPGA_CLK1_50, --                            clk.clk
        clk_130_clk                               => clk_130,      --                        clk_130.clk
				
	-- RESETCONTROL
        hps_0_f2h_cold_reset_req_reset_n          => not hps_cold_reset,          --       hps_0_f2h_cold_reset_req.reset_n
        hps_0_f2h_debug_reset_req_reset_n         => not hps_debug_reset,         --      hps_0_f2h_debug_reset_req.reset_n
        hps_0_f2h_stm_hw_events_stm_hwevents      => stm_hw_events,               --        hps_0_f2h_stm_hw_events.stm_hwevents
        hps_0_f2h_warm_reset_req_reset_n          => not hps_warm_reset,          --       hps_0_f2h_warm_reset_req.reset_n
        hps_0_h2f_reset_reset_n                   => hps_fpga_reset_n,            --                hps_0_h2f_reset.reset_n                  --                               .oct_rzqin
        reset_reset_n                             => hps_fpga_reset_n,     
				
	-- I/O
	button_pio_external_connection_export     => fpga_debounced_buttons,     -- button_pio_external_connection.export
	led_pio_external_connection_export        => fpga_led_internal,          --    led_pio_external_connection.export
        dipsw_pio_external_connection_export      => SW, 
				
	-- ethernet
        hps_0_hps_io_hps_io_emac1_inst_TX_CLK     => HPS_ENET_GTX_CLK,     --                   hps_0_hps_io.hps_io_emac1_inst_TX_CLK
        hps_0_hps_io_hps_io_emac1_inst_TXD0       => HPS_ENET_TX_DATA(0),  --                               .hps_io_emac1_inst_TXD0
        hps_0_hps_io_hps_io_emac1_inst_TXD1       => HPS_ENET_TX_DATA(1),  --                               .hps_io_emac1_inst_TXD1
        hps_0_hps_io_hps_io_emac1_inst_TXD2       => HPS_ENET_TX_DATA(2),  --                               .hps_io_emac1_inst_TXD2
        hps_0_hps_io_hps_io_emac1_inst_TXD3       => HPS_ENET_TX_DATA(3),  --                               .hps_io_emac1_inst_TXD3
        hps_0_hps_io_hps_io_emac1_inst_RXD0       => HPS_ENET_RX_DATA(0),  --                               .hps_io_emac1_inst_RXD0
        hps_0_hps_io_hps_io_emac1_inst_MDIO       => HPS_ENET_MDIO,        --                               .hps_io_emac1_inst_MDIO
        hps_0_hps_io_hps_io_emac1_inst_MDC        => HPS_ENET_MDC,         --                               .hps_io_emac1_inst_MDC
        hps_0_hps_io_hps_io_emac1_inst_RX_CTL     => HPS_ENET_RX_DV,       --                               .hps_io_emac1_inst_RX_CTL
        hps_0_hps_io_hps_io_emac1_inst_TX_CTL     => HPS_ENET_TX_EN,       --                               .hps_io_emac1_inst_TX_CTL
        hps_0_hps_io_hps_io_emac1_inst_RX_CLK     => HPS_ENET_RX_CLK,      --                               .hps_io_emac1_inst_RX_CLK
        hps_0_hps_io_hps_io_emac1_inst_RXD1       => HPS_ENET_RX_DATA(1),  --                               .hps_io_emac1_inst_RXD1
        hps_0_hps_io_hps_io_emac1_inst_RXD2       => HPS_ENET_RX_DATA(2),  --                               .hps_io_emac1_inst_RXD2
        hps_0_hps_io_hps_io_emac1_inst_RXD3       => HPS_ENET_RX_DATA(3),  --                               .hps_io_emac1_inst_RXD3
   
	-- sdi
	hps_0_hps_io_hps_io_sdio_inst_CMD         => HPS_SD_CMD,         --                               .hps_io_sdio_inst_CMD
        hps_0_hps_io_hps_io_sdio_inst_D0          => HPS_SD_DATA(0),     --                               .hps_io_sdio_inst_D0
        hps_0_hps_io_hps_io_sdio_inst_D1          => HPS_SD_DATA(1),     --                               .hps_io_sdio_inst_D1
        hps_0_hps_io_hps_io_sdio_inst_CLK         => HPS_SD_CLK,         --                               .hps_io_sdio_inst_CLK
        hps_0_hps_io_hps_io_sdio_inst_D2          => HPS_SD_DATA(2),     --                               .hps_io_sdio_inst_D2
        hps_0_hps_io_hps_io_sdio_inst_D3          => HPS_SD_DATA(3),     --                               .hps_io_sdio_inst_D3
            
	-- usb
        hps_0_hps_io_hps_io_usb1_inst_D0          => HPS_USB_DATA(0),    --                               .hps_io_usb1_inst_D0
        hps_0_hps_io_hps_io_usb1_inst_D1          => HPS_USB_DATA(1),    --                               .hps_io_usb1_inst_D1
        hps_0_hps_io_hps_io_usb1_inst_D2          => HPS_USB_DATA(2),    --                               .hps_io_usb1_inst_D2
        hps_0_hps_io_hps_io_usb1_inst_D3          => HPS_USB_DATA(3),    --                               .hps_io_usb1_inst_D3
        hps_0_hps_io_hps_io_usb1_inst_D4          => HPS_USB_DATA(4),    --                               .hps_io_usb1_inst_D4
        hps_0_hps_io_hps_io_usb1_inst_D5          => HPS_USB_DATA(5),    --                               .hps_io_usb1_inst_D5
        hps_0_hps_io_hps_io_usb1_inst_D6          => HPS_USB_DATA(6),    --                               .hps_io_usb1_inst_D6
        hps_0_hps_io_hps_io_usb1_inst_D7          => HPS_USB_DATA(7),    --                               .hps_io_usb1_inst_D7
        hps_0_hps_io_hps_io_usb1_inst_CLK         => HPS_USB_CLKOUT,     --                               .hps_io_usb1_inst_CLK
        hps_0_hps_io_hps_io_usb1_inst_STP         => HPS_USB_STP,        --                               .hps_io_usb1_inst_STP
        hps_0_hps_io_hps_io_usb1_inst_DIR         => HPS_USB_DIR,        --                               .hps_io_usb1_inst_DIR
        hps_0_hps_io_hps_io_usb1_inst_NXT         => HPS_USB_NXT,        --                               .hps_io_usb1_inst_NXT
            
	-- spi
	hps_0_hps_io_hps_io_spim1_inst_CLK        => HPS_SPIM_CLK,       --                               .hps_io_spim1_inst_CLK
        hps_0_hps_io_hps_io_spim1_inst_MOSI       => HPS_SPIM_MOSI,      --                               .hps_io_spim1_inst_MOSI
        hps_0_hps_io_hps_io_spim1_inst_MISO       => HPS_SPIM_MISO,      --                               .hps_io_spim1_inst_MISO
        hps_0_hps_io_hps_io_spim1_inst_SS0        => HPS_SPIM_SS,        --                               .hps_io_spim1_inst_SS0
            
	-- uart
	hps_0_hps_io_hps_io_uart0_inst_RX         => HPS_UART_RX,        --                               .hps_io_uart0_inst_RX
        hps_0_hps_io_hps_io_uart0_inst_TX         => HPS_UART_TX,        --                               .hps_io_uart0_inst_TX
            
	-- i2c
	hps_0_hps_io_hps_io_i2c0_inst_SDA         => HPS_I2C0_SDAT,      --                               .hps_io_i2c0_inst_SDA
        hps_0_hps_io_hps_io_i2c0_inst_SCL         => HPS_I2C0_SCLK,      --                               .hps_io_i2c0_inst_SCL
        hps_0_hps_io_hps_io_i2c1_inst_SDA         => HPS_I2C1_SDAT,      --                               .hps_io_i2c1_inst_SDA
        hps_0_hps_io_hps_io_i2c1_inst_SCL         => HPS_I2C1_SCLK,      --                               .hps_io_i2c1_inst_SCL
   
	-- GPIOs
	hps_0_hps_io_hps_io_gpio_inst_GPIO09      => HPS_CONV_USB_N,     --                               .hps_io_gpio_inst_GPIO09
        hps_0_hps_io_hps_io_gpio_inst_GPIO35      => HPS_ENET_INT_N,     --                               .hps_io_gpio_inst_GPIO35
        hps_0_hps_io_hps_io_gpio_inst_GPIO40      => HPS_LTC_GPIO,       --                               .hps_io_gpio_inst_GPIO40
        hps_0_hps_io_hps_io_gpio_inst_GPIO53      => HPS_LED,            --                               .hps_io_gpio_inst_GPIO53
        hps_0_hps_io_hps_io_gpio_inst_GPIO54      => HPS_KEY,            --                               .hps_io_gpio_inst_GPIO54
        hps_0_hps_io_hps_io_gpio_inst_GPIO61      => HPS_GSENSOR_INT,    --                               .hps_io_gpio_inst_GPIO61
            
	-- DDR3 RAM
        memory_mem_a                              => HPS_DDR3_ADDR,      --                         memory.mem_a
        memory_mem_ba                             => HPS_DDR3_BA,        --                               .mem_ba
        memory_mem_ck                             => HPS_DDR3_CK_P,      --                               .mem_ck
        memory_mem_ck_n                           => HPS_DDR3_CK_N,      --                               .mem_ck_n
        memory_mem_cke                            => HPS_DDR3_CKE,       --                               .mem_cke
        memory_mem_cs_n                           => HPS_DDR3_CS_N,      --                               .mem_cs_n
        memory_mem_ras_n                          => HPS_DDR3_RAS_N,     --                               .mem_ras_n
        memory_mem_cas_n                          => HPS_DDR3_CAS_N,     --                               .mem_cas_n
        memory_mem_we_n                           => HPS_DDR3_WE_N,      --                               .mem_we_n
        memory_mem_reset_n                        => HPS_DDR3_RESET_N,   --                               .mem_reset_n
        memory_mem_dq                             => HPS_DDR3_DQ,        --                               .mem_dq
        memory_mem_dqs                            => HPS_DDR3_DQS_P,     --                               .mem_dqs
        memory_mem_dqs_n                          => HPS_DDR3_DQS_N,     --                               .mem_dqs_n
        memory_mem_odt                            => HPS_DDR3_ODT,       --                               .mem_odt
        memory_mem_dm                             => HPS_DDR3_DM,        --                               .mem_dm
        memory_oct_rzqin                          => HPS_DDR3_RZQ        --                          reset.reset_n
    );
		  
    vga_pll_i : vga_pll 
    port map (
        refclk  => fpga_clk_50,         --  refclk.clk
        rst     =>  '0',                --   reset.reset
        outclk_0 => clk_65,             -- outclk0.clk
        outclk_1 => clk_130,            -- outclk1.clk
        locked   => open                --  locked.export
    ); 
	
    I2C_HDMI_Config_inst : I2C_HDMI_Config 
    port map(
        iCLK => FPGA_CLK1_50,
        iRST_N => '1',
        I2C_SCLK  => HDMI_I2C_SCL,
        I2C_SDAT => HDMI_I2C_SDA,
        HDMI_TX_INT => HDMI_TX_INT,
        READY => open
    );	

    HSP_RESET0_INIT : hps_reset0 
    port map (
        fpga_clk_50 => fpga_clk_50 ,
        hps_fpga_reset_n => hps_fpga_reset_n,
        hps_cold_reset => hps_cold_reset,
        hps_warm_reset => hps_warm_reset,
        hps_debug_reset => hps_debug_reset
    );

    debounce_i : debounce
    port map (
        clk  => fpga_clk_50 ,
        reset_n => hps_fpga_reset_n, 	
        data_in => KEY,
        data_out => fpga_debounced_buttons
    );
end rtl;
