

clear;

lght = 1/16;

# CONFIGURATION {{{
global config;
config.line.plot = 0.6;
config.line.separator = 0.7;
config.line.stem = 0.25;
config.line.atm_height = 1.8;
config.line.grid = 0.03;
config.line.boundary = 0.2;

config.color.separator = [0 0 0];
config.color.apoapsis = [.2745*.8 0.7098*.8 0.8274*.8];
config.color.periapsis = config.color.apoapsis;
config.color.altitude = [0*.7 .4*.7 .5*.7];
config.color.atm_height = [1 .80 .92];
#config.color.atm_height = [0 0 0];
config.color.in_atm = [0^lght .4^lght .5^lght];
config.color.speed = [.96 .54 .20];
config.color.thrust = [0.8588 0.2823 0.2980];
config.color.Q = [.5 0 .4];
config.color.mass = [0.3468 0.44 0.2821];
config.color.boundary = [0 0 0];
config.color.time_to_apo = [.2745 0.7098 0.8274];
config.color.time_to_peri = [.2745 0.7098 0.8274];
config.color.eccentricity = [0.9215 0.6431 0.1960];
config.color.inclination = [0.9215 0.6431 0.1960];
config.color.data_sample = [1, 1, 1];
config.color.atm_press = [.56, .56, .56];
config.color.semiminor = 'r';
config.color.semimajor = 'b';

config.fill.outside = [.8 .8 .9];
config.fill.empty = [.66 .66 .66];
config.fill.apoapsis = [.2745^lght 0.7098^lght 0.8274^lght];
config.fill.periapsis = [1 1 1];
config.fill.Q = [.94 .9933 1];
config.fill.thrust = [1 .7 .6];
config.fill.data_sample = [.5 .5 .5];
config.fill.throttle = [1, .9, .6];
config.fill.stage = [1, .9, .6];
config.fill.mass = [.7, .7, .7];
config.fill.atm_press = [.7, .7, .7];
config.fill.time_to_apo = [.2745 0.7098 0.8274];
config.fill.time_to_peri = [.2745 0.7098 0.8274];
config.fill.semiminor = [.8 .8 .9];
config.fill.semimajor = [.8 .8 .9];

config.fontsize.global = 5.5;
config.fontsize.axis = 4;
# }}}

# FUNCTIONS {{{
function [r] = setVisual()
	#set(gca, 'color', [.5 .5 .5]);
	global t config;
	set(gca, 'GridLineStyle','-');
	set(gca, 'linewidth', config.line.grid);

	set(gca, 'xtick', ceil(t.min):(t.gap):floor(t.max));
	set(gca, 'xlim', [(t.min), (t.max)]);
	#set(gca, 'xticklabel', [] );

	set(gca, 'xgrid', 'on');
	set(gca, 'ygrid', 'on');

	set(gca, 'fontsize', (config.fontsize.axis));
endfunction

function [r] = horizLine(y, color, width)
	global t;
	r = line( [(t.min) (t.max)], [y y], 'color', color, 'linewidth', width);
endfunction

function [r] = dataPlot(datum, color, width)
	global t fdata fld;
	r = plot(t.data, fdata(fld.(datum),:), 'color', color, 'linewidth', width);
endfunction

function [r] = dataFill(datum, color, base)
	global t fdata fld;
	r = area(t.data, fdata(fld.(datum),:), 'basevalue', base,
		'facecolor', color, 'edgecolor', color, 'linewidth', 0);
endfunction

function [r b p] = dataSecondPlot(datum, color, width)
	global t fdata fld config;
	[r b p] = plotyy(t.data, zeros(size(t.data)), t.data, fdata(fld.(datum),:));

	set(b, 'linewidth', 0);
	set(b, 'marker', 'none');

	set(p, 'color', color);
	set(p, 'linewidth', width);

	set(r(1), 'GridLineStyle', '-');

	set(r, 'ycolor', 'k');
	set(r, 'xtick', []);
	set(r, 'xlim', [(t.min), t.max]);
	set(r, 'linewidth', (config.line.grid));
	set(r, 'ygrid', 'on');
	set(r, 'fontsize', (config.fontsize.axis));
endfunction

function [r] = dataStem(val, color, width)
	global t fdata fld;

	r = stem(t.data, val, 'marker', 'none', 'color', color, 'linewidth', width);
endfunction

function [r] = addGraph(h)
	global graph;
	r = subplot(graph.number, 1, 1, 'align',
		'position', [graph.width(1), graph.level-h, graph.width(2), h]);
	graph.number = graph.number + 1;
	graph.level = graph.level - h;
	hold on;
