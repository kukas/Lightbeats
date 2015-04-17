class HorseSlideshowAct extends SlideshowAct {
	// speed of horse animation
	int wait = 350;

	HorseSlideshowAct(String src) {
		super(src);
	}

	void show() {
		showTimestamp = millis();
	}

	void draw() {
		background(255);

		image(slide, 0, 0);

		if(millis() - showTimestamp > wait)
			parent.next();
	}
}