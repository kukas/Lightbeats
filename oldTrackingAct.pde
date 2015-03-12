import JMyron.*;
class OldTrackingAct extends Act {
	JMyron m; //a camera object
	PImage saved; 
	PImage destination; 
	int numPixels;
	int threshold;
	int program; //variable for controlling speed of movement along x axis
	float pixelBrightness;

	color transparentColor = color(0,0,0,0);

	void init() {
		m = new JMyron();//make a new instance of the object

		numPixels = 640 * 480;
		program = -3; //controlling speed along x axis, on start stay static until UP or DOWN arrow keys are pressed
		
		saved = createImage(width, height, ARGB); //inicialization
		destination = createImage(640, 480, ARGB); //inicialization
		threshold = 170; // Brightness treshold value
	}

	void show() {
		m.start(640, 480);//start a capture  
		m.findGlobs(0);//disable the intelligence to speed up frame rate
	}

	void draw() {
		m.update(); //update the camera view

		int[] img = m.image(); //get the normal image of the camera   
		// destination.loadPixels();
		for(int i=0; i<numPixels; i++){ //loop through all the pixels
			pixelBrightness = brightness(img[i]);
			if (pixelBrightness>threshold) {      
				destination.pixels[i] = img[i]; //draw each pixel to the screen
			}
			else {
				destination.pixels[i] = transparentColor; //make pixels transparent
			}
		}
		destination.updatePixels();

		background(0);
		image(saved, program, 0);

		pushMatrix(); //rotate 640*480 image from webcam by 90 degrees,
		scale(height/640.0); // scale it so it takes up whole height
		rotate(PI/2); //so we make use of wider field of view (width is bigger than height)
		translate(0, -1067); //+ we will have more space for moving image along x-axis if the actual camera image is placed on the right edge.
		image(destination, 0, 0); //display current frame offset in x-axis for y offset (rotated image)
		popMatrix();

		saved = get();
	}

	void hide() {
		m.stop();
	}

	void keyPressed() {
		switch(keyCode){
			case RIGHT:
				parent.next();
				break;
			case LEFT:
				parent.prev();
				break;

			case 'E':
				m.settings();
				break;
			case 'W':
				program--;
				break;
			case 'S':
				program++;
				break;
			case 'A':
				threshold--;
				break;
			case 'D':
				threshold++;
				break;
		}
	}
}