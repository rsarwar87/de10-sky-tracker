/// Led Blinker driver
///
/// (c) Koheron

#ifndef __DRIVERS_SKY_INTERFACE_HPP__
#define __DRIVERS_SKY_INTERFACE_HPP__

#include <context.hpp>
#include <drv8825.hpp>
#include <params.hpp>

enum t_status { Idle = 0, Slew, GoTo, Parking, Undefined };
  constexpr double fclk0_period_us =
      1000000.0 / ((double)(prm::fclk0));  // Number of descriptors

using namespace std::chrono_literals;
class SkyTrackerInterface {
 public:
  SkyTrackerInterface(Context& ctx_)
      : ctx(ctx_),
        ctl(ctx.mm.get<mem::control>()),
        sts(ctx.mm.get<mem::status>()),
        stepper(ctx.get<Drv8825>()) {
    for (size_t i = 0; i < 2; i++) {
      m_params.period_usec[0][i] = 1;     // time period in us
      m_params.period_ticks[0][i] = 100;  // time period in 20ns ticks
      m_params.speed_ratio[0][i] = 1;     // speed of motor
      m_params.period_usec[1][i] = 1;     // time period in us
      m_params.period_ticks[1][i] = 100;  // time period in 20ns ticks
      m_params.speed_ratio[1][i] = 1;     // speed of motor

      m_params.highSpeedMode[0][i] = false;
      m_params.highSpeedMode[1][i] = false;
      m_params.GotoTarget[i] = 0;
      m_params.GotoNCycles[i] = 0;

      m_params.minPeriod[i] = (uint32_t)((15 / fclk0_period_us) + .5);  // slowest speed allowed
      m_params.maxPeriod[i] =
          (uint32_t)((268435.0 / fclk0_period_us) + .5);  // Speed at which mount should stop. May be lower than
                    // minSpeed if doing a very slow IVal.

      m_params.motorDirection[0][i] = true;
      m_params.motorDirection[1][i] = true;

      m_params.motorMode[0][i] = 0x07;  // microsteps 16 => //4
      m_params.motorMode[1][i] = 0x07;  // microsteps

      m_params.versionNumber[i] = 0xd4444;  //_eVal: Version number

      m_params.stepPerRotation[i] =
          200*32*144*5;  //_aVal: Steps per axis revolution

      m_params.backlash_period_usec[i] =
          10.;  //_sVal: Steps per worm gear revolution
      m_params.backlash_ticks[i] = 0x300;    //_eVal: Version number
      m_params.backlash_ncycle[i] = 0x3000;  //_aVal: Steps per axis revolution
      m_params.backlash_mode[i] = 0x7;  //_aVal: Steps per axis revolution
      m_params.initialized[i] = false;  //_aVal: Steps per axis revolution

      set_backlash(i, 15.1, 127, 7);
      set_steps_per_rotation(i, get_steps_per_rotation(i));
      set_current_position(i, get_steps_per_rotation(i)/2);

    }
  }

  bool set_led_pwm(uint8_t val) {
    ctl.write<reg::led_pwm>(val);
    ctx.log<INFO>("%s(): %d\n", __func__, val);
    return true;
  }
  bool set_speed_ratio(uint8_t axis, bool isSlew, double val) {
    if (!check_axis_id(axis, __func__)) return false;
    if (val < 0.25) {
      ctx.log<ERROR>("%s(%u) val out of range %9.5f\n", __func__, axis, val);
      return false;
    }
    m_params.speed_ratio[isSlew][axis] = val;
    ctx.log<INFO>("%s(%u): %9.5f\n", __func__, axis,
                  m_params.speed_ratio[isSlew][axis]);
    return true;
  }
  double get_speed_ratio(uint8_t axis, bool isSlew) {
    if (!check_axis_id(axis, __func__)) return -1.;
    ctx.log<INFO>("%s(%u): %9.5f\n", __func__, axis,
                  m_params.speed_ratio[isSlew][axis]);
    return m_params.speed_ratio[isSlew][axis];
  }
  uint32_t get_steps_per_rotation(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    ctx.log<INFO>("%s(%u): %u ticks\n", __func__, axis,
                  m_params.stepPerRotation[axis]);
    return m_params.stepPerRotation[axis];
  }
  bool set_steps_per_rotation(uint8_t axis, uint32_t steps) {
    if (!check_axis_id(axis, __func__)) return false;
    if (steps > 0x3FFFFFFF) {
      ctx.log<ERROR>("%s(%u): %u steps (Max %u ticks)\n", __func__, axis, steps,
                     0x3FFFFFFF);
      return false;
    }
    m_params.stepPerRotation[axis] = steps;
    ctx.log<INFO>("%s(%u): %u ticks\n", __func__, axis,
                  m_params.stepPerRotation[axis]);
    if (axis == 0) stepper.set_max_step<0>(steps);
    else stepper.set_max_step<1>(steps);
    return true;
  }

