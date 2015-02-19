int ballCounter = 0;
// míček / kandidát na míček
class Ball {
	ArrayList<State> stateHistory;
	// počet zaznamenaných stavů
	int historyLength = ballStateCount;
	// jak moc jsme si jistí, že míček stále existuje?
	float probability = 1;
	// jak moc jsme si jistí, že je toto opravdu míček?
	float ballProbability = 0.5;
	boolean updated;

	int id;

	State avgState;
	State predictedState;

	String debugString = "";

	Ball (State state) {
		id = ++ballCounter;

		stateHistory = new ArrayList<State>();
		avgState = new State();
		predictedState = new State();
		addState(state);

		updated = true;
	}

	// přidá nový stav a odebere nejstarší
	void addState(State state){
		if(stateHistory.size() == historyLength){
			stateHistory.remove(historyLength-1);
		}
		stateHistory.add(0, state);

		update();
	}

	// přidá vypočítaný stav
	void predict () {
		probability *= 0.5;
		addState(new State(predictedState));
	}

	void removeOldestState(){
		if(hasHistory()){
			stateHistory.remove(stateHistory.size()-1);
			update();
		}
	}

	boolean hasHistory(){
		return stateHistory.size() > 0;
	}
	
	State getState(){
		return stateHistory.get(0);
	}

	State getState(int index){
		return stateHistory.get(index);
	}

	// vypočítá předpokládanou pozici míčku na dalším snímku
	void updatePrediction() {
		if(stateHistory.size() >= 1){
			State state1 = getState(0); // poslední
			predictedState.scolor = state1.scolor;
			if(stateHistory.size() >= 2){
				State state2 = getState(1); // předposlední

				// predictedState.ssize.set(state1.ssize);
				// predictedState.ssize.add(state2.ssize);
				// predictedState.ssize.div(2);
				predictedState.ssize = avgState.ssize.get();

				if(stateHistory.size() >= 3 && false){ // fix
					State state3 = getState(2); // předpředposlední

					// korekce se týká připadu, kdy míček mizí za překážkou a zmenšuje se mu velikost
					// při zmenšující se velikosti se totiž přesouvá i střed, který pak nekoresponduje s reálným
					PVector state1CorrectedPosition;
					PVector state2CorrectedPosition;
					PVector state3CorrectedPosition;

					if(PVector.sub(state1.sposition, state2.sposition).dot(new PVector(1, 1)) > 0){
						state1CorrectedPosition = PVector.sub(avgState.ssize, state1.ssize);
						state2CorrectedPosition = PVector.sub(avgState.ssize, state2.ssize);
						state3CorrectedPosition = PVector.sub(avgState.ssize, state3.ssize);
					}
					else {
						state1CorrectedPosition = PVector.sub(state1.ssize, avgState.ssize);
						state2CorrectedPosition = PVector.sub(state2.ssize, avgState.ssize);
						state3CorrectedPosition = PVector.sub(state3.ssize, avgState.ssize);
					}

					state1CorrectedPosition.mult(0.5 * correctionWeight);
					state2CorrectedPosition.mult(0.5 * correctionWeight);
					state3CorrectedPosition.mult(0.5 * correctionWeight);
					state1CorrectedPosition.add(state1.sposition);
					state2CorrectedPosition.add(state2.sposition);
					state3CorrectedPosition.add(state3.sposition);

					// v_p = 3v_1 - 3v_2 + v_3;
					predictedState.sposition.set(state1CorrectedPosition);
					predictedState.sposition.mult(3);
					predictedState.sposition.sub(PVector.mult(state2CorrectedPosition, 3));
					predictedState.sposition.add(state3CorrectedPosition);

					// predictedState.sposition.set(state1.sposition);
					// predictedState.sposition.mult(3);
					// predictedState.sposition.sub(PVector.mult(state2.sposition, 3));
					// predictedState.sposition.add(state3.sposition);

					// State state3 = getState(2); // předpředposlední
					// State state4 = getState(3);

					// predictedState.sposition.set(state1.sposition);
					// predictedState.sposition.sub(state2.sposition);
					// predictedState.sposition.sub(state3.sposition);
					// predictedState.sposition.add(state4.sposition);

					// predictedState.sposition.add(PVector.mult(state1.sposition, 2));
					// predictedState.sposition.sub(state2.sposition);

				}
				else {
					// korekce se týká připadu, kdy míček mizí za překážkou a zmenšuje se mu velikost
					// při zmenšující se velikosti se totiž přesouvá i střed, který pak nekoresponduje s reálným
					PVector state1CorrectedPosition;
					PVector state2CorrectedPosition;

					if(PVector.sub(state1.sposition, state2.sposition).dot(new PVector(1, 1)) > 0){
						state1CorrectedPosition = PVector.sub(avgState.ssize, state1.ssize);
						state2CorrectedPosition = PVector.sub(avgState.ssize, state2.ssize);
					}
					else {
						state1CorrectedPosition = PVector.sub(state1.ssize, avgState.ssize);
						state2CorrectedPosition = PVector.sub(state2.ssize, avgState.ssize);
					}

					state1CorrectedPosition.mult(0.5 * correctionWeight);
					state2CorrectedPosition.mult(0.5 * correctionWeight);
					state1CorrectedPosition.add(state1.sposition);
					state2CorrectedPosition.add(state2.sposition);

					// v_p = 2v_1 - v_2;
					predictedState.sposition.set(state1CorrectedPosition);
					predictedState.sposition.mult(2);
					predictedState.sposition.sub(state2CorrectedPosition);

					// predictedState.sposition.set(state1.sposition);
					// predictedState.sposition.mult(2);
					// predictedState.sposition.sub(state2.sposition);
				}

			}
			else {
				predictedState.sposition = state1.sposition.get();
				predictedState.ssize = state1.ssize.get();
			}
		}
	}

