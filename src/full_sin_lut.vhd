-- Description: this entity uses the fact that a sinusoidal wave has two symmetries. It uses a LUT 
-- with only a quarter of a sinus wave and builds the rest of the wave by exploiting the symmetries..

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity full_sin_lut is
generic( ADDR_BITS: integer := 11;
         DATA_BITS: integer := 16
       );
port( addr: in std_logic_vector(ADDR_BITS-1 downto 0);
      data: out signed(DATA_BITS-1 downto 0)
    );
end full_sin_lut; 

architecture full_sin_arch of full_sin_lut is
    component sin_lut
    port(
        addr : in std_logic_vector(ADDR_BITS-3 downto 0);          
        data : out signed(DATA_BITS-1 downto 0)
        );
    end component;
    
    signal lut_addr: std_logic_vector(ADDR_BITS-3 downto 0);
    signal lut_data: signed(DATA_BITS-1 downto 0); 
    
    constant last_sin_lut_addr: unsigned(ADDR_BITS-3 downto 0) := to_unsigned(2**(ADDR_BITS-2)-1, ADDR_BITS-2);
    signal addr_sin_lut_inv: std_logic_vector(ADDR_BITS-3 downto 0);
begin

    Inst_sin_lut: sin_lut port map(
        addr => lut_addr,
        data => lut_data
    );
    
    with addr(ADDR_BITS-1) select
       data <= lut_data when '0',
               -lut_data when others;
       
     addr_sin_lut_inv <=  std_logic_vector(last_sin_lut_addr - unsigned(addr(ADDR_BITS-3 downto 0)));
       
    with addr(ADDR_BITS-2) select
       lut_addr <= addr(ADDR_BITS-3 downto 0) when '0',
                   addr_sin_lut_inv when others;

end full_sin_arch;
