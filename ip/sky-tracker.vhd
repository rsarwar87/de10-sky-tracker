
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


entity sky_tracker is
    Port ( 
			  clk_50 : in STD_LOGIC := '0';
           rstn_50 : in STD_LOGIC := '1';
			  
           ra_mode : out STD_LOGIC_VECTOR (2 downto 0);
           ra_enable_n : out STD_LOGIC;
           ra_sleep_n : out STD_LOGIC;
           ra_rst_n : out STD_LOGIC;
           ra_step : out STD_LOGIC;
           ra_direction : out STD_LOGIC;
           ra_fault_n : in STD_LOGIC;
			  de_mode : out STD_LOGIC_VECTOR (2 downto 0);
           de_enable_n : out STD_LOGIC;
           de_sleep_n : out STD_LOGIC;
           de_rst_n : out STD_LOGIC;
           de_step : out STD_LOGIC;
           de_direction : out STD_LOGIC;
           de_fault_n : in STD_LOGIC;
			  
			  sts_acknowledge                           : out    std_logic                     := 'X';             -- acknowledge
           sts_irq                                   : out    std_logic                     := 'X';             -- irq
           sts_address                               : in   std_logic_vector(11 downto 0);                    -- address
           sts_bus_enable                            : in    std_logic;                                        -- bus_enable
           sts_byte_enable                           : in    std_logic_vector(3 downto 0);                     -- byte_enable
           sts_rw                                    : in    std_logic;                                        -- rw
           sts_write_data                            : in    std_logic_vector(31 downto 0);                    -- write_data
           sts_read_data                             : out   std_logic_vector(31 downto 0) := (others => 'X'); -- read_data
           
			  ctrl_acknowledge                          : out    std_logic                     := 'X';             -- acknowledge
           ctrl_irq                                  : out    std_logic                     := 'X';             -- irq
           ctrl_address                              : in   std_logic_vector(11 downto 0);                    -- address
           ctrl_bus_enable                           : in   std_logic;                                        -- bus_enable
           ctrl_byte_enable                          : in   std_logic_vector(3 downto 0);                     -- byte_enable
           ctrl_rw                                   : in   std_logic;                                        -- rw
           ctrl_write_data                           : in   std_logic_vector(31 downto 0);                    -- write_data
           ctrl_read_data                            : out    std_logic_vector(31 downto 0) := (others => 'X') ; -- read_data
			  buf3_export                             : out    std_logic_vector(31 downto 0) := (others => 'X'); -- export
            buf1_export                               : out    std_logic_vector(31 downto 0) := (others => 'X'); -- export
            buf0_export                               : out    std_logic_vector(31 downto 0) := (others => 'X'); -- export
            ra_status_export                          : out   std_logic_vector(31 downto 0) := (others => 'X'); -- export
            de_status_export                          : out   std_logic_vector(31 downto 0) := (others => 'X'); -- export
            ra_step_count_export                           : out    std_logic_vector(31 downto 0) := (others => 'X'); -- export
            de_step_count_export                           : out   std_logic_vector(31 downto 0) := (others => 'X'); -- export
            de_counter_load_export                    : in   std_logic_vector(31 downto 0);                    -- export
            ra_counter_load_export                  : in   std_logic_vector(31 downto 0);                    -- export
            de_counter_max_export                     : in std_logic_vector(31 downto 0);                    -- export
            ra_counter_max_export                     : in std_logic_vector(31 downto 0);                    -- export
            de_cmdcontrol_export                      : in    std_logic_vector(31 downto 0);                    -- export
            ra_cmdcontrol_export                      : in    std_logic_vector(31 downto 0);                    -- export
            de_cmdduration_export                     : in    std_logic_vector(31 downto 0);                    -- export
            ra_cmdduration_export                     : in    std_logic_vector(31 downto 0);                    -- export
            de_trackctrl_export                       : in    std_logic_vector(31 downto 0);                    -- export
            ra_trackctrl_export                       : in    std_logic_vector(31 downto 0);                    -- export
            de_cmdtick_export                         : in    std_logic_vector(31 downto 0);                    -- export
            ra_cmdtick_export                         : in std_logic_vector(31 downto 0);                    -- export
            de_backlash_tick_export                   : in    std_logic_vector(31 downto 0);                    -- export
            ra_backlash_tick_export                   : in    std_logic_vector(31 downto 0);                    -- export
            de_backlash_duration_export               : in std_logic_vector(31 downto 0);                    -- export
            ra_backlash_duration_export               : in    std_logic_vector(31 downto 0)                     -- export
			  
           );