endfunction

function [r] = continuosRot(datum)
	global t fdata fld config;
	k = 0;
	p = fdata(fld.(datum), 1);
	for i = 1:(size(fdata)(2))
		n = fdata(fld.(datum), i);
		if n-p > 300
			k = k-1;
		elseif n-p < -300
			k = k+1;
		endif
		p = n;
		fdata(fld.(datum), i) = n + k*360;
	endfor
endfunction

function [c] = absCell(c)
	for i = 1:size(c)(2)
		k = abs(str2num(c{i}));
		c(i) = num2str(k);
	endfor
endfunction
# }}}

# LOAD DATA FILE {{{
global fdata fld;
file = input("Enter FDR filename (without extension): ", "s");
#file = "PID13_log";

source([file ".fdo"]);
fdata = transpose(fdata);

max_stage = max(fdata(fld.("STAGE"),:));

continuosRot("PITCH");
continuosRot("ROLL");
continuosRot("YAW");

t_bound(1) = min(fdata(fld.("MET"),:));
t_bound(2) = max(fdata(fld.("MET"),:));

if (t_bound(1) <= 0) && (t_bound(2) > 0)
	t_begin = find(fdata(fld.("MET"),:)==0)(end);
	t_delta = fdata(fld.("UT"),t_begin) - fdata(fld.("MET"),t_begin);
	for i = 1:(t_begin-1)
		fdata(fld.("MET"),i) = fdata(fld.("UT"),i) - t_delta;
	endfor
endif

#fdata = fdata(:,140:260);
#fdata = fdata(:,600:end);
#fdata = fdata(:,600:700);
#fdata = fdata(:,150:end);
#fdata = fdata(:,19:end);
# }}}

# PAGE SETTINGS {{{
global graph;
graph.number = 1;
graph.width = [0.1 0.8];
graph.level = 0.95;

page = figure(1);
set(page, 'papertype', "a4");
set(page, 'paperorientation', "portrait");
set(page, 'paperunits', "centimeters");
set(page, 'paperpositionmode', "manual");
set(page, 'paperposition', [ .2, 1, 20.8, 28.7] );
set (0, "defaulttextfontsize", 5.5);

clf;
hold on;
# }}}

# SETUP TIME SCALE {{{
global t;
t.data = fdata(fld.("MET"),:);
t.min = (min(t.data));
t.max = (max(t.data));

t.gap = 120;
if ( (t.max-t.min) < 2520 )
	t.gap = 60;
endif
if ( (t.max-t.min) < 1260 )
	t.gap = 30;
endif
if ( (t.max-t.min) < 630 )
	t.gap = 15;
endif
if ( (t.max-t.min) < 420 )
	t.gap = 10;
endif
if ( (t.max-t.min) < 240 )
	t.gap = 5;
endif
if ( (t.max-t.min) < 120 )
	t.gap = 2;
endif
if ( (t.max-t.min) < 60 )
	t.gap = 1;
endif
# }}}

graph.main.h = 0.28;
graph.main.level = graph.level;
graph.number = 2;
graph.level = (graph.level - graph.main.h);
hold on;

% SAMPLES {{{
addGraph(0.006);

dataStem(ones(size(t.data)), config.color.data_sample, config.line.stem);
set(gca, 'color', config.fill.data_sample);
set(gca, 'xticklabel', [] );

set(gca, 'ytick', 0:1);
set(gca, 'yticklabel', [] );
set(gca, 'yaxislocation', 'right');
setVisual();
set(gca, 'xtick', 0:0);

horizLine( get(gca, 'ylim')(2), config.color.separator, config.line.separator);
horizLine( get(gca, 'ylim')(1), config.color.separator, config.line.separator);
% }}}

% THROTTLE {{{
addGraph(0.014);

a = dataFill("THROTTLE", config.fill.throttle, 0);
set(a, 'edgecolor', config.color.boundary);
set(a, 'linewidth', config.line.boundary);

set(gca, 'color', config.fill.empty);

set(gca, 'ytick', 0:.5:1);
set(gca, 'yticklabel', [] );
set(gca, 'yaxislocation', 'right');
set(gca, 'ylabel', 'T (%)');

set(gca,'xticklabel', [] );
setVisual();

horizLine( 0, config.color.separator, config.line.separator);
% }}}

