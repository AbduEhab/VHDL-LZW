----------------------------------------------------------------------------------
-- Engineer: Abdelrahman Ehab Ahmed Attia
-- 
-- Create Date:    21:23:30 08/13/2021 
-- Module Name:    Decoder - Behavioral 
-- Project Name: VHDL-LZW
-- Target Devices: Spartin-3
--
-- Revision: 
-- Revision 0.26
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

USE IEEE.NUMERIC_STD.ALL;

ENTITY Decoder IS
    PORT (
        clk : IN STD_LOGIC; -- system clock
        decodingSequence : IN STD_LOGIC_VECTOR (127 DOWNTO 0); -- sequence to encode
        outputSequence : OUT STD_LOGIC_VECTOR (127 DOWNTO 0); -- encoded sequence
        isComplete : OUT STD_LOGIC; -- states if encoding is complete
        isSuccessful : OUT STD_LOGIC -- states if encoding was successful
    );
END Decoder;

ARCHITECTURE Behavioral OF Decoder IS

    COMPONENT HashMap IS
        GENERIC (
            bitSize : INTEGER := 9;
            valueSize : INTEGER := 9
        );

        PORT (
            clk : IN STD_LOGIC; -- system clock
            key : IN INTEGER RANGE 0 TO (2 ** bitSize) - 1; -- key to assign value to
            value : IN INTEGER RANGE 0 TO (2 ** valueSize) - 1; -- value to be assigned
            dataDirection : IN STD_LOGIC; -- writeToMap (0), readFromMap (1)
            enable : IN STD_LOGIC; -- Enable signal
            valueFound : OUT STD_LOGIC; -- states if the value was found or not
            isFull : OUT STD_LOGIC; -- states if the map is full
            currentSize : OUT INTEGER RANGE 0 TO 2 ** bitSize; -- states the current amount of stored elements
            output : OUT INTEGER RANGE 0 TO (2 ** valueSize) - 1
        );
    END COMPONENT;

    SIGNAL sKey : INTEGER RANGE 0 TO 127;
    SIGNAL sValue : INTEGER RANGE 0 TO (2 ** 16) - 1;
    SIGNAL returnedValue : INTEGER RANGE 0 TO (2 ** 16) - 1;
    SIGNAL valueFound : STD_LOGIC;
    SIGNAL isFull : STD_LOGIC := '0';
    SIGNAL currentSize : INTEGER RANGE 0 TO(2 ** 7) - 1;
    SIGNAL dataDirection : STD_LOGIC;
    SIGNAL enable : STD_LOGIC := '0';

    SIGNAL repeatedSequence : STD_LOGIC := '0';

BEGIN

    directory : HashMap GENERIC MAP(8, 16) PORT MAP(clk, sKey, sValue, dataDirection, enable, valueFound, isFull, currentSize, returnedValue);

    PROCESS (decodingSequence)

        VARIABLE counter : INTEGER RANGE 0 TO 63;
        VARIABLE sOutputSequence : STD_LOGIC_VECTOR (127 DOWNTO 0);
        VARIABLE sCurrBuffer : STD_LOGIC_VECTOR (127 DOWNTO 0);
        VARIABLE sNextBuffer : STD_LOGIC_VECTOR (127 DOWNTO 0);

    BEGIN
        FOR i IN 0 TO 128/8 LOOP

            enable <= '0';

            IF rising_edge(clk) THEN

                IF to_integer(unsigned(decodingSequence(127 - (i) * 9 DOWNTO 127 - (i) * 9))) = 1 THEN

                    dataDirection <= '1';
                    skey <= to_integer(unsigned(decodingSequence(127 - (i) * 9 DOWNTO (127 - (i) * 9) - 9)));
                    enable <= '1';
                    sCurrBuffer := STD_LOGIC_VECTOR(to_signed(to_integer(unsigned(sCurrBuffer)) + returnedValue, 128));

                    ELSE
                    sCurrBuffer := STD_LOGIC_VECTOR(to_signed(to_integer(unsigned(sCurrBuffer)) + to_integer(unsigned(decodingSequence(127 - (i) * 9 DOWNTO (127 - (i) * 9) - 8))), 128));

                END IF;

                IF i = 0 THEN

                    sNextBuffer := STD_LOGIC_VECTOR(to_signed(to_integer(unsigned(sNextBuffer)) + to_integer(unsigned(decodingSequence(127 - (i + 1) * 9 DOWNTO (127 - (i + 1) * 9) - 8))), 128));

                    dataDirection <= '0';
                    skey <= counter;
                    sValue <= to_integer(unsigned(sCurrBuffer)) + to_integer(unsigned(sNextBuffer));
                    enable <= '1';

                    sOutputSequence := sCurrBuffer;

                    sCurrBuffer := (OTHERS => '0');
                    sNextBuffer := (OTHERS => '0');

                    NEXT;
                END IF;

                IF i = (128/8) - 1 THEN

                    sOutputSequence := STD_LOGIC_VECTOR(to_signed(to_integer(unsigned(sOutputSequence)) + to_integer(unsigned(sCurrBuffer)), 128));
                    EXIT;
                END IF;

                IF to_integer(unsigned(decodingSequence(127 - (i + 1) * 9 DOWNTO 127 - (i + 1) * 9))) = 1 THEN

                    dataDirection <= '1';
                    skey <= to_integer(unsigned(decodingSequence(127 - (i + 1) * 9 DOWNTO (127 - (i + 1) * 9) - 9)));
                    enable <= '1';
                    sNextBuffer := STD_LOGIC_VECTOR(to_signed(to_integer(unsigned(sNextBuffer)) + returnedValue, 128));

                    ELSE
                    sNextBuffer := STD_LOGIC_VECTOR(to_signed(to_integer(unsigned(sNextBuffer)) + to_integer(unsigned(decodingSequence(127 - (i + 1) * 9 DOWNTO (127 - (i + 1) * 9) - 8))), 128));

                END IF;

                dataDirection <= '0';
                skey <= counter;
                sValue <= to_integer(unsigned(sCurrBuffer & sNextBuffer(127 DOWNTO 119)));
                enable <= '1';

                sOutputSequence := STD_LOGIC_VECTOR(to_signed(to_integer(unsigned(sOutputSequence)) + to_integer(unsigned(sCurrBuffer)), 128));

                sCurrBuffer := (OTHERS => '0');
                sNextBuffer := (OTHERS => '0');

            END IF;
        END LOOP;

        outputSequence <= sOutputSequence;

    END PROCESS;
END Behavioral;