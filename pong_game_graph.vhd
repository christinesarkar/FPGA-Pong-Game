-- Listing 13.7
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pong_game_graph is
   port(
      clk, reset: std_logic;
      button: std_logic_vector(1 downto 0);
      pixel_x,pixel_y: in std_logic_vector(9 downto 0);
      gra_still: in std_logic;
      graph_on, hit, miss: out std_logic;
      rgb: out std_logic_vector(2 downto 0)
   );
end pong_game_graph;


architecture arch of pong_game_graph is
   signal pix_x, pix_y: unsigned(9 downto 0);
   constant MAXIMUM_X: integer:=640;
   constant MAXIMUM_Y: integer:=480;
   constant WALL_X_L: integer:=32;
   constant WALL_X_R: integer:=35;
   constant PADDLE_X_L: integer:=600;
   constant PADDLE_X_R: integer:=603;
   signal paddle_y_t, paddle_y_b: unsigned(9 downto 0);
   constant PADDLE_Y_SIZE: integer:=72;
   signal paddle_y_reg, paddle_y_next: unsigned(9 downto 0);
   constant PADDLE_V: integer:=4;
   constant BALL_SIZE: integer:=8; -- 8
   signal ball_x_l, ball_x_r: unsigned(9 downto 0);
   signal ball_y_t, ball_y_b: unsigned(9 downto 0);
   signal ball_x_reg, ball_x_next: unsigned(9 downto 0);
   signal ball_y_reg, ball_y_next: unsigned(9 downto 0);
   signal ball_vx_reg, ball_vx_next: unsigned(9 downto 0);
   signal ball_vy_reg, ball_vy_next: unsigned(9 downto 0);
   constant BALL_V_P: unsigned(9 downto 0)
            :=to_unsigned(2,10);
   constant BALL_V_N: unsigned(9 downto 0)
            :=unsigned(to_signed(-2,10));
   type rom_type is array (0 to 7) of
        std_logic_vector (7 downto 0);
   constant BALL_ROM: rom_type :=
   (
      "00111100", --   ****
      "01111110", --  ******
      "11111111", -- ********
      "11111111", -- ********
      "11111111", -- ********
      "11111111", -- ********
      "01111110", --  ******
      "00111100"  --   ****
   );
   signal rom_addr, rom_col: unsigned(2 downto 0);
   signal rom_data: std_logic_vector(7 downto 0);
   signal rom_bit: std_logic;
   signal wall_on, paddle_on, sq_ball_on, rd_ball_on: std_logic;
   signal wall_rgb, paddle_rgb, ball_rgb:
          std_logic_vector(2 downto 0);
   signal refr_tick: std_logic;
   