% THRUST / MAXTHRUST {{{
addGraph(0.07);

a1 = dataFill("MAXTHRUST", config.fill.outside, 0); 
a2 = dataFill("THRUST", config.fill.thrust, 0);

dataPlot("THRUST", config.color.thrust, config.line.plot);
bound = get(gca, 'ylim');

set(a2, 'basevalue', bound(1));
set(a1, 'basevalue', bound(2));

set(gca, 'ylabel', 'Thrust (kN)');
set(gca, 'xticklabel', [] );
setVisual();

horizLine( 0, config.color.separator, config.line.separator);
% }}}

% STAGE {{{
addGraph(0.02);

a = dataFill("STAGE", config.fill.stage, 0);
set(a, 'edgecolor', config.color.boundary);
set(a, 'linewidth', config.line.boundary);

set(gca, 'ylim', [-1 max_stage]);

if max_stage > 5
	lbl_gap = 2;
elseif max_stage > 10
	lbl_gap = 3;
else
	lbl_gap = 1;
endif

set(gca, 'ytick', (-1):lbl_gap:(max_stage));
set(gca, 'yticklabel', 0:lbl_gap:(max_stage+1));
axis('ij');

set(a, 'basevalue', -1);
set(gca, 'color', config.fill.empty);

set(gca, 'ylabel', 'Stage');
set(gca, 'yaxislocation', 'right');
set(gca, 'xticklabel', [] );
setVisual();

horizLine( max_stage, config.color.separator, config.line.separator);
% }}}

% MASS   {{{
addGraph(0.07);

a = dataFill("MASS", config.fill.mass, 0);
dataPlot("MASS", config.color.mass, config.line.plot);

set(gca, 'ylabel', 'Mass (t)');

set(gca, 'xticklabel', [] );
setVisual();

horizLine( 0, config.color.separator, config.line.separator);
% }}}

% ATM PRESSURE / Q {{{
# Convert to kPa
addGraph(0.07);

fdata(fld.("ATM PRESSURE"),:) = fdata(fld.("ATM PRESSURE"),:)*atm2kPa;
fdata(fld.("Q"),:) = fdata(fld.("ATM PRESSURE"),:)+(fdata(fld.("Q"),:)*atm2kPa);

a = dataFill("ATM PRESSURE", config.fill.atm_press, 0);
dataPlot("ATM PRESSURE", config.color.atm_press, config.line.plot); 
dataPlot("Q", config.color.Q, config.line.plot); 

set(gca, 'color', config.fill.Q);

set(gca, 'ylabel', 'Pressure (kPa)');
set(gca, 'yaxislocation', 'right');
set(gca, 'xticklabel', [] );
setVisual();

horizLine( 0, config.color.separator, config.line.separator);
% }}}

% TIME TO APO / TIME TO PERI / PERIOD   {{{
addGraph(0.08);

p1 = dataFill("PERIOD", config.fill.outside, 0);
p2 = dataFill("PERIOD", config.fill.outside, 0);
pval = get(p2, 'ydata');
set(p2, 'ydata', -pval);

bound = get(gca, 'ylim');

set(p1, 'basevalue', bound(2));
set(p2, 'basevalue', bound(1));

fdata(fld.("TIME TO PERI"),:) = -fdata(fld.("TIME TO PERI"),:);
#dataFill("TIME TO APO", config.fill.time_to_apo, 0);
#dataFill("TIME TO PERI", config.fill.time_to_peri, 0);

dataPlot("TIME TO APO", config.color.time_to_apo, config.line.plot);
dataPlot("TIME TO PERI", config.color.time_to_peri, config.line.plot);

ylbl = absCell(get(gca, 'yticklabel'));
ylbl(1) = ' ';
set(gca, 'yticklabel', ylbl);

set(gca, 'ylabel', 'Period (s)');
set(gca, 'xticklabel', [] );
setVisual();

horizLine( 0, config.color.separator, config.line.separator);
horizLine( bound(1), config.color.separator, config.line.separator);
% }}}

% SEMIMINOR / SEMIMAJOR / ECCENTRICITY   {{{
addGraph(0.08);

fdata(fld.("SEMIMINOR"),:) = fdata(fld.("SEMIMINOR"),:)/1000;
fdata(fld.("SEMIMAJOR"),:) = fdata(fld.("SEMIMAJOR"),:)/1000;

sd = dataSecondPlot("ECCENTRICITY", config.color.eccentricity, config.line.plot);

#a1 = dataFill("SEMIMINOR", config.fill.semiminor, 0);
#a2 = dataFill("SEMIMAJOR", config.fill.semimajor, 0);
a1 = dataFill("SEMIMINOR", 'w', 0);
a2 = dataFill("SEMIMAJOR", 'w', 0);

dataPlot("SEMIMINOR", config.color.semiminor, config.line.plot);
dataPlot("SEMIMAJOR", config.color.semimajor, config.line.plot);

bound = get(gca, 'ylim');

set(gca, 'color', config.fill.semiminor);

set(a1, 'basevalue', bound(1));
set(a2, 'basevalue', bound(2));

set(sd(2), 'ylabel', 'Eccentricity');
set(gca, 'ylabel', 'Radius (km)');
set(gca, 'xticklabel', [] );
setVisual();

horizLine( 0, config.color.separator, config.line.separator);
% }}}

