----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:26:34 12/10/2014 
-- Design Name: 
-- Module Name:    TX - Behavioral 
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TX is
PORT(
	CLK		:	IN 	STD_LOGIC;
	START		:	IN 	STD_LOGIC;
	DATA		:	IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
	BUSY		:	OUT 	STD_LOGIC;
	TX_LINE		:	OUT 	STD_LOGIC

);
end TX;

architecture Behavioral of TX is

SIGNAL 	PRESCALER	:	INTEGER	RANGE	0 TO 10417:=0;
SIGNAL	INDEX			:	INTEGER	RANGE	0 TO 9:=0;
SIGNAL	DATAFLL		:	STD_LOGIC_VECTOR(9 DOWNTO 0):=(OTHERS=>'0');
SIGNAL	TX_FLAG		:	STD_LOGIC:='0';

type StateType is (ST_IDLE, ST_START_TX, ST_WAIT);
signal state: StateType:=ST_IDLE;



begin

PROCESS(CLK)BEGIN		
	IF (CLK'EVENT AND CLK='1') THEN
		CASE state IS
			WHEN ST_IDLE 	=>	
									IF (TX_FLAG='0' AND START='1') THEN
										TX_FLAG					<='1';
										BUSY						<='1';
										DATAFLL(0)				<='0';
										DATAFLL(9)				<='1';
										DATAFLL(8 DOWNTO 1)	<=DATA;
										STATE						<=ST_START_TX;
										
									ELSIF (TX_FLAG='0' AND START='0') THEN
										TX_FLAG		<='0';
										BUSY			<='0';
										DATAFLL(0)	<='1';
										DATAFLL(9)	<='0';
										INDEX 		<= 0;
										TX_LINE		<='1';
										state			<=ST_IDLE;
									END IF;
									
			WHEN ST_START_TX	=>
										
									IF(PRESCALER<10417)THEN
										TX_LINE		<=DATAFLL(INDEX);
										PRESCALER	<=PRESCALER+1;	
									ELSE 
										PRESCALER	<=0;
										IF(INDEX<9)THEN
											INDEX <=INDEX+1;
											STATE<=ST_START_TX;
										ELSE 
											STATE			<=ST_WAIT;
											TX_FLAG		<='0';
											BUSY			<='0';
											DATAFLL(0)	<='1';
											DATAFLL(9)	<='0';
											INDEX 		<= 0;
											TX_LINE		<='1';
										END IF;
									END IF;
			WHEN ST_WAIT	=>
									TX_FLAG		<='0';
									BUSY			<='0';
									DATAFLL(0)	<='1';
									DATAFLL(9)	<='0';
									INDEX 		<= 0;
									TX_LINE		<='1';
							
									IF(START='0')THEN 
										state	<= ST_IDLE;
									ELSE
										state	<=	ST_WAIT;
									END IF;
										
		END CASE;								
	END IF;
		
END PROCESS;

end Behavioral;