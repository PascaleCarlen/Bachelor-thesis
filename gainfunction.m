% Select Data files from SEG-Y

fname = '201902*__Ekko_L0_profil-*_proc5.sgy'; 
pname = '/Users/pascale/Documents/Bachelorarbeit/Data/Oberaletsch_Pascale/20190219_Oberaletsch_Testing/L1/';

files = dir([pname fname]);

% Read Data files


for i = 1:length(files); %!!!1:length(files) ändern
    
    [params.fname, params.pname, params.comments,params.offset,...
     params.ntr,params.nsamp,params.sra,...
     params.px,params.py,params.pz,params.data,params.zdem,...
     params.origpx,params.origpy,params.tti,params.zeff,...
     params.vel,params.head,params.azi,params.pitch,params.roll,params.hag,...
     params.profnr,params.date,params.info,...
     p,proc_steps] = read_in_sgy(files(i).name,pname);
 
    procp = make_procp(params.comments,params);
    
	[params.segyfolder,params.plotfolder,params.pickfolder,...
     params.matdata,params.tag,params.tag2] = create_variable_names(params);

  %Apply spherical divergence correction (gain)
	t = 0:params.sra:params.sra*(params.nsamp-1);
    vice = 0.1689;
	radius = t/2 * vice;
    z = t/2.0*vice;

    sphdiv = repelem(radius,params.ntr,1)';
    params.data = params.data .* sphdiv;


% Write Data to SEG-Y

    p = p + 1;
    handle_segy_write(p,params,procp,proc_steps);

end