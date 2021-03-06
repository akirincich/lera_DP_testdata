%radar_pattern.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%radar_pattern.m
%
%  Antenna pattern file for SITE      NWPT
%
%  this script finishes the setup of the lera patt structure by loading the
%  site specific

%  this script is called directly in load_lera_pattern_v?.m in order to 
%  finish the setup of the lera antenna pattern structure 'patt' by loading the
%  site specific reciever antenna response for signals from all directions 
%
%  This script describes the rx pattern response when arranged as a rectangular
%  grid.  To create the 'ideal' pattern we define
%
%   N     - number of elements in x direction, 
%   M     - number of elements in y direction 
%   phi   - steering angle in math coordinates (in degrees relative to x (eg ccwE))*
%   counterclockwise of east (if the x axis of the instrument array was 
%    pointed east, which it never is)
%   
%   NOTE: the 'steering angle' as defined here following van Trees is
%   the direction a waveform is going TOWARDS, not the direction it is
%   COMING from.   In HFR processing, we use the array as a RX array and are 
%   solely interested in the direction a target waveform is coming from 
%   and how that would map onto the antenna array.
%
%   THUS, to convert this into a useful map for an antenna pattern
%     measurement, and to be able to compare the ideal to measured ant
%     response patterns we first follow van Trees to develop the antenna
%     beam response pattern, and then define the 'response angle' as
%     psi=phi+180.  The response angle is returned within patt as phi to define
%     the antenna response in a format consistent with our HFR needs.
%
%  following van Trees in the context of our array:
%
% but here this is ccw of the positive x-axis through the array
% ^
% |          x   o   o
% y          o   o   o
%            o   o   o
%
%                x ->
%
% Thus the 'bearing' of the array should be the direction of the x axis.
%  (a change from vers. 1 of this script.
%
%   v1 see below for additional details
%   created from lera_pattern_work_v4 on 
%   11/23/2018
%
%  v2   1/21/2019
%      included measured pattern corrections  as adj_facts=[];
% by
% Anthony Kirincich
% WHOI PO
% akirincich@whoi.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(RC.SiteName,'nwt')==1;    %nantucket  LERA, installed on 6/2017

%%% update for new orientation of math here, 
%Array_bearing=[147+90]; % based on bearing of 5 to 3 ant line. (see below)
Array_bearing=[142+90]; % based on bearing of 5 to 3 ant line. (see below)
% .                            and adjusted to line with x axis of ant
%                              array, which should be along ants 1 to 7

%the compass bearing (CW of true north) of the positive x direction of the 
% antenna pattern relative to the center of the array.



%%%%%%%% set array variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%phi=180:1:360; 
phi=1:1:360;  % the steering angle, defined following van Trees.
psi0=phi-180;   %  the response angle, defined here as the direction a wave-
%psi= phi-180;   %  the response angle, defined here as the direction a wave-
                  %   form would be coming from as, measured by the array
                  %   design, following van Trees.
%%% both phi and psi are in math coordinates!!! %%%
 
th=90;  %the vertical orientation of the array slice, 90 deg is horizontal
M=3; N=3;
%%%%%%%%%%%%%%%%%%%%

%%
%%%%%%%%%%%%%  define element spacing.
% Define dx/lambda and dy/lambda, that is, normalized by lambda
dx = 0.3535; dy = 0.3535;   %for lera system, ideal
% See Van Trees, 2002, pg 235, 240, 249

% Make grid of M and N, indexed from zero, M columns
% % this seems to put the phase center at a corner
% [m,n] = meshgrid(0:M-1,0:N-1);
%
% Try to put the phase center in the middle
%[m,n] = meshgrid(  (0:M-1) - mean(0:M-1)  ,   (0:N-1) - mean(0:N-1)   );
[n,m] = meshgrid(  (0:N-1) - mean(0:N-1) , (0:M-1) - mean(0:M-1)  );   %switch m,n to match van trees

m=flipud(m);  %flipup needed to get the same sense as van trees fig 4.7
%
% n = -1     0     1
%     -1     0     1
%    -1     0     1
% m = -1    -1    -1   or after flipud:    1     1     1
%     0     0     0                       0     0     0       
%     1     1     1                      -1    -1    -1 
%     

% vectorize these, down each column, row 1 to m
m = m(:);
n = n(:);

% now expand to size of phi
m = repmat(m,1,length(phi));
n = repmat(n,1,length(phi));

% make matrix out of phi
phi = repmat(phi(:)',size(m,1),1);

% eqn 4.2, 4.3 with dx defined in wavelengths
psi_x = 2.*pi.*dx.*sind(th).*cosd(phi);
psi_y = 2.*pi.*dy.*sind(th).*sind(phi);


% Compute the matrix of array manifold vectors (eqn 4.50, 4.53)
A = exp( 1i.* ( (n .* psi_x)  + (m .* psi_y) ) );  %follows van trees, working from equ 4.1 to 4.50

% for the arbitrary array orientation, shown above...
%[ n(:,1) m(:,1) ] =     -1    -1      ant_num   1
%                        -1     0                2
%                        -1    1                3
%                         0     -1                4
%                         0     0                5
%                         0     1               6
%                         1     -1                7
%                         1     0                8
%                         1    1                9
%
% or:
%    x,y    (1)  -1,1    (4)   0,1   (7)   1,1
%           (2)  -1,0    (5)   0,0   (8)   1,0
%           (3)  -1,-1   (6)   0,-1  (9)   1,-1

sense= {'Sense of rotation is CW is negative, CCW is positive, i.e. math';
 ' orientation is about the rightward x-axis or towards ant 8,';
 ' i.e.  a hit at phi=0 (psi=180) means the scatterer (and the wavenumber vector) is going from ant 2 towards ant 8';
 '  (as defined, the crest are normal to the wavenumber vector)';
  ' THUS';
  'for a scattered waveform coming from offshore of ant 9 and traveling toward ant 1:';
  'phi= 135 and psi = -45 ';
  ' i.e. psi is still in math coordinates about the bearing direction of the array (the pos x axis)'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

if CONST.goplot(2)==1;
    %%%%% plot some examples for reference
    tt=[360 45 90 135];
    figure(10); clf;
    [np,mp] = meshgrid(  (0:N-1) - mean(0:N-1) , (0:M-1) - mean(0:M-1)  );   %switch m,n to match van trees
    mp=flipud(mp);  %flipup needed to get the same sense as van trees fig 4.7
    
    for ii=1:length(tt)
        i=find(phi(1,:)==tt(ii));
        x=[real(A(1:3,i))'; real(A(4:6,i))'; real(A(7:9,i))']';
        y=[imag(A(1:3,i))'; imag(A(4:6,i))'; imag(A(7:9,i))']';
        subplot(1,length(tt),ii);
        contourf(np,mp,x,'linecolor','none'); caxis([-1 1]); hold on; grid on;
        contour(np,mp,y,[0 0],'linecolor','w','linestyle','-');
        contour(np,mp,y,[.1:.1:1],'linecolor','k','linestyle','-');
        contour(np,mp,y,[-1:.1:-.1],'linecolor','k','linestyle','--');
        title(['incoming waveform for phi=' num2str(phi(1,i))])
%x
%y
%pause 
    end
    disp('note that contour is messing up the offangle parts because of interpolation')
end

%%% as described here, in the lera array with the orientation given,
%%% point 1 is the one to cut, reorient the whole array to 
A=A([2:9],:);

%%%%%%%%%%
%%% .     a look at the Rx back end  %%%   
%         channel number  8  7  6  5  4  3  2  1
% 6/1/2017  cable number  9  8  7  6  5  4  3  2    with cable 1 as a spare
% 7/18/2017 cable number  9  8  7  6  5  4  1  2    with no spare as cable 3 was cut by a mower

%%%%%% from  6/1 to 7/17/2017 %%%%%%%
% the  nwt cable grid is:
%  5  2     or flipped    6   7
%  4  3  6             2  3   8
%  9  8  7             5  4   9
% 
% which maps into channels
%  4  1       or flipped   5  6
%  3  2  5              1  2  7
%  8  7  6              4  3  8

% %  so: ideal actual
% mapper=[ 1  1; %8;
%          2  4; %3;
%          3  5; %4;
%          4  2; %7;
%          5  3; %2;
%          6  6; %1;
%          7  7; %6;
%          8  8]; %5];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% from 7/18/2017 to present %%%%%%
% the  nwt cable grid is:
%  5  2     or flipped    6   7
%  4  3  6             1  2   8
%  9  8  7             5  4   9
% 
% which maps into channels
%  4  1       or flipped   5  6
%  3  2  5              2  1  7
%  8  7  6              4  3  8

% %  so: ideal actual
mapper=[ 1  2;
         2  4;
         3  5;
         4  1;
         5  3;
         6  6;
         7  7;
         8  8];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%so the cable number that matches the ant_num is
[s,i]=sort(mapper(:,2),'ascend'); mapper(:,3)=i;

mapper_what='(1) ideal_pattern_ant# (2) array channel  (3) map to transform ideal # to channel 1-8';

disp('NWTP:  Note that the cable mapping changed on 7/18/2017.  Are you using the correct map?')

%%%%% for NWTP  %%%%% done on 01/21/2019
meas_patt_date=datenum(2019,1,21,0,0,0);
adj_facts =[ 1     1/1     1/1.5     1/1.3    1/2   1/3     1     1/1.25;
              0    20       10         0      0+10     20     10        20];
disp(['includes Measured Pattern corrections, made on: ' datestr(meas_patt_date)] )



else ; disp('site name is not correct');
    adfasdasdfas
    
end


