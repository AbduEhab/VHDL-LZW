----------------------------------------------------------------------------------
-- Engineer: Abdelrahman Ehab Ahmed Attia
-- 
-- Create Date:    11:13:58 02/07/2021 
-- Module Name:    HashMap - Behavioral 
-- Project Name: VHDL-LZW
-- Target Devices: Spartin-3
--
-- Revision: 
-- Revision 0.9

----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY HashMap IS
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
END HashMap;

ARCHITECTURE Behavioral OF HashMap IS

	COMPONENT Ram IS

		GENERIC (
			wordLength : INTEGER := 3;
			ramSize : INTEGER := 3
		);

		PORT (
			enable : IN STD_LOGIC;
			data : IN INTEGER RANGE 0 TO (2 ** wordLength) - 1;
			address : IN INTEGER RANGE 0 TO (2 ** ramSize) - 1;
			dataDirection : IN STD_LOGIC; -- Write(0), Read(1)
			output : OUT INTEGER RANGE 0 TO (2 ** wordLength) - 1
		);

	END COMPONENT;

	SIGNAL full : STD_LOGIC := '0';
	SIGNAL ramEnable : STD_LOGIC := '0';
	SIGNAL positionMapEnable : STD_LOGIC := '0';
	SIGNAL ramValue : INTEGER RANGE 0 TO (2 ** valueSize) - 1 := 0;
	SIGNAL ramreturnedValue : INTEGER RANGE 0 TO (2 ** valueSize) - 1 := 0;
	SIGNAL positionMapValue : INTEGER RANGE 0 TO 1;
	SIGNAL ramAddress : INTEGER RANGE 0 TO (2 ** bitSize) - 1 := 0;
	SIGNAL ramDataDirection : STD_LOGIC := '0';
	SIGNAL positionState : INTEGER RANGE 0 TO 1 := 0;

BEGIN

	valueArray : Ram
	GENERIC MAP(
		valueSize,
		bitSize
	)

	PORT MAP(
		ramEnable,
		ramValue,
		ramAddress,
		ramDataDirection,
		output
	);

	positionMap : Ram
	GENERIC MAP(
		1,
		bitSize
	)
	PORT MAP(
		positionMapEnable,
		positionMapValue,
		ramAddress,
		ramDataDirection,
		positionState
	);

	MainFunc : PROCESS (clk) IS

		VARIABLE counter : INTEGER;

	BEGIN

		positionMapEnable <= '0';
		ramEnable <= '0';

		IF rising_edge(clk) AND enable = '1' AND full = '0' THEN

			ramValue <= value;
			positionMapEnable <= '1';

			IF enable = '1' AND full = '0' THEN

				positionMapEnable <= '0';

				CASE dataDirection IS

					WHEN '0' => -- if data is to be writen to the map

						ramValue <= value;
						ramDataDirection <= '0';

						positionMapValue <= 1;

						-- make sure that key was not used before
						IF positionState = 0 THEN -- if key is unique

							-- associate value with key
							ramEnable <= '1';

							-- make key non-unique
							-- positionMapEnable <= '1';

							valueFound <= '0'; -- output that the key was accepted
							currentSize <= counter + 1; -- output current size
							counter := counter + 1; -- increase size

						ELSE -- if key is non-unique

							currentSize <= counter; -- output current size
							valueFound <= '1'; -- output that the key was rejected (key is non-unique)

						END IF;

						-- update full signal and output if the Hashmap is full
						IF counter >= 2 ** bitSize THEN
							full <= '1';
							isFull <= '1';
						ELSE
							full <= '0';
							isFull <= '0';
						END IF;

					WHEN '1' => -- if data is to be read from the map

						ramAddress <= key;
						ramDataDirection <= '1';

						IF positionState = 0 THEN -- if key was not used before

							valueFound <= '0'; -- output that the key was rejected (key is unique)
							currentSize <= counter; -- output current size

						ELSE -- if key is non-unique

							-- output the requested value
							-- ramEnable <= '1';

							valueFound <= '1'; -- output that the key was accepted
							currentSize <= counter; -- output current size

						END IF;

						-- update full signal and output if the Hashmap is full
						IF counter >= 2 ** bitSize THEN
							full <= '1';
							isFull <= '1';
						ELSE
							full <= '0';
							isFull <= '0';
						END IF;

					WHEN OTHERS =>
				END CASE;
				ELSE
				valueFound <= '1'; -- output that the key was rejected
				isFull <= '1'; -- output that the map is full
				currentSize <= counter; -- output current size
			END IF;
		END IF;

	END PROCESS MainFunc;
END Behavioral;