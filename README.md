# FIR Filter Design and Hardware Implementation

A collection of MATLAB, Simulink, and SystemVerilog implementations of FIR digital filters developed as part of Digital Signal Processing and Digital Communication laboratory work.

The repository covers FIR filter design using the window method, simulation of raised cosine filtering in Simulink, and RTL implementation of FIR-based filters in SystemVerilog.

---

## Repository Structure

```
.
├── Simulink/
│   └── raised_cosine_filter.slx
│
├── matlab/
│   └── fir_window_method_design.m
│
├── rtl/
│   ├── fir_filter.sv
│   └── moving_average.sv
│
├── tb/
│   ├── fir_filter_tb.sv
│   └── moving_average_tb.sv
│
├── LICENSE
└── README.md
```

---

## Features

- FIR low-pass filter design using the window method
- Comparison of Rectangular, Triangular, Hann, Hamming and Blackman windows
- Custom iterative FFT and inverse FFT implementation
- Time-domain FIR filtering using convolution
- Frequency response and performance analysis
- Raised cosine filter modeling in Simulink
- RTL implementation of FIR and Moving Average filters in SystemVerilog
- Functional verification using SystemVerilog testbenches

---

## MATLAB

The MATLAB implementation includes

- Ideal low-pass FIR design
- Window-based coefficient generation
- Custom FFT/IFFT implementation
- FIR filtering of noisy input signals
- Frequency response analysis
- Transition width and stopband attenuation evaluation
- Comparison of multiple window functions

Run

```matlab
fir_window_method_design
```

to generate all plots and analysis.

---

## Simulink

The Simulink model implements a raised cosine filtering system using FIR filter coefficients generated from MATLAB.

The model demonstrates signal filtering and output waveform verification using sinusoidal test signals.

---

## SystemVerilog

RTL modules include

- FIR Filter
- Moving Average Filter

The accompanying testbenches verify functional correctness using simulation.

---

## Tools

- MATLAB
- Simulink
- SystemVerilog

---

## License

This project is released under the MIT License.
