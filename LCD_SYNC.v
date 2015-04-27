// Nombre del archivo: LCD_SYNC.v 
// 
// Descripcion: Este codigo Verilog implementa un controlador de sincronismo y datos para 
// una pantalla VGA, mediante el uso de un PLL para adaptar la frecuencia de reloj y utilizando contadores para
// obtener la seÃ±ales de sincronismo apropiadas para la correcta visualiaciÃ³n en la pantalla ,muestra por pantalla un caracter
// previamente introducido en la memoria ROM, este codigo dispone de: 
// 1. clk, Reloj activo por flanco de subida a . 
// 2. NCLK Reloj activo por flanco de subida con la mitad de frecuencia que CLK, obtenido como salida del PLL. 
// 3. RST_n Reset activo a nivel bajo
// 4.GREST Reset vinculado al reset general, para la pantalla activo a nivel bajo
// 5.HD SeÃ±al de sincronismo horizontal se activa cuando se recorren todas las filas.
// 6.VD SeÃ±al de sincronismo vertical se activa cuando se recorren todas las columnas
// 7.DEN seÃ±al de habilitacion activa a nivel alto que se activa cuando estamos en la zona de visualizacion 
// 8.Filas indica el numero de bits para filas
// 9.Columnas Indica el numero de bits para las columnas
// 10. Las salidas R,G,B se utilizan para mostrar cada uno de los 3 colores por pantalla cada una de 8 bits
// para mostrar un caracter
// -------------------------------------------------------------------- 
// -------------------------------------------------------------------- 
module LCD_SYNC (CLK, RST_n, NCLK, GREST, HD, VD, DEN, Filas, Columnas, R, G, B);

parameter fin_h = 1056; 
parameter fin_v = 525; 
parameter max_v = 515;
parameter min_v = 35;
parameter max_h = 1016;
parameter min_h = 216;

`include "MathFun.vh"

parameter WIDTH_H=CLogB2(fin_h); 
parameter WIDTH_V=CLogB2(fin_v); 
input CLK, RST_n;
output NCLK, GREST, DEN;
output reg [WIDTH_H-1:0] Filas; 
output reg [WIDTH_V-1:0] Columnas; 
output reg HD=0, VD=0;
output reg[7:0] R, G, B;
wire [10:0] filasc, columnasc;
wire [7:0] dato;

assign filasc=Filas ;
assign columnasc=Columnas;
assign GREST = RST_n; 

pll_ltm u0 (  
.inclk0 (CLK),
.c0 ( NCLK ));



mrom	mrom_inst (
	.address ({6'b00000100,filasc[6:4]}),
	.clock ( NCLK ),
	.q ( dato )
	);
	
	 always@(posedge NCLK)
if(DEN)
	begin
		if(dato[columnasc[6:4]])
			begin
			R=8'b00000000;
			G=8'b00000000;
			B=8'b00000000;
			end
		else
			begin
			R=8'b11111111;
			G=8'b11111111;
			B=8'b11111111;
			end
	end

always @ (posedge NCLK or negedge RST_n)
begin
 if (!RST_n)
	Filas <= 0;
 else if (Filas == fin_h-1)
			begin
				Filas <= 0;
				HD <=1;
			end
		else
			begin
				Filas <= Filas + 1;
				HD <= 0;
			end
end

always @ (posedge HD or negedge RST_n) 
begin
 if (!RST_n)
	Columnas <= 0;
 else if (Columnas == fin_v-1)
			begin
				Columnas <= 0;
				VD <=1;
			end
		else
			begin
				Columnas <= Columnas + 1;
				VD <= 0;
			end
end




assign DEN = (Filas > min_h & Filas < max_h & Columnas > min_v & Columnas < max_v)? 1'b1 : 1'b0;



endmodule
