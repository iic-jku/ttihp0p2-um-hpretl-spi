# SPDX-FileCopyrightText: © 2024 Tiny Tapeout and Harald Pretl, IIC@JKU
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 0.1 us (10 MHz)
    clock = Clock(dut.clk, 0.1, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 3)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Check that cookie not detected
    assert dut.uo_out.value[2] == 0
    
    # Load magic cookie
    load_word = "0xCAFE"
    load_word_bin = format(int(load_word, 16), '016b')
    load_word_bits = [int(bit) for bit in load_word_bin]

    dut._log.info("Loading " + str(load_word_bin))

    # Shift cookie in
    for i in range(16):
        # b0 is clk, b1 is dat, b2 is load, b3 is select
        dut.ui_in.value = 1*0 + 2*load_word_bits[i] + 4*0 + 8*0

        await ClockCycles(dut.clk, 3)

        # b0 is clk, b1 is dat, b2 is load, b3 is select
        dut.ui_in.value = 1*1 + 2*load_word_bits[i] + 4*0 + 8*0

        await ClockCycles(dut.clk, 3)

        assert (dut.uo_out.value & 2) == 0

    # serial register is loaded, now store it
    # b0 is clk, b1 is dat, b2 is load, b3 is select
    dut.ui_in.value = 1*0 + 2*0 + 4*0 + 8*0
    await ClockCycles(dut.clk, 3)
    dut.ui_in.value = 1*0 + 2*0 + 4*1 + 8*0
    await ClockCycles(dut.clk, 3)

    # check magic cookie detection
    dut._log.info("Check magic cookie detection")
    assert (dut.uo_out.value & 2) == 2

    # check output parallel selection
    dut._log.info("Check parallel output")
    dut.ui_in.value = 1*0 + 2*0 + 4*0 + 8*0
    await ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xfe
    dut.ui_in.value = 1*0 + 2*0 + 4*0 + 8*1
    await ClockCycles(dut.clk, 1)
    assert dut.uio_out.value == 0xca

    # Shift 0 in
    for i in range(16):
        # b0 is clk, b1 is dat, b2 is load, b3 is select
        dut.ui_in.value = 1*0 + 2*0 + 4*0 + 8*0

        await ClockCycles(dut.clk, 3)

        # b0 is clk, b1 is dat, b2 is load, b3 is select
        dut.ui_in.value = 1*1 + 2*0 + 4*0 + 8*0

        await ClockCycles(dut.clk, 3)

        assert (dut.uo_out.value & 2) == 2

    # serial register is loaded, now store it
    # b0 is clk, b1 is dat, b2 is load, b3 is select
    dut.ui_in.value = 1*0 + 2*0 + 4*0 + 8*0
    await ClockCycles(dut.clk, 3)
    dut.ui_in.value = 1*0 + 2*0 + 4*1 + 8*0
    await ClockCycles(dut.clk, 3)

    # Wait a few cycles to watch DAC operation
    await ClockCycles(dut.clk, 100)

    # Shift 1 in
    for i in range(16):
        # b0 is clk, b1 is dat, b2 is load, b3 is select
        dut.ui_in.value = 1*0 + 2*1 + 4*0 + 8*0

        await ClockCycles(dut.clk, 3)

        #b0 is clk, b1 is dat, b2 is load, b3 is select
        dut.ui_in.value = 1*1 + 2*1 + 4*0 + 8*0

        await ClockCycles(dut.clk, 3)

        assert (dut.uo_out.value & 2) == 0

    # serial register is loaded, now store it
    # b0 is clk, b1 is dat, b2 is load, b3 is select
    dut.ui_in.value = 1*0 + 2*0 + 4*0 + 8*0
    await ClockCycles(dut.clk, 3)
    dut.ui_in.value = 1*0 + 2*0 + 4*1 + 8*0
    await ClockCycles(dut.clk, 3)

    # Wait a few cycles to watch DAC operation
    await ClockCycles(dut.clk, 100)