% INCLINATION   {{{
addGraph(0.05);

horizLine( 0, config.color.separator, config.line.separator);

dataPlot("INCLINATION", config.color.inclination, config.line.plot);

#bound = get(gca, 'ylim');

#set(gca, 'ytick', (bound(1)):90:(bound(2)) );
set(gca, 'ylabel', 'Inclination (°)');

ylbl = get(gca, 'yticklabel');
ylbl(end) = ' ';
set(gca, 'yticklabel', ylbl);

set(gca, 'xticklabel', [] );
setVisual();

horizLine( bound(1), config.color.separator, config.line.separator);
% }}}

% YAW / PITCH / ROLL   {{{
addGraph(0.05);

horizLine( 0, config.color.separator, config.line.separator);

dataPlot("YAW", 'r', config.line.plot);

bound = get(gca, 'ylim');

#set(gca, 'ytick', (bound(1)):90:(bound(2)) );
set(gca, 'yaxislocation', 'right');
set(gca, 'ylabel', 'Yaw (°)');

set(gca, 'xticklabel', [] );
setVisual();

horizLine( bound(1), config.color.separator, config.line.separator);


addGraph(0.05);

horizLine( 0, config.color.separator, config.line.separator);

dataPlot("PITCH", 'g', config.line.plot);

bound = get(gca, 'ylim');

#set(gca, 'ytick', (bound(1)):90:(bound(2)) );
set(gca, 'ylabel', 'Pitch (°)');

set(gca, 'xticklabel', [] );
setVisual();

horizLine( bound(1), config.color.separator, config.line.separator);


addGraph(0.05);

horizLine( 0, config.color.separator, config.line.separator);

dataPlot("ROLL", 'b', config.line.plot);

bound = get(gca, 'ylim');

#set(gca, 'ytick', (bound(1)):90:(bound(2)) );
set(gca, 'yaxislocation', 'right');
set(gca, 'ylabel', 'Roll (°)');
set(gca, 'xlabel', 'Time (s)');

#set(gca, 'xticklabel', [] );
setVisual();

horizLine( bound(1), config.color.separator, config.line.separator);
% }}}

% ALTITUDE / SPEED / APOAPSIS / PERIAPSIS / ATM HEIGHT   {{{
graph.level = graph.main.level;
addGraph(graph.main.h);
fdata(fld.("PERIAPSIS"),:) = max(fdata(fld.("PERIAPSIS"),:),0);

sd = dataSecondPlot("SPEED", config.color.speed, config.line.plot);

a1 = dataFill("APOAPSIS", 'w', 0);
a2 = dataFill("PERIAPSIS", config.fill.periapsis, 0);

if  ( max(fdata(fld.("APOAPSIS"),:)) > max(fdata(fld.("ATM HEIGHT"))) )
#	&& ( min(fdata(fld.("PERIAPSIS"),:)) < min(fdata(fld.("ATM HEIGHT"))) ) )
	ah = dataPlot("ATM HEIGHT", config.color.atm_height, config.line.atm_height);
endif
#set(gca, 'children', get(gca, 'children')([4 1 2 3]));

dataPlot("ALTITUDE", config.color.altitude, config.line.plot);
dataPlot("APOAPSIS", config.color.apoapsis, config.line.plot);
dataPlot("PERIAPSIS", config.color.periapsis, config.line.plot);

bound = get(gca, 'ylim');

set(a2, 'basevalue', bound(1));
set(a1, 'basevalue', bound(2));

set(sd(2), 'ylabel', 'Speed (m/s)');
set(gca, 'ylabel', 'Height (m)');

set(gca, 'color', config.fill.apoapsis);
set(gca, 'xaxislocation', 'top');
setVisual();

horizLine( bound(1), config.color.separator, config.line.separator);
horizLine( bound(2), config.color.separator, config.line.separator);

#set(gca, 'children', get(gca, 'children')([6 1 2 3 4 5 7 8 9]));
% }}}

print(1, file, '-dsvg');
print(1, file, '-dpdf');

# vim: fdc=6 fdm=marker :
