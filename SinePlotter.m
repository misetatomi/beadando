classdef SinePlotter < handle
	%SINEPLOTTER Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		
		% A fõablak mutatója
		Window;
		
		EditAmplitude;
		FunctionSelector;
		EditFrequency;
		EditPhase;
		EditOffset;
		
		AddButton;
		ModifyButton;
		DeleteButton;
		
		FunctionList;			% A vezérlõelem (listbox)
		FunctionDataBase = [];	% Tömb a paraméterekkel: [A, cos/sin = 1/2, f, q, B]
		
		AxesTop;
		AxesBottom;
	end
	
	properties
		%TODO: A vezérlõelemek méretei lehetnek konstansok, 
		% hogy egyszerûen paraméterezhetõ legyen a felület.
	end
	
	methods
		
		function this = SinePlotter()
			
			this.CreateWindow();
			
		end
		
		function CreateWindow(this)
			
			this.Window = figure(100);
			this.Window.ToolBar = 'none';
			this.Window.MenuBar = 'none';
			
			% Az ablak legyen legalább 800 képpont széles
			this.Window.Position(3) = 800;
			
			% Az átméretezés kezelése saját függvénnyel
			this.Window.SizeChangedFcn = @this.WindowSizeChanged;
			
			this.EditAmplitude = uicontrol('Parent', this.Window, 'Style', 'edit', 'Position', [10 15 90 25]);
			SinePlotter.AddLabel(this.EditAmplitude, 'Amplitúdó');
			
			this.FunctionSelector = uicontrol('Parent', this.Window, 'Style', 'popupmenu', ...
				'Position', [110 15 60 24], 'String', {'cos', 'sin'});
			SinePlotter.AddLabel(this.FunctionSelector, 'Függvény');
			
			this.EditFrequency = uicontrol('Parent', this.Window, 'Style', 'edit', 'Position', [180 15 90 25]);
			SinePlotter.AddLabel(this.EditFrequency, 'Körfrekvencia');
			
			this.EditPhase = uicontrol('Parent', this.Window, 'Style', 'edit', 'Position', [280 15 90 25]);
			SinePlotter.AddLabel(this.EditPhase, 'Fázis');
			
			this.EditOffset = uicontrol('Parent', this.Window, 'Style', 'edit', 'Position', [380 15 90 25]);
			SinePlotter.AddLabel(this.EditOffset, 'Eltolás');
			
			this.AddButton = uicontrol('Style', 'pushbutton', 'String', 'Hozzáadás', ...
				'Position', [480 15 90 25], ...
				'Callback', @this.AddFunction);
			
			this.ModifyButton = uicontrol('Style', 'pushbutton', 'String', 'Hozzáadás', ...
				'Position', [580 15 90 25], 'Enable', 'off');
			
			this.DeleteButton = uicontrol('Style', 'pushbutton', 'String', 'Eltávolítás', ...
				'Position', [680 15 90 25], 'Enable', 'off');
			
			this.FunctionList = uicontrol('Style', 'listbox');
			this.FunctionList.Position = [10, 15+25+20+15, 150, this.Window.Position(4) - (15+25+20) - 2*15];
			
			this.AxesTop = axes('Parent', this.Window, 'Units', 'pixels');
			%TODO Paraméteresre alakítani az elhelyezést 
			this.AxesTop.Position = [ ...
				15+150+30, ...											% A FunctionList mellé kerül
				(this.Window.Position(4) - (15+25+20) - 2*15)/2 + (15+25+20), ...	% Gombok feletti rész fele - hézag
				this.Window.Position(3) - (15+150+30) - 15, ...
				(this.Window.Position(4) - (15+25+20) - 2*15)/2 ...
				];
			
			title(this.AxesTop, 'Felsõ tengelykereszt', 'FontSize', 16, 'FontWeight', 'bold'); 
			
			%TODO A másik tengelykereszt
			
		end
		
		function AddFunction(this, h, ~, ~)
			% Vezérlõ értékének olvasása
			A = str2double(this.EditAmplitude.String);			% Ha nem szám akkor NaN
			
			%TODO: Ellenõrizni a többi értéket is
			
			if (~isnan(A))
				% Új elem kerül az adatbázisba
				this.FunctionDataBase(end+1, 1:5) = [ ...
					A, ...
					this.FunctionSelector.Value, ...				% 1: cos; 2: sin
					str2double(this.EditFrequency.String), ...
					str2double(this.EditPhase.String), ...
					str2double(this.EditOffset.String) ...
					];
			end
		end
		
		function WindowSizeChanged(this, h, ~, ~)
			% Kezelni kell a fõablak átméretezését
			
			% Meg kell növelni a függvény lista magasságát
			% Az összefüggés ugyanaz, mint a létrehozásnál, csak frissül a Window.Position(4)
			this.FunctionList.Position = [10, 15+25+20+15, 150, this.Window.Position(4) - (15+25+20) - 2*15];
			
			this.AxesTop.Position = [ ...
				15+150+30, ...											% A FunctionList mellé kerül
				(this.Window.Position(4) - (15+25+20) - 2*15)/2 + (15+25+20), ...	% Gombok feletti rész fele
				this.Window.Position(3) - (15+150+30) - 15, ...
				(this.Window.Position(4) - (15+25+20) - 2*15)/2 ...
				];
		end
		
	end
	
	methods (Static)
		
		% Felirat létrehozása már létezõ vezérlõhöz
		function h = AddLabel(control, label)
			
			p = control.Position;
			
			h = uicontrol( ...
				'Parent', control.Parent, ...
				'Style', 'text', ...
				'Position', [p(1), p(2)+p(4), p(3), 20], ...	% A felirat a vezérlõ fölé kerül
				'String', label, ...
				'HorizontalAlignment', 'left' ...
				);
		end
		
	end
	
end

