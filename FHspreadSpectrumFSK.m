% Spread spectrum Frequncy Hopping
% This program provides simulation for FHSS signaling using
% noncoherent detection of FSK .
% The jammer will jam 1 of the L frequency bands and
% can be turned on or off by inputting jamming= l or 0
% Noncoherent detection
%---------------------------------------------------------
clear;clc;clf;
n= 10000 ;%Number o f data symbols in the simulation
L= 8;% Number of frequency bands
Lh= 1 ;% Number of hops per symbol ( bit )
m= 1 ; % Number of users
%----------------------------------------------
% Generating information bits
s_data=round( rand ( n , m ) ) ;
%--------------------------------------
% Turn partial band jamming on or off
jamming= input ( ' jamming = ? ( Enter 1 for Yes , 0 for No ) ' ) ;
%------------------------------------------
% Generating random phases on the two frequencies
xbase1 = exp ( j * 2 * pi .* rand ( Lh * n , 1 ) ) ;
xbase0 = exp ( j * 2 * pi .* rand ( Lh * n , 1 ) )  ;
%--------------------------------------------------------
% Modulating two orthogonal frequencies
A=kron ( s_data , ones ( Lh , 1 ) ) .* xbase1;
B=kron ( ( 1- s_data ) , ones ( Lh , 1 ) ) .* xbase0;
xmodsig= [A   B] ;
clear xbase0 xbase1 ;
% Generating a random hopping sequence nLh long
Phop =round ( rand ( Lh * n , 1 ) * ( L - 1 ) ) + 1 ; % PN hopping pattern ;
Xsiga = sparse ( 1 : Lh * n , Phop , xmodsig ( : , 1 ) ) ;
Xsigb= sparse ( 1 : Lh * n , Phop , xmodsig ( : , 2 ) ) ;
%-------------------------------------------------
% Generating noise sequences for both frequency channels
noise1 =randn ( Lh*n , 1 ) + j * randn ( Lh* n , 1) ;
noise2 = randn ( Lh * n , 1 ) + j * randn ( Lh* n , 1 ) ;
Nsiga= sparse ( 1 : Lh*n , Phop , noise1 ) ;
Nsigb=sparse ( 1 : Lh * n , Phop , noise2 ) ;
clear noise1 noise2 xmodsig ;
BER= [ ] ;
BER_az = [ ] ;
%------------------------------------------
% Add a jammed channel ( randomly picked )
if ( jamming )
nch=round ( rand* ( L - 1 ) ) + 1 ;
Xsiga ( : , nch ) =Xsiga ( : , nch ) * 0 ;
Xsigb ( : , nch ) =Xsigb ( : , nch ) * 0 ;
Nsiga ( : , nch ) =Nsiga ( : , nch ) * 0 ;
Nsigb ( : , nch ) =Nsigb ( : , nch ) * 0 ;
end
%------------------------------------------
% Generating the channel noise ( AWGN )
for i = 1 : 10 
Eb2N ( i ) = i ;% ( Eb / N in dB )
Eb2N_num= 10 .^ ( Eb2N ( i ) / 10 ) ; % Eb / N in numeral
Var_n= 1 / ( 2 .* Eb2N_num ) ;% 1 / SNR is the noise variance
signois = sqrt( Var_n ) ; % standard deviati on
ych1 =Xsiga+ signois * Nsiga ;% AWGN complex channels
ych2 =Xsigb+ signois *Nsigb ;% AWGN channels

%---------------------------
% Noncoherent detection
for kk= 0 : n-1 
Yvec1 = [ ] ; Yvec2 = [ ] ;
for kk2 = 1 : Lh 
 Yvec1 = [ Yvec1 ych1( (kk .* Lh+kk2) , Phop( kk * Lh+kk2 ) ) ] ;
Yvec2 = [ Yvec2 ych2( kk * Lh+kk2 , Phop ( kk* Lh+kk2 ) ) ] ;   
end
ydim1 =Yvec1 * Yvec1' ;
ydim2 =Yvec2 * Yvec2' ;
dec( kk+ 1 ) = ( ydim1 >ydim2 ) ;
end
clear ych1 ych2 ;
% Compute BER from simulation
BER= [ BER ; sum( dec' ~= s_data ) / n ] ;
% Compare against analytical BER 
BER_az = [ BER_az ; 0.5 * exp(-Eb2N_num/ 2 ) ] ;
end
figber = semilogy(Eb2N , BER_az , ' R-' , Eb2N , BER , ' k-o ' ) ;
% set( figber , ' Linewidth ' , 2 ) ;
legend( 'Analytical BER ' , ' FHSS simulation ' ) ;
fx=xlabel( ' E_b/N ( dB )' ) ;
fy=ylabel( ' Bit error rate' ) ;
grid
