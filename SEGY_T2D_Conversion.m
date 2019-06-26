%% 

% Select Data files from SEG-Y

fname = '201902*__Ekko_L0_profil-037_proc2.sgy'; %!!!proc2 ändern
%vorher: fname = '201902*__Ekko_L0_profil-*_proc2.sgy';
%!!!jetzt:testing
pname = '/Users/pascale/Documents/Bachelorarbeit/Data/Oberaletsch_Pascale/20190219_Oberaletsch_Testing/L1/';

files = dir([pname fname]);

% Read Data files

%vorher:for i = 1:1%length(files); %!!!1:length(files) ändern
for i = 1:1%length(files); %!!!1:length(files) ändern
    
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


% Stretch from Time to Depth: (SegyPlotData - is the function to plot in
% altitude (Option 4))

    t = (0:params.nsamp-1)*params.sra;

    datum = 2250;
    dz = params.sra/2.0*procp.vice;
    maxalt = datum;%max(params.zeff) + 20;
    minalt = min(params.zeff) - procp.maxdepth;
    nz = round((maxalt - minalt)/dz);
    zz = linspace(-maxalt,-minalt,nz);

    dataz = zeros(nz,params.ntr);
    itopo = round(params.tti/params.sra);
    itopo(itopo < 1) = 1;
    surface_sample = []; %vector with sample number of the surface for each trace in dataz

    for a = 1:params.ntr
    [~,mi] = min(abs(zz+params.zeff(a))); % index of surface altitude
    nins = params.nsamp - itopo(a); % No. of samples to be transferred from data
    i3 = itopo(a);
    i4 = itopo(a)+nins - 1;
    i1 = mi;
    i2 = mi + nins - 1;
    
    if (i2 > nz)
        i4 = i4 - (i2-nz);
        i2 = nz;
    end
    dataz(i1:i2,a) = params.data(i3:i4,a);
    surface_sample = [surface_sample,i1];
    end
    
    figure;
    subplot(1,2,1);
    imagesc(params.px,t,params.data);
    colormap(gray);colormap;caxis([-1e5 1e5]);
    title('Before T2D Conversion')
    subplot(1,2,2);
    imagesc(params.px,zz,dataz);
    colormap(gray);colormap;caxis([-1e5 1e5]);
    title('After T2D Conversion')
    
    params.data = dataz;

% Write Data to SEG-Y

    p = p + 1;
    handle_segy_write(p,params,procp,proc_steps);

end