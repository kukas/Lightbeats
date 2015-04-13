class Renderer {
	Animation duck;
	int camResX = 640;
	int camResY = 480;
	
	Renderer() {
		duck = new Animation("duck/framespsd", 24, 80);
	}

	void render(ArrayList<Ball> balls, long timestamp) {
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
					float r = sqrt(state.ssize.x*state.ssize.x + state.ssize.y*state.ssize.y);
					duck.display((timestamp-ball.timestamp)*1E-6, state.sposition.x, state.sposition.y, 2.5*r, 2.5*r);
				}
		}
		
		popMatrix();
	}
};
