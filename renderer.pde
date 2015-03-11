class Renderer {
	Balls balls;

	Animation duck;

	Renderer(Balls balls) {
		this.balls = balls;
	}

	void init() {
		duck = new Animation("duck/framespsd", 24, 80);
	}

	// ŠNECI! - skoro jako na videu
	void rendersneci() {
		pushMatrix();
		
		noStroke();
		// scale(min(width/float(camResX), height/float(camResY)));
		rotate(PI/2);
		translate(0, -width);
		scale(float(height)/float(camResX));

		for (Ball ball : balls.balls) {
			if(ball.ballProbability == 1){
				for (State state : ball.stateHistory) {
					if(!state.predicted){
						float translation = 0.3*(frameTimestamp - state.timestamp);
						fill(red(state.scolor), green(state.scolor), blue(state.scolor));
						float x = state.sposition.x;
						float y = state.sposition.y+translation;
						ellipse(x, y, state.ssize.x, state.ssize.y);
					}
				}
			}
		}

		popMatrix();
	}

	void render() {
		pushMatrix();

		translate((width - height/float(camResY)*float(camResX))/2.0, 0);
		scale(min(width/float(camResX), height/float(camResY)));

		noStroke();
		noFill();
		for (Ball ball : balls.balls) {
			if(ball.ballProbability == 1){
				// ČÁRA ZA MÍČKY
				// noFill();
				// stroke(red(ball.avgState.scolor), green(ball.avgState.scolor), blue(ball.avgState.scolor));
				// strokeWeight(5);
				// beginShape(LINES);
				// for (State state : ball.stateHistory) {
				// 	if(!state.predicted){
				// 		vertex(state.sposition.x, state.sposition.y);
				// 	}
				// }
				// endShape();

				// CHAPADLA!!
				// for (State state : ball.stateHistory) {
				// 	if(!state.predicted){
				// 		fill(red(state.scolor), green(state.scolor), blue(state.scolor));
				// 		float factor = 300.0/(300 + frameTimestamp - state.timestamp);
				// 		float x = state.sposition.x + (camResX/2 - state.sposition.x)*factor;
				// 		float y = state.sposition.y + (camResY/2 - state.sposition.y)*factor;
				// 		ellipse(x, y, state.ssize.x*factor, state.ssize.y*factor);
				// 	}
				// }

				// UBÍHAJÍCÍ STOPY DOZADU
				// for(int i = ball.stateHistory.size()-1; i >= 0; i--){
				// 	State state = ball.stateHistory.get(i);
				// 	if(!state.predicted){
				// 		float factor = 300.0/(300 + frameTimestamp - state.timestamp);
				// 		fill(red(state.scolor), green(state.scolor), blue(state.scolor), int(factor*255));
				// 		float x = camResX/2 + (-camResX/2 + state.sposition.x)*factor;
				// 		float y = camResY/2 + (-camResY/2 + state.sposition.y)*factor;
				// 		ellipse(x, y, state.ssize.x*factor, state.ssize.y*factor);
				// 	}
				// }

				// KACHNY!!!! (vypadaj suprově)
				if(ball.stateHistory.size() < 2)
					continue;
				State state = ball.getState();
				if(!state.predicted){
					float r = sqrt(state.ssize.x*state.ssize.x + state.ssize.y*state.ssize.y);
					duck.display(frameTimestamp-ball.timestamp, state.sposition.x, state.sposition.y, 2.5*r, 2.5*r);
				}
			}
		}

		// noFill();
		// stroke(255, 255, 255, 128);
		// strokeWeight(3);
		// for (int i = 0; i < balls.balls.size()-1; i++) {
		// 	for (int j = i+1; j < balls.balls.size(); j++	) {
		// 		Ball b1 = balls.balls.get(i);
		// 		Ball b2 = balls.balls.get(j);
		// 		if(b1.ballProbability == 1 && b2.ballProbability == 1){
		// 			State s1 = b1.avgState;
		// 			State s2 = b2.avgState;
		// 			line(s1.sposition.x, s1.sposition.y, s2.sposition.x, s2.sposition.y);
		// 		}
		// 	}
		// }

		popMatrix();
	}
};