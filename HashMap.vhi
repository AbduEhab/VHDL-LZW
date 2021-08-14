
-- VHDL Instantiation Created from source file HashMap.vhd -- 20:54:45 08/13/2021
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT HashMap
	PORT(
		clk : IN std_logic;
		key : IN std_logic_vector(0 to 8);
		value : IN std_logic_vector(0 to 8);
		dataDirection : IN std_logic;
		enable : IN std_logic;          
		valueFound : OUT std_logic;
		isFull : OUT std_logic;
		currentSize : OUT std_logic_vector(0 to 9);
		output : OUT std_logic_vector(0 to 8)
		);
	END COMPONENT;

	Inst_HashMap: HashMap PORT MAP(
		clk => ,
		key => ,
		value => ,
		dataDirection => ,
		enable => ,
		valueFound => ,
		isFull => ,
		currentSize => ,
		output => 
	);


