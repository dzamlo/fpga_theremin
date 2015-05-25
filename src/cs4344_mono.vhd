-- This is a slightly modified version of the cde provided by the professor.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity cs4344_mono is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           audio_in : in STD_LOGIC_VECTOR(15 downto 0);
           done : out std_logic;
           SDOUT : out  STD_LOGIC;
           SCLK : out  STD_LOGIC;
           MCLK : out  STD_LOGIC;
           LRCK : out  STD_LOGIC);
end cs4344_mono;

architecture Behavioral of cs4344_mono is

signal div_cnt: unsigned(9 downto 0);
signal shift_reg_en: std_logic;
signal shift_reg_load: std_logic;
signal shift_reg: std_logic_vector(15 downto 0); 

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst='1' then
                div_cnt<= (others=>'0');
            else
                div_cnt<= div_cnt + 1;
            end if;
        end if;
    end process;
    
    LRCK <= div_cnt(9); -- 50MHz / 1024 = 48.828125 KHz ~= 48KHz
    MCLK <= div_cnt(1); -- 50MHz / 4 = 256x frequencie of LRCK
    
    shift_reg_load <= '1' when div_cnt(8 downto 0) = 0
                          else '0';

    done <= shift_reg_load;
    
    shift_reg_en <= '1' when div_cnt(4 downto 0) = 0
                        else '0';

    SCLK <= div_cnt(4);

    SDOUT <= shift_reg(15);
    
    process(clk)
    begin
        if rising_edge(clk) then
            if rst='1' then
                shift_reg<= (others=>'0');
            elsif shift_reg_load = '1' then
                shift_reg(15 downto 0) <= audio_in;
            elsif shift_reg_en = '1' then
                shift_reg <= shift_reg(14 downto 0) & '0'; 
            end if;
        end if;
    end process;

end Behavioral;
