    function t = text_corner(varargin)
%% function t = text_corner({{ax}}, txt, {corner}, {{{[color]}}} )
% this function generates a text (txt) in the corner of the 
% axis (ax) with color (color), where (t) is the text property handel
%
%  t = text_corner(ax, txt, corner)
%
%  t = text_corner(txt, corner)
%
%  t = text_corner(txt)
%       puts txt above plot like title
%
%   text_corner
%       returns an example plot with all corner numbers    

warning off;

switch nargin
    case 0
        figure
            plot([1 1], [1 1]);
            for i=[1:9]
              t = text_corner(num2str(i), i);
              t.FontSize = 14;
              t.FontWeight = 'bold';
            end
            for i=[-9:-6 -4:-1 12 23 45 56 78 89 14 25 36 47 58 69 ...
                  1245 2356 4578 5689 -12 -23 -14 -36 -47 -69 -78 -89]
              t = text_corner(num2str(i), i);
            end
            set(gca,'Xticklabel',{},'Yticklabel',{});
    case 1 
        t = text_corner(gca, varargin{1}, 5);
    case 2
        t = text_corner(gca, varargin{1}, varargin{2});
    case 4 
        t = text_corner(varargin{1}, varargin{2}, varargin{3});
            t.Color = varargin{4};
    case 3
            ax  = varargin{1};
            txt = varargin{2};
            corner = varargin{3};
        switch corner
            case 1
                t = text(.01, .99, txt,'units','normalized','horizontalalignment','left', ...
                    'verticalalignment', 'top','Parent',ax);
            case 2
                t = text(.5, .99, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'top', 'Parent',ax);
            case 3
                t = text(.99, .99, txt,'units','normalized','horizontalalignment','right',...
                     'verticalalignment', 'top','Parent',ax);
            case 4
                t = text(.01, .5, txt,'units','normalized','horizontalalignment','left',...,
                    'verticalalignment', 'middle', 'Parent',ax);
            case 5
                t = text(.5, .5, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'middle', 'Parent',ax);
            case 6
                t = text(.99, .5, txt,'units','normalized','horizontalalignment','right',...,
                    'verticalalignment', 'middle', 'Parent',ax);
            case 7
                t = text(.01, .01, txt,'units','normalized','horizontalalignment','left',...
                    'verticalalignment', 'bottom', 'Parent',ax);
            case 8
                t = text(.5, .01, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'bottom', 'Parent',ax);
            case 9
                t = text(.99, .01, txt,'units','normalized','horizontalalignment','right',...,
                    'verticalalignment', 'bottom', 'Parent',ax);
            case 0
                t = text(.5, 1.01, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'bottom', 'Parent',ax);
            case -1
                t = text(.01, 1.01, txt,'units','normalized','horizontalalignment','left', ...
                    'verticalalignment', 'bottom','Parent',ax);
            case {-2, 10}
                t = text(.5, 1.01, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'bottom', 'Parent',ax);
            case -3
                t = text(.99, 1.01, txt,'units','normalized','horizontalalignment','right',...
                     'verticalalignment', 'bottom','Parent',ax);
            case -4
                t = text(-.01, .5, txt,'units','normalized','horizontalalignment','right',...,
                    'verticalalignment', 'middle', 'Parent',ax);
            case -5
                t = text(.5, .5, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'middle', 'Parent',ax);
            case -6
                t = text(1.01, .5, txt,'units','normalized','horizontalalignment','left',...,
                    'verticalalignment', 'middle', 'Parent',ax);
            case -7
                t = text(.01, -.01, txt,'units','normalized','horizontalalignment','left',...
                    'verticalalignment', 'top', 'Parent',ax);
            case -8
                t = text(.5, -.01, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'top', 'Parent',ax);
            case -9
                t = text(.99, -.01, txt,'units','normalized','horizontalalignment','right',...,
                    'verticalalignment', 'top', 'Parent',ax);

            case {12 , 21}
                t = text(.25, .99, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'top', 'Parent',ax);
            case {23 , 32}
                t = text(.75, .99, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'top', 'Parent',ax);
            case {45 , 54}
                t = text(.25, .5, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'middle', 'Parent',ax);
            case {56, 65}
                t = text(.75, .5, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'middle', 'Parent',ax);
            case {78 , 87}
                t = text(.25, .01, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'bottom', 'Parent',ax);
            case {89 , 98}
                t = text(.75, .01, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'bottom', 'Parent',ax);

            case {14, 41}
                t = text(.01, .75, txt,'units','normalized','horizontalalignment','left',...,
                    'verticalalignment', 'middle', 'Parent',ax);
            case {47, 74}
                t = text(.01, .25, txt,'units','normalized','horizontalalignment','left',...,
                    'verticalalignment', 'middle', 'Parent',ax);
            case {36, 63}
                t = text(.99, .75, txt,'units','normalized','horizontalalignment','right',...,
                    'verticalalignment', 'middle', 'Parent',ax);
            case {69, 96}
                t = text(.99, .25, txt,'units','normalized','horizontalalignment','right',...,
                    'verticalalignment', 'middle', 'Parent',ax);
            case {25, 52}
                t = text(.5, .75, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'middle', 'Parent',ax);
            case {58, 85}
                t = text(.5, .25, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'middle', 'Parent',ax);

            case {1245, 4512, 1425, 2514}
                t = text(.25, .75, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'middle', 'Parent',ax);
            case {2356, 5623, 2536, 3625}
                t = text(.75, .75, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'middle', 'Parent',ax);
            case {4578, 7845, 4758, 5847}
                t = text(.25, .25, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'middle', 'Parent',ax);
            case {5869, 5689, 6958, 8956, 9865}
                t = text(.75, .25, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'middle', 'Parent',ax);

            case {-12 , -21}
                t = text(.25, 1.01, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'bottom', 'Parent',ax);
            case {-23 , -32}
                t = text(.75, 1.01, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'bottom', 'Parent',ax);
            case {-78 , -87}
                t = text(.25,-.01, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'top', 'Parent',ax);
            case {-89 , -98}
                t = text(.75,-.01, txt,'units','normalized','horizontalalignment','center',...,
                    'verticalalignment', 'top', 'Parent',ax);

            case {-14, -41}
                t = text(-.01, .75, txt,'units','normalized','horizontalalignment','right',...,
                    'verticalalignment', 'middle', 'Parent',ax);
            case {-47, -74}
                t = text(-.01, .25, txt,'units','normalized','horizontalalignment','right',...,
                    'verticalalignment', 'middle', 'Parent',ax);
            case {-36, -63}
                t = text(1.01, .75, txt,'units','normalized','horizontalalignment','left',...,
                    'verticalalignment', 'middle', 'Parent',ax);
            case {-69, -96}
                t = text(1.01, .25, txt,'units','normalized','horizontalalignment','left',...,
                    'verticalalignment', 'middle', 'Parent',ax);
            otherwise
                disp('choose corner:');
                disp('type text_corner() without arguments to see options');
        end
    otherwise
        disp('!!!!!!!!!!!TOO MANY INPUT ARGUMENTS!!!!!!!!')
end
