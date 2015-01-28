library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY uart_rx IS
    PORT ( 
				CLK 			: 	IN  	STD_LOGIC;
				RESET 			: 	IN  	STD_LOGIC;
				UART_RXD		: 	IN  	STD_LOGIC;
				DONE			:	OUT	STD_LOGIC;
				DATA_RECV		:	OUT	STD_LOGIC_VECTOR(383 DOWNTO 0)
				);
END uart_rx;

ARCHITECTURE Behavioral OF uart_rx IS

SIGNAL	RX_DATA		:	STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	RX_BUSY		:	STD_LOGIC;

SIGNAL 	count			:	INTEGER	RANGE 0 to 384:=383;
SIGNAL 	count1 		:	INTEGER	RANGE 0 to 49:=0;
SIGNAL 	DATA_SIG		:	STD_LOGIC_VECTOR(383 DOWNTO 0):=(OTHERS=>'0');
SIGNAL 	DATA			:	INTEGER	RANGE 0 to 128:=0;


TYPE STATETYPE IS (ST_WAIT_TO_RECEIVE, ST_START_READ, ST_READ, ST_DONE);
SIGNAL STATE	: STATETYPE	:= ST_WAIT_TO_RECEIVE	;

BEGIN

RECEIVER : ENTITY work.RX
PORT MAP (
				CLK		=>	CLK,		
				RX_LINE	=>	UART_RXD,
				BUSY		=>	RX_BUSY,
				DATA		=>	RX_DATA
			);

PROCESS(RESET,CLK)BEGIN
	IF(RESET='1')THEN
		count1	<= 0;
		count		<= 383;
		DATA		<=	0;
		state	<=	ST_WAIT_TO_RECEIVE;
		DONE	<='0';

	ELSIF(CLK'EVENT AND CLK='1')THEN
		CASE STATE IS
			WHEN ST_WAIT_TO_RECEIVE	=>	
				
				IF(RX_BUSY='1')THEN
					state	<= ST_START_READ;
				ELSE
					count1	<= 0;
					count		<= 383;
					DATA		<=	0;
					DONE	   <='0';
					state	<=	ST_WAIT_TO_RECEIVE;
				END IF;
				
			WHEN ST_START_READ	=>
				DONE	<='0';
				IF(RX_BUSY='0')THEN
					STATE	<=	ST_READ;
				ELSE
					STATE	<=	ST_START_READ;
				END IF;	
			
			WHEN ST_READ=>
								
					DATA_SIG(count DOWNTO count-7)<= RX_DATA;
					count				<=	count-8;
					IF(count1>46)THEN 
						DATA_RECV	<=DATA_SIG;
						STATE 		<= ST_DONE;
					ELSE
						count1		<=	count1+1;
						STATE 		<= ST_WAIT_TO_RECEIVE;
					END IF;
					
				WHEN ST_DONE	=>
							DATA_RECV<=	DATA_SIG;
							count1	<= 0;
							count		<= 383;
							DATA		<=	0;
							DONE		<=	'1';
							STATE		<=	ST_WAIT_TO_RECEIVE;
							
		END CASE;
	END IF;
END PROCESS;
END Behavioral;