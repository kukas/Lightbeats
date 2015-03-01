class VecN {
	float[] values;
	int dimension;

	VecN (float[] values) {
		this.values = values;
		dimension = values.length;
	}

	float get (int index) {
		return values[index];
	}

	VecN set (float value, int index) {
		values[index] = value;
		return this;
	}

	VecN multiply (float scalar) {
		for (int i = 0; i < dimension; i++) {
			values[i] *= scalar;
		}
		return this;
	}

	VecN add (VecN v) {
		for (int i = 0; i < dimension; i++) {
			values[i] += v.values[i];
		}
		return this;
	}

	VecN sub (VecN v) {
		for (int i = 0; i < dimension; i++) {
			values[i] -= v.values[i];
		}
		return this;
	}

	VecN clone () {
		float[] valuesCopy = new float[dimension];
		arrayCopy(values, valuesCopy);
		
		return new VecN(valuesCopy);
	}

	VecN doPrt (float prt) {
		for (int i = 0; i < dimension; i++) {
			if(random(1) > prt)
				values[i] = 0;
		}
		
		return this;
	}
};

class Candidate {
	float error;
	VecN position;
	Finder parent;

	Candidate (Finder parent, VecN position) {
		this.position = position;
		this.parent = parent;
	}

	float calculateError () {
		return parent.fitCircles(position);
	}

	void updateError () {
		error = calculateError();
	}

	void follow (Candidate candidate) {
		if(candidate != this){
			VecN step = candidate.position.clone().sub(position).doPrt(parent.prt).multiply(parent.step);
			VecN origin = position.clone();

			float minError = 0;
			int minErrorSteps = 0;
			int iterations = floor(parent.mass/parent.step);

			float currentError;
			for (int i = 0; i < iterations; i++) {
				position.add(step);
				currentError = calculateError();

				if(currentError < minError || i == 0){
					minError = currentError;
					minErrorSteps = i+1;
				}
			}

			position = origin.add(step.multiply(minErrorSteps));
			error = minError;
		}
	}
};

// SOMA genetic algorithm
class Finder {
	float mass;
	float step;
	float prt;
	int np;
	int migrationsLimit;
	float acceptedError;

	int d;

	int debugPerf;

	Candidate[] candidates;

	int[][] globPixels;
	int pointCount;

	Finder () {
		mass            = 2;
		step            = 0.07;
		prt             = 0.35;
		np              = 15;
		migrationsLimit = 30;
		acceptedError   = 1;
		d               = 3;
	}

	Candidate[] getMinMax () {
		Candidate[] minmax = new Candidate[2];
		minmax[0] = candidates[0];
		minmax[1] = candidates[0];

		for (int i = 1; i < np; i++) {
			if(candidates[i].error < minmax[0].error){
				minmax[0] = candidates[i];
			}
			if(candidates[i].error > minmax[1].error){
				minmax[1] = candidates[i];
			}
		}
		return minmax;
	}

	void init () {
		debugPerf = 0;

		if(d == 3){
		// if(tips.length == 3){
			prt = 0.5;
		}

		candidates = new Candidate[np];
		for(int i=0; i<np; i++){
			float[] values = new float[d];

			for (int j = 0; j < d; j+=3) {
				int[] p1 = globPixels[int(random(0, pointCount))];
				// State b = tips[int(random(0, tips.length))].getState();

				// values[j] = b.sposition.x + (p1[0] - b.sposition.x)*random(1);
				// values[j+1] = b.sposition.y + (p1[1] - b.sposition.y)*random(1);
				// values[j+2] = (b.ssize.x * b.ssize.y)*random(0.1, 0.5);

				int[] p2 = globPixels[int(random(0, pointCount))];
				values[j] = p2[0] + (p1[0] - p2[0])*random(1);
				values[j+1] = p2[1] + (p1[1] - p2[1])*random(1);
				values[j+2] = abs(p1[0] - p2[0])*pointCount/2;
			}

			VecN position = new VecN(values);
			Candidate candidate = new Candidate(this, position);

			candidate.updateError();
			candidates[i] = candidate;
		}

		// for(int i=0; i<np; i++){
		// 	stroke(255, 255, 0, 150);
		// 	float dd = sqrt(candidates[i].position.get(2))*2;
		// 	ellipse(candidates[i].position.get(0), candidates[i].position.get(1), dd, dd);
		// 	stroke(255, 0, 255, 150);
		// 	dd = sqrt(candidates[i].position.get(5))*2;
		// 	ellipse(candidates[i].position.get(3), candidates[i].position.get(4), dd, dd);
		// }
	}

