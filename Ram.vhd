----------------------------------------------------------------------------------
-- Engineer: Abdelrahman Ehab Ahmed Attia
-- 
-- Create Date:    17:40:10 08/01/2021 
-- Module Name:    Ram - Behavioral 
-- Project Name: VHDL-LZW
-- Target Devices: Spartin-3
--
-- Revision: 
-- Revision 1.0
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- RAM entity
ENTITY Ram IS

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
END ENTITY;

ARCHITECTURE Behavioral OF Ram IS

  TYPE Mamory IS ARRAY (0 TO (2 ** ramSize) - 1) OF INTEGER RANGE 0 TO (2 ** wordLength) - 1;
  SIGNAL memory : Mamory;

BEGIN

  PROCESS (enable)
  BEGIN
    IF (dataDirection = '0' AND enable = '1') THEN
      memory(address) <= data;
      ELSIF (dataDirection = '1' AND enable = '1') THEN
      output <= memory(address);
      ELSE
      output <= 0;
    END IF;
  END PROCESS;

END Behavioral;