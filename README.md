
# StarTracker for DE10-Nano Board.

## Hardware Design

### RA/DE DRV8825 controller

The two motors are controlled by `ip/drv8825.vhd` which can accept backlash offsets, slew tracking (continuous motor operation at a given period) and goto commands which can either be based on a targeted step count or an increment or decrement count.

The steps are counted at 50 Mhz; depending of the voltage on the motor the minimum period would change. at 20 v, the minim period is 125 ticks.

The goto commands can contain acceleration flag which will accelerate the motor to the targetted speed over a period of 2 seconds. The flag is ignored by the design if the number of increment/decrement needed for the operation is not high enough to justify their use; or is the period is not short enough to justify it.

|Ports |Description |
|----------------|------------------------------
|clk_50 | clock; must be 50 MHz
|rstn_50 | Active low reset
|drv8825_enable_n | pin to DRV8825 enable pin (active low). Pin is only enabled when motors are spinning
|drv8825_mode [2 downto 0] | DRV8825 mode selector, set from the command mode. When it is set as 5 or higher, the step counter is incremented by one. When it is 4, than by 2; 3 -> 4; 2 -> 8; 1 -> 16; 0 -> 32 in order to keep with the microsteppings.
| drv8825_sleep_n drv8825_rst_n | to the DRV8825
| drv8825_step | Clock for the DRV8825
| drv8825_direction | direction of the DRV8825
| drv8825_fault_n | reporting fault on DRV8825
| ctrl_step_count [32 downoto 0] | reports the current step count to the top level
| ctrl_status [31 downto 0] | reports status update to the top level, e.g. is the motor running, what mode, etc.
| ctrl_cmdcontrol [0] | Goto command parameters. This is the execute pin. Command is only executed at the rising edge of this bit
| ctrl_cmdcontrol [1] | Defines goto command parameter. When high, the command is interpretted as a goto call, i.e. motor will spin until that counter reaches the value defined by ctrl_cmdduration. When low, the command is interpreted as a simple increment or decrement command, where the motor is spun for the number of cycles defined by ctrl_cmdduration.
| ctrl_cmdcontrol [2] | Defines goto command parameter related to the director of the motor
| ctrl_cmdcontrol [3] | Defines park command parameter. motor will spin till counter reaches zero
| ctrl_cmdcontrol [6 downto 4] | Defines goto command parameter related to the direction of the motor.
| ctrl_cmdcontrol [7] | Defines goto command parameter related acceleration of the motor. When high, acceleration and de-acceleration ramps are to be used.
| ctrl_cmdcontrol [30] | When high, it cancels the current any command currently being processed immediately.
| ctrl_cmdcontrol [31] | When high, it cancels the current any command currently being processed whilst deaccelating.
| ctrl_cmdtick [31 downto 0] | Define goto parameters related to the period at which command is to be executed in.
| ctrl_cmdduration [31 downto 0] | Define goto parameters related to the number of cycles/target count of the command.
| ctrl_backlash_tick [2 downto 0] | Define backlash parameters related the motor mode.
| ctrl_backlash_tick [31 downto 3] | Define backlash parameters related to the steps or the number of ticks the backlash correction is to execute in. Backlash is active when it is a non-zero value.
| ctrl_backlash_duration [31 downto 0] | Define backlash parameters related to the steps the backlash correction is to execute for. Backlash is active when it is a non-zero value.
| ctrl_counter_load [31 downto 0] | Overwrites the current step count; count is updated on the rising edge of bit 31. Therefore 31 bits are available for a possible max count.
| ctrl_counter_max [31 downto 0] | Loads the maximum count per revolution; count is updated on the rising edge of bit 31. Therefore 31 bits are available for a possible max count.
| ctrl_trackctrl [0] | Define slew to/tracking parameters. Only executed when no goto command is being executed. Bit 0 must be high if tracking is to be enabled.
| ctrl_trackctrl [1] | Define slew to/tracking parameters. Bit 1 defines the direction of motion
| ctrl_trackctrl [5 downto 2] | Define slew to/tracking parameters. Bit 2-5 defines the motor mode
| ctrl_trackctrl [31 downto 6] | Define slew to/tracking parameters. remaining bits defines the speed/period is number of 20 ns ticks.

### Top Level

#### Camera Triggers

#### Polar LED

#### LED Status

## Software design

### Register Map

The registers are deviced into two grous

#### Status

#### Control

## Reference design:

OEM supplied LXDE GHRD.

the top level was is implemented in VHDL. The remaining ip/soc_system was taken from SoC_FB example.
