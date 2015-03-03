int ballCounter = 0;
// míček / kandidát na míček
class Ball {
	ArrayList<State> stateHistory;
	// počet zaznamenaných stavů
	int historyLength = ballStateCount;
	// jak moc jsme si jistí, že je toto opravdu míček?
	float ballProbability = 0.5;
	// počet posledních predikovaných stavů za sebou
	int predictedStates;
	// byl tomuto míčku tento frame přiřazen nový State?
	boolean updated;

	int id;
	int timestamp;

	// průměrný stav z posledních avgStateCount stavů
	State avgState;
	State predictedState;

	// debug string se zobrazí nad míčkem v debug módu
	String debugString = "";

	Ball(State state) {
		id = ++ballCounter;
		timestamp = frameTimestamp;

		stateHistory = new ArrayList<State>();
		avgState = new State();
		predictedState = new State();
		
		updateBall(state);
	}

	// přidá nový stav a odebere nejstarší
	void addState(State state) {
		if(stateHistory.size() == historyLength){
			stateHistory.remove(historyLength-1);
		}
		stateHistory.add(0, state);

		// zobrazí predikovaný stav při přidávání nového míčku, lze tím dobře srovnávat úspěšnost predikce
		if(debug){
			stroke(0, 255, 0);
			noFill();
			ellipse(predictedState.sposition.x, predictedState.sposition.y, predictedState.ssize.x, predictedState.ssize.y);
			noStroke();
		}

		update();
	}

	// přidá vypočítaný stav
	void predict() {
		predictedStates++;

		State state = new State(predictedState);
		state.predicted = true;
		addState(state);
	}

	void updateBall(State state) {
		updated = true;
		predictedStates = 0;
		addState(state);
	}

	void removeOldestState() {
		if(hasHistory()){
			stateHistory.remove(stateHistory.size()-1);
			update();
		}
	}

	boolean hasHistory() {
		return stateHistory.size() > 0;
	}
	
	State getState() {
		return stateHistory.get(0);
	}

	State getState(int index) {
		return stateHistory.get(index);
	}

	// aktualizuje predikci pozice míčku na novém snímku
	void updatePrediction() {
		// musíme mít z čeho predikovat
		if(stateHistory.size() >= 1){
			State state1 = getState(0); // poslední stav
			// predikovaná barva je poslední zaznamenaná barva
			predictedState.scolor = state1.scolor;
			if(stateHistory.size() >= 2){
				State state2 = getState(1); // předposlední stav

				// predikovaná velikost je poslední zaznamenaná velikost
				predictedState.ssize = avgState.ssize.get();

				if(stateHistory.size() >= 3){
					// pokud máme 3 a více stavů, můžeme vypočítat rychlost a zrychlení
					State state3 = getState(2); // předpředposlední stav

					// TODO: Opravit korekci, nějak blbne
					// korekce se týká připadu, kdy míček mizí za překážkou a zmenšuje se mu velikost
					// při zmenšující se velikosti se totiž přesouvá i střed, který pak nekoresponduje s reálným
					// PVector state1CorrectedPosition;
					// PVector state2CorrectedPosition;
					// PVector state3CorrectedPosition;

					// if(PVector.sub(state1.sposition, state2.sposition).dot(new PVector(1.0, 1.0)) > 0){
					// 	state1CorrectedPosition = PVector.sub(avgState.ssize, state1.ssize);
					// 	state2CorrectedPosition = PVector.sub(avgState.ssize, state2.ssize);
					// 	state3CorrectedPosition = PVector.sub(avgState.ssize, state3.ssize);
					// }
					// else {
					// 	state1CorrectedPosition = PVector.sub(state1.ssize, avgState.ssize);
					// 	state2CorrectedPosition = PVector.sub(state2.ssize, avgState.ssize);
					// 	state3CorrectedPosition = PVector.sub(state3.ssize, avgState.ssize);
					// }

					// state1CorrectedPosition.mult(0.5);
					// state2CorrectedPosition.mult(0.5);
					// state3CorrectedPosition.mult(0.5);
					// state1CorrectedPosition.add(state1.sposition);
					// state2CorrectedPosition.add(state2.sposition);
					// state3CorrectedPosition.add(state3.sposition);


					float t1 = state1.timestamp-state2.timestamp;
					float t2 = state2.timestamp-state3.timestamp;

					// poslední rychlost
					// PVector v1 = PVector.sub(state1CorrectedPosition, state2CorrectedPosition);
					PVector v1 = PVector.sub(state1.sposition, state2.sposition);
					v1.div(t1);

					// předposlední rychlost
					// PVector v2 = PVector.sub(state2CorrectedPosition, state3CorrectedPosition);
					PVector v2 = PVector.sub(state2.sposition, state3.sposition);
					v2.div(t2);

					predictedState.sposition.set(v1);
					predictedState.sposition.mult(t1+t2);
					predictedState.sposition.sub( PVector.div(PVector.mult(v2, t1+t2), 2.0) );
					// predictedState.sposition.add(state1CorrectedPosition);
					predictedState.sposition.add(state1.sposition);

				}
				else {
					// pokud máme pouze 2 stavy, lze vypočítat rychlost

					// P0 = P1 + (P1 - P2)/t1 * t0
					// ^    ^     ^             ^= čas posledního snímku
					// |    |     |=============== dráha/čas => rychlost
					// |    |===================== poslední pozice
					// |========================== nová pozice

					float t0 = frameTimestamp - state1.timestamp;
					float t1 = state1.timestamp - state2.timestamp;
					predictedState.sposition.set(state1.sposition);
					predictedState.sposition.sub(state2.sposition);
					predictedState.sposition.mult(t0/t1);
					predictedState.sposition.add(state1.sposition);
				}

			}
			else {
				// pokud máme v historii pouze jeden stav, predikovaný stav = poslední stav
				predictedState.sposition = state1.sposition.get();
				predictedState.ssize = state1.ssize.get();
			}
		}
	}

