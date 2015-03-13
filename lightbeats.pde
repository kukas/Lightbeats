import ddf.minim.*;

Minim minim;
AudioPlayer player;
AudioPlayer lecture;
Show show;

//FULLSCREEN---------------------------------------------
boolean sketchFullScreen() {
	return true;
}

//SETUP-----------------------------------------------------------------------------------------------
void setup(){
	size(1280,768); //size is defined first! 
	
	//SOUND
	minim = new Minim(this);
	player = minim.loadFile("diaprojector_button.wav");
	//LECTURE
	lecture = minim.loadFile("myubridge_opening_lecture.mp3");

	show = new Show();

	// SCÉNÁŘ --------------------------------------------------
	// film countdown
	show.addAct(new CountdownAct());
	// // slides
	for (int i=0;i<13;i++){
		SlideshowAct slide = new SlideshowAct(i+".jpg");
		show.addAct(slide);
		if(i == 0)
			slide.wait = 5000;
	}
	// tracking
	show.addAct(new TrackingAct(this));
	show.addAct(new OldTrackingAct(this));
	show.addAct(new ZoetropeAct("zoetrope.jpg"));
	// horse animation
	HorseSlideshowAct act = new HorseSlideshowAct("milimetr_res.png");
	act.wait = 1000000;
	show.addAct(act);
	for (int i=0;i<7;i++){
		act = new HorseSlideshowAct("konik_"+i+".jpg");
		// poslední koník automaticky nepřepne na další act
		if(i == 6)
			act.wait = 100000;
		show.addAct(act);
	}
	// zoetrope animation

	show.init();
}

//Draw loop 
void draw() {
	show.draw();
}     

//KEYBOARD ARROWS--------------------------------------------------------
void keyPressed() {
	show.keyPressed();
	switch(keyCode) {
		case 27: // ESCAPE
			stop();
			break;
	}
}

void mousePressed() {
	if (mouseButton == RIGHT)
		show.mousePressed();
}

public void stop() {
	show.stop();
	super.stop();
}