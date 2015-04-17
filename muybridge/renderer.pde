class Renderer {
	Animation duck;
	int camResX = 640;
	int camResY = 480;

	PImage sittingBird;
	PImage deadBird;
	
	Renderer() {
		duck = new Animation("duck/framespsd", 24, 80);
		sittingBird = loadImage("duck/sedici_ptak.png");
		deadBird = loadImage("duck/mrtvy_ptak.png");
	}

	void render(ArrayList<Ball> balls, long timestamp, int scene) {
		pushMatrix();

		translate((width - height/float(camResY)*float(camResX))/2.0, 0);
		scale(min(width/float(camResX), height/float(camResY)));

		noStroke();
		noFill();
		for (Ball ball : balls) {
				if(ball.stateHistory.size() < 2 || !ball.updated)
					continue;

				State state = ball.getState();
				if(!state.predicted){
					// float r = sqrt(state.ssize.x*state.ssize.x + state.ssize.y*state.ssize.y);
					// duck.display((timestamp-ball.timestamp)*1E-6, state.sposition.x, state.sposition.y, 2.5*r, 2.5*r);

					float r = sqrt(state.ssize.x*state.ssize.x + state.ssize.y*state.ssize.y) * 2.5;
					// float r = sqrt(avgState.ssize.x*avgState.ssize.x + avgState.ssize.y*avgState.ssize.y) * 2.5;
					imageMode(CENTER);
					float dt = (timestamp-ball.timestamp)*1E-6;

					if(scene == 0){
						image(sittingBird, state.sposition.x, state.sposition.y, r, r/sittingBird.width*sittingBird.height);
					}
					else if(scene == 1){
						duck.display(dt, state.sposition.x, state.sposition.y, r*2, r*2);
					}
					else if(scene == 2){
						float acceleration = 0.00002;
						float ysize = r/deadBird.width*deadBird.height;
						float ypos = min(state.sposition.y+dt*dt*acceleration, camResY-ysize/2);
						image(deadBird, state.sposition.x, ypos, r, ysize);
					}
					imageMode(CORNER);
				}
		}
		
		popMatrix();
	}
};