	Candidate migrate () {
		Candidate[] minmax = getMinMax();
		int migrations = 0;
		do {
			migration(minmax[0]);
			minmax = getMinMax();
		} while (++migrations < migrationsLimit && (minmax[1].error-minmax[0].error) > acceptedError);

		// balls.debugString = ""+(minmax[1].error-minmax[0].error);
		return minmax[0];
	}

	void migration (Candidate leader) {
		// stroke(255, 255, 0, 150);
		// noFill();
		// float dd = sqrt(leader.position.get(2))*2;
		// ellipse(leader.position.get(0), leader.position.get(1), dd, dd);
		// stroke(255, 0, 255, 150);
		// dd = sqrt(leader.position.get(5))*2;
		// ellipse(leader.position.get(3), leader.position.get(4), dd, dd);

		for (Candidate candidate : candidates) {
			candidate.follow(leader);
		}

	}

	float fitCircles (VecN circles) {
		debugPerf++;

		float error = 0;

		float[] errors = new float[d/3];
		for (int j = 0; j < pointCount; j+=3) {
			int[] p = globPixels[j];
			for (int i = 0; i < d; i+=3) {
				float x = circles.get(i);
				float y = circles.get(i+1);
				float r2 = circles.get(i+2);

				float dx = p[0] - x;
				float dy = p[1] - y;
				// errors[i/3] = abs(dx*dx + dy*dy - r2);
				float maxd = 256;
				float d2 = dx*dx + dy*dy;
				float dd2 = abs(d2 - r2);
				errors[i/3] = dd2;
				// if(d2 > r2){
				// 	errors[i/3] *= dd2*0.1;
				// 	errors[i/3] += dd2;
				// }

				if(dd2 > maxd){
					errors[i/3] = maxd+0.15*dd2; //-1/dd2;
				}
				// else {
					// errors[i/3] = sqrt(d);
				// }
			}
			error += min(errors);
		}

		if(d > 3){
			for (int i = 0; i < d; i+=3) {
				float dx = circles.get(i) + circles.get((i+3)%d);
				float dy = circles.get(i+1) + circles.get((i+4)%d);
				error += dx*dx + dy*dy;
			}
		}

		return error;
	}

	ArrayList<State> findBalls (int[][] globPixels, int ballCount) {
		this.globPixels = globPixels;
		pointCount = globPixels.length;
		// d = tips.length*3;
		this.d = ballCount*3;

		stroke(255, 0, 0);
		// for (int[] p : globPixels) {
		for (int i = 0; i < globPixels.length; i += 3) {
			int[] p = globPixels[i];
			point(p[0], p[1]);
		}
		// }

		init();

		Candidate leader = migrate();

		ArrayList<State> foundStates = new ArrayList<State>();

		for(int i=0; i<d; i+=3){
			int x = int(leader.position.get(i));
			int y = int(leader.position.get(i+1));
			int r = int(sqrt(leader.position.get(i+2)));
			int dd = 2*r;

			boolean duplicate = false;

			for (State s : foundStates) {
				// float dsize = abs(s.ssize.x - dd);
				float dx = abs(s.sposition.x - x);
				float dy = abs(s.sposition.y - y);

				// pokud se souřadnicí liší alespoň o 5 pixelů
				if(max(dx, dy) < 5){
					duplicate = true;
				}
			}

			if(!duplicate){
				color globColor = m.average(x-r, y-r, dd, dd);
				PVector globPosition = new PVector(x, y);
				PVector globSize = new PVector(dd, dd);

				State state = new State(globColor, globPosition, globSize);
				state.precise = true;

				noFill();
				stroke(0, 0, 255);
				ellipse(state.sposition.x, state.sposition.y, state.ssize.x, state.ssize.y);
				noStroke();
				foundStates.add(state);
			}
		}

		return foundStates;
	}
};