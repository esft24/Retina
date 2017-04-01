#Objetos que permiten correr un programa tal que por medio de metodos de programacion
# de tipo turtle graphics creen una imagen en formato pbm.

class Turtle
	include Math
	DEG = Math::PI / 180.0
	attr_accessor :canvas, :canvasraw, :canvasmatrix
	
	def initialize
		@canvas = []
		@canvasraw = []
		@xy = [0.0, 0.0]
		@towards = 0.0
		@eye = false
		@canvasmatrix = []
		initmatrix
		openeye
	end
	
	def setposition coordx, coordy
		@xy = [coordx, coordy]
		openeye if @eye
	end
	
	def pointto degrees
		@towards = degrees % 360
	end
	
	def openeye
		@eye = true
		@canvas << [[@xy[0].round, @xy[1].round]]
		@canvasraw << [@xy]
	end

	def closeeye
		@eye = false
	end
	
	def home
		setposition(0.0, 0.0)
	end
	
	def rotater degrees
		@towards += degrees
		@towards %= 360 #=%
	end
	
	def rotatel degrees
		rotater(-degrees)
	end
	
	def forward steps
		@xy = [@xy[0] + sin(@towards * DEG) * steps,
			   @xy[1] + cos(@towards * DEG) * steps]
		
		@canvasraw.last << @xy if @eye
		
		if @canvas.last.last[0] != @xy[0].round and @canvas.last.last[1] != @xy[1].round and @eye
			diagonal_to_lines
		else
			@canvas.last << [@xy[0].round, @xy[1].round] if @eye
		end
	end
	
	def backward steps
		forward(-steps)
	end
	
	def arc degrees, radius
		xini = @xy[0]
		yini = @xy[1]
		d = degrees
		r = radius
		closeeye
		forward(r)
		rotater(90)
		openeye
		realr = r/(360/(PI * 2))

		for i in 0..(d)
			forward(realr)
			rotater(1)
		end
		rotatel(d+90+1)
		setposition(xini, yini)
	end
	
	def initmatrix
		for i in 0..1000
			dummy = []
			for i in 0..1000
				dummy << 0
			end
			@canvasmatrix << dummy
		end
		@canvasmatrix[500][500] = 1
	end
	
	def diagonal_to_lines
		spt = @canvas.last.last.dup 						
		ept = [@xy[0].round, @xy[1].round]				
		up = true
		right = true
				
		hdist = (spt[0] - ept[0]).abs + 1.0
		vdist = (spt[1] - ept[1]).abs + 1.0
		
		rate = hdist/vdist
		if spt[1] > ept[1]
			up = false
		end
		
		if spt[0] > ept[0]
			right = false
		end
		
		times = vdist - 2
		actual = rate
		lastsum = 0
		
		upordown = -1
		leftorright = -1
		if up
			upordown = 1
		end
		
		if right
			leftorright = 1
		end
		
		# up down
		if vdist > hdist
			for i in 0..times
				if right
					spt[0] = spt[0] + actual.floor
				else
					spt[0] = spt[0] - actual.floor
				end
				
				spt[1] = spt[1] + upordown
				lastsum = actual.floor
				actual = actual + rate - lastsum
				@canvas.last << [spt[0], spt[1] - upordown]
				@canvas.last << [spt[0], spt[1]]
			end
		# left right
		else
			times = hdist - 2
			rate = vdist/hdist
			actual = rate
			for i in 0..times
				
				if up
					spt[1] = spt[1] + actual.floor
				else
					spt[1] = spt[1] - actual.floor
				end
				
				spt[0] = spt[0] + leftorright
				lastsum = actual.floor
				actual = actual + rate - lastsum
				@canvas.last << [spt[0] - leftorright, spt[1]]
				@canvas.last << [spt[0], spt[1]]
			end
		end
	end
	
	def tomatrix
		take = @canvas[0]
		@canvas = @canvas[1..-1]
		
		if take.size == 1
			if((500 - take[0][1] >= 0 && 500 - take[0][1] <= 1000) && (take[0][0] + 500 >= 0 && take[0][1] + 500 <= 1000))
				@canvasmatrix[500 - take[0][1]][take[0][0] + 500] = 1
			end
		end
		
		for i in 0..take.size - 2
			stp = take[i]
			etp = take[i + 1]
			
			if stp == etp
				next
			end
			if stp[0] != etp[0]
				y = etp[1]
				mx = [stp[0], etp[0]].max
				mn = [stp[0], etp[0]].min
				
				for j in mn..mx
					if((500 - y >= 0 && 500 - y <= 1000) && (j + 500 >= 0 && j + 500 <= 1000))
						@canvasmatrix[500 - y][j + 500] = 1
					end
				end
			end
			
			if stp[1] != etp[1]
				x = etp[0]
				mx = [stp[1], etp[1]].max
				mn = [stp[1], etp[1]].min
				
				for j in mn..mx
					if((500 - j >= 0 && 500 - j <= 1000) && (x + 500 >= 0 && x + 500 <= 1000))
						@canvasmatrix[500 - j][x + 500] = 1
					end
				end
			end
		end
		
		if @canvas.size != 0
			tomatrix
		end
	end
	
	def toFile filename
		tomatrix
		File.open("#{filename}.pbm", "w") do |pbm|
			pbm.syswrite("P1\n")
			pbm.syswrite("1001 1001\n")
			
			@canvasmatrix.each do |a|
				i = 1
				a.each do |b|
					if b == 0
						pbm.syswrite("0")
					else
						pbm.syswrite("1")
					end
					if i != 1002
						pbm.syswrite(" ")
					end
					i+=1
				end
				pbm.syswrite("\n")
			end
		end
	end
end