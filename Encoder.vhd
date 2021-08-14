----------------------------------------------------------------------------------
-- Engineer: Abdelrahman Ehab Ahmed Attia
-- 
-- Create Date:    10:38:42 08/02/2021 
-- Module Name:    Encoder - Behavioral 
-- Project Name: VHDL-LZW
-- Target Devices: Spartin-3
--
-- Revision: 
-- Revision 0.32
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Encoder IS
    PORT (
        clk : IN STD_LOGIC; -- system clock
        encodingSequence : IN STD_LOGIC_VECTOR (127 DOWNTO 0); -- sequence to encode
        outputSequence : OUT STD_LOGIC_VECTOR (127 DOWNTO 0); -- encoded sequence
        isComplete : OUT STD_LOGIC; -- states if encoding is complete
        isSuccessful : OUT STD_LOGIC -- states if encoding was successful
    );
END Encoder;

ARCHITECTURE Structural OF Encoder IS

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
    SIGNAL sBuffer : STD_LOGIC_VECTOR (127 DOWNTO 0);
    SIGNAL repeatedSequence : STD_LOGIC := '0';

BEGIN

    directory : HashMap GENERIC MAP(9, 16) PORT MAP(clk, sKey, sValue, dataDirection, enable, valueFound, isFull, currentSize, returnedValue);

    PROCESS (encodingSequence)

        VARIABLE counter : INTEGER RANGE 0 TO 63;
        VARIABLE bufferSize : INTEGER RANGE 0 TO 63;
        VARIABLE sOutputSequence : STD_LOGIC_VECTOR (127 DOWNTO 0);

    BEGIN

        FOR i IN 0 TO 128/8 LOOP

            IF rising_edge(clk) THEN

                enable <= '0';

                IF isFull = '0' THEN
                    IF (repeatedSequence = '0') THEN
                        sBuffer <= sBuffer & '0' & encodingSequence(127 - i * 8 DOWNTO (127 - i * 8) - 8);
                        bufferSize := bufferSize + 1;
                    END IF;

                    IF i = 0 THEN
                        sBuffer <= sBuffer & '0' & encodingSequence(127 - (i + 1) * 8 DOWNTO (127 - (i + 1) * 8) - 8);
                        bufferSize := bufferSize + 1;
                        sKey <= to_integer(unsigned(sBuffer));
                        dataDirection <= '0';
                        sValue <= counter;
                        counter := counter + 1;
                        enable <= '1';
                        sOutputSequence := sOutputSequence & sBuffer(127 DOWNTO 127 - (bufferSize * i * 8) + 8);
                        bufferSize := 0;
                        NEXT;
                    END IF;

                    IF i = (128/8) - 1 THEN
                        sKey <= to_integer(unsigned(sBuffer(127 DOWNTO 127 - (bufferSize * i * 8) + 8)));
                        enable <= '1';
                        IF valueFound = '1' THEN
                            enable <= '0';
                            sOutputSequence := sOutputSequence & sBuffer(127 DOWNTO 127 - (bufferSize * i * 8) + 8);
                            ELSE

                            sKey <= to_integer(unsigned(sBuffer(127 DOWNTO 127 - (bufferSize * i * 8) + 8)));
                            enable <= '1';
                            sOutputSequence := sOutputSequence & STD_LOGIC_VECTOR(to_signed(returnedValue, 16)) & sBuffer(127 - (bufferSize * i * 8) DOWNTO 127 - (bufferSize * i * 8) + 8);

                        END IF;

                        EXIT;
                    END IF;

                END IF;

                IF repeatedSequence = '1' THEN
                    sBuffer <= sBuffer & '0' & encodingSequence(127 - (i + 1) * 8 DOWNTO (127 - (i + 1) * 8) - 8);

                    sKey <= to_integer(unsigned(sBuffer(127 DOWNTO 127 - (bufferSize * i * 8) + 8)));
                    enable <= '1';

                    IF valueFound = '1' THEN
                        NEXT;

                        ELSE
                        enable <= '0';

                        sBuffer <= sBuffer & encodingSequence(127 - (i + 1) * 8 DOWNTO (127 - (i + 1) * 8) - 8);
                        bufferSize := bufferSize + 1;
                        sKey <= to_integer(unsigned(sBuffer));
                        dataDirection <= '0';
                        sValue <= counter;
                        counter := counter + 1;
                        enable <= '1';
                        sOutputSequence := sOutputSequence & sBuffer(127 DOWNTO 127 - (bufferSize * i * 8) + 8);

                        repeatedSequence <= '0';

                    END IF;

                    ELSE
                    sBuffer <= sBuffer & '0' & encodingSequence(127 - (i + 1) * 8 DOWNTO (127 - (i + 1) * 8) - 8);

                    sKey <= to_integer(unsigned(sBuffer(127 DOWNTO 127 - (bufferSize * i * 8) + 8)));
                    enable <= '1';

                    IF valueFound = '1' THEN
                        repeatedSequence <= '1';
                        NEXT;

                        ELSE
                        enable <= '0';
                        sBuffer <= sBuffer & encodingSequence(127 - (i + 1) * 8 DOWNTO (127 - (i + 1) * 8) - 8);
                        bufferSize := bufferSize + 1;
                        sKey <= to_integer(unsigned(sBuffer));
                        dataDirection <= '0';
                        sValue <= counter;
                        counter := counter + 1;
                        enable <= '1';
                        sOutputSequence := sOutputSequence & sBuffer(127 DOWNTO 127 - (bufferSize * i * 8) + 8);
                        sBuffer <= (OTHERS => '0');
                    END IF;

                END IF;

                ELSE
                isComplete <= '1';
                isSuccessful <= '0';
            END IF;
        END LOOP;

        outputSequence <= sOutputSequence;

    END PROCESS;

END Structural;