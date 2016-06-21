function h = SubplotLetterMW( letter, x_pct, y_pct, fsize )
%function h = SubplotLetterMW( letter, x_pct, y_pct, fsize )
%   add letter label to the current panel, calcualted
%   from northwestward corner
%   
% ZZX @ APL-UW 2010-03

%% display
%disp('Calling function SubplotLetterMW ... ')

if nargin < 1, return; end
if nargin < 2, x_pct = 0.05; end
if nargin < 3, y_pct = 0.1;  end
if nargin < 4, fsize = 14;   end

%% check xlim and ylim
xlm = get(gca, 'xlim');
x0 = xlm(1); x1 = xlm(2);
ylm = get(gca, 'ylim');
y0 = ylm(1); y1 = ylm(2);

%% Two cases: log and linear
xSC=get(gca, 'XScale');
ySC=get(gca, 'YScale');
yDIR = get(gca, 'ydir' );
xDIR = get(gca, 'xdir' );

%% calculate its y location
if strcmp( ySC,  'linear')
    if strcmp( yDIR, 'reverse')
        y = y0+(y1-y0)*y_pct;
    else
        y = y1-(y1-y0)*y_pct;    
    end
else
    if strcmp( yDIR, 'reverse')
        y = 10^( log10( y0 + y_pct*(log10(y1)-log10(y0)) ) ); 
    else
        y = 10^( log10( y1 - y_pct*(log10(y1)-log10(y0)) ) ); 
    end    
end


%% calculate its x location
if strcmp( ySC,  'linear')
    if strcmp( xDIR, 'reverse')
        x = x1-(x1-x0)*x_pct;
    else
        x = x0+(x1-x0)*x_pct;
    end
else
    if strcmp( xDIR, 'reverse')
        x = 10^( log10( x0 + y_pct*(log10(x1)-log10(x0)) ) ); 
    else
        x = 10^( log10( x1 - y_pct*(log10(x1)-log10(x0)) ) ); 
    end
end

%% add text
h = text(x, y, letter, 'backgroundcolor', 'w' );

%% define fontsize as given
set(h, 'fontsize', fsize);

return;

