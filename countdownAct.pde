class CountdownAct extends Act {
	PImage filtr_sum;
	int wait = 300 * 1000; // countdown delay

	void init() {
		filtr_sum = createImage( width, height, ARGB );
	}

	void show() {
		super.show();
	}

	void draw() {
		//START TIMER
		background (255);
		stroke(0); 
		strokeWeight(5);

		int seconds = floor((wait-millis())/1000);

		//second hand 
		// float quarterCircle = PI/2;
		float angle = (-(2.0 * PI/60.0) * seconds);
		line(width/2, height/2 , width/2 + width * cos(angle), height/2 + width * sin(angle));   

		//circle
		fill(255); 
		ellipse(width/2,height/2,400,400);
		//numbers
		fill(0); 
		textSize(150);
		text(seconds, width/2-150, height/2+50);

		pushMatrix();
		textSize(40);
		translate(width/2,height/2);
		rotate(angle);

		text("                  LIGHTBEATS.CZ",0,0);
		popMatrix();
		//noise
		filtr_sum.loadPixels();
		for (int i = 0; i < width*height; i++) {
		float random_color= random(0, 255);
		filtr_sum.pixels[i] = color(random_color,random_color,random_color,50);
		}
		filtr_sum.updatePixels();
		image(filtr_sum,0,0);

		if(millis()-showTimestamp > wait)
			parent.next();
	}
}
