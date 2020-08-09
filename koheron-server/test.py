#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
from koheron import command, connect
import time
import pdb

class SkyTrackerInterface(object):
    def __init__(self, client):
        self.client = client

    # setter
    @command()
    def set_led_pwm(self, value):
        return self.client.recv_bool()
    @command()
    def set_backlash(self, axis, period_usec, ncycles, mode):
        return self.client.recv_bool()
    @command()
    def set_motor_mode(self, axis, isSlew, mode):
        return self.client.recv_bool()
    @command()
    def set_speed_ratio(self, axis, isSlew, isForward):
        return self.client.recv_bool()
    @command()
    def set_motor_highspeedmode(self, axis, isSlew, isHighSpeed):
        return self.client.recv_bool()
    @command()
    def set_motor_direction(self, axis, isSlew, isForward):
        return self.client.recv_bool()
    @command()
    def set_steps_per_rotation(self, axis, val_us):
        return self.client.recv_bool()
    @command()
    def set_current_position(self, axis, val):
        return self.client.recv_bool()
    @command()
    def set_min_period(self, axis, val_us):
        return self.client.recv_bool()
    @command()
    def set_max_period(self, axis, val_us):
        return self.client.recv_bool()
    @command()
    def set_motor_period_ticks(self, axis, isSlew, val):
        return self.client.recv_bool()
    @command()
    def set_motor_period_usec(self, axis, isSlew, val):
        return self.client.recv_bool()
    @command()
    def set_goto_target(self, axis, val):
        return self.client.recv_bool()
    @command()
    def set_goto_increment(self, axis, val):
        return self.client.recv_bool()
    # getters
    @command()
    def get_version(self):
        return self.client.recv_uint32()
    @command()
    def get_steps_per_rotation(self, axis):
        return self.client.recv_uint32()
    @command()
    def get_speed_ratio(self, axis, isSlew):
        return self.client.recv_double()
    @command()
    def get_backlash_period_ticks(self, axis):
        return self.client.recv_uint32()
    @command()
    def get_backlash_period_usec(self, axis):
        return self.client.recv_double()
    @command()
    def get_backlash_ncycles(self, axis):
        return self.client.recv_uint32()
    @command()
    def get_motor_highspeedmode(self, axis, isSlew):
        return self.client.recv_bool()
    @command()
    def get_motor_mode(self, axis, isSlew):
        return self.client.recv_uint32()
    @command()
    def get_motor_direction(self, axis, isSlew):
        return self.client.recv_bool()
    @command()
    def get_min_period_ticks(self, axis):
        return self.client.recv_uint32()
    @command()
    def get_max_period_ticks(self, axis):
        return self.client.recv_uint32()
    @command()
    def get_motor_period_usec(self, axis, isSlew):
        return self.client.recv_double()
    @command()
    def get_motor_period_ticks(self, axis, isSlew):
        return self.client.recv_uint32()
    @command()
    def get_raw_stepcount(self, axis):
        return self.client.recv_uint32()
    @command()
    def get_raw_status(self, axis):
        return self.client.recv_uint32()
    @command()
    def get_goto_increment(self, axis):
        return self.client.recv_uint32()
    @command()
    def get_goto_target(self, axis):
        return self.client.recv_uint32()

    # command
    @command()
    def enable_backlash(self, axis):
        return self.client.recv_bool()
    @command()
    def assign_raw_backlash(self, axis, ticks, ncycles, mode):
        return self.client.recv_bool()
    @command()
    def disable_raw_backlash(self, axis):
        return self.client.recv_bool()
    @command()
    def start_raw_tracking(self, isForward, periodticks, mode):
        return self.client.recv_bool()
    @command()
    def disable_raw_tracking(self, axis, instant):
        return self.client.recv_bool()
    @command()
    def send_raw_command(self, axis, isForward, ticks, mode, isGoTo, use_accel):
        return self.client.recv_bool()
    @command()
    def park_raw_telescope(self, axis, isForward, ticks, mode, use_accel):
        return self.client.recv_bool()
    @command()
    def cancel_raw_command(self, axis, instant):
        return self.client.recv_bool()


    # skywathcer interface
    @command("ASCOMInterface")
    def SwpCmdInitialize(self, axis):
        return self.client.recv_bool()
    @command("ASCOMInterface")
    def SwpGetBoardVersion(self):
        return self.client.recv_uint32()
    @command("ASCOMInterface")
    def SwpGetGridPerRevolution(self, axis):
        return self.client.recv_uint32()
    @command("ASCOMInterface")
    def SwpGetTimerInterruptFreq(self):
        return self.client.recv_uint32()
    @command("ASCOMInterface")
    def SwpGetHighSpeedRatio(self, axis):
        return self.client.recv_double()
    @command("ASCOMInterface")
    def SwpCmdStopAxis(self, axis, instant):
        return self.client.recv_bool()
    @command("ASCOMInterface")
    def SwpSetAxisPosition(self, axis, value):
        return self.client.recv_bool()
    @command("ASCOMInterface")
    def SwpGetAxisPosition(self, axis):
        return self.client.recv_uint32()
    @command("ASCOMInterface")
    def SwpSetMotionModeDirection(self, axis, isSlew, isForward, isHighSpeed):
        return self.client.recv_bool()
    @command("ASCOMInterface")
    def SwpSetGotoTarget(self, axis, targt):
        return self.client.recv_bool()
    @command("ASCOMInterface")
    def SwpSetGotoTargetIncrement(self, axis, ncycles):
        return self.client.recv_bool()
    @command("ASCOMInterface")
    def SwpSetStepPeriod(self, axis, isSlew, period_usec):
        return self.client.recv_bool()
    @command("ASCOMInterface")
    def SwpCmdStartMotion(self, axis, isSlew, use_accel, isGoto):
        return self.client.recv_bool()
    @command("ASCOMInterface")
    def SwpSetHomePosition(self, axis, period_usec):
        return self.client.recv_bool()
    @command("ASCOMInterface")
    def SwpGetAuxEncoder(self, axis):
        return self.client.recv_uint32()
    @command("ASCOMInterface")
    def SwpSetFeature(self, axis, cmd):
        return self.client.recv_bool()
    @command("ASCOMInterface")
    def SwpGetFeature(self, axis):
        return self.client.recv_uint32()

    def Initialize(self):
        for i in range(0, 2):
            print('\n\nset_min_period{0} : {1}'.format(i, self.set_min_period(i, 15)))
            print('set_led_pwm{0} : {1}'.format(i, self.set_led_pwm(100)))
            print('set_max_period{0} : {1}'.format(i, self.set_max_period(i, 268435.0)))
            print('set_backlash{0} : {1}'.format(i, self.set_backlash(i, 15.1, 127, 7)))
            print('set_steps_per_rotation{0} : {1}'.format(i, self.set_steps_per_rotation(i, 200*32*144*5)))
            print('set_current_position{0} : {1}'.format(i, self.set_current_position(i, 0x0)))
            print('set_goto_target{0} : {1}'.format(i, self.set_goto_target(i, 200*32)))
            print('set_goto_increment{0} : {1}'.format(i, self.set_goto_increment(i, 200*32)))
            print('==========================================')
            for j in range (0, 2):
