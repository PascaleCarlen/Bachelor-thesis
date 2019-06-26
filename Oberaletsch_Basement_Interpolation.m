clear all
pname = '/Users/pascale/Documents/Bachelorarbeit/Data/Oberaletsch_Pascale/20190219_Oberaletsch/L2/';
fname = '201902*__Ekko_L0_profil-*_bedrock.txt';

file = dir([pname fname]);

x = [];
y = [];
z_surf = [];
z_basement = [];
thickness = [];
w = [];

for i = 1:length(file)
    t = readtable([pname file(i).name],'Format','%s%f%f%f%f%f%f%f%f%f');
    
    x = [x;t.Var2];
    y = [y;t.Var3];
    z_surf = [z_surf;t.Var4]; %ice surface elevation
    z_basement = [z_basement;t.Var5]; %bedrock elevation
    thickness = [thickness;t.Var6]; %surface - basement
    w = [w;t.Var7]; %1 or 2
    
end

%Also add to X,Y,z_surf,z_basment and thickness the glacier outline:
% Read in glacier outline
outline=dlmread('oa_rand_20090908.xyzn');
glacx=outline(1:1959,1); %Only using first 1959 points as main contour
glacy=outline(1:1959,2);
glacz_surf=outline(1:1959,3);


%Read: https://ch.mathworks.com/help/matlab/ref/griddata.html

% Set-up Interpolation Grid...
%Every 1m from 
X = 642700:1:643400;
Y = 139520:1:140200;
% Test area:
% X = 643000:1:643100;
% Y = 139720:1:139820;

% Remove 0 thickness from x,y,z_basement
ox = x;
oy = y;
ozbasement = z_basement;
x = x(thickness~=0);
y = y(thickness~=0);
z_basement = z_basement(thickness~=0); 

% Add glacier outline to be 0 thickness:
x = vertcat(x,glacx); %vertcat: addiert 2 Vektoren senkrecht untereinander
y = vertcat(y,glacy);
z_basement = vertcat(z_basement,glacz_surf);

[XX,YY] = meshgrid(X,Y);

% Interpolate

ZZ = griddata(x,y,z_basement,XX,YY);

% Check interpolation is correct...

figure;
imagesc(X,Y,ZZ)
caxis([2050 2180]) %sonst erkennt man nichts
colorbar
title('Interpolation: X,Y,ZZ')

% Smooth Basement and QC
ZZ_sm = imgaussfilt(ZZ,[10,10]); %Max 10 in smoothing

% Remove data that is outside of glacier area
bound = boundary(glacx,glacy);
flag = inpolygon(XX,YY,glacx(bound),glacy(bound));
ZZ_sm(~flag) = NaN;
reshape(ZZ_sm,length(Y),length(X));


% Check interpolation and flag drop is correct...

figure;
imagesc(X,Y,ZZ_sm)
caxis([2050 2180])
colorbar
title('Data removed outside of glacier area')

% Ensure that horizon is in depth at same datum
% Datum of data: 2250 m

Elev_Bed = 2250 - ZZ_sm; % meters below surface
%2250=0s bei OpendTect ganz oben

figure;
imagesc(X,Y,Elev_Bed)
caxis([0 300])
colorbar
title('Interpolated and Elevation below datum=2250m is shown')
% Save X, Y and Z in text file to be read into OpendTect

ascii(:,1) = reshape(XX,[size(XX,1)*size(XX,2),1]);
ascii(:,2) = reshape(YY,[size(YY,1)*size(YY,2),1]);
ascii(:,3) = reshape(Elev_Bed,[size(Elev_Bed,1)*size(Elev_Bed,2),1]);
% save('basementinterpol.txt','ascii','-ascii') 
%save('Oberaletsch_Basement_ThicknessInterpolation.mat')
