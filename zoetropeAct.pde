class ZoetropeAct extends Act {
	String zoetropeSrc;
	PImage zoetrope;

	float fps = 20; // framerate of the animation
	float acceleration = 0.05;
	int frame;

	float i = 0;
	float y = 0;

	int animationTimestamp;

	int scene = 0;
	ZoetropeAct(String src) {
		zoetropeSrc = src;
	}

	void init() {
		zoetrope = loadImage(zoetropeSrc);
	}

	void show() {
		super.show();
		frame = millis();
		scene = 0;

		player.rewind();
		player.play();
	}

	void draw() {
		// mění fps animace
		frame++;
		if(millis() - frame < 1000/fps){
			return;
		}

		frame = millis();
		background(221);

		pushMatrix(); //independent coordinates manipulation
		translate(width/2, zoetrope.height/2); // Translate origin to center
		imageMode(CENTER); //coordinates start from center of image

		if(scene > 0){
			i += y;
			if (y<1)
				y += 0.01;
			else
				y = 1;
			
			float dt = (millis() - animationTimestamp)/1000.0;
			// rotate(PI/7.0*floor(dt*fps) * (1.0-1.0/(1.0+dt*dt*dt*acceleration)) );
			rotate(PI/7.0 * i);
		}

		image(zoetrope, 0, 0);
		popMatrix(); //end of coordinates manipulation revert to default
		imageMode(CORNER); //revert back to corner image mode
	}

	void keyPressed() {
		switch(keyCode){
			case RIGHT:
				scene++;
				if(scene == 1)
					animationTimestamp = millis();
				if(scene >= 2)
					parent.next();
				break;
			case LEFT:
				parent.prev();
				break;
		}
	}
};
