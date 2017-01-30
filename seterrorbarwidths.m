function seterrorbarwidths( hs, errorbarwidth)

    if isa(hs,'matlab.graphics.axis.Axes')
        hzoom = zoom(hs);
        set(hzoom,'ActionPostCallback',@(~,~)zoomCallback(hs,errorbarwidth));
        return
    elseif isa(hs,'matlab.graphics.chart.primitive.ErrorBar') || isa(hs,'matlab.graphics.primitive.Data')
        hscell = {};
        for i = 1:numel(hs)
           hscell{i} = hs(i);
        end
    else
        error('invalid input'); 
    end
    
    for i = 1:numel(hscell)
        if isa(hscell{i},'matlab.graphics.chart.primitive.ErrorBar')
            hscell{i}.BarMode = 'manual';
            
            x = get(hscell{i},'XData');
            y = get(hscell{i},'YData');
            l = get(hscell{i},'LData');
            u = get(hscell{i},'UData');
            npt = size(x,1);
            
            xlims = hscell{i}.Parent.XLim;
            ylims = hscell{i}.Parent.YLim;
            fx = @(x) (x-xlims(1))./diff(xlims);
            fy = @(y) (y-ylims(1))./diff(ylims);
            
            tee = errorbarwidth*diff(xlims);
            xl = x - tee;
            xr = x + tee;
            ytop = y + u;
            ybot = y - l;
            npt = size(y,2);
            n = size(y,1);
            
            %assignin('base','vdold',hscell{i}.Bar.VertexData);
            % build up nan-separated vector for bars
            xb = zeros(npt*6,n);
            xb(1:6:end,:) = x;
            xb(2:6:end,:) = x;
            xb(3:6:end,:) = xl;
            xb(4:6:end,:) = xr;
            xb(5:6:end,:) = xl;
            xb(6:6:end,:) = xr;

            yb = zeros(npt*6,n);
            yb(1:6:end,:) = ytop;
            yb(2:6:end,:) = ybot;
            yb(3:6:end,:) = ytop;
            yb(4:6:end,:) = ytop;
            yb(5:6:end,:) = ybot;
            yb(6:6:end,:) = ybot;
            
            zb = 0.5*ones(npt*6,n);

            hscell{i}.Bar.VertexData = single([fx(xb');fy(yb');zb']);
            %assignin('base','vdnew',hscell{i}.Bar.VertexData);
            %hscell{i}.Bar_I.VertexData = single([xb';yb';zb']);
            %assignin('base','herr',hscell{i});
        end
    end
end

function zoomCallback(ha,axesPercent)
    errorbarwidth = diff(get(ha,'XLim'))*axesPercent;
    assignin('base','ha',ha);
    %drawnow;
    seterrorbarwidths(get(ha,'Children'),errorbarwidth);
    %drawnow;
end