// uchovává všechny míčky i kandidáty na míčky
class Balls {
	ArrayList<Ball> balls;

	String debugString = "";

	Finder finder;

	Balls() {
		balls = new ArrayList<Ball>();

		finder = new Finder();
	}

	void adapt() {
		for (Ball ball : balls) {
			ball.ballProbability = 0.5;
		}
	}

	// projde globy a přiřadí je k míčkům / vytvoří nové míčky
	void processGlobs(int[][] globs, int[][][] globPixels) {
		ArrayList<State> states = new ArrayList<State>();

		for (Ball ball : balls) {
			// predikce se updatuje zde, protože teprve teď známe timestamp nového snímku
			ball.updatePrediction();
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

		// přidá jednoduché případy
			// a) nové míčky
			// b) stávající míčky, kterým program připsal velikou pravděpodobnost
		for (int i=states.size()-1; i>=0; i--) {
			State state = states.get(i);

			if(balls.size() > 0){
				int ballCount = balls.size();

				// vytvoří pole pravděpodobností pro každý známý míček
				float[] probabilities = new float[ballCount];
				HashMap<Float, Ball> ballsProbabilities = new HashMap<Float, Ball>(ballCount);

				for (int j = 0; j < ballCount; j++) {
					if(!balls.get(j).updated){
						probabilities[j] = balls.get(j).getProbability(state);
					}
					ballsProbabilities.put(probabilities[j], balls.get(j));
				}

				// optimalizovat :'( (EDIT: neni to tak hrozný :D )
				probabilities = reverse(sort(probabilities));

				int circleCount = 0;
				for (float probability : probabilities) {
					if(probability > 0.6 && circleCount < 2){
						circleCount++;
					}
					else {
						break;
					}
				}

				fill(255,255,255);
				textSize(30);
				textAlign(LEFT, TOP);
				text(""+circleCount, state.sposition.x, state.sposition.y);
				textSize(12);

				// if(circleCount > 0 && state.globId != null){
				if(circleCount > 0){
					int[][] boundary = globPixels[state.globId];
					ArrayList<State> circles = finder.findCircles(boundary, state, circleCount);
					// strokeWeight(3);
					// noFill();
					// for (int j=0; j<circles.size(); j++) {
					// 	State circle = circles.get(j);
					// 	stroke(j*255, 255, 0, 128);
					// 	ellipse(circle.sposition.x, circle.sposition.y, circle.ssize.x, circle.ssize.y);
					// }
					// strokeWeight(1);

					if(circles.size() == 1){
						Ball bestBall = ballsProbabilities.get(probabilities[0]);
						float newProbability = bestBall.getProbability(circles.get(0));
						if(newProbability > probabilities[0]){
							// odstraní původní, protože máme lepší
							states.remove(state);

							state = circles.get(0);
							ballsProbabilities.put(newProbability, bestBall);
							probabilities[0] = newProbability;
						}
					}
					if(circles.size() == 2){
						// states.remove(state);
						// states.addAll(circles);
						// i += 2;
						// continue;

						Ball bestBall = ballsProbabilities.get(probabilities[0]);
						float newProbability1 = bestBall.getProbability(circles.get(0));
						float newProbability2 = bestBall.getProbability(circles.get(1));
						if(newProbability1 > newProbability2 && newProbability1 > probabilities[0]){
							states.remove(state);

							state = circles.get(0);
							ballsProbabilities.put(newProbability1, bestBall);
							probabilities[0] = newProbability1;
							fill(255,0,0);
							text(""+newProbability1, 0, 0);
							fill(0,255,0);
							text(""+newProbability2, 0, 0);
							
							// states.add(circles.get(1));
							// i++;
						}
						if(newProbability2 > newProbability1 && newProbability2 > probabilities[0]){
							states.remove(state);

							state = circles.get(1);
							ballsProbabilities.put(newProbability2, bestBall);
							probabilities[0] = newProbability2;

							// states.add(circles.get(0));
							// i++;
						}
					}
				}

				// známý míček
				if(probabilities[0] > 0.6){
					Ball ball = ballsProbabilities.get(probabilities[0]);
					ball.updateBall(state);
					states.remove(state);
					continue;
				}
				// nový míček!
				if(probabilities[0] < 0.3){
					addBall(state);
					states.remove(state);
					continue;
				}

				// ostatní případy jsou sporné a chce se mi z nich plakat
			}
			else {
				// pokud netrackujeme žádné míčky, vytvoří nové ze všech globů
				addBall(state);
				states.remove(state);
			}
		}

		// ve states jsou teď sporné míčky, můžeme je leda oplakávat

		for (int i = balls.size()-1; i >= 0; i--) {
			Ball ball = balls.get(i);
			
			// projde všechny míčky, ke kterým nebyl nalezen glob
			if(!ball.updated){
				// několik stavů si míček dopočítá
				if(ball.predictedStates < 3){
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

	void addBall(State state) {
		balls.add(new Ball(state));
	}

	void render() {
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