	void updateAverages(){
		float[] sumColor = new float[3];
		float[] sumPosition = new float[2];
		float[] sumSize = new float[2];

		for (State state : stateHistory) {
			sumColor[0] += red(state.scolor);
			sumColor[1] += green(state.scolor);
			sumColor[2] += blue(state.scolor);
			sumPosition[0] += state.sposition.x;
			sumPosition[1] += state.sposition.y;
			sumSize[0] += state.ssize.x;
			sumSize[1] += state.ssize.y;
		}

		int count = stateHistory.size();
		sumColor[0] /= count;
		sumColor[1] /= count;
		sumColor[2] /= count;
		sumPosition[0] /= count;
		sumPosition[1] /= count;
		sumSize[0] /= count;
		sumSize[1] /= count;

		avgState.scolor = color(sumColor[0], sumColor[1], sumColor[2]);
		avgState.sposition.x = sumPosition[0];
		avgState.sposition.y = sumPosition[1];
		avgState.ssize.x = sumSize[0];
		avgState.ssize.y = sumSize[1];
	}

	void updateProbability () {
		// pokud jsme už jednou zjistili, že glob je míček, pak přestaneme pochybovat
		if(ballProbability > ballProbabilityThreshold){
			ballProbability = 1;
		}
		else {
			if (stateHistory.size() > 5) {
				State state = getState();
				float avgDiff = PVector.sub(avgState.sposition, state.sposition).magSq();
				// pokud se hýbe víc než 10px/frame
				float minAvgDiff = pow(10, 2);
				ballProbability = ballProbability + (constrain(avgDiff/minAvgDiff, 0.0, 1.0) - ballProbability)*0.2;
			}
		}
	}

	void update () {
		updatePrediction();
		updateAverages();

		updateProbability();
	}

	// vrátí pravděpodobnost, se kterou daný state patří k míčku
	float getProbability (State state) {
		// float dColor = abs(red(state.scolor) - red(avgState.scolor)) + abs(green(state.scolor) - green(avgState.scolor)) + abs(blue(state.scolor) - blue(avgState.scolor));
		float dr = red(state.scolor) - red(avgState.scolor);
		float dg = green(state.scolor) - green(avgState.scolor);
		float db = blue(state.scolor) - blue(avgState.scolor);
		float dColor = abs(dr) + abs(dg) + abs(db);

		float dColorPerc = constrain((dColorMax-dColor)/dColorMax*colorWeight, 0.0, colorWeight);

		State lastState = getState();
		float dx = state.sposition.x - lastState.sposition.x;
		float dy = state.sposition.y - lastState.sposition.y;
		float dPosition = dx*dx + dy*dy;
		float dPositionPerc = constrain((dPositionMax-dPosition)/dPositionMax*positionWeight, 0.0, positionWeight);

		dx = state.sposition.x - predictedState.sposition.x;
		dy = state.sposition.y - predictedState.sposition.y;
		float dPredictedPosition = dx*dx + dy*dy;
		float dPredictedPositionPerc = constrain((dPredictedPositionMax-dPredictedPosition)/dPredictedPositionMax*predictedPositionWeight, 0.0, predictedPositionWeight);

		dx = state.ssize.x - avgState.ssize.x;
		dy = state.ssize.y - avgState.ssize.y;
		float dSize = dx*dx + dy*dy;
		float dSizePerc = constrain((dSizeMax-dSize)/dSizeMax*sizeWeight, 0.0, sizeWeight);

		// debugString = ""+round((dColorPerc + dPositionPerc + dPredictedPositionPerc + dSizePerc)*100.0)/100.0;

		return dColorPerc + dPositionPerc + dPredictedPositionPerc + dSizePerc;
	}

	void render(){
		if(ballProbability < 0.1)
			return;

		for (State state : stateHistory) {
			fill(red(state.scolor), green(state.scolor), blue(state.scolor));
			ellipse(state.sposition.x, state.sposition.y, state.ssize.x, state.ssize.y);
		}

		if(debug){
			State state = getState();

			fill(128, 0, 0, ballProbability*255);
			ellipse(state.sposition.x, state.sposition.y, state.ssize.x, state.ssize.y);
			noFill();
			stroke(0, 255, 0);
			ellipse(predictedState.sposition.x, predictedState.sposition.y, predictedState.ssize.x, predictedState.ssize.y);
			noStroke();

			textAlign(CENTER, CENTER);
			// zobrazení debug string
			fill(255,255,255);
			textSize(12);
			text(debugString, state.sposition.x, state.sposition.y);
			// zobrazení id
			fill(0, 0, 255);
			textSize(32);
			text(""+id, state.sposition.x, state.sposition.y);
		}
	}
};