%radar_header.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%radar_header.m
%
% . This m-file contains/loads the setup and sampling parameters for the
% lera radar system. It is altered 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RC=[];
RC.SiteName='nwt';

%%define variables for program 
%global IQORDER SHIFT SHIFT_POS
RC.NCHAN=16;                       % number of dtacq A/D channel pairs
RC.IQ=2;                           % number of channels to make a pair
RC.NANT=8;                         % number of antennas

RC.dds_setup_file='dds_prog.out.22-Jun-2017.mat';  % the dds setup file to load

%%%% in the future, combine these next 2?
RC.OVER=2;                         % dtacq oversampling rate, relative to wera, also means that
                                % mt*over= true samples/per chirp for this dtaq
                                %(mt = incoming sample rate from dds_prog
                             
RC.COMP_FAC=8;                     % extra compression factor


RC.NCHIRP=2048;                    % number of minimum chirps

RC.SKIP=2;                         % number of chirps to skip at the beginning and end.
                                %  this is done for the 
%%%old, not needed b/c of new SKIP format
%FIRSKIP=28;                     % number of samples skipped before first chirp due to FIR transcient

%RC.SHIFT_POS=RC.COMP_FAC*20*2;        % total number of samples to add to chirp to make clean filtering
RC.SHIFT_FRAC=.08;        % fraction of the total number of samples to add to chirp to make clean filtering

RC.SHIFT=6;                        % number of bits to lose when converting 32->16 bits, 
                                % see the last line of the 2mat file loop


%%%%% if there is an issue with the ordering of the I and Q channels, due to cable switching 
%%%%% .    internal dds definitions of what is I and what is Q.
%%%%% .  if wrong, Bragg energy maps into negative range cells
%RC.IQORDER='swap';                  % ordering of I and Q channels; use 'norm' or 'swap'
RC.IQORDER='norm';                 % ordering of I and Q channels; use 'norm' or 'swap'

%%%% the NWT lera is 'norm?' %%%

%%
%load the dds_setup file and delete unneeded terms.

eval(['load ' config_dir RC.dds_setup_file ])
RC.dds_setup.F0=0; 
RC.dds_setup.F1=F1;
RC.dds_setup.Fd=Fd;
RC.dds_setup.Td=Td;
RC.dds_setup.Tr=Tr;
RC.dds_setup.Fclk=Fclk;
RC.dds_setup.fs=fs;
RC.dds_setup.dds=dds;

RC.Fc=fr;
RC.chirp=chirp;
RC.BW=hf_bw;
RC.c=c;
RC.mt=mt;
%%
%clear the rest of this file, should be re-coded in the future
clear F0             Tr         i_FVclk        l_FVclk        lw_fs_ratio    n_hf_lf        w_Fclk ...        
F1             c              dds_step       i_Fclk         l_Fclk         mt             n_pll          w_chirp     ...   
Fclk           c0             fr             i_fs           l_fs           n_FVclk        nl_Fclk_ratio  w_fs       ...   
Fd             chirp          fs             i_hf_lf        l_hf_lf        n_Fclk         range_res      w_hf_lf    ...    
Td             dds            hf_bw          i_pll          l_pll          n_fs           w_FVclk        w_pll ;   

%%
%translate mt from dds into how many samples the DTAQ has per chirp

%RC.dtaq_samp_chirp=floor(RC.mt)*RC.OVER;  % the old way to do this, didn't
%work when Pierre switched to Mt~1984

RC.dtaq_samp_chirp=round(RC.mt)*RC.OVER;  %works now, need to be careful as 
%  mt is an important product of what goes into to set the dds, but is not directly
% input, thus rounding errors can get this wrong.  


%%
%%%% discussion ak

% Lera aims to set the sweep rate of the radar such that 60 Hz modulation shows up at 
% zero doppler shift.  How does this happen?
% 
% The dds sweeps thru BW in a time period set by the sweep rate (or chirps/s)
% The Dtaq samples at close to 12khz (12000 Hz) (or 
% 
% So a sweep rate of 3 (3 chirps/s) would give 4000 samples/chirp for the dataset.
% wera needs a 6khz signal (hence the 'oversampling' constants). So cutting for the 'oversampling'
% The wera samples per chirp would be 2000.

%%% discussion pf

% the sampling constrain  to operate an HF radar is that chirps repeat identically
% with respect to both the mains and its harmonics, and with respect to the ADC sampling frequency
%
% this is very generally done by constraining the chirp length to be an integral number of both
% the sampling period, and the mains period.
%
% the principal intermodulation is quadratic, and thus the 120 Hz harmonic
% dominates the mains
%
%f2m=120
%
%
% the ADC sampling frequency is obtained by integer divide from the OCXO clock, which is 100 MHz
% in the lera implementation, we divide by 4 in hardware, followed by 4 in the PPL of the ADC 
% followed by 512 in the sigma-delta oversampling, for a total of 2^13.
% the sampling frequency is therefore
%
% fc=10^8/2^13
%
%fc= 12207.03125 Hz
%
% it is important to note that unless a custom OCXO is cut, a very tedious and expensive process,
% the frequencies will not be exact multiple of each other. Only off-the-shelf OCXO are pratical.
%
% at 16 MHz, chirp length of about 3/second give a proper spectral spreading of the second order
% 
% the exact chirp length that would precisely synchronize the two would be
%
%format rat; fc/f2m
%
% which is 9257/(7*13) in prime numbers
% that would however give too long a chirp (0.7583 sec) 
% therefore an approximate shorter value is needed
% that would still maintain the 120 Hz intermodulation near zero Doppler.
% an optimum chirp length is then computed as follows
%
% 1. length is assumed to be about 330 msec
% 2. that is about 40 fm periods
% 3. let's explore nearby multipliers of fm and find the corresponding multiplier of fc
%         mult      chirp	 2*mt
%         35        291.67       3560.38
%         36        300.00       3662.11
%         37        308.33       3763.83
%         38        316.67       3865.56
%         39        325.00       3967.29
%         40        333.33       4069.01
%         41        341.67       4170.74
%         42        350.00       4272.46
%         43        358.33       4374.19
%         44        366.67       4475.91
% we chose 39, which is 3*13 because it gives us constancy with the mexican custom clocks, which 
% we custom-ordered so that 39 gives an exact  chirp of 0.325 sec and exact MT of 3840.
% it turns out to be also one of the pre-programmed frequencies of the wera
% here those parameters are approximate because we do not have the custom clock.
% 
% however any in the table above will work, and I can see that 40 gives a much better mt fit
% need to experiment a little bit
% also note that on islands the mains is not synced on atomic time usually, and so frequency 
% can be quite off 120 Hz.
