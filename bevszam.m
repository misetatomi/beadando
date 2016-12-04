function bevszam
x_lim=[0 0.01];
y_lim=[-1 1];
amplitudo =0;
offset =0;
frekvencia =0;
fuggvenytar = [];
multx = [];
multy = [];
window = figure('Position',[100,100,700,500])
window.SizeChangedFcn = @DrawWindow;
DrawWindow()
    function DrawWindow(hObject, eventdata, handles)
        multx = window.Position(3)./700;
        multy = window.Position(4)./500;
        clf;
txt1 = uicontrol('Style','text',...
    'Position',[80*multx 450*multy 120*multx 20*multy],...
    'String','Amplitudo');
txt2 = uicontrol('Style','text',...
    'Position',[230*multx 450*multy 120*multx 20*multy],...
    'String','Frekvenca');
txt3 = uicontrol('Style','text',...
    'Position',[378*multx 450*multy 120*multx 20*multy],...
    'String','Offset');
txt4 = uicontrol('Style','text',...
    'Position',[528*multx 450*multy 120*multx 20*multy],...
    'String','Körfrekvencia');
editamplitudo = uicontrol('Style', 'edit',...
    'Position', [90*multx 430*multy 100*multx 25*multy],...
    'Callback', @setamplitudo);
editfrekvencia = uicontrol('Style', 'edit',...
    'Position', [238*multx 430*multy 100*multx 25*multy],...
    'Callback', @setfrekvencia);
editoffset = uicontrol('Style', 'edit',...
    'Position', [388*multx 430*multy 100*multx 25*multy],...
    'Callback', @setoffset);
editfazis = uicontrol('Style', 'edit',...
    'Position', [535*multx 430*multy 100*multx 25*multy],...
    'Callback', @setamplitudo);
tar = uicontrol('Style', 'listbox',...
    'Position', [90*multx 300*multy 545*multx 100*multy],...
    'Callback', '');
addbutt = uicontrol('Style', 'pushbutton', 'String', 'Add',...
    'Position', [10*multx 380*multy 50*multx 20*multy],...
    'Callback', @addbutton_Callback);
deletebutt = uicontrol('Style', 'pushbutton', 'String', 'Delete',...
    'Position', [10*multx 340*multy 50*multx 20*multy],...
    'Callback', @removebutton_Callback);
plotbutt = uicontrol('Style', 'pushbutton', 'String', 'Plot',...
    'Position', [10*multx 300*multy 50*multx 20*multy],...
    'Callback', @plotbutton_Callback);
    end
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
        fuggvenytar(tar.Value,:)=[]; 
        tar.Value = 1;
        Populate_List();
    end
    function setfrekvencia(source,callbackdata)
        frekvencia = str2num(get(editfrekvencia,'String'))
        if ~isnumeric(str2num(get(editfrekvencia,'String')))
            frekvencia = 'Wrong input';
        end
    end
    function setamplitudo(source,callbackdata)
        amplitudo = str2num(get(window.editamplitudo,'String'))
        if ~isnumeric(str2num(get(window.editamplitudo,'String')))
            amplitudo = 'Wrong input';
        end
    end
    function setoffset(source,callbackdata)
        offset = str2num(get(editoffset,'String'))
        if ~isnumeric(str2num(get(editoffset,'String')))
            offset= 'Wrong input';
        end
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