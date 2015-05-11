"""Genreate the lookup tables"""
from __future__ import absolute_import, division, print_function
from math import pi, sin


def write_header(f):
    header_str = "library IEEE;\n" \
                 "use IEEE.std_logic_1164.all;\n" \
                 "use IEEE.numeric_std.all;\n"
    f.write(header_str)


def write_entity(f, entity_name, addr_bits, data_bits):
    entity_str = "entity {entity_name} is\n" \
                 "port( addr: in std_logic_vector({addr_bits}-1 downto 0);\n" \
                 "      data: out signed({data_bits}-1 downto 0)\n" \
                 "    );\n"\
                 "end {entity_name};\n"
    entity_str = entity_str.format(entity_name=entity_name,
                                   addr_bits=addr_bits,
                                   data_bits=data_bits)
    f.write(entity_str)


def bin_with_length(v, length):
    bits = bin(v)[2:]
    return "0" * (length - len(bits)) + bits


def write_architecture(f, entity_name, values, addr_bits, data_bits):
    architecture_str_start = "architecture lut_arch of {entity_name} is\n"\
                             "begin\n" \
                             "with addr select data <=\n"
    architecture_str_start = architecture_str_start.format(
        entity_name=entity_name)
    f.write(architecture_str_start)
    for i, value in enumerate(values):
        line_str = "to_signed({value}, {data_bits}) when \"{addr_bin}\",\n"
        line_str = line_str.format(value=value,
                                   data_bits=data_bits,
                                   addr_bin=bin_with_length(i, addr_bits))
        f.write(line_str)

    architecture_str_end = "to_signed(0, {data_bits}) when others;\n"\
                           "end lut_arch;\n"
    architecture_str_end = architecture_str_end.format(data_bits=data_bits)
    f.write(architecture_str_end)


def make_vhdl(filename, entity_name, f, addr_bits, data_bits):
    n = 2**addr_bits
    values = gen(f, n, data_bits)
    with open(filename, "w") as f:
        write_header(f)
        write_entity(f, entity_name, addr_bits, data_bits)
        write_architecture(f, entity_name, values, addr_bits, data_bits)


def gen(f, n, bits=16):
    value_max = 2**(bits - 1) - 1
    for i in range(n):
        value = f(i / float(n - 1))
        yield int(round(value * value_max))


def quarter_sin(i):
    return sin(pi * i / 2)


if __name__ == '__main__':
    # number of samples
    ADDR_BITS = 9
    # number of bits for each value
    DATA_BITS = 16
    make_vhdl("quarter_sin_512_16.vhd", "sin_lut", quarter_sin, 9, DATA_BITS)
