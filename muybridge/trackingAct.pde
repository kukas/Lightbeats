class TrackingAct extends Act {
	LBClient lbclient;
	PApplet papplet;

	AudioPlayer shotgun;
	
	int scene = 0;
	TrackingAct(PApplet papplet) {
		this.papplet = papplet;
	}

	void init() {
		lbclient = new LBClient(papplet, "127.0.0.1", 10002);

		shotgun = minim.loadFile("shotgun.wav");
	}

	void show() {
		lbclient.client.clear();
	}

	void draw() {
		background(0);
		lbclient.receive();
		lbclient.render(scene);
	}

	void mousePressed() {
		next();
	}

	void next() {
		scene++;
		if(scene == 2){
			shotgun.rewind();
			shotgun.play();
		}
		if(scene >= 3)
			parent.next();
	}
}