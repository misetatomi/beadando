classdef SinePlotter < handle
	%SINEPLOTTER Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		
		% A fõablak mutatója
		Window;
		SumPlot;
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
		
		H_1 = 30;	% Hézagok
		H_2 = 60;
		H_3 = 20;
		H_4 = 15;
		
		B_h = 25; % Gombmagasság
		B_w = 90; % Gombszélesség
		
		
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
			
			this.EditAmplitude = uicontrol('Parent', this.Window, 'Style', 'edit', 'Position', [10 SinePlotter.H_4 SinePlotter.B_w SinePlotter.B_h]);
			SinePlotter.AddLabel(this.EditAmplitude, 'Amplitúdó');
			
			this.FunctionSelector = uicontrol('Parent', this.Window, 'Style', 'popupmenu', ...
				'Position', [110 SinePlotter.H_4 60 SinePlotter.B_h], 'String', {'cos', 'sin'});
			SinePlotter.AddLabel(this.FunctionSelector, 'Függvény');
			
			this.EditFrequency = uicontrol('Parent', this.Window, 'Style', 'edit', 'Position', [180 SinePlotter.H_4 SinePlotter.B_w SinePlotter.B_h]);
			SinePlotter.AddLabel(this.EditFrequency, 'Körfrekvencia');
			
			this.EditPhase = uicontrol('Parent', this.Window, 'Style', 'edit', 'Position', [280 SinePlotter.H_4 SinePlotter.B_w SinePlotter.B_h]);
			SinePlotter.AddLabel(this.EditPhase, 'Fázis');
			
			this.EditOffset = uicontrol('Parent', this.Window, 'Style', 'edit', 'Position', [380 SinePlotter.H_4 SinePlotter.B_w SinePlotter.B_h]);
			SinePlotter.AddLabel(this.EditOffset, 'Eltolás');
			
			this.AddButton = uicontrol('Style', 'pushbutton', 'String', 'Hozzáadás', ...
				'Position', [480 SinePlotter.H_4 SinePlotter.B_w SinePlotter.B_h], ...
				'Callback', @this.AddFunction);
			
			this.ModifyButton = uicontrol('Style', 'pushbutton', 'String', 'Módosítás', ...
				'Position', [580 SinePlotter.H_4 SinePlotter.B_w SinePlotter.B_h], 'Enable', 'on', 'Callback', @this.ModifyFunction);
						
			this.DeleteButton = uicontrol('Style', 'pushbutton', 'String', 'Eltávolítás', ...
				'Position', [680 SinePlotter.H_4 SinePlotter.B_w SinePlotter.B_h], 'Enable', 'on', 'Callback', @this.RemoveFunction);
			
			this.FunctionList = uicontrol('Style', 'listbox');
			this.FunctionList.Position = [10, SinePlotter.H_4+SinePlotter.B_h+SinePlotter.H_3+SinePlotter.H_4, SinePlotter.L_0, this.Window.Position(4) - (SinePlotter.H_4+SinePlotter.B_h+SinePlotter.H_3) - 2*15];
			
			this.AxesTop = axes('Parent', this.Window, 'Units', 'pixels');
			%TODO függvényeket csinálni a méretezéshez
			this.AxesTop.Position = [ ...
				15 + SinePlotter.L_0 + 30, ...											% A FunctionList mellé kerül
				this.GetAxisHeight() + (2*SinePlotter.H_4 + SinePlotter.B_h + 20 + SinePlotter.H_2 + SinePlotter.H_3), ...	% Gombok feletti rész fele - hézag
				this.Window.Position(3) - (SinePlotter.H_4 + SinePlotter.L_0 + 30) - 15, ...
				this.GetAxisHeight() ... % Gombok feletti rész fele - hézag
				];
			
			title(this.AxesTop, 'Felsõ tengelykereszt', 'FontSize', 16, 'FontWeight', 'bold');
			hold(this.AxesTop, 'on');
			
			% A másik tengelykereszt
			
			this.AxesBottom = axes('Parent', this.Window, 'Units', 'pixels');
			this.AxesBottom.Position = [ ...
				15+SinePlotter.L_0 + 30, ...											
				SinePlotter.H_4 + SinePlotter.B_h + 20 + 15 + SinePlotter.H_3, ...	
				this.Window.Position(3) - (SinePlotter.H_4 + SinePlotter.L_0 + 30) - 15, ...
				this.GetAxisHeight() ...
				];
			
			title(this.AxesBottom, 'Alsó tengelykereszt', 'FontSize', 16, 'FontWeight', 'bold'); 
			hold(this.AxesBottom, 'on');
			
		end
		
		function a_y = GetAxisHeight(this)
			% A tengelykeresztek magassága
			a_y = (this.Window.Position(4) - 2*SinePlotter.H_4 - SinePlotter.H_1 - SinePlotter.H_2 - SinePlotter.H_3 - 25 - 20)/2;
		end
		
		function AddFunction(this, h, ~, ~)
			% Vezérlõ értékének olvasása
			A = eval(this.EditAmplitude.String);			% Ha nem szám akkor NaN
			F = eval(this.EditFrequency.String);
			P = eval(this.EditPhase.String);
			O = eval(this.EditOffset.String);
			
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
				if isempty(this.FunctionDataBase)
					
					msgbox('A lista üres!', 'Hiba!', 'error');
				else
					this.FunctionList.String(i) = [];
		
					delete(this.FunctionDataBase{i, 6});
		
					this.FunctionDataBase(i, :) = [];
                    
                    this.FunctionList.Value = 1;
		
					drawnow;
                    RefreshSum(this);
				end
		end
		
		function ModifyFunction(this, h, ~, ~)
			if isempty(this.FunctionDataBase)
			msgbox('A lista üres!', 'Hiba!', 'error');
			else
				
				% Vezérlõ értékének olvasása
				A = eval(this.EditAmplitude.String);			% Ha nem szám akkor NaN
				F = eval(this.EditFrequency.String);
				P = eval(this.EditPhase.String);
				O = eval(this.EditOffset.String);
			
				i = this.FunctionList.Value;
				c = this.FunctionDataBase{i, 6}.Color;
				delete(this.FunctionDataBase{i, 6});
			
				if ((~isnan(A)) && (~isnan(F)) && (~isnan(P)) && (~isnan(O)))
					% Új elem kerül az adatbázisba
					this.FunctionDataBase(i, 1:6) = { ...
						A, ...
						this.FunctionSelector.Value, ...				% 1: cos; 2: sin
						F, ...
						P, ...
						O, ...
						0 ...
						};
		
					this.FunctionList.String{i} = this.ParamToString();
				
					% Ábrázolás
					
					this.CreatePlot(i);
					this.FunctionDataBase{i, 6}.Color = c;
					
				else
					msgbox('Hiba történt!', 'Hiba!', 'error');
				end
			end
			
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
			RefreshSum(this);
        end
        function RefreshSum(this)
			
			% A legnagyobb körfrekvencia
			wmax = max([this.FunctionDataBase{:, 3}]);
			
			% Az eredõt a legnagyobb frekvenciájú összetevõ alapján kell ábrázolni
			t = [0:(2*pi/wmax/100):1, 1];
			x = zeros(size(t));
			
			for i = 1:size(this.FunctionDataBase, 1);
				a = [this.FunctionDataBase{i, 1:5}];
				
				f = @(t) a(1)*cos(a(3) * t + a(4)) + a(5);
				if (a(2) == 2)
					% Szinusz
					f = @(t) a(1)*sin(a(3) * t + a(4)) + a(5);
				end
				
				x = x + f(t);
			end
			
			delete(this.SumPlot);
			this.SumPlot = plot(this.AxesBottom, t, x, 'LineWidth', 3);
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
			
			% Meg kell növelni a függvény lista magasságát
			% Az összefüggés ugyanaz, mint a létrehozásnál, csak frissül a Window.Position(4)
			this.FunctionList.Position = [10, SinePlotter.H_4+SinePlotter.B_h+SinePlotter.H_3+SinePlotter.H_4, SinePlotter.L_0, this.Window.Position(4) - (SinePlotter.H_4+SinePlotter.B_h+SinePlotter.H_3) - 2*15];
			
			this.AxesTop.Position = [ ...
				15+SinePlotter.L_0+30, ...											% A FunctionList mellé kerül
				this.GetAxisHeight() + (2*SinePlotter.H_4 + SinePlotter.B_h + 20 + SinePlotter.H_2 + SinePlotter.H_3), ...	% Gombok feletti rész fele - hézag
				this.Window.Position(3) - (SinePlotter.H_4 + SinePlotter.L_0 + 30) - 15, ...
				this.GetAxisHeight() ... % Gombok feletti rész fele - hézag
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