#                print('set_motor_mode{0}-{1} : {2}'.format(i, j, self.set_motor_mode(i, j, 7)))
                print('set_speed_ratio{0}-{1} : {2}'.format(i, j, self.set_speed_ratio(i, j, 1)))
                print('set_motor_highspeedmode{0}-{1} : {2}'.format(i, j, self.set_motor_highspeedmode(i, j, True)))
                print('set_motor_direction{0}-{1} : {2}'.format(i, j, self.set_motor_direction(i, j, 0)))
                print('set_motor_period_usec{0}-{1} : {2}'.format(i, j, self.set_motor_period_usec(i, j, 15)))

    def PrintSpeed(self):
        for i in range (0, 2):
            for j in range (0, 2):
                print('get_motor_direction{0}-{1}: {2}'.format(i, j, self.get_motor_direction(i, j)))
                print('get_motor_period_usec{0}-{1}: {2}'.format(i, j, self.get_motor_period_usec(i, j)))

    def PrintAll(self):
        print("get_version: {0}".format(self.get_version()))
        for i in range (0, 2):
            print('\n\nget_backlash_period{0}: {1}'.format(i, self.get_backlash_period_ticks(i)))
            print('get_backlash_period_usec{0}: {1}'.format(i, self.get_backlash_period_usec(i)))
            print('get_backlash_ncycles{0}: {1}'.format(i, self.get_backlash_ncycles(i)))
            print('get_steps_per_rotation{0}: {1}'.format(i, self.get_steps_per_rotation(i)))
            print('get_max_period{0}: {1}'.format(i, self.get_max_period_ticks(i)))
            print('get_min_period{0}: {1}'.format(i, self.get_min_period_ticks(i)))
            print('get_raw_status{0}: {1}'.format(i, self.get_raw_status(i)))
            print('get_raw_stepcount{0}: {1}'.format(i, self.get_raw_stepcount(i)))
            print('get_goto_increment{0}: {1}'.format(i, self.get_goto_increment(i)))
            print('get_goto_target{0}: {1}'.format(i, self.get_goto_target(i)))
            print('=========================')
            for j in range (0, 2):
                print('get_spped_ratio{0}-{1}: {2}'.format(i, j, self.get_speed_ratio(i, j)))
                print('get_motor_highspeedmode{0}-{1}: {2}'.format(i, j, self.get_motor_highspeedmode(i, j)))
                print('get_motor_mode{0}-{1}: {2}'.format(i, j, self.get_motor_mode(i, j)))
                print('get_motor_direction{0}-{1}: {2}'.format(i, j, self.get_motor_direction(i, j)))
                print('get_motor_period_usec{0}-{1}: {2}'.format(i, j, self.get_motor_period_usec(i, j)))
                print('get_motor_period_ticks{0}-{1}: {2}'.format(i, j, self.get_motor_period_ticks(i, j)))

    def apply_siderail(self, axis):
        SKYWATCHER_STELLAR_DAY = 86164.098903691
        SKYWATCHER_STELLAR_SPEED = 15.041067179



if __name__ == '__main__':
    host = os.getenv('HOST','192.168.1.122')
    client = connect(host, name='mars_star_tracker')
    driver = SkyTrackerInterface(client)
    driver.Initialize()
    driver.PrintAll()
    driver.cancel_raw_command(0, False)
    driver.cancel_raw_command(1, False)
    driver.enable_backlash(0)
    driver.enable_backlash(1)

    print('Disable tracking0 {0}'.format(driver.disable_raw_tracking(0, False)))
    print('Disable tracking1 {0}'.format(driver.disable_raw_tracking(1, False)))
    print('Disable Cmd0 {0}'.format(driver.cancel_raw_command(0, True)))
    print('Disable Cmd1 {0}'.format(driver.cancel_raw_command(1, True)))
    time.sleep(1)
    driver.PrintAll()
    time.sleep(1)
    print('Start Command0 {0}'.format(driver.SwpCmdStartMotion(0, True, True, True)))
    print('Start Command1 {0}'.format(driver.SwpCmdStartMotion(1, True, True, True)))
    time.sleep(3)
    driver.PrintAll()