  uint32_t get_version() { return (m_params.versionNumber[0]); }
  uint32_t get_backlash_period_ticks(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    ctx.log<INFO>("%s(%u): %u ticks\n", __func__, axis,
                  m_params.backlash_ticks[axis]);
    return m_params.backlash_ticks[axis];
  }
  double get_backlash_period_usec(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    ctx.log<INFO>("%s(%u): %9.5f us\n", __func__, axis,
                  m_params.backlash_period_usec[axis]);
    return m_params.backlash_period_usec[axis];
  }
  uint32_t get_backlash_ncycles(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    ctx.log<INFO>("%s(%u): %u cycles\n", __func__, axis,
                  m_params.backlash_ncycle[axis]);
    return m_params.backlash_ncycle[axis];
  }
  bool set_backlash(uint8_t axis, double period_usec, uint32_t cycles, uint8_t mode) {
    if (!check_axis_id(axis, __func__)) return false;
    uint32_t _ticks = (uint32_t)((period_usec  / fclk0_period_us) + .5);
    if (mode > 7) {
      ctx.log<ERROR>("%s(%u): mode out of range %u (%u max)\n",
                     __func__, axis, mode, 7);
      return false;
    }
    if (_ticks > m_params.maxPeriod[axis] ||
        _ticks < m_params.minPeriod[axis]) {
      ctx.log<ERROR>("%s(%u): period out of range %9.5f usec (%u ticks)\n",
                     __func__, axis, period_usec, _ticks);
      return false;
    }
    m_params.backlash_period_usec[axis] = period_usec;
    m_params.backlash_ticks[axis] = _ticks;
    m_params.backlash_ncycle[axis] = cycles;
    m_params.backlash_mode[axis] = mode;
    ctx.log<INFO>(
        "%s(%u): backlash period set to %9.5f us (%u ticks) for %u cycles\n",
        __func__, axis, period_usec, _ticks, cycles);
    return true;
  }
  bool set_motor_mode(uint8_t axis, bool isSlew, uint8_t val) {
    if (!check_axis_id(axis, __func__)) return false;
    if (val > 7) {
      ctx.log<ERROR>("%s(%u): invalid mode for %s (%u)\n", __func__, axis,
                     isSlew ? "Slew" : "GoTo", val);
      return false;
    }

    m_params.motorMode[isSlew][axis] = val;
    ctx.log<INFO>("%s(%u): %s mode set to %s\n", __func__, axis,
                  isSlew ? "Slew" : "GoTo", val);
    return true;
  }
  uint32_t get_motor_mode(uint8_t axis, bool isSlew) {
    if (!check_axis_id(axis, __func__)) return false;
    uint32_t ret = m_params.motorMode[isSlew][axis];
    ctx.log<INFO>("%s(%u): %s is in %u mode\n", __func__, axis,
                  isSlew ? "Slew" : "GoTo", ret);
    return (ret);
  }
  bool set_motor_highspeedmode(uint8_t axis, bool isSlew, bool isHighSpeed) {
    if (!check_axis_id(axis, __func__)) return false;
    m_params.highSpeedMode[isSlew][axis] = isHighSpeed;
    ctx.log<INFO>("%s(%u): %s high speed = %s\n", __func__, axis,
                  isSlew ? "Slew" : "GoTo",
                  isHighSpeed ? "True" : "False");
    return true;
  }
  bool get_motor_highspeedmode(uint8_t axis, bool isSlew) {
    if (!check_axis_id(axis, __func__)) return false;
    bool ret = m_params.highSpeedMode[isSlew][axis];
    ctx.log<INFO>("%s(%u): %s highspeed: %s\n", __func__, axis,
                  isSlew ? "Slew" : "GoTo", ret ? "True" : "False");
    return (ret);
  }
  bool set_motor_direction(uint8_t axis, bool isSlew, bool isForward) {
    if (!check_axis_id(axis, __func__)) return false;
    m_params.motorDirection[isSlew][axis] = isForward;
    ctx.log<INFO>("%s(%u): %s is in %s direction\n", __func__, axis,
                  isSlew ? "Slew" : "GoTo", isForward ? "Forward" : "Backward");
    return true;
  }
  bool get_motor_direction(uint8_t axis, bool isSlew) {
    if (!check_axis_id(axis, __func__)) return false;
    bool ret = m_params.motorDirection[isSlew][axis];
    ctx.log<INFO>("%s(%u): %s is in %s direction\n", __func__, axis,
                  isSlew ? "Slew" : "GoTo", ret ? "Forward" : "Backward");
    return (ret);
  }
  bool set_min_period(uint8_t axis, double val_usec) {
    if (!check_axis_id(axis, __func__)) return false;
    uint32_t _ticks = (uint32_t)((val_usec / fclk0_period_us) + .5);
    if (_ticks < 2) {
      ctx.log<ERROR>(
          "%s(%u): %9.5f usec (%u ticks). Minimum allowed is 0.05 usec\n",
          __func__, axis, val_usec, _ticks);
      return false;
    }
    m_params.minPeriod[axis] = _ticks;
    ctx.log<INFO>("%s(%u): %u ticks (%9.5f usec)\n", __func__, axis,
                  m_params.minPeriod[axis], val_usec);
    return true;
  }
  bool set_max_period(uint8_t axis, double val_usec) {
    if (!check_axis_id(axis, __func__)) return false;
    if (val_usec > 2684354.) {
      ctx.log<ERROR>("%s(%u): %9.5f usec. Max allowed is 2683454 usec \n",
                     __func__, axis, val_usec);
      return false;
    }
    uint32_t _ticks = (uint32_t)((val_usec / fclk0_period_us) + .5);
    m_params.maxPeriod[axis] = _ticks;
    ctx.log<INFO>("%s(%u): %u ticks\n", __func__, axis, m_params.maxPeriod[axis]);
    return true;
  }
  uint32_t get_min_period_ticks(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    ctx.log<INFO>("%s(%u): %u ticks\n", __func__, axis, m_params.minPeriod[axis]);
    return (m_params.minPeriod[axis]);
  }
  uint32_t get_max_period_ticks(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    ctx.log<INFO>("%s(%u): %u ticks\n", __func__, axis, m_params.maxPeriod[axis]);
    return (m_params.maxPeriod[axis]);
  }
  uint32_t get_motor_period_ticks(uint8_t axis, bool isSlew) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    ctx.log<INFO>("%s(%u-%u): %u\n", __func__, axis, isSlew,
                  m_params.period_ticks[isSlew][axis]);
    return (m_params.period_ticks[isSlew][axis]);
  }
  double get_motor_period_usec(uint8_t axis, bool isSlew) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    ctx.log<INFO>("%s(%u-%u): %9.5f\n", __func__, axis, isSlew,
                  m_params.period_usec[isSlew][axis]);
    return (m_params.period_usec[isSlew][axis]);
  }
  bool set_motor_period_usec(uint8_t axis, bool isSlew, double val_usec) {
    if (!check_axis_id(axis, __func__)) return false;
    uint32_t _ticks = (uint32_t)((val_usec  / fclk0_period_us) + .5);
    if (_ticks > m_params.maxPeriod[axis] ||
        _ticks < m_params.minPeriod[axis]) {
      ctx.log<ERROR>("%s(%u): out of range %9.5f usec (%u ticks)\n", __func__, 
          axis, val_usec, _ticks);
      return false;
    }
    m_params.period_usec[isSlew][axis] = val_usec;
    m_params.period_ticks[isSlew][axis] = _ticks;
    // m_params.motorSpeed[isSlew][axis] = m_params.stepPerRotation[axis]*;
    ctx.log<INFO>("%s(%u): %9.5f usec (%u ticks)\n", __func__, axis,
                  m_params.period_usec[isSlew][axis], _ticks);
    return true;
  }
  bool set_motor_period_ticks(uint8_t axis, bool isSlew, uint32_t val_ticks) {
    if (!check_axis_id(axis, __func__)) return false;
    if (val_ticks > m_params.maxPeriod[axis] ||
        val_ticks < m_params.minPeriod[axis]) {
      ctx.log<ERROR>("%s(%u): out of range %u\n", __func__, axis, val_ticks);
      return false;
    }
    m_params.period_usec[isSlew][axis] = val_ticks * fclk0_period_us;
    m_params.period_ticks[isSlew][axis] = val_ticks;
    // m_params.motorSpeed[isSlew][axis] = m_params.stepPerRotation[axis]*;
    ctx.log<INFO>("%s(%u): %u\n", __func__, axis,
                  m_params.period_ticks[isSlew][axis]);

    if (isSlew)
      if ((get_raw_status(axis) & 0x1) == 1)
      {
        ctx.log<INFO>("%s(%u): updating speed\n", __func__, axis);
        start_raw_tracking(axis, m_params.motorDirection[isSlew][axis],
                              m_params.period_ticks[isSlew][axis],
                              m_params.motorMode[isSlew][axis], true);
      }
    return true;
  }

  bool set_init(uint8_t axis, bool val)
  {
    if (!check_axis_id(axis, __func__)) return false;
    m_params.initialized[axis] = val;
    return true; 
  }
  bool get_init(uint8_t axis)
  {
    if (!check_axis_id(axis, __func__)) return false;
    return m_params.initialized[axis];
  }
  bool set_backlash_period(uint8_t axis, uint32_t ticks)
  {
    if (!check_axis_id(axis, __func__)) return false;
    uint32_t period_usec = (uint32_t)((ticks  * fclk0_period_us) );
    if (ticks > m_params.maxPeriod[axis] ||
        ticks < m_params.minPeriod[axis]) {
      ctx.log<ERROR>("%s(%u): period out of range %9.5f usec (%u ticks)\n",
                     __func__, axis, period_usec, ticks);
      return false;
    }
    m_params.backlash_period_usec[axis] = period_usec;
    m_params.backlash_ticks[axis] = ticks;
    ctx.log<INFO>(
        "%s(%u): backlash period set to %9.5f us (%u ticks) \n",
        __func__, axis, period_usec, ticks);
    return true; 
  }
  bool set_backlash_cycles(uint8_t axis, uint32_t cycles)
  {
    if (!check_axis_id(axis, __func__)) return false;
    m_params.backlash_ncycle[axis] = cycles;
    ctx.log<INFO>("%s(%u): %u\n", __func__, axis, cycles);
    return true; 
  }
  uint32_t get_raw_status(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    if (axis == 0)
      return stepper.get_status<0>();
    else
      return stepper.get_status<1>();
  }
  uint32_t get_raw_stepcount(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    if (axis == 0)
      return stepper.get_stepcount<0>();
    else
      return stepper.get_stepcount<1>();
  }

  bool enable_backlash(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return false;
    if (axis == 0)
      stepper.set_backlash<0>(m_params.backlash_ticks[axis], m_params.backlash_ncycle[axis], m_params.backlash_mode[axis]);
    else
      stepper.set_backlash<1>(m_params.backlash_ticks[axis], m_params.backlash_ncycle[axis], m_params.backlash_mode[axis]);
    return true;
  }
  bool assign_raw_backlash(uint8_t axis, uint32_t ticks, uint32_t ncycles, uint8_t mode) {
    if (!check_axis_id(axis, __func__)) return false;
    if (axis == 0)
      stepper.set_backlash<0>(ticks, ncycles, mode);
    else
      stepper.set_backlash<1>(ticks, ncycles, mode);
    return true;
  }
  bool disable_raw_backlash(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return false;
    if (axis == 0)
      stepper.disable_backlash<0>();
    else
      stepper.disable_backlash<1>();
    return true;
  }
  bool disable_raw_tracking(uint8_t axis, bool instant) {
    if (!check_axis_id(axis, __func__)) return false;
    if (axis == 0)
      stepper.disable_tracking<0>(instant);
    else
      stepper.disable_tracking<1>(instant);
    return true;
  }
  bool start_tracking(uint8_t axis, bool isSlew) {
      return start_raw_tracking(axis, m_params.motorDirection[isSlew][axis],
                              m_params.period_ticks[isSlew][axis],
                              m_params.motorMode[isSlew][axis]);
  }
  bool start_raw_tracking(uint8_t axis, bool isForward, uint32_t periodticks,
                          uint8_t mode, bool update = false) {
    if (!check_axis_id(axis, __func__)) return false;
    if (axis == 0)
      stepper.enable_tracking<0>(isForward, periodticks, mode, update);
    else
      stepper.enable_tracking<1>(isForward, periodticks, mode, update);
    return true;
  }
  bool park_raw_telescope(uint8_t axis, bool isForward, uint32_t period_ticks,
                          uint8_t mode, bool use_accel) {
    if (!check_axis_id(axis, __func__)) return false;
    if (axis == 0)
      stepper.set_park<0>(isForward, period_ticks, mode, use_accel);
    else
      stepper.set_park<1>(isForward, period_ticks, mode, use_accel);
    return true;
  }
  bool send_command(uint8_t axis, bool isSlew, bool use_accel, bool isGoto) {
      return send_raw_command(axis, m_params.motorDirection[isSlew][axis],
                             isGoto ? m_params.GotoTarget[axis] : m_params.GotoNCycles[axis],
                             m_params.period_ticks[isSlew][axis],
                             m_params.motorMode[isSlew][axis], isGoto, use_accel);
  }
  bool send_raw_command(uint8_t axis, bool isForward, uint32_t ncycles,
                        uint32_t period_ticks, uint8_t mode, bool isGoTo, bool use_accel) {
    if (!check_axis_id(axis, __func__)) return true;
    if (axis == 0)
      stepper.set_command<0>(isForward, ncycles, period_ticks, mode, isGoTo, use_accel);
    else
      stepper.set_command<1>(isForward, ncycles, period_ticks, mode, isGoTo, use_accel);
    return true;
  }
  bool cancel_raw_command(uint8_t axis, bool instant) {
    if (!check_axis_id(axis, __func__)) return false;
    if (axis == 0)
      stepper.cancel_command<0>(instant);
    else
      stepper.cancel_command<1>(instant);
    return true;
  }
  bool set_current_position(uint8_t axis, uint32_t val) {
    if (!check_axis_id(axis, __func__)) return false;
    if (val > m_params.stepPerRotation[axis]) {
      ctx.log<ERROR>("%s(%u): out of range %u; stepPerRotation=%u\n", __func__,
                     axis, val, m_params.stepPerRotation[axis]);
      return false;
    } else if (val == m_params.stepPerRotation[axis])
      val = 0;
    if (axis == 0) stepper.set_current_position<0>(val);
    else stepper.set_current_position<1>(val);
    return true;
  }
  uint32_t get_goto_increment(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    ctx.log<INFO>("%s(%u): %u\n", __func__, axis, m_params.GotoNCycles[axis]);
    return m_params.GotoNCycles[axis];
  }
  bool set_goto_increment(uint8_t axis, uint32_t ncycles) {
    if (!check_axis_id(axis, __func__)) return false;
    ctx.log<INFO>("%s(%u): %u\n", __func__, axis, ncycles);
    m_params.GotoNCycles[axis] = ncycles % m_params.stepPerRotation[axis];
    return true;
  }
  uint32_t get_goto_target(uint8_t axis) {
    if (!check_axis_id(axis, __func__)) return 0xFFFFFFFF;
    ctx.log<INFO>("%s(%u): %u\n", __func__, axis, m_params.GotoTarget[axis]);
    return m_params.GotoTarget[axis];
  }
  bool set_goto_target(uint8_t axis, uint32_t target) {
    if (!check_axis_id(axis, __func__)) return false;
    if (target > m_params.stepPerRotation[axis]) {
      ctx.log<ERROR>("%s(%u) val out of range %u (max=%u)\n", __func__, axis,
                     target, m_params.stepPerRotation[axis]);
      return false;
    }
    ctx.log<INFO>("%s(%u): %u\n", __func__, axis, target);
    m_params.GotoTarget[axis] = target;
    return true;
  }


 private:
  Context& ctx;
  Memory<mem::control>& ctl;
  Memory<mem::status>& sts;
  Drv8825& stepper;

  parameters m_params;

  bool check_axis_id(uint8_t axis, std::string str) {
    if (axis > 1) {
      ctx.log<ERROR>("ASCOMInteface: %s- Invalid axis: %u\n", str, axis);
      return false;
    }
    ctx.log<INFO>("ASCOMInteface: %s\n", str);
    return true;
  }
};

#endif  // __DRIVERS_LED_BLINKER_HPP__
