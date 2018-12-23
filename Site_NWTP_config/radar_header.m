%radar_header.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% radar_header.m
%
% This m-file contains/loads the setup and sampling parameters for a
% lera radar system. It should be adjusted to be particular to the site
% in question during the site deployment phase an adjusted as needed there
% after.  
%
% Importantly, the lera_DP processing calls this file BOTH during the
% conversion from the raw A2D converted data file to the chirped, decimated
% timeseries file on the site computer as well as when processing the
% timeseries file to spectra and radials. It is critical that the same 
% radar_header file be used for both, and that the parameters correspond to
% how the radar was operated during the data collection period.
%
% Partially to ensure this, radar_header loads a mat file version of the
% same settings transfered to the DDS or DTACQ for operating the radar.
% Thus the file name (and date) of the last radar set up file is a critical
% parameter of this header file.
%
%  created by
%  Anthony Kirincich
%  WHOI PO
%  akirincich@whoi.edu  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RC=[];
%%%%%%%%%%%%%%%% likely user defined parameters %%%%%%%%

RC.SiteName='nwt';  %the site name on the site

%%% What type of radar is it?  MK2 or 3
RC.radar_type='MK2';
%RC.radar_type='MK3';

%%%% what setup file should be used 
%RC.dds_setup_file='dds_prog.out.22-Jun-2017.mat';  % the dds setup file to load
RC.dds_setup_file='dds_prog.out.02-May-2018.mat';

%%% What is the gain on the receiver 
RC.gain=1;			%'low' ...preferred for data collection
%RC.gain=10;			%'high'

%%% with is the shift bits to focus data collected on 'viable data only'
%RC.SHIFT=6;          % number of bits to lose when converting 32->16 bits, 
RC.SHIFT=5;           % number of bits to lose when converting 32->16 bits, 


%%% set info on the antenna makeup
RC.RxAntConfig='8-channel Rectangular Array';
%RC.TxAntConfig='4-post Quad Array';
RC.TxAntConfig='2-post quarter lambda Cordioid Array';
RC.Tx_bearing= 270;  %in degT


%%%%%%%%%% background work to create rest of data structure with setup information %%%
%define variables for program 
RC.NCHAN=16;                       % number of dtacq A/D channel pairs
RC.IQ=2;                           % number of channels to make a pair
RC.NANT=8;                         % number of antennas

RC.OVER=2;	% dtacq oversampling rate, also means that
				% mt*over= true samples/per chirp for this dtaq
				% mt = incoming sample rate from dds_prog
                             
%RC.COMP_FAC=8;                     % extra compression factor
RC.COMP_FAC=16;			       % extra compression factor
RC.MT=1920;			% number of samples per chirp at 6 kHz
RC.NCHIRP=1024;			% number of minimum chirps


RC.SKIP=2;			% number of chirps to skip at the beginning and end.
                                % this is done for the old, not needed b/c of new SKIP format

 %translate mt from dds into how many samples the DTAQ has per chirp
RC.dtaq_samp_chirp=round(RC.MT)*RC.OVER;	%works now, need to be careful as 
% mt is an important product of what goes into to set the dds, but is not directly
% input, thus rounding errors can get this wrong.  

RC.SHIFT_FRAC=.08;        % fraction of the total number of samples to add to chirp to make clean filtering

%load the dds_setup file and delete unneeded terms.
%eval(['load ' config_dir RC.dds_setup_file ])    % old config dir variable name
eval(['load ' confdir RC.dds_setup_file ])    %same as onboard lera variable name


if strcmp(RC.radar_type,'MK2')==1
    RC.BIT_LENGTH=23;  %for an MK2 receiver, a 24 bit AD converter
    
    % ordering of I and Q channels; use 'norm' or 'swap'
    RC.IQORDER='norm';		%norm is more likely
    %RC.IQORDER='swap';
    % if there is an issue with the ordering of the I and Q channels, due to cable switching
    % internal dds definitions of what is I and what is Q.
    % if wrong, Bragg energy maps into negative range cells
    
    %%% old MK2 , not needed here?
    RC.dds_setup.F0=0;
    RC.dds_setup.F1=F1;
    RC.dds_setup.dds=dds;
    RC.mt=mt;
    freq=fr;
    
elseif strcmp(RC.radar_type,'MK3')==1
    RC.BIT_LENGTH=31;  %for an MK3 receiver, a 32 bit AD converter
    RC.IQORDER='radcelf';		% for MK3
end


%%

%%%%% set other constants
% speed of light in vacuum
 c0=2.99792458e8;
 % speed of radio waves in moist tropical air
 c=c0*(1-300/1e6);

%%% transfer coefficients and settings from the setup file to the 
RC.Fc=freq;		% the center frequency
RC.chirp=chirp;		% the chirp interval in s
RC.BW=hf_bw;		% the bandwidth
RC.c=c;			% the speed of light

RC.dds_setup.Fd=Fd;	% delta frequency (DFR), min freq change
RC.dds_setup.Td=Td;	% Ramp rate (RRCR), how many Fds per change
RC.dds_setup.Tr=Tr;	% the number of changes/samples per chirp
RC.dds_setup.Fclk=Fclk;	% clock frequency of the DDSC
RC.dds_setup.fs=fs;	% ADC audio sampling frequency


%to delete 
%%
%clear the rest of this file, should be re-coded in the future
clear F0             Tr         i_FVclk        l_FVclk        lw_fs_ratio    n_hf_lf        w_Fclk ...        
F1             c              dds_step       i_Fclk         l_Fclk         mt             n_pll          w_chirp     ...   
Fclk           c0             fr             i_fs           l_fs           n_FVclk        nl_Fclk_ratio  w_fs       ...   
Fd             chirp          fs             i_hf_lf        l_hf_lf        n_Fclk         range_res      w_hf_lf    ...    
Td             dds            hf_bw          i_pll          l_pll          n_fs           w_FVclk        w_pll ;   

