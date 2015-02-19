// uchovává všechny míčky i kandidáty na míčky
class Balls {
	ArrayList<Ball> balls;

	String debugString = "";

	Balls () {
		balls = new ArrayList<Ball>();
	}

	void adapt() {
		for (Ball ball : balls) {
			ball.ballProbability = 0.5;
		}
	}

	// projde globy a přiřadí je k míčkům / vytvoří nové míčky
	void processGlobs (int[][] globs) {
		ArrayList<State> states = new ArrayList<State>();

		for (Ball ball : balls) {
			ball.updated = false;
		}

		for (int[] glob : globs) {
			color globColor = m.average(glob[0], glob[1], glob[0] + glob[2], glob[1] + glob[3]);
			PVector globPosition = new PVector(glob[0]+glob[2]/2, glob[1]+glob[3]/2);
			PVector globSize = new PVector(glob[2], glob[3]);

			states.add(new State(globColor, globPosition, globSize));
		}

		String[] dbg = new String[states.size()];
		// přidá jednoduché případy
			// a) nové míčky
			// b) stávající míčky, kterým program připsal velikou pravděpodobnost
		for (int i=states.size()-1; i>=0; i--) {
			State state = states.get(i);
			if(balls.size() > 0){
				float[] probabilities = new float[balls.size()];
				float[] probabilitiesSorted = new float[balls.size()];
				// pokud už jsou uložené míčky
				for (int j = 0; j < balls.size(); j++) {
					probabilities[j] = balls.get(j).getProbability(state);
					probabilitiesSorted[j] = probabilities[j];
				}

				dbg[i] = join(str(probabilitiesSorted), ", ");

				// optimalizovat :'(
				probabilitiesSorted = reverse(sort(probabilitiesSorted));
				// println(probabilitiesSorted);
				int max1 = find(probabilitiesSorted[0], probabilities);

				// vysoká pravděpodobnost, že glob = známý míček
				if(probabilitiesSorted[0] > 0.7){
					Ball ball = balls.get(max1);

					ball.updated = true;
					ball.probability = 1;
					ball.addState(state);
					states.remove(state);
				}
				// glob neodpovídá žádnému novému míčku
				if(probabilitiesSorted[0] < 0.3){
					balls.add(new Ball(state));
					states.remove(state);
				}
			}
			else {
				// pokud netrackujeme žádné míčky, vytvoří ze všech globů
				balls.add(new Ball(state));
				states.remove(state);
			}
		}

		// debugString = join(dbg, "\n");
		debugString = ""+threshold;

		// ve states nám teď zůstaly sporné globy
		// zatím s nimi nic nedělám

		for (int i = balls.size()-1; i >= 0; i--) {
			Ball ball = balls.get(i);
			// projde všechny míčky, ke kterým nebyl nalezen glob
			if(!ball.updated){
				// několik stavů si míček dopočítá
				if(ball.probability > pow(0.5, 5)){
					ball.predict();
				}
				// pokud počet dopočítaných stavů překročí hranici
				else {
					// pak se začnou stavy odzadu mazat
					ball.removeOldestState();
					// dokud míček nezmizí
					if(!ball.hasHistory()){
						balls.remove(ball);
					}
				}
			}
		}
	}

	void render(){
		for (Ball ball : balls) {
			ball.render();
		}

		if(debug){
			fill(255,255,255);
			textSize(12);
			textAlign(LEFT, TOP);
			text(debugString, 0, 0);
		}
	}
};