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
		FunctionDataBase = [];	% T�mb a param�terekkel: [A, cos/sin = 1/2, f, q, B]
		
		AxesTop;
		AxesBottom;
	end
	
	properties
		%TODO: A vez�rl�elemek m�retei lehetnek konstansok, 
		% hogy egyszer�en param�terezhet� legyen a fel�let.
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
			
			this.EditAmplitude = uicontrol('Parent', this.Window, 'Style', 'edit', 'Position', [10 15 90 25]);
			SinePlotter.AddLabel(this.EditAmplitude, 'Amplit�d�');
			
			this.FunctionSelector = uicontrol('Parent', this.Window, 'Style', 'popupmenu', ...
				'Position', [110 15 60 24], 'String', {'cos', 'sin'});
			SinePlotter.AddLabel(this.FunctionSelector, 'F�ggv�ny');
			
			this.EditFrequency = uicontrol('Parent', this.Window, 'Style', 'edit', 'Position', [180 15 90 25]);
			SinePlotter.AddLabel(this.EditFrequency, 'K�rfrekvencia');
			
			this.EditPhase = uicontrol('Parent', this.Window, 'Style', 'edit', 'Position', [280 15 90 25]);
			SinePlotter.AddLabel(this.EditPhase, 'F�zis');
			
			this.EditOffset = uicontrol('Parent', this.Window, 'Style', 'edit', 'Position', [380 15 90 25]);
			SinePlotter.AddLabel(this.EditOffset, 'Eltol�s');
			
			this.AddButton = uicontrol('Style', 'pushbutton', 'String', 'Hozz�ad�s', ...
				'Position', [480 15 90 25], ...
				'Callback', @this.AddFunction);
			
			this.ModifyButton = uicontrol('Style', 'pushbutton', 'String', 'M�dos�t�s', ...
				'Position', [580 15 90 25], 'Enable', 'off');
			%if(this.AddButton 
			
			this.DeleteButton = uicontrol('Style', 'pushbutton', 'String', 'Elt�vol�t�s', ...
				'Position', [680 15 90 25], 'Enable', 'off');
			
			this.FunctionList = uicontrol('Style', 'listbox');
			this.FunctionList.Position = [10, 15+25+20+15, 150, this.Window.Position(4) - (15+25+20) - 2*15];
			
			this.AxesTop = axes('Parent', this.Window, 'Units', 'pixels');
			%TODO Param�teresre alak�tani az elhelyez�st 
			this.AxesTop.Position = [ ...
				15+150+30, ...											% A FunctionList mell� ker�l
				(this.Window.Position(4) - (15+25+20) - 2*15)/2 + (15+25+20+2*25), ...	% Gombok feletti r�sz fele - h�zag
				this.Window.Position(3) - (15+150+30) - 15, ...
				(this.Window.Position(4) - (15+25+20) - 2*15)/3 ... % Az Ablak 1/3-a
				];
			
			title(this.AxesTop, 'Fels� tengelykereszt', 'FontSize', 16, 'FontWeight', 'bold'); 
			
			% A m�sik tengelykereszt
			
			this.AxesBottom = axes('Parent', this.Window, 'Units', 'pixels');
			this.AxesBottom.Position = [ ...
				15+150+30, ...											
				(this.Window.Position(4) - this.Window.Position(4))/2 + (15+25+20+25), ...	
				this.Window.Position(3) - (15+150+30) - 15, ...
				(this.Window.Position(4) - (15+25+20) - 2*15)/3 ...
				];
			
			title(this.AxesBottom, 'Als� tengelykereszt', 'FontSize', 16, 'FontWeight', 'bold'); 
			
			
		end
		
		function AddFunction(this, h, ~, ~)
			% Vez�rl� �rt�k�nek olvas�sa
			A = str2double(this.EditAmplitude.String);			% Ha nem sz�m akkor NaN
			F = str2double(this.EditFrequency.String);
			P = str2double(this.EditPhase.String);
			O = str2double(this.EditOffset.String);
			
			%TODO: Beolvas�si 'callback hiba kik�sz�b�l�se
			
			if ((~isnan(A)) && (~isnan(F)) && (~isnan(P)) && (~isnan(O)))
				% �j elem ker�l az adatb�zisba
				this.FunctionDataBase(end+1, 1:5) = [ ...
					A, ...
					this.FunctionSelector.Value, ...				% 1: cos; 2: sin
					F, ...
					P, ...
					O, ...
					];
				%this.ModifyButton('Enable','on')
			end
		end
		
		function WindowSizeChanged(this, h, ~, ~)
			% Kezelni kell a f�ablak �tm�retez�s�t - minim�lis ablakm�ret
			% megad�sa this.WindowPosition(3) 783, this.WindowPosition(4) 376
			
				
			
				% Meg kell n�velni a f�ggv�ny lista magass�g�t
				% Az �sszef�gg�s ugyanaz, mint a l�trehoz�sn�l, csak friss�l a Window.Position(4)
				this.FunctionList.Position = [10, 15+25+20+15, 150, this.Window.Position(4) - (15+25+20) - 2*15];
			
				this.AxesTop.Position = [ ...
					15+150+30, ...											% A FunctionList mell� ker�l
					(this.Window.Position(4) - (15+25+20) - 2*15)/2 + (15+25+20+2*25), ...	% Gombok feletti r�sz fele
					this.Window.Position(3) - (15+150+30) - 15, ...
					(this.Window.Position(4) - (15+25+20) - 2*15)/3 ... % Az ablak magass�g�nak a harmada
					];
			
			
				this.AxesBottom.Position = [ ...
					15+150+30, ...											
					(this.Window.Position(4) - this.Window.Position(4))/2 + (15+25+20+25), ...	
					this.Window.Position(3) - (15+150+30) - 15, ...
					(this.Window.Position(4) - (15+25+20) - 2*15)/3 ...
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

