<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

A simple serial 16b register (mini SPI) with magic cookie detection is implemented. In addition, a 16bit sigma-delta modulator of 1st or 2nd order is included.

## How to test

- Load the shift register in a serial way.
- Check the magic cookie detection.
- Check the digital output (low- and high-byte) of the loaded data word.
- Check the output voltage of the delta-sigma modulator by using an external RC lowpass filter.

## External hardware

Just a way to set digital inputs is needed. A scope for monitoring output signals would be good. A voltmeter can be used to inspect the DAC output voltage.
