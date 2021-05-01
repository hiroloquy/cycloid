reset
set angle rad

#=================== Parameters ====================
array radius[3] = [2., 1., 0.5]
array pointSize[3] = [1.8,  1.5, 1.3]
array color[3] = [0xff0000, 0xffa500, 0x0080ff]#0x4169e1]　# red, orange, web-blue
lineWidth = 3
numPNG = 0
LOOP = 4 # Simulate until theta = LOOP*pi [rad]

#=================== Functions ====================
cycloidX(i, t, tmax) = (t<=tmax) ? radius[i]*(t-sin(t)) : 1/0 # Restrict the domain of parameter t
cycloidY(i, t, tmax) = (t<=tmax) ? radius[i]*(1-cos(t)) : 1/0 # Restrict the domain of parameter t
centerX(i, t) = radius[i]*t
centerY(i, t) = radius[i]
trnpColor(i, rate) = color[i] + (int(255*rate) << 24) # Adjust transparency of color[i], 0(solid)<rate<1

#=================== Plot ====================
set term pngcairo truecolor enhanced dashed size 1280, 540 font 'Times, 18'
system 'mkdir png2'
set size ratio -1

commandXtics = "set xtics nomirror ('-{/:Italic π}' -pi, 0, '{/:Italic π}' pi"
do for[i=2:LOOP+1:1]{
	commandXtics = commandXtics.sprintf(", '%d{/:Italic π}' %d*pi", i, i)
}
commandXtics = commandXtics.") tc rgb 'black'"
eval commandXtics

set grid
set nokey
set samples 5e3
maxXrange = (LOOP+1)*pi
set xrange [-pi:maxXrange]
set yrange [0:2*radius[1]+1]
set xl '{/:Italic x}'
set yl '{/:Italic y}'

set parametric
set trange [0:2*LOOP*pi]

do for [deg=0:360*LOOP:3]{
	set output sprintf("png2/img_%04d.png", numPNG)
	# set title sprintf("{/:Italic θ} = %d°", deg)

    numPNG = numPNG + 1
	theta = deg * pi/180
	commandPlot = "plot 1/0, 1/0" # This command is dummy and means "plot nothing"

	# If arrow i overflow the graph area, you cut the arrow.
	do for [i=1:3]{
		speed = 2.0**(3-i)
		theta_sp = theta/speed

		# Draw the line representing rotation
		set arrow i nohead from centerX(i, theta_sp), centerY(i, theta_sp) \
			to cycloidX(i, theta_sp, theta_sp), cycloidY(i, theta_sp, theta_sp) lc rgb trnpColor(i, 0.4) lw lineWidth front

		# Prepare to draw the rotating circle, the point P and the locus of the point P (cycloid)
		commandPlot = commandPlot.sprintf(", centerX(%d, %f)+radius[%d]*cos(t*1./LOOP), \
			centerY(%d, %f)+radius[%d]*sin(t*1./LOOP) w l lc rgb trnpColor(%d, %f) lw lineWidth", i, theta_sp, i, i, theta_sp, i, i, 0.4)
		commandPlot = commandPlot.sprintf(", cycloidX(%d, %f, %f), cycloidY(%d, %f, %f) \
			with points pt 7 lc rgb trnpColor(%d, %f) ps pointSize[%d]", i, theta_sp, theta_sp, i, theta_sp, theta_sp , i, 0.4, i)
		commandPlot = commandPlot.sprintf(", cycloidX(%d, t, %f),cycloidY(%d, t, %f) \
			with line lc rgb trnpColor(%d, %f) lw lineWidth", i, theta_sp, i, theta_sp, i, 0.4)
	}

	eval commandPlot
	set out # Output PNG file
}
