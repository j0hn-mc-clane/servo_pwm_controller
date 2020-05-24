LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.clocks_pkg.ALL;

ENTITY pwm_controller_tb IS
END ENTITY;

ARCHITECTURE test OF pwm_controller_tb IS
    SIGNAL clk : std_logic := '0';
    SIGNAL rst : std_logic;
    SIGNAL set : std_logic;
    SIGNAL servo_clk : std_logic := '0';
    SIGNAL done : std_logic;
    SIGNAL addrdata : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pwm : std_logic;
    SIGNAL end_simulation : BOOLEAN := FALSE;

    COMPONENT PWM_Counter IS
        PORT (
            rst : IN std_logic;
            servo_clk : IN std_logic;
            position : IN std_logic_vector(7 DOWNTO 0);
            pwm : OUT std_logic);
    END COMPONENT;
    COMPONENT PWM_Controller IS
        PORT (
            rst : IN std_logic;
            clk : IN std_logic;
            servo_clk : IN std_logic;
            set : IN std_logic;
            done : OUT std_logic;
            addrdata : IN std_logic_vector(7 DOWNTO 0);
            pwm : OUT std_logic);
    END COMPONENT;

BEGIN

    UUT : PWM_Controller
    PORT MAP(
        rst => rst,
        clk => clk,
        servo_clk => servo_clk,
        set => set,
        done => done,
        addrdata => addrdata,
        pwm => pwm);

    -- Generate clock signals using clocks_pkg
    clock(servo_clk, 1.953125 us, end_simulation);
    clock(clk, 20 ms, end_simulation);

    stimuli_gen : PROCESS
    BEGIN
        REPORT " -- Simulation start --"
            SEVERITY note;
        -- INITIAL
        WAIT UNTIL rising_edge(clk);
        set <= '0';
        rst <= '1';
        WAIT UNTIL rising_edge(clk);
        rst <= '0';
        set <= '1'; -- SET
        addrdata <= "00000001"; -- BROADCAST
        ASSERT done = '1'
        REPORT "Done should remain H if data has not been sent"
            SEVERITY error;
        WAIT UNTIL rising_edge(clk);
        addrdata <= (OTHERS => '0'); -- NOW SEND DATA 00000000
        WAIT UNTIL rising_edge(clk);
        set <= '0'; -- UNSET
        ASSERT done = '0'
        REPORT "Done should be L when building PWM"
            SEVERITY error;
        WAIT UNTIL rising_edge(clk);

        WAIT UNTIL rising_edge(clk);
        ASSERT done = '1'
        REPORT "Done should be H when PWM is built"
            SEVERITY error;
        REPORT "-- Simulation done --"
            SEVERITY note;
        end_simulation <= true;
        WAIT;
    END PROCESS stimuli_gen;
END ARCHITECTURE test;