end sky_tracker;

architecture Behavioral of sky_tracker is

signal ra_step_count 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal ra_status     		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal ra_cmdcontrol 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- steps, go, stop, direction
signal ra_cmdtick           : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal ra_cmdduration 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal ra_backlash_tick 	 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');  -- speed of backlash
signal ra_backlash_duration : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal ra_counter_load 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal ra_counter_max 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal ra_trackctrl 			 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

signal de_step_count 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal de_status     		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal de_cmdcontrol 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- steps, go, stop, direction
signal de_cmdtick           : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal de_cmdduration 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal de_backlash_tick 	 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');  -- speed of backlash
signal de_backlash_duration : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal de_counter_load 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal de_counter_max 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal de_trackctrl 			 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
begin

bus_imp : block
signal sts_ack, ctrl_ack : std_logic := '0';
begin
	ctrl_irq <= '0';
	sts_irq <= '0';
	
	ra_step_count_export <= ra_step_count;
	de_step_count_export <= de_step_count;
	ra_status_export <= ra_status;
	de_status_export <= de_status;
	buf3_export <= x"0110FFFF";
	buf1_export <= x"FFFF1001";
	buf0_export <= x"00000042";
	
				ra_counter_load                    <= de_counter_load_export;                    --                de_counter_load.export
            de_counter_load <= ra_counter_load_export;                  --              de_counter_load_1.export
            de_counter_max <= de_counter_max_export;                     --                 de_counter_max.export
            ra_counter_max	<= ra_counter_max_export;                     --                 ra_counter_max.export
            de_cmdcontrol	<= de_cmdcontrol_export;                      --                  de_cmdcontrol.export
            ra_cmdcontrol	<= ra_cmdcontrol_export;                      --                  ra_cmdcontrol.export
            de_cmdduration	<= de_cmdduration_export;                     --                 de_cmdduration.export
            ra_cmdduration	<= ra_cmdduration_export;                     --                 ra_cmdduration.export
            de_trackctrl	<= de_trackctrl_export;                       --                   de_trackctrl.export
            ra_trackctrl	<= ra_trackctrl_export;                       --                   ra_trackctrl.export
            de_cmdtick		<= de_cmdtick_export;                         --                     de_cmdtick.export
            ra_cmdtick		<= ra_cmdtick_export;                         --                     ra_cmdtick.export
            de_backlash_tick	<= de_backlash_tick_export;                   --               de_backlash_tick.export
            ra_backlash_tick	<= ra_backlash_tick_export;                   --               ra_backlash_tick.export
            de_backlash_duration	<= de_backlash_duration_export;               --           de_backlash_duration.export
            ra_backlash_duration	<= ra_backlash_duration_export;