	void updateAverages() {
		float[] sumColor = new float[3];
		float[] sumPosition = new float[2];
		float[] sumSize = new float[2];

		// počítá z avgStateCount stavů nebo z méně
		int count = min(stateHistory.size(), avgStateCount);
		
		for (int i=0; i<count; i++) {
			State state = stateHistory.get(i);

			sumColor[0] += red(state.scolor);
			sumColor[1] += green(state.scolor);
			sumColor[2] += blue(state.scolor);
			sumPosition[0] += state.sposition.x;
			sumPosition[1] += state.sposition.y;
			sumSize[0] += state.ssize.x;
			sumSize[1] += state.ssize.y;
		}

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

	// vyhodnocuje, zda je tento Ball opravdu žonglérský míček
	void updateProbability() {
		// pokud jsme už jednou zjistili, že glob je míček, pak přestaneme pochybovat
		if(ballProbability > ballProbabilityThreshold){
			ballProbability = 1;
		}
		else {
			if (stateHistory.size() > 0) {
				State state = getState();
				float avgDiff = PVector.sub(avgState.sposition, state.sposition).magSq();
				// pokud se hýbe víc než 10px/frame
				float minAvgDiff = 100;
				ballProbability = ballProbability + (constrain(avgDiff/minAvgDiff, 0.0, 1.0) - ballProbability)*0.2;
			}
		}
	}

	void update() {
		updateAverages();

		updateProbability();
	}

	// vrátí pravděpodobnost, se kterou daný state patří k míčku
	float getProbability(State state) {
		// rozdíl od průměrné barvy
		float dr = red(state.scolor) - red(avgState.scolor);
		float dg = green(state.scolor) - green(avgState.scolor);
		float db = blue(state.scolor) - blue(avgState.scolor);
		float dColor = (abs(dr) + abs(dg) + abs(db))/deltaTime;
		float dColorPerc = constrain((dColorMax-dColor)/dColorMax*colorWeight, 0.0, colorWeight);

		// vzdálenost od poslední pozice
		State lastState = getState();
		float dx = state.sposition.x - lastState.sposition.x;
		float dy = state.sposition.y - lastState.sposition.y;
		float dPosition = (dx*dx + dy*dy)/deltaTime;
		float dPositionPerc = constrain((dPositionMax-dPosition)/dPositionMax*positionWeight, 0.0, positionWeight);

		// vzdálenost od predikované pozice
		dx = state.sposition.x - predictedState.sposition.x;
		dy = state.sposition.y - predictedState.sposition.y;
		float dPredictedPosition = (dx*dx + dy*dy)/deltaTime;
		float dPredictedPositionPerc = constrain((dPredictedPositionMax-dPredictedPosition)/dPredictedPositionMax*predictedPositionWeight, 0.0, predictedPositionWeight);

		// změna velikosti míčku
		dx = state.ssize.x - avgState.ssize.x;
		dy = state.ssize.y - avgState.ssize.y;
		float dSize = (dx*dx + dy*dy)/deltaTime;
		float dSizePerc = constrain((dSizeMax-dSize)/dSizeMax*sizeWeight, 0.0, sizeWeight);

		debugString = round((dColorPerc)*100.0)/100.0 + "; max(" +round((dPositionPerc)*100.0)/100.0 + "," +round((dPredictedPositionPerc)*100.0)/100.0 + "); " +round((dSizePerc)*100.0)/100.0;

		return dColorPerc + max(dPositionPerc, dPredictedPositionPerc) + dSizePerc;
	}

	void render() {
		if(debug){
			State state = getState();

			noFill();
			if(ballProbability == 1){
				if(updated)
					stroke(255, 255, 255);
				else
					stroke(255, 0, 0);
			}
			else
				stroke(255, 255, 255, 128);
			ellipse(state.sposition.x, state.sposition.y, state.ssize.x, state.ssize.y);
			noStroke();

			// pokud není žonglérský míček, nezobrazí se id ani debug string
			if(ballProbability < 1)
				return;

			// zobrazení debug string
			textAlign(CENTER, BOTTOM);
			fill(255,255,255);
			textSize(12);
			text(debugString, state.sposition.x, state.sposition.y-state.ssize.y/2);
			textAlign(CENTER, CENTER);
			// zobrazení id
			fill(0, 0, 255);
			textSize(28);
			text(""+id, state.sposition.x, state.sposition.y);
		}
	}
};