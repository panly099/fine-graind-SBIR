% % Create some data
		t = 0:.1:4*pi;
		s = sin(t);

      % Add an annotation requiring (x,y) coordinate vectors
		plot(t,s);ylim([-1.2 1.2])
		xa = [1.6 2]*pi;
		ya = [0 0];
		[xaf,yaf] = ds2nfu(xa,ya);
		annotation('arrow',xaf,yaf)

      % Add an annotation requiring a position vector
		pose = [4*pi/2 .9 pi .2];
		posef = ds2nfu(pose);
		annotation('ellipse',posef)

      % Add annotations on a figure with multiple axes
		figure;
		hAx1 = subplot(211);
		plot(t,s);ylim([-1.2 1.2])
		hAx2 = subplot(212);
		plot(t,-s);ylim([-1.2 1.2])
		[xaf,yaf] = ds2nfu(hAx1,xa,ya);
		annotation('arrow',xaf,yaf)
		pose = [4*pi/2 -1.1 pi .2];
		posef = ds2nfu(hAx2,pose);
		annotation('ellipse',posef)
