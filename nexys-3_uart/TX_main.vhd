library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    Port ( 
				CLK 		: 	IN  	STD_LOGIC;
				RESET 	: 	IN  	STD_LOGIC;
				DONE		:	IN  	STD_LOGIC;
				SW			:	IN		STD_LOGIC_VECTOR(127 DOWNTO 0);
				UART_TXD	: 	OUT 	STD_LOGIC
				);
end uart_tx;

architecture Behavioral of uart_tx is

SIGNAL	TX_DATA	:	STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	TX_START	:	STD_LOGIC:='0';
SIGNAL	TX_BUSY	:	STD_LOGIC;
SIGNAL	KEY		:	STD_LOGIC:='0';
SIGNAL	count		:	INTEGER RANGE 0 to 201400:=0;
SIGNAL	count1	:	INTEGER RANGE 0 to 128:=127;
SIGNAL	no_bytes	:	INTEGER RANGE 0 to 16:=0;
--SIGNAL	count1	:	STD_LOGIC_VECTOR(7 DOWNTO 0):="00001110";

type StateType is (ST_IDLE,ST_PRE_SEND, ST_SEND, ST_WAIT , ST_STOP);
signal state: StateType:=ST_IDLE;

begin
transmitter : ENTITY work.TX
PORT MAP (
				CLK		=>	CLK,
				START		=>	KEY,
				BUSY		=> TX_BUSY,
				DATA		=> TX_DATA,
				TX_LINE	=> UART_TXD
			);

PROCESS(RESET,CLK)BEGIN

--- the only extra thing added.. remove if design not working
	IF(RESET='1')THEN
		state	<=	ST_IDLE;
		TX_START	<='0';
		KEY		<='0';
		count		<=	0;
		count1	<=	127;
		no_bytes	<=	0;
	ELSIF(CLK'EVENT AND CLK='1') THEN
	
		CASE state is
			WHEN ST_IDLE	=>
								count		<=	0;
								count1	<=	127;
								no_bytes	<=	0;
								TX_START	<='0';
								KEY		<='0';
								IF(DONE='1')THEN
									state	<= ST_PRE_SEND;
								ELSE
									state	<=	ST_IDLE;
								END IF;
			
			WHEN ST_PRE_SEND	=>
								IF (no_bytes<=15)THEN
									TX_START	<='0';
									KEY		<='0';
									state 	<=	ST_SEND;
									TX_DATA	<= SW(count1 DOWNTO count1-7);
									count1	<=	count1-8;
									no_bytes	<=	no_bytes+1;
			
								ELSE
									no_bytes	<=	0;
									count1	<= 0;
									state		<=	ST_STOP;
								END iF;
			WHEN ST_SEND	=>
								TX_START	<='1';
								KEY		<='1';
								state	<= ST_WAIT;
			
			WHEN ST_WAIT	=>
								IF(count<201400)THEN
									state	<=	ST_WAIT;
									TX_START	<='0';
									KEY		<='0';
									count		<=count+1;
								ELSE
									count		<=0;
									state		<=ST_PRE_SEND;
								END IF;
			WHEN ST_STOP	=>
									STATE		<=	ST_IDLE;
									count		<=	0;
								   count1	<=	127;
									no_bytes	<=	0;
									TX_START	<='0';
									KEY		<='0';
														
		END CASE;
	END IF;
END PROCESS;

	
end Behavioral;