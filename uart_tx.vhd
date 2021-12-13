
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity uart_tx is

	Port ( clk : in STD_LOGIC;
			 --reset : in STD_LOGIC;
			 inicio : in STD_LOGIC; -- boton de inicio de la transmision
			 TX : out STD_LOGIC; -- pin donde se enviaran los datos
			 --DPSwitch : in std_logic_vector(0 to 7); -- Vector que contiene las 255 combinaciones del Dip Switch		 
			 led_indicador : out std_logic); -- led de indicador que la transmisión fue terminada
end uart_tx;

architecture Behavioral of uart_tx is

	signal clk_div : std_logic; -- divisor del reloj
	signal clk_counter : integer range 0 to 625; -- señal para el contador de 0.5(12Mhz/115200)
  
	signal trama : integer range 0 to 7; -- indice para seleccionar cada bit del vector de datos
	--signal reinicio : integer range 0 to 1;
  
	type estado_t is (IDLE, START, DATA, STOP); -- maquina de estados del transmisor
	signal estado : estado_t; 
	
	signal retardo : integer range 0 to 200; -- entero para realizar un retraso para evitar el rebote del pulsador
	signal start1 : std_logic; -- señal para dar inicio a la transmision del UART
	
	signal datos : std_logic_vector(7 downto 0);
	signal puntero : integer range 0 to 7;
  
begin

-----------------------------------------------------
-- Divisor de reloj de 12Mhz a 115200bps
-----------------------------------------------------

process(clk,start1)
begin
  if (start1='1') then
    clk_div <='0';
  elsif(rising_edge(clk)) then
    if(clk_counter = 625) then    
      clk_div<=not(clk_div);
      clk_counter <= 0;
    else
      clk_counter <= clk_counter +1;
    end if;
    
  end if;  
 end process;    
  
  
 
 process (puntero) begin

	case puntero is
		when 0 => datos <= "00000000";
		when 1 => datos <= "00000001";
		when 2 => datos <= "01001000";
		when 3 => datos <= "01100000";
		when 4 => datos <= "00110010";
		when 5 => datos <= "00100100";
		when 6 => datos <= "01011100";
		when 7 => datos <= "01110010";
		when others => datos <= "00000000";
	end case;
end process;	
-----------------------------------------------------
-- Maquina de estados que forma la trama para la transmisión
-----------------------------------------------------

process(clk_div,inicio,start1)
begin

		  if (inicio='0') then -- Si se presiona el SW1 inicia la transmisión y se limpian las variables necesarias
			 TX <= '1';
			 estado <= IDLE;
			 trama <= 0;
			 led_indicador <= '0';
			 start1 <= '0';
			 retardo <= 0;
			 puntero <=0;
		  elsif(rising_edge(clk_div)) then
			 case(estado) is
				when IDLE =>  -- el estado IDLE indica que está en reposo para iniciar una nueva transmisión
				  TX <= '1';
				  trama <= 0;
				  if(retardo=50) then -- retardo de 50 ciclos de reloj para evitar el rebote del push button
					 estado <= START;
					 retardo <= 0;
				  else
					 retardo <= retardo +1;
				  end if;	 
				when START => -- el estado START envía el primer bit de inicio para la transmisión
				  TX <= '0';
				  estado <= DATA;
				when DATA => -- el estado DATA envía bit por bit los datos que se toman desde el DIP switch
				  
				  TX <= datos(trama);
				  if(trama=7) then -- condición para verificar que ya se enviaron los 8 bits de información
					 estado <= STOP;
				  else
					 trama <= trama+1;
				  end if;
				when STOP => -- cuando termina la transmisión se envía un último bit de parada para finalizar la transmisión
				  TX <= '1';
				  led_indicador <= '1';
				  if(puntero=7) then -- condición para verificar que ya se enviaron los 8 bits de información
					 estado <= STOP;
					 puntero <= 0;
				  else
					 puntero <= puntero+1;
					 estado <= IDLE;
				  end if;
				end case;
			
			
		  end if;
		

end process;    

end Behavioral;
