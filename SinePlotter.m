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
		FunctionDataBase = cell(0, 6);		% Cellatömb a paraméterekkel: {A, cos/sin = 1/2, f, q, B, plot_handle}
		
		AxesTop;
		AxesBottom;
		
		XLim = [0, 1];
		
	end
	
	properties(Constant)
		%TODO: A vezérlõelemek méretei lehetnek konstansok, 
		% hogy egyszerûen paraméterezhetõ legyen a felület.
		
		H_1 = 30;	% Hézagok
		H_2 = 60;
		H_3 = 20;
		
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
			
			this.ModifyButton = uicontrol('Style', 'pushbutton', 'String', 'Módosítás', ...
				'Position', [580 15 90 25], 'Enable', 'off');
						
			this.DeleteButton = uicontrol('Style', 'pushbutton', 'String', 'Eltávolítás', ...
				'Position', [680 15 90 25], 'Enable', 'on', 'Callback', @this.RemoveFunction);
			
			this.FunctionList = uicontrol('Style', 'listbox');
			this.FunctionList.Position = [10, 15+25+20+15, SinePlotter.L_0, this.Window.Position(4) - (15+25+20) - 2*15];
			
			this.AxesTop = axes('Parent', this.Window, 'Units', 'pixels');
			%TODO Paraméteresre alakítani az elhelyezést 
			%TODO függvényeket csinálni a méretezéshez
			this.AxesTop.Position = [ ...
				15+SinePlotter.L_0+30, ...											% A FunctionList mellé kerül
				this.GetAxisHeight() + (2*15 + 25 + 20 + SinePlotter.H_2 + SinePlotter.H_3), ...	% Gombok feletti rész fele - hézag
				this.Window.Position(3) - (15+SinePlotter.L_0+30) - 15, ...
				this.GetAxisHeight() ... % Gombok feletti rész fele - hézag
				];
			
			title(this.AxesTop, 'Felsõ tengelykereszt', 'FontSize', 16, 'FontWeight', 'bold');
			hold(this.AxesTop, 'on');
			
			% A másik tengelykereszt
			
			this.AxesBottom = axes('Parent', this.Window, 'Units', 'pixels');
			this.AxesBottom.Position = [ ...
				15+SinePlotter.L_0+30, ...											
				15+25+20+15 + SinePlotter.H_3, ...	
				this.Window.Position(3) - (15+SinePlotter.L_0+30) - 15, ...
				this.GetAxisHeight() ...
				];
			
			title(this.AxesBottom, 'Alsó tengelykereszt', 'FontSize', 16, 'FontWeight', 'bold'); 
			hold(this.AxesBottom, 'on');
			
		end
		
		function a_y = GetAxisHeight(this)
			% A tengelykeresztek magassága
			a_y = (this.Window.Position(4) - 2*15 - SinePlotter.H_1 - SinePlotter.H_2 - SinePlotter.H_3 - 25 - 20)/2;
		end
		
		function AddFunction(this, h, ~, ~)
			% Vezérlõ értékének olvasása
			A = str2double(this.EditAmplitude.String);			% Ha nem szám akkor NaN
			F = eval(this.EditFrequency.String);
			P = str2double(this.EditPhase.String);
			O = str2double(this.EditOffset.String);
			
			%TODO: Beolvasási 'callback hiba kiküszöbölése
			
			if ((~isnan(A)) && (~isnan(F)) && (~isnan(P)) && (~isnan(O)))
				% Új elem kerül az adatbázisba
				this.FunctionDataBase(end+1, 1:6) = { ...
					A, ...
					this.FunctionSelector.Value, ...				% 1: cos; 2: sin
					F, ...
					P, ...
					O, ...
					0 ...
					};
				%this.ModifyButton('Enable','on')
				
				this.FunctionList.String{end+1} = this.ParamToString();
				
				% Ábrázolás
				this.CreatePlot(size(this.FunctionDataBase, 1));
				
			else
				msgbox('Hiba történt!', 'Hiba!', 'error');
			end
		end
		
		function RemoveFunction(this, h, ~, ~)
			% TODO Hibakezelés (nincs kiválasztás, üres a lista, ...)
			i = this.FunctionList.Value;
			this.FunctionList.String(i) = [];
			
			delete(this.FunctionDataBase{i, 6});
			
			this.FunctionDataBase(i, :) = [];
			
			drawnow;
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
			% Kezelni kell a fõablak átméretezését - minimális ablakméret
			% megadása this.WindowPosition(3) 783, this.WindowPosition(4) 376
				
			% Meg kell növelni a függvény lista magasságát
			% Az összefüggés ugyanaz, mint a létrehozásnál, csak frissül a Window.Position(4)
			this.FunctionList.Position = [10, 15+25+20+15, SinePlotter.L_0, this.Window.Position(4) - (15+25+20) - 2*15];

			this.AxesTop.Position = [ ...
				15+SinePlotter.L_0+30, ...											% A FunctionList mellé kerül
				this.GetAxisHeight() + (2*15 + 25 + 20 + SinePlotter.H_2 + SinePlotter.H_3), ...	% Gombok feletti rész fele - hézag
				this.Window.Position(3) - (15+SinePlotter.L_0+30) - 15, ...
				this.GetAxisHeight() ... % Gombok feletti rész fele - hézag
				];

			this.AxesBottom.Position = [ ...
				15+SinePlotter.L_0+30, ...											
				15+25+20+15 + SinePlotter.H_3, ...	
				this.Window.Position(3) - (15+SinePlotter.L_0+30) - 15, ...
				this.GetAxisHeight() ...
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