--	process (clk_50, rstn_50) 
--	begin
--		if (rstn_50 = '0') then
--			sts_read_data <= (others => '0');
--			sts_acknowledge <= '0';
--			sts_ack <= '0';
--		elsif (rising_edge(clk_50)) then
--			--sts_read_data <= sts_read_data;
--			sts_acknowledge <= sts_ack;
--			sts_ack <= '0';
--			if (sts_bus_enable = '1' and ctrl_rw = '1') then
--			case sts_address(4 downto 2) is
--				when "000" =>
--					sts_read_data <= x"0110FFFF";
--					sts_ack <= '1';
--				when "001" => 
--					sts_read_data <= x"FFFF1001";
--					sts_ack <= '1';
--				when "010" =>
--					sts_read_data <= de_step_count;
--					sts_ack <= '1';
--				when "011" => 
--					sts_read_data <= ra_step_count;
--					sts_ack <= '1';
--				when "100" =>
--					sts_read_data <= de_status;
--					sts_ack <= '1';
--				when "101" => 
--					sts_read_data <= ra_status;
--					sts_ack <= '1';
--				when "110" => 
--					sts_read_data <= x"00000042";
--					sts_ack <= '1';
--				when others =>
--					sts_read_data <= (others => '0');
--					sts_ack <= '1';
--			end case;
--			end if;
--		end if;
--	end process;
--	
--	process (clk_50, rstn_50) 
--	begin
--		if (rstn_50 = '0') then
--			ctrl_read_data <= (others => '0');
--			ctrl_acknowledge <= '0';
--			ctrl_ack <= '0';
--		elsif (rising_edge(clk_50)) then
--			--ctrl_read_data <= ctrl_read_data;
--			ctrl_acknowledge <= ctrl_ack;
--			ctrl_ack <= '0';
--			if (ctrl_bus_enable = '1') then
--			case ctrl_address(5 downto 2) is
--				when "0000" =>
--					if ctrl_rw = '1' then
--						ctrl_read_data <= de_counter_load;
--						ctrl_ack <= '1';
--					else
--						for byte_index in 0 to (32/8-1) loop
--							if (ctrl_byte_enable(byte_index) = '1') then
--								de_counter_load <= ctrl_write_data;
--							end if;
--						end loop;
--					end if;
--				when "0001" => 
--					if ctrl_rw = '1' then
--						ctrl_read_data <= ra_counter_load;
--						ctrl_ack <= '1';
--					else
--						for byte_index in 0 to (32/8-1) loop
--							if (ctrl_byte_enable(byte_index) = '1') then
--								ra_counter_load <= ctrl_write_data;
--							end if;
--						end loop;
--					end if;
--				when "0010" =>
--					if ctrl_rw = '1' then
--						ctrl_read_data <= de_counter_max;
--						ctrl_ack <= '1';
--					else
--						for byte_index in 0 to (32/8-1) loop
--							if (ctrl_byte_enable(byte_index) = '1') then
--								de_counter_max <= ctrl_write_data;
--							end if;
--						end loop;
--					end if;
--				when "0011" => 
--					if ctrl_rw = '1' then
--						ctrl_read_data <= ra_counter_max;
--						ctrl_ack <= '1';
--					else
--						for byte_index in 0 to (32/8-1) loop
--							if (ctrl_byte_enable(byte_index) = '1') then
--								ra_counter_max <= ctrl_write_data;
--							end if;
--						end loop;
--					end if;
--				when "0100" =>
--					if ctrl_rw = '1' then
--						ctrl_read_data <= de_cmdcontrol;
--						ctrl_ack <= '1';
--					else
--						for byte_index in 0 to (32/8-1) loop
--							if (ctrl_byte_enable(byte_index) = '1') then
--								de_cmdcontrol <= ctrl_write_data;
--							end if;
--						end loop;
--					end if;
--				when "0101" => 
--					if ctrl_rw = '1' then
--						ctrl_read_data <= ra_cmdcontrol;
--						ctrl_ack <= '1';
--					else
--						for byte_index in 0 to (32/8-1) loop
--							if (ctrl_byte_enable(byte_index) = '1') then
--								ra_cmdcontrol <= ctrl_write_data;
--							end if;
--						end loop;
--					end if;
--				when "0110" => 
--					if ctrl_rw = '1' then
--						ctrl_read_data <= de_cmdduration;
--						ctrl_ack <= '1';
--					else
--						for byte_index in 0 to (32/8-1) loop
--							if (ctrl_byte_enable(byte_index) = '1') then
--								de_cmdduration <= ctrl_write_data;
--							end if;
--						end loop;
--					end if;
--				when "0111" => 
--					if ctrl_rw = '1' then
--						ctrl_read_data <= ra_cmdduration;
--						ctrl_ack <= '1';
--					else
--						for byte_index in 0 to (32/8-1) loop
--							if (ctrl_byte_enable(byte_index) = '1') then
--								ra_cmdduration <= ctrl_write_data;
--							end if;
--						end loop;
--					end if;
--					
--				when "1000" =>
--					if ctrl_rw = '1' then
--						ctrl_read_data <= de_trackctrl;
--						ctrl_ack <= '1';
--					else
--						for byte_index in 0 to (32/8-1) loop
--							if (ctrl_byte_enable(byte_index) = '1') then
--								de_trackctrl <= ctrl_write_data;
--							end if;
--						end loop;
--					end if;
--				when "1001" => 
--					if ctrl_rw = '1' then
--						ctrl_read_data <= ra_trackctrl;
--						ctrl_ack <= '1';
--					else
--						for byte_index in 0 to (32/8-1) loop
--							if (ctrl_byte_enable(byte_index) = '1') then
--								ra_trackctrl <= ctrl_write_data;
--							end if;
--						end loop;
--					end if;
--				when "1010" =>
--					if ctrl_rw = '1' then
--						ctrl_read_data <= de_cmdtick;
--						ctrl_ack <= '1';
--					else
--						for byte_index in 0 to (32/8-1) loop
--							if (ctrl_byte_enable(byte_index) = '1') then
--								de_cmdtick <= ctrl_write_data;
--							end if;
--						end loop;
--					end if;
--				when "1011" => 
--					if ctrl_rw = '1' then
--						ctrl_read_data <= ra_cmdtick;
--						ctrl_ack <= '1';
--					else
--						for byte_index in 0 to (32/8-1) loop
--							if (ctrl_byte_enable(byte_index) = '1') then
--								ra_cmdtick <= ctrl_write_data;
--							end if;
--						end loop;
--					end if;
--				when "1100" =>
--					if ctrl_rw = '1' then
--						ctrl_read_data <= de_backlash_tick;
--						ctrl_ack <= '1';
--					else
--						for byte_index in 0 to (32/8-1) loop
--							if (ctrl_byte_enable(byte_index) = '1') then
--								de_backlash_tick <= ctrl_write_data;
--							end if;
--						end loop;
--					end if;
--				when "1101" => 
--					if ctrl_rw = '1' then
--						ctrl_read_data <= ra_backlash_tick;
--						ctrl_ack <= '1';
--					else
--						for byte_index in 0 to (32/8-1) loop
--							if (ctrl_byte_enable(byte_index) = '1') then
--								ra_backlash_tick <= ctrl_write_data;
--							end if;
--						end loop;
--					end if;
--				when "1110" => 
--					if ctrl_rw = '1' then
--						ctrl_read_data <= de_backlash_duration;
--						ctrl_ack <= '1';
--					else
--						for byte_index in 0 to (32/8-1) loop
--							if (ctrl_byte_enable(byte_index) = '1') then
--								de_backlash_duration <= ctrl_write_data;
--							end if;
--						end loop;
--					end if;
--				when "1111" => 
--					if ctrl_rw = '1' then
--						ctrl_read_data <= ra_backlash_duration;
--						ctrl_ack <= '1';
--					else
--						for byte_index in 0 to (32/8-1) loop
--							if (ctrl_byte_enable(byte_index) = '1') then
--								ra_backlash_duration <= ctrl_write_data;
--							end if;
--						end loop;
--					end if;
--				when others =>
--					sts_read_data <= (others => '0');
--					sts_ack <= '1';
--			end case;
--			end if;
--		end if;
--	end process;

