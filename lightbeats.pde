import ddf.minim.*;

Minim minim;
AudioPlayer player;
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

	show = new Show();

	// SCÉNÁŘ --------------------------------------------------
	// film countdown
	show.addAct(new CountdownAct());
	// slides
	for (int i=0;i<13;i++){
		show.addAct(new SlideshowAct(i+".jpg"));
	}
	// tracking
	show.addAct(new TrackingAct(this));
	show.addAct(new OldTrackingAct());
	show.addAct(new ZoetropeAct("zoetrope.jpg"));
	// horse animation
	HorseSlideshowAct act = new HorseSlideshowAct("milimetrovy_orez.jpg");
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
}
