class Renderer {
	Balls balls;

	Animation duck;
	PImage sittingBird;
	PImage deadBird;

	LB lb;
	Renderer(LB lb) {
		this.lb = lb;
		this.balls = lb.balls;
	}

	void init() {
		duck = new Animation("duck/framespsd", 24, 80);
		sittingBird = loadImage("duck/sedici_ptak.png");
		deadBird = loadImage("duck/mrtvy_ptak.png");
	}

	// ŠNECI! - skoro jako na videu
	void rendersneci() {
		pushMatrix();
		
		noStroke();
		// scale(min(width/float(camResX), height/float(camResY)));
		rotate(PI/2);
		translate(0, -width);
		scale(float(height)/float(lb.camResX));

		for (Ball ball : balls.balls) {
			if(ball.ballProbability == 1){
				for (State state : ball.stateHistory) {
					if(!state.predicted){
						float translation = 0.3*(lb.frameTimestamp - state.timestamp);
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

	void render(int scene) {
		pushMatrix();

		translate((width - height/float(lb.camResY)*float(lb.camResX))/2.0, 0);
		scale(min(width/float(lb.camResX), height/float(lb.camResY)));

		noStroke();
		noFill();
		for (Ball ball : balls.balls) {
			if(ball.ballProbability == 1){
				// KACHNY!!!! (vypadaj suprově)
				if(ball.stateHistory.size() < 2)
					continue;
				State state = ball.getState();
				if(!state.predicted){
					float r = sqrt(state.ssize.x*state.ssize.x + state.ssize.y*state.ssize.y) * 2.5;
					imageMode(CENTER);
					if(scene == 0){
						image(sittingBird, state.sposition.x, state.sposition.y, r, r/sittingBird.width*sittingBird.height);
					}
					else if(scene == 1){
						duck.display((lb.frameTimestamp-ball.timestamp)*1E-6, state.sposition.x, state.sposition.y, r, r);
					}
					else if(scene == 2){
						float dt = (lb.frameTimestamp-state.timestamp)*1E-6;
						float acceleration = 0.00002;
						float ysize = r/deadBird.width*deadBird.height;
						float ypos = min(state.sposition.y+dt*dt*acceleration, lb.camResY-ysize/2);
						image(deadBird, state.sposition.x, ypos, r, ysize);
					}
					imageMode(CORNER);
				}
			}
		}

		popMatrix();
	}
};