end block bus_imp;


drv_ips : block
begin
DRV_RA :  entity work.drv8825	
	port map (
		clk_50 => clk_50,
		ctrl_backlash_duration => ra_backlash_duration,
		ctrl_backlash_tick => ra_backlash_tick,
		ctrl_cmdcontrol => ra_cmdcontrol,
		ctrl_cmdduration => ra_cmdduration,
		ctrl_cmdtick => ra_cmdtick,
		ctrl_counter_load => ra_counter_load,
		ctrl_counter_max => ra_counter_max,
		ctrl_status => ra_status,
		ctrl_step_count(31 downto 0) => ra_step_count(31 downto 0),
		ctrl_trackctrl(31 downto 0) => ra_trackctrl(31 downto 0),
		drv8825_direction => ra_direction,
		drv8825_enable_n => ra_enable_n,
		drv8825_fault_n => ra_fault_n,
		drv8825_mode(2 downto 0) => ra_mode(2 downto 0),
		drv8825_rst_n => ra_rst_n,
		drv8825_sleep_n => ra_sleep_n,
		drv8825_step => ra_step,
		rstn_50 => rstn_50

	);
	
	DRV_DE :  entity work.drv8825	
	port map (
		clk_50 => clk_50,
		ctrl_backlash_duration => de_backlash_duration,
		ctrl_backlash_tick => de_backlash_tick,
		ctrl_cmdcontrol => de_cmdcontrol,
		ctrl_cmdduration => de_cmdduration,
		ctrl_cmdtick => de_cmdtick,
		ctrl_counter_load => de_counter_load,
		ctrl_counter_max => de_counter_max,
		ctrl_status => de_status,
		ctrl_step_count(31 downto 0) => de_step_count(31 downto 0),
		ctrl_trackctrl(31 downto 0) => de_trackctrl(31 downto 0),
		drv8825_direction => de_direction,
		drv8825_enable_n => de_enable_n,
		drv8825_fault_n => de_fault_n,
		drv8825_mode(2 downto 0) => de_mode(2 downto 0),
		drv8825_rst_n => de_rst_n,
		drv8825_sleep_n => de_sleep_n,
		drv8825_step => de_step,
		rstn_50 => rstn_50

	);
end block drv_ips;

end Behavioral;