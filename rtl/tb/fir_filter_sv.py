import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
import math

# Function for generating test vectors
def gen_test(BW, coeff_vec):
    data_in = [n*10 for n in range(1000)]
    data_out = [0 for n in range(1000)]
    MAX_VAL = 2**(BW-1)-1
    MIN_VAL = -2**(BW-1)
    for k in range(4, 1000):
        filt_out_shift = math.floor((data_in[k-1]*coeff_vec[0] + data_in[k-2]*coeff_vec[1] + data_in[k-3]*coeff_vec[2] + data_in[k-4]*coeff_vec[3])/2**16)
        if (filt_out_shift > MAX_VAL):
            filt_out = MAX_VAL
        elif (filt_out_shift < MIN_VAL):
            filt_out = MIN_VAL
        else:
            filt_out = filt_out_shift
        data_out[k] = filt_out_shift
    return data_in, data_out

async def reset(dut):
    dut.i_rstb.value = 1
    await Timer(1, units = "ns")
    dut.i_rstb.value = 0
    await Timer(1, units = "ns")
    dut.i_rstb.value = 1
    return

@cocotb.test()
async def test_moving_average(dut):
    coeff_vec = [256, -256, 1023, -2000]
    [data_in, data_out] = gen_test(16, coeff_vec)
    dut.i_data.value = 0
    dut.i_coeff0.value = coeff_vec[0]
    dut.i_coeff1.value = coeff_vec[1]
    dut.i_coeff2.value = coeff_vec[2]
    dut.i_coeff3.value = coeff_vec[3]
    cocotb.start_soon(Clock(dut.i_clk, 1, units = "ns").start())
    await reset(dut)
    for n in range(len(data_in)):
        await FallingEdge(dut.i_clk)
        dut.i_data.value = int(data_in[n])
        if (n > 8):
            assert dut.o_data.value.signed_integer==data_out[n]
