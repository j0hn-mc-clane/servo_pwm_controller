LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.pwm_pk.ALL;

ENTITY PWM_Controller IS
    PORT (
        rst : IN std_logic;
        clk : IN std_logic;
        servo_clk : IN std_logic;
        set : IN std_logic;
        done : OUT std_logic;
        addrdata : IN std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');
        pwm : OUT std_logic);
END PWM_Controller;

ARCHITECTURE behavioral OF PWM_Controller IS
    COMPONENT PWM_Counter IS
        PORT (
            rst : IN std_logic;
            servo_clk : IN std_logic;
            position : IN std_logic_vector(7 DOWNTO 0);
            pwm : OUT std_logic);
    END COMPONENT;

    SIGNAL addr_is_read : BOOLEAN := FALSE;
    SIGNAL data_is_read : BOOLEAN := FALSE;
    SIGNAL is_addr_servo : BOOLEAN := FALSE;
    SIGNAL data_read : std_logic_vector(7 DOWNTO 0);
    SIGNAL pwm_built : BOOLEAN := FALSE;
BEGIN
    pwm_counter_map : PWM_Counter PORT MAP(
        rst => rst, servo_clk => servo_clk, position => data_read, pwm => pwm
    );

    PROCESS (rst, clk) -- start process on change of rst, clk
    BEGIN
        IF (rst = '1') THEN
            -- HALT 
            is_addr_servo <= FALSE;
            addr_is_read <= FALSE;
            data_is_read <= FALSE;
            data_read <= (OTHERS => '0');
            done <= '1';
        ELSIF rising_edge (clk) THEN
            IF (set = '1') THEN
                -- first clock pulse: read addr
                -- second clock pulse: read data and set done to zero
                IF (addrdata = BROADCAST_ADDR OR addrdata = UNICAST_ADDR) THEN
                    addr_is_read <= TRUE;
                    done <= '0';
                ELSE
                    IF addr_is_read = TRUE THEN
                        -- read data
                        data_is_read <= TRUE;
                        data_read <= addrdata;
                    END IF;
		    IF data_is_read <= TRUE THEN
			done <= '1';
		    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;