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
		step            = 0.11;
		prt             = 0.35;
		np              = 10;
		migrationsLimit = 70;
		acceptedError   = 5;
		d               = 6;
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

	Candidate migrate () {
		debugPerf = 0;

		candidates = new Candidate[np];

		for(int i=0; i<np; i++){
			float[] values = new float[d];

			for (int j = 0; j < d; j+=3) {
				int[] p1 = globPixels[int(random(0, pointCount))];
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

		Candidate[] minmax = getMinMax();
		int migrations = 0;
		do {
			migration(minmax[0]);
			minmax = getMinMax();
		} while (++migrations < migrationsLimit && (minmax[1].error-minmax[0].error) > acceptedError);

		balls.debugString = ""+(minmax[1].error-minmax[0].error);
		return minmax[0];
	}

	void migration (Candidate leader) {
		// stroke(255, 255, 0);
		// ellipse(leader.position.get(0), leader.position.get(1), leader.position.get(2), leader.position.get(2));
		// fill(255,255,255);
		// textSize(12);
		// textAlign(LEFT, TOP);
		// text(int(leader.error), leader.position.get(0)+leader.position.get(2), leader.position.get(1));
		// noFill();

		for (Candidate candidate : candidates) {
			candidate.follow(leader);
		}

	}

	float fitCircle (VecN circles, int index) {
		float error = 0;
		int circle = index*3;

		float[] errors = new float[d/3];
		for (int j = 0; j < pointCount; j++) {
			int[] p = globPixels[j];
			float x = circles.get(circle+0);
			float y = circles.get(circle+1);
			float r2 = circles.get(circle+2);

			float dx = p[0] - x;
			float dy = p[1] - y;
			error += abs(dx*dx + dy*dy - r2);
		}

		return error;
	}

	float fitCircles (VecN circles) {
		debugPerf++;

		float error = 0;

		float[] errors = new float[d/3];
		for (int j = 0; j < pointCount; j++) {
			int[] p = globPixels[j];
			for (int i = 0; i < d; i+=3) {
				float x = circles.get(i+0);
				float y = circles.get(i+1);
				float r2 = circles.get(i+2);

				float dx = p[0] - x;
				float dy = p[1] - y;
				errors[i/3] = abs(dx*dx + dy*dy - r2);
			}
			error += min(errors);
		}

		return error;
	}

	State[] findBalls (int[][] globPixels) {
		this.globPixels = globPixels;
		pointCount = globPixels.length;

		stroke(255, 0, 0);
		for(int j=0;j<pointCount - 1;j++){    
			line( globPixels[j][0]  ,  globPixels[j][1], globPixels[j+1][0]  ,  globPixels[j+1][1] );
		}

		Candidate leader = migrate();
		balls.debugString += "\n"+debugPerf+": "+leader.error+"\n"+int(leader.position.get(0))+" "+int(leader.position.get(1))+" "+int(leader.position.get(2));
		balls.debugString += "\n"+int(leader.position.get(3))+" "+int(leader.position.get(4))+" "+int(leader.position.get(5));

		float d;
		float fit0 = fitCircle(leader.position, 0);
		float fit1 = fitCircle(leader.position, 1);
		balls.debugString += "\n"+int(fit0)+" "+int(fit1);
		// if(fit0 < 5000 || abs(fit0 - fit1) < 1000){
			stroke(255, 255, 0);
			d = 2*sqrt(leader.position.get(2));
			ellipse(leader.position.get(0), leader.position.get(1), d, d);
		// }
		// if(fit1 < 5000 || abs(fit0 - fit1) < 1000){
			stroke(255, 0, 255);
			d = 2*sqrt(leader.position.get(5));
			ellipse(leader.position.get(3), leader.position.get(4), d, d);
		// }
		noStroke();

		return new State[1];
	}
};