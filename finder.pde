// based on: http://dcgi.felk.cvut.cz/home/sykorad/Sykora08-EGVE.pdf

class Finder {

	public Finder () {
		
	}

	ArrayList<State> findCircles(int[][] boundary, State boundingState, int circleCount) {
		int pointCount = boundary.length;
		int totalPointCount = pointCount;
		if(pointCount < 3)
			return new ArrayList<State>();

		int size = (int) max(boundingState.ssize.x, boundingState.ssize.y);
		int xbox = (int) (boundingState.sposition.x - boundingState.ssize.x/2.0);
		int ybox = (int) (boundingState.sposition.y - boundingState.ssize.y/2.0);

		if(size > 200)
			return new ArrayList<State>();

		ArrayList<State> circles = new ArrayList<State>();

		float lastCircleProbability = 0.2;
		int maxCircles = circleCount;
		while(maxCircles-- > 0){
			int[][] histogram = new int[size][size];

			int votes = 0;
			int threshold = 100;
			
			int maxValue = 0;
			int[] maxCoords = new int[2];

			int cycleLimit = 50000;
			int voteLimit = 3*pointCount;
			while(votes < voteLimit && cycleLimit-- > 0) {
				int[] p1 = boundary[(int) random(pointCount)];
				int[] p2 = boundary[(int) random(pointCount)];
				int[] p3 = boundary[(int) random(pointCount)];
				// optimalizovat?
				// nevybíráme stejné body
				if(p1 == p2 || p2 == p3 || p1 == p3)
					continue;

				int x32 = p3[0] - p2[0];
				int x13 = p1[0] - p3[0];
				int x21 = p2[0] - p1[0];

				int y32 = p3[1] - p2[1];
				int y13 = p1[1] - p3[1];
				int y21 = p2[1] - p1[1];

				int delitelx = (p1[0]*y32 + p2[0]*y13 + p3[0]*y21)*2;
				int delitely = (p1[1]*x32 + p2[1]*x13 + p3[1]*x21)*2;

				// body jsou na přímce, fuj!
				if(delitelx == 0 || delitely == 0)
					continue;

				int d1 = p1[0]*p1[0] + p1[1]*p1[1];
				int d2 = p2[0]*p2[0] + p2[1]*p2[1];
				int d3 = p3[0]*p3[0] + p3[1]*p3[1];

				int cx = (d1*y32 + d2*y13 + d3*y21)/delitelx - xbox;
				int cy = (d1*x32 + d2*x13 + d3*x21)/delitely - ybox;
				// println(cx, cy);
				if(cx > 0 && cx < size && cy > 0 && cy < size){
					histogram[cx][cy]++;
					votes++;
					
					if(histogram[cx][cy] > maxValue){
						maxValue = histogram[cx][cy];
						maxCoords[0] = cx;
						maxCoords[1] = cy;
					}

					if(maxValue > threshold)
						break;
				}
			}

			maxCoords[0] += xbox;
			maxCoords[1] += ybox;

			int[] radiusHistogram = new int[size];
			int maxRadiusValue = 0;
			int maxRadius = 0;
			for (int i = 0; i < pointCount; i++) {
				int[] p = boundary[i];
				int dx = maxCoords[0] - p[0];
				int dy = maxCoords[1] - p[1];
				int r = int(sqrt(dx*dx+dy*dy));
				if(r < size){
					radiusHistogram[r]++;
					if(radiusHistogram[r] > maxRadiusValue){
						maxRadiusValue = radiusHistogram[r];
						maxRadius = r;
					}
				}
			}

			if(maxRadiusValue <= 0)
				break;

			int avgRadius = 0;
			int sumRadius = 0;
			for (int i = 0; i < size; i++) {
				if(radiusHistogram[i] > 0.9*maxRadiusValue){
					avgRadius += i*radiusHistogram[i];
					sumRadius += radiusHistogram[i];
				}
			}

			avgRadius /= sumRadius;

			boolean[] pixelDelete = new boolean[pointCount];
			int newPointCount = 0;
			for (int i = 0; i < pointCount; i++) {
				int[] p = boundary[i];
				int dx = maxCoords[0] - p[0];
				int dy = maxCoords[1] - p[1];
				if(abs(sqrt(dx*dx+dy*dy) - avgRadius) < 2){
					pixelDelete[i] = true;
				}
				else {
					pixelDelete[i] = false;
					newPointCount++;
				}
			}

			// println(maxValue);
			// if(maxValue > 1){
			// 	strokeWeight(1);
			// 	// fill(0,0,0,200);
			// 	noFill();
			// 	stroke(255, 255, 255);
			// 	rect(xbox, ybox, size, size);

			// 	for (int x = 0; x < size; x++) {
			// 		for (int y = 0; y < size; y++) {
			// 			if(histogram[x][y] > 0){
			// 				stroke(histogram[x][y]/float(maxValue)*255.0, 255);
			// 				point(x+xbox, y+ybox);
			// 			}
			// 		}
			// 	}
			// }


			float circleProbability = maxValue*maxRadiusValue/float(votes) * (pointCount - newPointCount)/pointCount;

			if(lastCircleProbability/circleProbability < 1.5){
				// fill(0, 255, 0, 200);
				// text(""+circleProbability, maxCoords[0], maxCoords[1]);
				// noFill();

				color globColor = m.average(maxCoords[0]-avgRadius, maxCoords[1]-avgRadius, maxCoords[0]+avgRadius, maxCoords[1]+avgRadius);
				PVector globPosition = new PVector(maxCoords[0], maxCoords[1]);
				PVector globSize = new PVector(avgRadius*2, avgRadius*2);

				State state = new State(globColor, globPosition, globSize);
				circles.add(state);
			}
			else {
				// fill(255, 0, 0, 200);
				// text(""+circleProbability, maxCoords[0], maxCoords[1]);
				// noFill();

				break;
			}

			lastCircleProbability = circleProbability;

			if(newPointCount < 40)
				break;

			int[][] newBoundary = new int[newPointCount][2];
			int index = 0;
			for (int i = 0; i < pointCount; i++) {
				if(!pixelDelete[i]){
					newBoundary[index++] = boundary[i];
				}
			}

			pointCount = newPointCount;
			boundary = newBoundary;

			stroke(255, 0, 0);
			strokeWeight(1);
			if(boundary!=null){
				beginShape(POINTS);
				for(int j=0;j<boundary.length;j++){
					vertex(boundary[j][0], boundary[j][1]);
				}
				endShape();
			}
		}

		if(circles.size() == 2){
			State c1 = circles.get(0);
			State c2 = circles.get(1);
			float dx = c1.sposition.x-c2.sposition.x;
			float dy = c1.sposition.y-c2.sposition.y;
			float d = sqrt(dx*dx+dy*dy);
			if(d + c1.ssize.x < c2.ssize.x + 2)
				circles.remove(0);
			if(d + c2.ssize.x < c1.ssize.x + 2)
				circles.remove(1);
		}

		return circles;
	}
};