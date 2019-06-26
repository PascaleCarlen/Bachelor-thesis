clear all
pname = '/Volumes/NeueFestplatte/Snowhorizons2/';
fname = '201902*__Ekko_L0_profil-*_snowhorizons.txt';

file = dir([pname fname]);

x = [];
y = [];
z_surf = [];
z_hor2 = [];


for i = 1:length(file)
     
    t = readtable([pname file(i).name],'Format','%s%f%f%f%f%f%f');
    x = [x;t.Var2];
    y = [y;t.Var3];
    z_surf = [z_surf;t.Var4]; %ice surface elevation
    z_hor2 = [z_hor2;t.Var6]; %depth below surface of Horizon 2 
  
    
end

% Plot data and check the extent
figure;grid on; hold on;
scatter(x,y,10,z_hor2) %10: Dicke der Linien und Farben sind nach z_hor1
colorbar


%Remove 0m depth from x,y,z_hor2 
ox=x;
oy=y;
oz_hor2=z_hor2;
x=x(z_hor2~=0);
y=y(z_hor2~=0);
z_surf=z_surf(z_hor2~=0);
z_hor2=z_hor2(z_hor2~=0);
figure;grid on;hold on;
scatter(x,y,10,z_hor2)
colorbar

elev_hor = 2250 - z_surf + z_hor2; %damit das Datum passt


%Only run once to pick polygon und dann auskommentieren und load('Horzon2.mat')
% [x1,y1]=getpts
% save('Hor2.mat','x1','y1')

load('Hor2.mat')
%Interpolation grid/area
xx = floor(min(x1)):1:ceil(max(x1)); %X(vom basement) = xx
yy = floor(min(y1)):1:ceil(max(y1));
[XX1,YY1]=meshgrid(xx,yy);

%Interpolation:
ZZ1=griddata(x,y,elev_hor,XX1,YY1);


%Check interpolation is correct
figure;
imagesc(xx,yy,ZZ1)
%war: imagesc(x1,y1,ZZ1)
colorbar


% Smooth Horizon 1
ZZ1_sm=imgaussfilt(ZZ1,[5,5]);

figure;
imagesc(xx,yy,ZZ1_sm)


% Apply boundary 1 to ZZ1_sm
bound1 = boundary(x1,y1);
flag = inpolygon(XX1,YY1,x1(bound1),y1(bound1));
ZZ1_sm(~flag) = NaN;
reshape(ZZ1_sm,length(yy),length(xx));
%war: reshape(ZZ1_sm,length(xx),length(yy));

figure;
imagesc(xx,yy,ZZ1_sm)


% Save X, Y and Z in text file to be read into OpendTect

ascii(:,1)=reshape(XX1,[size(XX1,1)*size(XX1,2),1]);
ascii(:,2)=reshape(YY1,[size(YY1,1)*size(YY1,2),1]);
ascii(:,3)=reshape(ZZ1_sm,[size(ZZ1_sm,1)*size(ZZ1_sm,2),1]);


save('hor2_sm.txt','ascii','-ascii')
%save('Oberaletsch_Hor2_interpolation.mat')