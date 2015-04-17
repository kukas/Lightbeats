class Act {
	Show parent;
	int showTimestamp;

	void init() {

	}

	void show() {
		showTimestamp = millis();
	}

	void hide() {
		
	}

	void draw() {

	}

	void keyPressed() {
		switch(keyCode){
			case RIGHT:
				next();
				break;
			case LEFT:
				parent.prev();
				break;
		}
	}

	void next() {
		parent.next();
	}

	void mousePressed() {
		next();
	}
}