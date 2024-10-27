![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Simple SPI Test

(c) 2024 Harald Pretl, Institute for Integrated Circuits, Johannes Kepler University, Linz, Austria

This project implements a simple SPI where the loaded 16b data can be output in 8b chunks (high and low byte). In addition, a magic cookie detection is implemented (an output goes active on detection of 0xCAFE).

In addition, a first- and second-order delta-sigma modulator is implemented create a simple low-frequency voltage output with 16b.

Further, a sine generator with programmable frequency can be used to drive the DS-modulator.

The input and output list documentation can be found in `info.yaml`.
