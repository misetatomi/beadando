function bevszam
x_lim=[0 0.01];
y_lim=[-1 1];
amplitudo =0;
offset =0;
frekvencia =0;
       txt1 = uicontrol('Style','text',...
           'Position',[90 360 120 20],...
           'String','Amplitudo');
       txt2 = uicontrol('Style','text',...
           'Position',[240 360 120 20],...
           'String','Frekvenca');
       txt3 = uicontrol('Style','text',...
           'Position',[390 360 120 20],...
           'String','Offset');
       editamplitudo = uicontrol('Style', 'edit',...
           'Position', [100 340 100 25],...
           'Callback', @setamplitudo);
       editfrekvencia = uicontrol('Style', 'edit',...
           'Position', [250 340 100 25],...
           'Callback', @setfrekvencia);  
       editoffset = uicontrol('Style', 'edit',...
           'Position', [400 340 100 25],...
           'Callback', @setoffset);  
       tar = uicontrol('Style', 'listbox',...
        'Position', [100 210 400 100],...
        'Callback', '');  
       addbutt = uicontrol('Style', 'pushbutton', 'String', 'Add',...
        'Position', [10 290 50 20],...
        'Callback', @addbutton_Callback);  
       deletebutt = uicontrol('Style', 'pushbutton', 'String', 'Delete',...
        'Position', [10 250 50 20],...
        'Callback', @removebutton_Callback);  
       plotbutt = uicontrol('Style', 'pushbutton', 'String', 'Plot',...
        'Position', [10 210 50 20],...
        'Callback', @plotbutton_Callback);  
    fuggvenytar = []
  %   function selected_Callback(hObject, eventdata, handles)
  %      selected = tar.Value
  % end
    function Populate_List()
    tar.String=[];
    for i=1:size(fuggvenytar)
       
        tar.String=[tar.String; num2str(fuggvenytar(i,1)) '  '  num2str(fuggvenytar(i,2)) '   ' num2str(fuggvenytar(i,3))];
    end
    end
    function addbutton_Callback(hObject, eventdata, handles)
        fuggvenytar = [fuggvenytar; amplitudo, frekvencia, offset];
        Populate_List()
    end
    function removebutton_Callback(hObject, eventdata, handles)
		for i = 0:size(fuggvenytar)
			if(tar.Value == i)
				if(i ~= size(fuggvenytar, 1))
					fuggvenytar(i, :) = fuggvenytar(i+1, :);
					for j=i+1:size(fuggvenytar)-1
						fuggvenytar(j, :) = fuggvenytar(j+1, :);
					end
				
					fuggvenytar(j, :) = [];
				end
	
				if(i == size(fuggvenytar, 1))
					fuggvenytar(i, :) = [];
				end
				
			end
		end
		Populate_List();
	end
function setfrekvencia(source,callbackdata)
        frekvencia = str2num(get(editfrekvencia,'String'))
end
function setamplitudo(source,callbackdata)
        amplitudo = str2num(get(editamplitudo,'String'))
end
function setoffset(source,callbackdata)
        offset = str2num(get(editoffset,'String'))
end
function plotbutton_Callback(hObject, eventdata, handles)
for i=1:length(fuggvenytar)
x = 0:pi/(100*100000):2*pi;
sum = 0:pi/(100*100000):2*pi;
y = fuggvenytar(i, 1)*sin(fuggvenytar(i,3)+(2*pi*fuggvenytar(i,2)*x));
sum = sum + y;
subplot (2,2,3);
plot(x,y);
hold on
grid on;
xlim(x_lim);
subplot (2,2,4);
plot(x,sum);
hold on
grid on;
xlim(x_lim);
ylim(y_lim);
end
end
end