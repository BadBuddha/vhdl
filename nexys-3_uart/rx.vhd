----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:41:04 12/10/2014 
-- Design Name: 
-- Module Name:    RX - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity RX is
PORT(
	CLK		:	IN 	STD_LOGIC;
	RX_LINE		:	IN 	STD_LOGIC;
	BUSY		:	OUT 	STD_LOGIC;
	DATA		:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0)

);
end RX;

architecture Behavioral of RX is

SIGNAL 	PRESCALER		:	INTEGER	RANGE	0 TO 10417:=0;
SIGNAL	INDEX			:	INTEGER	RANGE	0 TO 9:=0;
SIGNAL	DATAFLL			:	STD_LOGIC_VECTOR(9 DOWNTO 0);--:=(OTHERS=>'0');
SIGNAL	RX_FLAG			:	STD_LOGIC	:='0'; 
SIGNAL 	next_receive		: 	STD_LOGIC	:='0';	--to check if recived(0)=0 and only then read the other bits.

TYPE 		StateType IS (ST_IDLE, ST_RECEIVE_FIRST, ST_RECEIVE_OTHERS, ST_STORE);
SIGNAL 	state: StateType:=ST_IDLE;

--SIGNAL CONTROL0 			: std_logic_vector(35 downto 0); 
--SIGNAL Chipscope_Trig	: std_logic_vector(7 downto 0);


BEGIN

		
PROCESS(CLK)BEGIN		
	IF (CLK'EVENT AND CLK='1') THEN
		CASE state IS
			WHEN ST_IDLE =>
								--DATA		<=(OTHERS=>'0');
								IF(RX_FLAG='0' and RX_LINE='0')THEN
									INDEX		<=	0;
									BUSY		<=	'1';
									RX_FLAG	<=	'1';
									state		<= ST_RECEIVE_FIRST;
								ELSE
									INDEX		<=	0;
									BUSY		<=	'0';
									RX_FLAG	<=	'0';
									state    <=ST_IDLE;
									
								END IF;
			
			WHEN ST_RECEIVE_FIRST =>
								--DATA		<=(OTHERS=>'0');
								IF(PRESCALER<10417)THEN
									PRESCALER	<=	PRESCALER+1;
								ELSE
									PRESCALER	<=	0;
									INDEX	<=1;
									--IF(next_receive='1')THEN
											state <= ST_RECEIVE_OTHERS;
									--ELSE
											--state	<= ST_IDLE;
											--BUSY	<=	'0';
									--END IF;
									
								END IF;
								
								IF(PRESCALER=5208)THEN
									IF(RX_LINE='0')THEN
										DATAFLL(0)		<= '0';
										--next_receive	<= '1';
										state				<= ST_RECEIVE_FIRST;
									--ELSE
										--next_receive	<='0';
									END IF;	
								END iF;
								
								
			WHEN ST_RECEIVE_OTHERS =>	
								--DATA			<=(OTHERS=>'1');
								IF(PRESCALER<10417)THEN
									PRESCALER	<=	PRESCALER+1;
								ELSE
									PRESCALER	<=	0;
									IF(INDEX<9)THEN
										INDEX		<=	INDEX+1;
										STATE		<=	ST_RECEIVE_OTHERS;
									ELSE
										STATE		<=	ST_STORE;
									END IF;
								END IF;
									
									IF(PRESCALER=5208)THEN
										IF(RX_LINE='0')THEN
											DATAFLL(INDEX)<='0';
										ELSE
											DATAFLL(INDEX)<='1';
										END IF;
										state		<=ST_RECEIVE_OTHERS;
									END IF;
	
										
		WHEN ST_STORE=>
						BUSY		<=	'0';
						IF(DATAFLL(0)='0'AND DATAFLL(9)='1')THEN
							DATA<=DATAFLL(8 DOWNTO 1);
						ELSE
							DATA<=(OTHERS=>'1');
						END IF;
						INDEX		<=	0;
						RX_FLAG	<=	'0';
						state		<=	ST_IDLE;		
		END CASE;								
	END IF;
		
END PROCESS;

end Behavioral;

