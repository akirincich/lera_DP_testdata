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

RC.dds_setup_file='dds_prog.out.05-Jun-2017.mat';  % the dds setup file to load


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

%clear the rest of this file, should be re-coded in the future
clear F0             Tr         i_FVclk        l_FVclk        lw_fs_ratio    n_hf_lf        w_Fclk ...        
F1             c              dds_step       i_Fclk         l_Fclk         mt             n_pll          w_chirp     ...   
Fclk           c0             fr             i_fs           l_fs           n_FVclk        nl_Fclk_ratio  w_fs       ...   
Fd             chirp          fs             i_hf_lf        l_hf_lf        n_Fclk         range_res      w_hf_lf    ...    
Td             dds            hf_bw          i_pll          l_pll          n_fs           w_FVclk        w_pll ;   

%%
%translate mt from dds into how many samples the DTAQ has per chirp
RC.dtaq_samp_chirp=floor(RC.mt)*RC.OVER;


%%
%%%% discussion

% Lera aims to set the sweep rate of the radar such that 60 Hz modulation shows up at 
% zero doppler shift.  How does this happen?
% 
% The dds sweeps thru BW in a time period set by the sweep rate (or chirps/s)
% The Dtaq samples at close to 12khz (12000 Hz) (or 
% 
% So a sweep rate of 3 (3 chirps/s) would give 4000 samples/chirp for the dataset.
% wera needs a 6khz signal (hence the 'oversampling' constants). So cutting for the 'oversampling'
% The wera samples per chirp would be 2000.




