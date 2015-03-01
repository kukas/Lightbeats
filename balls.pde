// uchovává všechny míčky i kandidáty na míčky
class Balls {
	ArrayList<Ball> balls;

	String debugString = "";

	Finder finder;

	Balls () {
		balls = new ArrayList<Ball>();

		finder = new Finder();
	}

	void adapt() {
		for (Ball ball : balls) {
			ball.ballProbability = 0.5;
		}
	}

	// projde globy a přiřadí je k míčkům / vytvoří nové míčky
	void processGlobs (int[][] globs, int[] camPixels) {
		ArrayList<State> states = new ArrayList<State>();

		debugString = "";

		for (Ball ball : balls) {
			ball.updated = false;
		}

		for (int i = 0; i < globs.length; i++) {
			int[] glob = globs[i];
			
			// filtrování globů, které jsou uvnitř jiných globů
			// - nevěstí to nic dobrého a míček to v 90% případů neni
			boolean inside = false;
			for (int j = i-1; j >= 0; j--) { // zneužívá se tady toho, že pokud glob bude v jiném globu, ten glob je před ním
				int[] glob2 = globs[j];
				if(glob2[0] < glob[0] && glob2[1] < glob[1] && glob2[0]+glob2[2] > glob[0]+glob[2] && glob2[1]+glob2[3] > glob[1]+glob[3]){
					inside = true;
					break;
				}
			}
			if(inside){
				continue;
			}

			color globColor = m.average(glob[0], glob[1], glob[0] + glob[2], glob[1] + glob[3]);
			PVector globPosition = new PVector(glob[0]+glob[2]/2, glob[1]+glob[3]/2);
			PVector globSize = new PVector(glob[2], glob[3]);

			State state = new State(globColor, globPosition, globSize);
			state.globId = i;
			states.add(state);
		}

		// připravené pro krušné časy - jmyron poskytuje obrys globu v bodech
		int globPixels[][][];
		// přidá jednoduché případy
			// a) nové míčky
			// b) stávající míčky, kterým program připsal velikou pravděpodobnost
			// c) hraniční případy, kdy více míčků u sebe splyne v jeden glob
	
		// globPixels = m.globPixels();
		// globPixels = m.globEdgePoints(3);
		// for (int i=states.size()-1; i>=0; i--) {
		// 	State state = states.get(i);
		// 	if(!state.precise){
		// 		if(globPixels[state.globId] != null){
		// 			ArrayList<State> foundStates = finder.findBalls(globPixels[state.globId], 2);
		// 			i += foundStates.size();
					
		// 			states.remove(state);
		// 			states.addAll(0, foundStates);
		// 		}
		// 	}
		// }
		
		debugString += balls.size()+", "+states.size()+"\n";
		for (int i=states.size()-1; i>=0; i--) {
			debugString += "\n"+i+": ";
			State state = states.get(i);

			// if(debug){
			// 	noFill();
			// 	stroke(255, 255, 255, 128);
			// 	if(state.precise){
			// 		stroke(255, 255, 0);
			// 	}
			// 	strokeWeight(3);
			// 	rectMode(CENTER);
			// 	rect(state.sposition.x, state.sposition.y, state.ssize.x, state.ssize.y);
			// 	rectMode(CORNER);
			// 	strokeWeight(1);
			// 	noStroke();
			// }

			if(balls.size() > 0){
				int ballCount = balls.size();

				float[] probabilities = new float[ballCount];
				HashMap<Float, Ball> ballsProbabilities = new HashMap<Float, Ball>(ballCount);

				for (int j = 0; j < ballCount; j++) {
					if(!balls.get(j).updated){
						probabilities[j] = balls.get(j).getProbability(state);
					}
					ballsProbabilities.put(probabilities[j], balls.get(j));
				}

				// optimalizovat :'(
				probabilities = reverse(sort(probabilities));

				stroke(255, 255, 255, 128);
				text(round(probabilities[0]*100)/100.0, state.sposition.x, state.sposition.y);
				
				if(probabilities[0] > 0.6 || (probabilities[0] > 0.5 && state.precise)){
					Ball ball = ballsProbabilities.get(probabilities[0]);
					updateBall(state, ball);
					states.remove(state);
					continue;
				}
				if(probabilities[0] < 0.1){
					addBall(state);
					states.remove(state);
					continue;
				}

				// if(!state.precise){
				// 	int bc = 0;
				// 	for(int j=0; j<probabilities.length; j++){
				// 		if(probabilities[j] > 0.4)
				// 			bc++;
				// 	}
				// 	globPixels = m.globEdgePoints(5);
				// 	if(bc > 0 && globPixels[state.globId] != null){
				// 		ArrayList<State> foundStates = finder.findBalls(globPixels[state.globId], bc);
				// 		i += foundStates.size();
						
				// 		states.remove(state);
				// 		states.addAll(0, foundStates);
				// 	}
				// }

				// pro jeden evidovaný míček
				// if(ballCount == 1){
				// 	// vysoká pravděpodobnost, že glob = známý míček
				// 	if(probabilities[0] > 0.7){
				// 		Ball ball = ballsProbabilities.get(probabilities[0]);
				// 		updateBall(state, ball);
				// 		states.remove(state);
				// 		continue;
				// 	}
				// 	// glob neodpovídá žádnému novému míčku
				// 	if(probabilities[0] < 0.4){
				// 		addBall(state);
				// 		states.remove(state);
				// 		continue;
				// 	}
				// 	// if(!state.precise){
				// 	// 	globPixels = m.globEdgePoints(5);
				// 	// 	if(globPixels[state.globId] != null){
				// 	// 		Ball[] tips = new Ball[1];
				// 	// 		tips[0] = ballsProbabilities.get(probabilities[0]);
				// 	// 		ArrayList<State> foundStates = finder.findBalls(globPixels[state.globId], tips);
				// 	// 		states.remove(state);
				// 	// 		states.addAll(foundStates);
				// 	// 		i += foundStates.size();
				// 	// 	}
				// 	// }
				// }
				// else {
				// 	// pokud je situace přehledná
				// 	if(probabilities[1] < 0.5 || state.precise){
				// 		debugString += "přehledné";
				// 		// vysoká pravděpodobnost, že glob = známý míček
				// 		if(probabilities[0] > 0.7 || state.precise){
				// 			Ball ball = ballsProbabilities.get(probabilities[0]);
				// 			updateBall(state, ball);
				// 			states.remove(state);
				// 		}
				// 		// glob neodpovídá žádnému novému míčku
				// 		if(probabilities[0] < 0.3){
				// 			addBall(state);
				// 			states.remove(state);
				// 		}
				// 	}
				// 	else {
				// 		debugString += "NEPŘEHLEDNÉ "+probabilities[1];
				// 		if(!state.precise){
				// 			globPixels = m.globEdgePoints(5);
				// 			if(globPixels[state.globId] != null){
				// 				Ball[] tips = new Ball[2];
				// 				tips[0] = ballsProbabilities.get(probabilities[0]);
				// 				tips[1] = ballsProbabilities.get(probabilities[1]);
				// 				ArrayList<State> foundStates = finder.findBalls(globPixels[state.globId], tips);
				// 				i += foundStates.size();
								
				// 				states.remove(state);
				// 				// states.addAll(0, foundStates);
				// 				for(State ssss : foundStates){
				// 					states.add(ssss);
				// 				}
				// 			}
				// 		}
				// 	}
				// }

			}
			else {
				// pokud netrackujeme žádné míčky, vytvoří ze všech globů
				addBall(state);
				states.remove(state);
			}
		}

		// debugString = ""+threshold;

		// ve states nám teď zůstaly sporné globy
		// zatím s nimi nic nedělám
		// if(states.size() > 0){
		// 	int globPixels[][][] = m.globEdgePoints(5);
		// 	for (int i=states.size()-1; i>=0; i--) {
		// 		State state = states.get(i);
		// 		if(globPixels[state.globId] != null){
		// 			finder.findBalls(globPixels[state.globId]);
		// 		}
		// 	}
		// }

		debugString += "\n";
		for (int i = balls.size()-1; i >= 0; i--) {
			Ball ball = balls.get(i);
			debugString += ball.updated+" ";
			
			// projde všechny míčky, ke kterým nebyl nalezen glob
			if(!ball.updated){
				// několik stavů si míček dopočítá
				// if(ball.probability > pow(0.5, 5)){
				// 	ball.predict();
				// }
				// // pokud počet dopočítaných stavů překročí hranici
				// else {
					// pak se začnou stavy odzadu mazat
					ball.removeOldestState();
					// dokud míček nezmizí
					if(!ball.hasHistory()){
						balls.remove(ball);
					}
				// }
			}
		}
	}

	void addBall (State state) {
		balls.add(new Ball(state));
	}

	void updateBall (State state, Ball ball) {
		ball.updated = true;
		ball.probability = 1;
		ball.addState(state);
	}

	void render(){
		for (Ball ball : balls) {
			ball.render();
		}

		if(debug){
			fill(255,255,255);
			textSize(16);
			textAlign(LEFT, TOP);
			text(debugString, 0, 0);
		}
	}
};