begin
   -- registers
   process (clk,reset)
   begin
      if reset='1' then
         paddle_y_reg <= (OTHERS=>'0');
         ball_x_reg <= (OTHERS=>'0');
         ball_y_reg <= (OTHERS=>'0');
         ball_vx_reg <= ("0000000100");
         ball_vy_reg <= ("0000000100");
      elsif (clk'event and clk='1') then
         paddle_y_reg <= paddle_y_next;
         ball_x_reg <= ball_x_next;
         ball_y_reg <= ball_y_next;
         ball_vx_reg <= ball_vx_next;
         ball_vy_reg <= ball_vy_next;
      end if;
   end process;
   pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);
   refr_tick <= '1' when (pix_y=481) and (pix_x=0) else
                '0';
   -- wall
   wall_on <=
      '1' when (WALL_X_L<=pix_x) and (pix_x<=WALL_X_R) else
      '0';
   wall_rgb <= "001"; -- blue
   -- paddle paddle
   paddle_y_t <= paddle_y_reg;
   paddle_y_b <= paddle_y_t + PADDLE_Y_SIZE - 1;
   paddle_on <=
      '1' when (PADDLE_X_L<=pix_x) and (pix_x<=PADDLE_X_R) and
               (paddle_y_t<=pix_y) and (pix_y<=paddle_y_b) else
      '0';
   paddle_rgb <= "010"; --green
   -- new paddle y-position
   process(paddle_y_reg,paddle_y_b,paddle_y_t,refr_tick,button,gra_still)
   begin
      paddle_y_next <= paddle_y_reg; -- so no move
      if gra_still='1' then  --initial position of paddle
         paddle_y_next <= to_unsigned((MAXIMUM_Y-PADDLE_Y_SIZE)/2,10);
      elsif refr_tick='1' then
         if button(1)='1' and paddle_y_b<(MAXIMUM_Y-1-PADDLE_V) then
            paddle_y_next <= paddle_y_reg + PADDLE_V; -- move [down] 
         elsif button(0)='1' and paddle_y_t > PADDLE_V then
            paddle_y_next <= paddle_y_reg - PADDLE_V; -- move [up]
         end if;
      end if;
   end process;
   -- FOR SQUARE BALL
   ball_x_l <= ball_x_reg;
   ball_y_t <= ball_y_reg;
   ball_x_r <= ball_x_l + BALL_SIZE - 1;
   ball_y_b <= ball_y_t + BALL_SIZE - 1;
   sq_ball_on <=
      '1' when (ball_x_l<=pix_x) and (pix_x<=ball_x_r) and
               (ball_y_t<=pix_y) and (pix_y<=ball_y_b) else
      '0';
   -- FOR ROUND BALL
   rom_addr <= pix_y(2 downto 0) - ball_y_t(2 downto 0);
   rom_col <= pix_x(2 downto 0) - ball_x_l(2 downto 0);
   rom_data <= BALL_ROM(to_integer(rom_addr));
   rom_bit <= rom_data(to_integer(not rom_col));
   rd_ball_on <=
      '1' when (sq_ball_on='1') and (rom_bit='1') else
      '0';
   ball_rgb <= "100";   -- RED
   -- NEW POSITION FOR BALL
   ball_x_next <=
      to_unsigned((MAXIMUM_X)/2,10) when gra_still='1' else
      ball_x_reg + ball_vx_reg when refr_tick='1' else
      ball_x_reg ;
   ball_y_next <=
      to_unsigned((MAXIMUM_Y)/2,10) when gra_still='1' else
      ball_y_reg + ball_vy_reg when refr_tick='1' else
      ball_y_reg ;
   -- NEW VELOCITY OF THE BALL
   -- WITH NEW HIT'S AND MISSED SIGNALS
   process(ball_vx_reg, ball_vy_reg, ball_x_l, ball_x_r,
           ball_y_t, ball_y_b, paddle_y_t, paddle_y_b, gra_still)
   begin
      hit <='0';
      miss <='0';
      ball_vx_next <= ball_vx_reg;
      ball_vy_next <= ball_vy_reg;
      if gra_still='1' then            -- V(I) INITIAL VELOCITY
         ball_vx_next <= BALL_V_N;
         ball_vy_next <= BALL_V_P;
      elsif ball_y_t < 1 then          -- REACH (TOP)
         ball_vy_next <= BALL_V_P;
      elsif ball_y_b > (MAXIMUM_Y-1) then  -- reach (DOWN)
         ball_vy_next <= BALL_V_N;
      elsif ball_x_l <= WALL_X_R  then -- reach UPTO wall
         ball_vx_next <= BALL_V_P;     -- BACK BOUNCE
      elsif (PADDLE_X_L<=ball_x_r) and (ball_x_r<=PADDLE_X_R) and
            (paddle_y_t<=ball_y_b) and (ball_y_t<=paddle_y_b) then
            -- A HIT, REACH X OF RIGHT PADDLE
            ball_vx_next <= BALL_V_N; -- BACK BOUNCE
            hit <= '1';
      elsif (ball_x_r>MAXIMUM_X) then     -- REACH TO CORRECT BORDER
         miss <= '1';                 -- A MISS
      end if;
   end process;
   -- RGB 
   process(wall_on,paddle_on,rd_ball_on,wall_rgb,paddle_rgb,ball_rgb)
   begin
      if wall_on='1' then
         rgb <= wall_rgb;
      elsif paddle_on='1' then
         rgb <= paddle_rgb;
      elsif rd_ball_on='1' then
         rgb <= ball_rgb;
      else
         rgb <= "110"; -- CHANGE BACKGROUND TO YELLOW
      end if;
   end process;
   -- new SIGNAL GRAPHIC_ON
   graph_on <= wall_on or paddle_on or rd_ball_on;
end arch;