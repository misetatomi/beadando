classdef SinePlotter < handle
	%SINEPLOTTER Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		
		% A f�ablak mutat�ja
		Window;
		
		EditAmplitude;
		FunctionSelector;
		EditFrequency;
		EditPhase;
		EditOffset;
		
		AddButton;
		ModifyButton;
		DeleteButton;
		
		FunctionList;			% A vez�rl�elem (listbox)
		FunctionDataBase = cell(0, 6);		% Cellat�mb a param�terekkel: {A, cos/sin = 1/2, f, q, B, plot_handle}
		
		AxesTop;
		AxesBottom;
		
		XLim = [0, 1];
		
	end
	
	properties(Constant)
		
		H_1 = 30;	% H�zagok
		H_2 = 60;
		H_3 = 20;
		H_4 = 15;
		
		B_h = 25; % Gombmagass�g
		B_w = 90; % Gombsz�less�g
		
		
		L_0 = 180;
	end
	
	methods
		
		function this = SinePlotter()
			
			this.CreateWindow();
			
		end
		
		function CreateWindow(this)
			
			this.Window = figure(100);
			this.Window.ToolBar = 'none';
			this.Window.MenuBar = 'none';
			
			% Az ablak legyen legal�bb 800 k�ppont sz�les
			this.Window.Position(3) = 800;
			
			% Az �tm�retez�s kezel�se saj�t f�ggv�nnyel
			this.Window.SizeChangedFcn = @this.WindowSizeChanged;
			
			this.EditAmplitude = uicontrol('Parent', this.Window, 'Style', 'edit', 'Position', [10 SinePlotter.H_4 SinePlotter.B_w SinePlotter.B_h]);
			SinePlotter.AddLabel(this.EditAmplitude, 'Amplit�d�');
			
			this.FunctionSelector = uicontrol('Parent', this.Window, 'Style', 'popupmenu', ...
				'Position', [110 SinePlotter.H_4 60 SinePlotter.B_h], 'String', {'cos', 'sin'});
			SinePlotter.AddLabel(this.FunctionSelector, 'F�ggv�ny');
			
			this.EditFrequency = uicontrol('Parent', this.Window, 'Style', 'edit', 'Position', [180 SinePlotter.H_4 SinePlotter.B_w SinePlotter.B_h]);
			SinePlotter.AddLabel(this.EditFrequency, 'K�rfrekvencia');
			
			this.EditPhase = uicontrol('Parent', this.Window, 'Style', 'edit', 'Position', [280 SinePlotter.H_4 SinePlotter.B_w SinePlotter.B_h]);
			SinePlotter.AddLabel(this.EditPhase, 'F�zis');
			
			this.EditOffset = uicontrol('Parent', this.Window, 'Style', 'edit', 'Position', [380 SinePlotter.H_4 SinePlotter.B_w SinePlotter.B_h]);
			SinePlotter.AddLabel(this.EditOffset, 'Eltol�s');
			
			this.AddButton = uicontrol('Style', 'pushbutton', 'String', 'Hozz�ad�s', ...
				'Position', [480 SinePlotter.H_4 SinePlotter.B_w SinePlotter.B_h], ...
				'Callback', @this.AddFunction);
			
			this.ModifyButton = uicontrol('Style', 'pushbutton', 'String', 'M�dos�t�s', ...
				'Position', [580 SinePlotter.H_4 SinePlotter.B_w SinePlotter.B_h], 'Enable', 'on', 'Callback', @this.ModifyFunction);
						
			this.DeleteButton = uicontrol('Style', 'pushbutton', 'String', 'Elt�vol�t�s', ...
				'Position', [680 SinePlotter.H_4 SinePlotter.B_w SinePlotter.B_h], 'Enable', 'on', 'Callback', @this.RemoveFunction);
			
			this.FunctionList = uicontrol('Style', 'listbox');
			this.FunctionList.Position = [10, SinePlotter.H_4+SinePlotter.B_h+SinePlotter.H_3+SinePlotter.H_4, SinePlotter.L_0, this.Window.Position(4) - (SinePlotter.H_4+SinePlotter.B_h+SinePlotter.H_3) - 2*15];
			
			this.AxesTop = axes('Parent', this.Window, 'Units', 'pixels');
			%TODO f�ggv�nyeket csin�lni a m�retez�shez
			this.AxesTop.Position = [ ...
				15 + SinePlotter.L_0 + 30, ...											% A FunctionList mell� ker�l
				this.GetAxisHeight() + (2*SinePlotter.H_4 + SinePlotter.B_h + 20 + SinePlotter.H_2 + SinePlotter.H_3), ...	% Gombok feletti r�sz fele - h�zag
				this.Window.Position(3) - (SinePlotter.H_4 + SinePlotter.L_0 + 30) - 15, ...
				this.GetAxisHeight() ... % Gombok feletti r�sz fele - h�zag
				];
			
			title(this.AxesTop, 'Fels� tengelykereszt', 'FontSize', 16, 'FontWeight', 'bold');
			hold(this.AxesTop, 'on');
			
			% A m�sik tengelykereszt
			
			this.AxesBottom = axes('Parent', this.Window, 'Units', 'pixels');
			this.AxesBottom.Position = [ ...
				15+SinePlotter.L_0 + 30, ...											
				SinePlotter.H_4 + SinePlotter.B_h + 20 + 15 + SinePlotter.H_3, ...	
				this.Window.Position(3) - (SinePlotter.H_4 + SinePlotter.L_0 + 30) - 15, ...
				this.GetAxisHeight() ...
				];
			
			title(this.AxesBottom, 'Als� tengelykereszt', 'FontSize', 16, 'FontWeight', 'bold'); 
			hold(this.AxesBottom, 'on');
			
		end
		
		function a_y = GetAxisHeight(this)
			% A tengelykeresztek magass�ga
			a_y = (this.Window.Position(4) - 2*SinePlotter.H_4 - SinePlotter.H_1 - SinePlotter.H_2 - SinePlotter.H_3 - 25 - 20)/2;
		end
		
		function AddFunction(this, h, ~, ~)
			% Vez�rl� �rt�k�nek olvas�sa
			A = eval(this.EditAmplitude.String);			% Ha nem sz�m akkor NaN
			F = eval(this.EditFrequency.String);
			P = eval(this.EditPhase.String);
			O = eval(this.EditOffset.String);
			
			if ((~isnan(A)) && (~isnan(F)) && (~isnan(P)) && (~isnan(O)))
				% �j elem ker�l az adatb�zisba
				this.FunctionDataBase(end+1, 1:6) = { ...
					A, ...
					this.FunctionSelector.Value, ...				% 1: cos; 2: sin
					F, ...
					P, ...
					O, ...
					0 ...
					};
				
				this.FunctionList.String{end+1} = this.ParamToString();
				
				% �br�zol�s
				this.CreatePlot(size(this.FunctionDataBase, 1));
				
			else
				msgbox('Hiba t�rt�nt!', 'Hiba!', 'error');
			end
		end
		
		function RemoveFunction(this, h, ~, ~)
			% TODO Hibakezel�s (nincs kiv�laszt�s, �res a lista, ...)
			i = this.FunctionList.Value;
			this.FunctionList.String(i) = [];
			
			delete(this.FunctionDataBase{i, 6});
			
			this.FunctionDataBase(i, :) = [];
			
			drawnow;
		end
		
		function ModifyFunction(this, h, ~, ~)
		% TODO meg�rni hogy m�k�dj�n...
			
			
		end
		
		function p = CreatePlot(this, i)
			
			a = [this.FunctionDataBase{i, 1:5}];
			
			f = @(t) a(1)*cos(a(3) * t + a(4)) + a(5);
			if(a(2) == 2)
				% Szinusz
				f = @(t) a(1)*sin(a(3) * t + a(4)) + a(5);
			end
			
			t = [0:(2*pi/a(3)/100):1, 1];
			p = plot(this.AxesTop, t, f(t), 'LineWidth', 2); 
			
			this.FunctionDataBase{i, 6} = p;
			
		end
		
		function str = ParamToString(this)
			
			f = ' cos';
			if (this.FunctionSelector.Value == 2)
				f = ' sin';
			end
				
			str = [ ...
				this.EditAmplitude.String, ...
				f, '(', ...
				this.EditFrequency.String, ' t + ', ...
				this.EditPhase.String, ') + ', ...
				this.EditOffset.String ...
				];
		end
		
		function WindowSizeChanged(this, h, ~, ~)
			
			% Meg kell n�velni a f�ggv�ny lista magass�g�t
			% Az �sszef�gg�s ugyanaz, mint a l�trehoz�sn�l, csak friss�l a Window.Position(4)
			this.FunctionList.Position = [10, 15+25+20+15, SinePlotter.L_0, this.Window.Position(4) - (15+25+20) - 2*15];

			this.AxesTop.Position = [ ...
				15+SinePlotter.L_0+30, ...											% A FunctionList mell� ker�l
				this.GetAxisHeight() + (2*SinePlotter.H_4 + SinePlotter.B_h + 20 + SinePlotter.H_2 + SinePlotter.H_3), ...	% Gombok feletti r�sz fele - h�zag
				this.Window.Position(3) - (SinePlotter.H_4 + SinePlotter.L_0 + 30) - 15, ...
				this.GetAxisHeight() ... % Gombok feletti r�sz fele - h�zag
				];

			this.AxesBottom.Position = [ ...
				15+SinePlotter.L_0+30, ...											
				SinePlotter.H_4 + SinePlotter.B_h+20+15 + SinePlotter.H_3, ...	
				this.Window.Position(3) - (15+SinePlotter.L_0 + 30) - 15, ...
				this.GetAxisHeight() ...
				];
			
		end
	end
	
	methods (Static)
		
		% Felirat l�trehoz�sa m�r l�tez� vez�rl�h�z
		function h = AddLabel(control, label)
			
			p = control.Position;
			
			h = uicontrol( ...
				'Parent', control.Parent, ...
				'Style', 'text', ...
				'Position', [p(1), p(2)+p(4), p(3), 20], ...	% A felirat a vez�rl� f�l� ker�l
				'String', label, ...
				'HorizontalAlignment', 'left' ...
				);
		end
		
	end
	
end

