LBClient lbclient;

boolean sketchFullScreen() {
	return true;
}

void setup() {
	//size(640, 480);
	size(displayWidth, displayHeight);
	frameRate(60);

	lbclient = new LBClient(this, "127.0.0.1", 10002);
}

void draw() {
	background(0);
	lbclient.receive();
	lbclient.render();
}
