import ddf.minim.analysis.*;
import ddf.minim.*;

class Renderer {
	Balls balls;

	int view = -1;
	int viewCount = 10;

	Animation duck;

	// sound
	Minim minim;  
	AudioPlayer jingle;
	FFT fftLin;
	BeatDetect beat;
	int beatCounter;
	float beatRadius;

	int[] barvy;

	long nextTimestamp;

	LB lb;
	Renderer(LB lb) {
		this.lb = lb;
		this.balls = lb.balls;
	}

	void init() {
		duck = new Animation("duck/framespsd", 24, 80);

		minim = new Minim(lb.parent);
		jingle = minim.loadFile("data/girls.mp3", 1024);

		fftLin = new FFT( jingle.bufferSize(), jingle.sampleRate() );
		fftLin.linAverages( 50 );
		beat = new BeatDetect();
		beatCounter = 0;
		beatRadius = 0;
		// barvy
		barvy = new int[5];
		barvy[0] = color(24,81,206);
		barvy[1] = color(198,24,0);
		barvy[2] = color(255,207,0);
		barvy[3] = color(49,182,57);
		barvy[4] = color(255,255,255);
	}

	void nextView() {
		// view = (view+1)%viewCount;
		view++;
		nextTimestamp = lb.frameTimestamp;

		if(view == 0)
			jingle.loop();
	}
	float rot = 0;
	void render() {
		pushMatrix();

		noStroke();
		noFill();

		fftLin.forward(jingle.mix);
		beat.detect(jingle.mix);

		switch (view) {
			case 0: // kuličky 1 - jednoduchý, bílý
				translate((width - height/float(lb.camResY)*float(lb.camResX))/2.0, 0);
				scale(min(width/float(lb.camResX), height/float(lb.camResY)));

				for (Ball ball : balls.balls) {
					if(ball.ballProbability == 1){
						State state = ball.getState();
						if (!state.predicted) {
							color c = barvy[4];
							fill(c);
							float x = state.sposition.x;
							float y = state.sposition.y;
							State avgState = ball.avgState;
							float r = (avgState.ssize.x+avgState.ssize.y)/3;
							ellipse(x, y, r, r);
						}
					}
				}
				break;
			case 1: // kuličky 2 - bílý, do rytmu
				translate((width - height/float(lb.camResY)*float(lb.camResX))/2.0, 0);
				scale(min(width/float(lb.camResX), height/float(lb.camResY)));

				if ( beat.isOnset() ){
					beatRadius = 40;
					beatCounter++;
				}
				beatRadius *= 0.9;

				for (Ball ball : balls.balls) {
					if(ball.ballProbability == 1){
						State state = ball.getState();
						if (!state.predicted) {
							color c = barvy[4];
							fill(c);
							float x = state.sposition.x;
							float y = state.sposition.y;
							State avgState = ball.avgState;
							float r = (avgState.ssize.x+avgState.ssize.y)/4 + beatRadius;
							ellipse(x, y, r, r);
						}
					}
				}
				break;
			case 2: // kuličky 3 - barevný, do rytmu
			case 4: // kuličky 3 - barevný, do rytmu
				translate((width - height/float(lb.camResY)*float(lb.camResX))/2.0, 0);
				scale(min(width/float(lb.camResX), height/float(lb.camResY)));

				if ( beat.isOnset() ){
					beatRadius = 50;
					beatCounter++;
				}
				beatRadius *= 0.9;

				background(map(beatRadius, 0, 40, 0, 20));

				for (Ball ball : balls.balls) {
					if(ball.ballProbability == 1){
						State state = ball.getState();
						if (!state.predicted) {
							color c = barvy[beatCounter%barvy.length];
							fill(c);
							float x = state.sposition.x;
							float y = state.sposition.y;
							State avgState = ball.avgState;
							float r = (avgState.ssize.x+avgState.ssize.y)/4 + beatRadius;
							ellipse(x, y, r, r);
						}
					}
				}
				break;
			case 3: // kuličky 4 - trails
				translate((width - height/float(lb.camResY)*float(lb.camResX))/2.0, 0);
				scale(min(width/float(lb.camResX), height/float(lb.camResY)));

				if ( beat.isOnset() ){
					beatRadius = 50;
					beatCounter++;
				}
				beatRadius *= 0.9;

				background(map(beatRadius, 0, 40, 0, 30));
				for (Ball ball : balls.balls) {
					if(ball.ballProbability == 1){
						// for (State state : ball.stateHistory) {
						for (int i = min(7, ball.stateHistory.size()-1); i >= 0; i--) {
							State state = ball.getState(i);
							if(!state.predicted && state.timestamp >= nextTimestamp){
								float factor = 300.0/(300.0 + 4*(lb.frameTimestamp - state.timestamp)*1E-6);
								color c = barvy[beatCounter%barvy.length];
								// fill(lerpColor(color(0), c, factor));
								fill(c, factor*255);
								float x = state.sposition.x;
								float y = state.sposition.y;
								float r = (state.ssize.x+state.ssize.y)/4 + beatRadius;
								ellipse(x, y, r, r);
							}
						}
					}
				}
				break;
			// case 4:
			// 	translate((width - height/float(lb.camResY)*float(lb.camResX))/2.0, 0);
			// 	scale(min(width/float(lb.camResX), height/float(lb.camResY)));

			// 	if ( beat.isOnset() ){
			// 		beatRadius = 50;
			// 		beatCounter++;
			// 	}
			// 	beatRadius *= 0.9;

			// 	background(map(beatRadius, 0, 40, 0, 20));

			// 	for (Ball ball : balls.balls) {
			// 		if(ball.ballProbability == 1){
			// 			State state = ball.getState();
			// 			if (!state.predicted) {
			// 				color c = barvy[beatCounter%barvy.length];
			// 				fill(c);
			// 				float x = state.sposition.x;
			// 				float y = state.sposition.y;
			// 				State avgState = ball.avgState;
			// 				float r = (avgState.ssize.x+avgState.ssize.y)/4 + beatRadius;
			// 				// ellipse(x, y, r, r);
			// 				pushMatrix();
			// 				translate(x, y);
			// 				PVector speed = new PVector();
			// 				if(ball.stateHistory.size() >= 3){
			// 					speed = PVector.sub(ball.getState(0).sposition, ball.getState(2).sposition);
			// 					speed.div((ball.getState(0).timestamp - ball.getState(2).timestamp)*1E-6);
			// 				}
			// 				// rotate((ball.timestamp - lb.frameTimestamp)*1E-10*(10+speed.mag()));
			// 				ball.rot += 0.001 + speed.magSq()/5.0;
			// 				rotate(ball.rot);
			// 				triangle(0, -sqrt(3)/3.0*r, -r/2.0, sqrt(3)/6.0*r, r/2.0, sqrt(3)/6.0*r);
			// 				popMatrix();
			// 			}
			// 		}
			// 	}
			// 	break;
			case 5: // přechod ptáci - kuličky
			case 10: // přechod ptáci - kuličky
				translate((width - height/float(lb.camResY)*float(lb.camResX))/2.0, 0);
				scale(min(width/float(lb.camResX), height/float(lb.camResY)));

				if ( beat.isOnset() ){
					beatRadius = 50;
					beatCounter++;
				}
				beatRadius *= 0.9;

				background(map(beatRadius, 0, 40, 0, 20));

				for (Ball ball : balls.balls) {
					if(ball.ballProbability == 1){
						State state = ball.getState();
						if (!state.predicted) {
							color c = barvy[beatCounter%barvy.length];
							fill(c);
							float x = state.sposition.x;
							float y = state.sposition.y;
							State avgState = ball.avgState;
							float r = (avgState.ssize.x+avgState.ssize.y)/4 + beatRadius;
							// if(beatCounter % 2 == 0){
							if(round((lb.frameTimestamp - nextTimestamp)*1E-6/125.0)%2 == 0){
								ellipse(x, y, r, r);
							}
							else {
								duck.display((lb.frameTimestamp-ball.timestamp)*1E-6, x, y, 2.5*r, 2.5*r);
							}
						}
					}
				}
				break;
			case 6: // ptáci
				translate((width - height/float(lb.camResY)*float(lb.camResX))/2.0, 0);
				scale(min(width/float(lb.camResX), height/float(lb.camResY)));

				if ( beat.isOnset() ){
					beatRadius = 50;
					beatCounter++;
				}
				beatRadius *= 0.9;

				background(map(beatRadius, 0, 40, 0, 20));

				for (Ball ball : balls.balls) {
					if(ball.ballProbability == 1){
						State state = ball.getState();
						if (!state.predicted) {
							color c = barvy[beatCounter%barvy.length];
							fill(c);
							float x = state.sposition.x;
							float y = state.sposition.y;
							State avgState = ball.avgState;
							float r = (avgState.ssize.x+avgState.ssize.y)/4 + beatRadius;
							duck.display((lb.frameTimestamp-ball.timestamp)*1E-6, x, y, 2.5*r, 2.5*r);
						}
					}
				}
				break;
			case 7: // ptáci s trojúhelníkem s přechodem
				translate((width - height/float(lb.camResY)*float(lb.camResX))/2.0, 0);
				scale(min(width/float(lb.camResX), height/float(lb.camResY)));

				if ( beat.isOnset() ){
					beatRadius = 50;
					beatCounter++;
				}
				beatRadius *= 0.9;

				background(map(beatRadius, 0, 40, 0, 20));

				for (Ball ball : balls.balls) {
					if(ball.ballProbability == 1){
						State state = ball.getState();
						if (!state.predicted) {
							color c = barvy[beatCounter%barvy.length];
							fill(c);
							float x = state.sposition.x;
							float y = state.sposition.y;
							State avgState = ball.avgState;
							float r = (avgState.ssize.x+avgState.ssize.y)/4 + beatRadius;
							duck.display((lb.frameTimestamp-ball.timestamp)*1E-6, x, y, 2.5*r, 2.5*r);
						}
					}
				}

				float factor = 1 - 10000.0/(10000.0 + 4*(lb.frameTimestamp - nextTimestamp)*1E-6);

				noFill();
				stroke(255, 255, 255, factor*160);
				strokeWeight(3);
				for (int i = 0; i < balls.balls.size()-1; i++) {
					for (int j = i+1; j < balls.balls.size(); j++	) {
						Ball b1 = balls.balls.get(i);
						Ball b2 = balls.balls.get(j);
						if(b1.ballProbability == 1 && b2.ballProbability == 1 && !b1.getState().predicted && !b2.getState().predicted){
							State s1 = b1.avgState;
							State s2 = b2.avgState;
							line(s1.sposition.x, s1.sposition.y, s2.sposition.x, s2.sposition.y);
						}
					}
				}

				break;
			case 9:
				translate((width - height/float(lb.camResY)*float(lb.camResX))/2.0, 0);
				scale(min(width/float(lb.camResX), height/float(lb.camResY)));

				if ( beat.isOnset() ){
					beatRadius = 50;
					beatCounter++;
				}
				beatRadius *= 0.9;

				background(map(beatRadius, 0, 40, 0, 20));

				for (Ball ball : balls.balls) {
					if(ball.ballProbability == 1){
						State state = ball.getState();
						if (!state.predicted) {
							color c = barvy[beatCounter%barvy.length];
							fill(c);
							float x = state.sposition.x;
							float y = state.sposition.y;
							State avgState = ball.avgState;
							float r = (avgState.ssize.x+avgState.ssize.y)/4 + beatRadius;
							duck.display((lb.frameTimestamp-ball.timestamp)*1E-6, x, y, 2.5*r, 2.5*r);
						}
					}
				}


				noFill();
				stroke(255, 255, 255, 160);
				strokeWeight(3);
				for (int i = 0; i < balls.balls.size()-1; i++) {
					for (int j = i+1; j < balls.balls.size(); j++	) {
						Ball b1 = balls.balls.get(i);
						Ball b2 = balls.balls.get(j);
						if(b1.ballProbability == 1 && b2.ballProbability == 1 && !b1.getState().predicted && !b2.getState().predicted){
							State s1 = b1.avgState;
							State s2 = b2.avgState;
							line(s1.sposition.x, s1.sposition.y, s2.sposition.x, s2.sposition.y);
						}
					}
				}

				break;
			case 8: // ptáci s trojúhelníkem se stabilizací
				translate((width - height/float(lb.camResY)*float(lb.camResX))/2.0, 0);
				scale(min(width/float(lb.camResX), height/float(lb.camResY)));

				if ( beat.isOnset() ){
					beatRadius = 50;
					beatCounter++;
				}
				beatRadius *= 0.9;

				background(map(beatRadius, 0, 40, 0, 20));

				if(balls.balls.size() == 0)
					break;

				Ball oldest = balls.balls.get(0);
				for (Ball ball : balls.balls) {
					if(ball.timestamp < oldest.timestamp && ball.updated)
						oldest = ball;
				}

				PVector stabilni = oldest.getState().sposition;
				translate(-stabilni.x+lb.camResX/2.0, -stabilni.y+lb.camResY/2.0);

				for (Ball ball : balls.balls) {
					if(ball.ballProbability == 1){
						State state = ball.getState();
						if (!state.predicted) {
							color c = barvy[beatCounter%barvy.length];
							fill(c);
							float x = state.sposition.x;
							float y = state.sposition.y;
							State avgState = ball.avgState;
							float r = (avgState.ssize.x+avgState.ssize.y)/4 + beatRadius;
							duck.display((lb.frameTimestamp-ball.timestamp)*1E-6, x, y, 2.5*r, 2.5*r);
						}
					}
				}


				noFill();
				stroke(255, 255, 255, 160);
				strokeWeight(3);
				for (int i = 0; i < balls.balls.size()-1; i++) {
					for (int j = i+1; j < balls.balls.size(); j++	) {
						Ball b1 = balls.balls.get(i);
						Ball b2 = balls.balls.get(j);
						if(b1.ballProbability == 1 && b2.ballProbability == 1 && !b1.getState().predicted && !b2.getState().predicted){
							State s1 = b1.avgState;
							State s2 = b2.avgState;
							line(s1.sposition.x, s1.sposition.y, s2.sposition.x, s2.sposition.y);
						}
					}
				}

				break;
			// case 0: // kuličky 4 - trails
			// 	translate((width - height/float(lb.camResY)*float(lb.camResX))/2.0, 0);
			// 	scale(min(width/float(lb.camResX), height/float(lb.camResY)));

			// 	if ( beat.isOnset() ){
			// 		beatRadius = 50;
			// 		beatCounter++;
			// 	}
			// 	beatRadius *= 0.9;

			// 	float cas = (lb.frameTimestamp - nextTimestamp)*1E-6;

			// 	background(map(beatRadius, 0, 40, 0, 30));
			// 	for (Ball ball : balls.balls) {
			// 		if(ball.ballProbability == 1){
			// 			int j = 0;
			// 			// trail
			// 			for (int i = min(30, ball.stateHistory.size()-1); i >= 0; i--) {
			// 				State state = ball.getState(i);
			// 				if(!state.predicted && state.timestamp >= nextTimestamp){
			// 					float casStav = max(0.0, (state.timestamp - nextTimestamp)*1E-6);
			// 					// float f = max(0.0, min(1.0, ()/1000.0*cas/1000.0)); //+ (lb.frameTimestamp - state.timestamp)*1E-6);
			// 					float f = min(1.0, pow(casStav/2000.0, 30.0)/10000000000000000000.0);

			// 					color c = barvy[(beatCounter+ball.id)%barvy.length];
			// 					fill(c, f*255);
			// 					float x = state.sposition.x;
			// 					float y = state.sposition.y;
			// 					// if(cas > 2000){
			// 					// 	y = lerp(y, height, 5000/(cas - 2000));
			// 					// 	// y += 5-5000/(cas - 2000);
			// 					// 	y -= max(0.0, (300-300*5000/(cas - 2000)))*(lb.frameTimestamp - state.timestamp)*1E-9;
			// 					// }
			// 					float r = (state.ssize.x+state.ssize.y)/4 + beatRadius;
			// 					ellipse(x, y, r, r);
			// 					j++;
			// 				}
			// 			}
			// 			// // lead
			// 			// State state = ball.getState();
			// 			// if(!state.predicted && state.timestamp >= nextTimestamp){
			// 			// 	color c = barvy[(beatCounter+ball.id)%barvy.length];
			// 			// 	fill(c);
			// 			// 	float x = state.sposition.x;
			// 			// 	float y = state.sposition.y;
			// 			// 	float r = (state.ssize.x+state.ssize.y)/4 + beatRadius;
			// 			// 	ellipse(x, y, r, r);
			// 			// }
			// 		}
			// 	}
			// 	break;
			case 11: // šneci
				rotate(PI/2);
				translate(0, -width);
				scale(float(height)/float(lb.camResX));

				if ( beat.isOnset() ){
					beatRadius = 50;
					beatCounter++;
				}
				beatRadius *= 0.9;

				background(map(beatRadius, 0, 40, 0, 30));

				for (Ball ball : balls.balls) {
					if(ball.ballProbability == 1){
						// long lastTimestamp = lb.frameTimestamp;
						int j = 0;
						for (int i = 0; i < min(200, ball.stateHistory.size()); i++) {
							State state = ball.stateHistory.get(i);
							float stateLife = (state.timestamp - ball.timestamp)*1E-6;
							// if(round(stateLife) % 120 < 60 || i == 0 || i == ball.stateHistory.size()-1){
							if(!state.predicted){
								j++;
								float translation = width/10 + 0.3*(lb.frameTimestamp - state.timestamp)*1E-6;
								// color b = color(brightness(state.scolor));
								color c = barvy[ball.id%barvy.length];
								fill(c);
								// fill(lerpColor(c, b, 0.2));
								// strokeWeight(5);
								// stroke( c );
								float x = state.sposition.x;// + (j%2==0?-1:1)*fftLin.getAvg(min(j, fftLin.avgSize()-1))*10;
								float y = translation;
								float r = (state.ssize.x+state.ssize.y)/4 + min(30, fftLin.getAvg(min(j, fftLin.avgSize()-1))*15);
								// float r = (state.ssize.x+state.ssize.y)/4;
								// float r = (state.ssize.x+state.ssize.y)/4 + min(30, fftLin.getAvg(min(j, fftLin.avgSize()-1))*10);
								ellipse(x, y, r, r);
							}
							// }
						}
					}
				}
				break;
		}

		// for (Ball ball : balls.balls) {
		// 	if(ball.ballProbability == 1){
		// 		// ČÁRA ZA MÍČKY
		// 		// noFill();
		// 		// stroke(red(ball.avgState.scolor), green(ball.avgState.scolor), blue(ball.avgState.scolor));
		// 		// strokeWeight(5);
		// 		// beginShape(LINES);
		// 		// for (State state : ball.stateHistory) {
		// 		// 	if(!state.predicted){
		// 		// 		vertex(state.sposition.x, state.sposition.y);
		// 		// 	}
		// 		// }
		// 		// endShape();

		// 		// CHAPADLA!!
		// 		// for (State state : ball.stateHistory) {
		// 		// 	if(!state.predicted){
		// 		// 		fill(red(state.scolor), green(state.scolor), blue(state.scolor));
		// 		// 		float factor = 300.0/(300 + frameTimestamp - state.timestamp);
		// 		// 		float x = state.sposition.x + (camResX/2 - state.sposition.x)*factor;
		// 		// 		float y = state.sposition.y + (camResY/2 - state.sposition.y)*factor;
		// 		// 		ellipse(x, y, state.ssize.x*factor, state.ssize.y*factor);
		// 		// 	}
		// 		// }

		// 		// UBÍHAJÍCÍ STOPY DOZADU
		// 		// for(int i = ball.stateHistory.size()-1; i >= 0; i--){
		// 		// 	State state = ball.stateHistory.get(i);
		// 		// 	if(!state.predicted){
		// 		// 		float factor = 300.0/(300 + frameTimestamp - state.timestamp);
		// 		// 		fill(red(state.scolor), green(state.scolor), blue(state.scolor), int(factor*255));
		// 		// 		float x = camResX/2 + (-camResX/2 + state.sposition.x)*factor;
		// 		// 		float y = camResY/2 + (-camResY/2 + state.sposition.y)*factor;
		// 		// 		ellipse(x, y, state.ssize.x*factor, state.ssize.y*factor);
		// 		// 	}
		// 		// }


		popMatrix();
	}
};