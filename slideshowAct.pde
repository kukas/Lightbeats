class SlideshowAct extends Act {
	String slideSrc;
	PImage slide;

	// speed of presentation
	int wait = 3000;
	SlideshowAct(String src) {
		slideSrc = src;
	}

	void init() {
		slide = loadImage(slideSrc);
	}

	void show() {
		super.show();

		player.rewind();
		player.play();
	}

	void draw() {
		background(255);

		int dt = millis() - showTimestamp;
		int h = height;
		image(slide, 0, max(0, h - sqrt(dt)*50));

		if(millis() - showTimestamp > wait)
			parent.next();
	}
}