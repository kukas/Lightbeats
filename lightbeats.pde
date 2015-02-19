/**
 * "Light beats" version 2.0
 * © 2014, http://lightbeats.cz/
 * Creative commons license BY-NC-SA Attribution-NonCommercial-ShareAlike for more information see: http://creativecommons.org/licenses/by-nc-sa/4.0/
 * Creative commons licence BY-NC-SA Uveďte autora-Neužívejte dílo komerčně-Zachovejte licenci 
 * the author disclaims all warranties with regard to this software including all implied warranties of merchantability and fitness. in no event shall the author be liable for any special, direct, indirect, or consequential damages or any damages whatsoever resulting from loss of use, data or profits, whether in an action of contract, negligence or other tortious action, arising out of or in connection with the use or performance of this software. 
 
 * Make a brightness treshold,
 * than buffer previous frames and animate them translated negatively on x axis. 
 * Visualization represent graphical juggling notation diagrams used by jugglers and known as siteswaps.
 * dependencies: Jmyron processing library, processing 2.2.1, webcam (originally designed for PS3eye)
 
 *Use arrows UP, DOWN for controlling speed of movement along x-axis 
 *Use arrows LEFT, RIGHT to controll the brightness treshold
 *Spacebar will save snapshot to the sketch folder
 *by clicking on running sketch the camera settings should appear
 */

import JMyron.*;

//---------------------------------------------------------------
// GLOBAL SETTINGS
// camera
int camResX = 640;
int camResY = 480;

// jmyron
float threshold = 220;

// dev
boolean debug = true;

// view
int ballStateCount = 10;

// glob detection
// - probability weights
float colorWeight = 0.4;
float positionWeight = 0.3;
float predictedPositionWeight = 0.1;
float sizeWeight = 0.2;
// - maximal values
float dColorMax = 255;
float dPositionMax = pow(60, 2);
float dPredictedPositionMax = pow(60, 2);
float dSizeMax = pow(40, 2);

// prediction
float correctionWeight = 0.5;

// ball detection
float ballProbabilityThreshold = 0.8; // po jaké hodnotě se glob považuje za míček


// zapne fullscreen
boolean sketchFullScreen() {
	return true;
}

int find (float needle, float[] haystack) {
	for (int i = 0; i < haystack.length; i++) {
		if(haystack[i] == needle)
			return i;
	}
	return -1;
}

JMyron m;
int[][] globArray;

int program = -3; //controlling speed along x axis, on start stay static until UP or DOWN arrow keys are pressed; 
 
PImage debugView;

// processing
Balls balls;


//-----------------------------------------------------------------------------------------------------------
//SETUP

void setup() {
	size(displayWidth, displayHeight);
	
	m = new JMyron();
	m.start(camResX, camResY);
	m.findGlobs(1);
	// m.trackColor(0, 0, 255, 255); //track the brightest
	// m.adaptivity(2);
	m.sensitivity(threshold);
	m.trackNotColor(0,0,0,255);
	m.minDensity(250);
	m.maxDensity(1000);
	ellipseMode(CENTER); //we draw ellipse from center
	noStroke();
	
	debugView = createImage(camResX, camResY, ARGB);

	balls = new Balls();
}

//-----------------------------------------------------------------------------------------------------------
//DRAW

void draw() {
	background(0); //Set background black
	m.update();
	
	if(debug){
		m.imageCopy(debugView.pixels);
		debugView.updatePixels();
		image(debugView, 0, 0);
	}

	globArray = m.globBoxes();

	if(debug){
		// draw the glob bounding boxes
		for(int i = 0; i < globArray.length; i++) {
			int[] boxArray = globArray[i];
		
			noFill();
			stroke(255, 0, 0);
			rect(boxArray[0], boxArray[1], boxArray[2], boxArray[3]);
			noStroke();
		}
	}

	balls.processGlobs(globArray);
	balls.render();
}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------
//User input - calibrating camera and animation
	
void mousePressed(){
	m.settings();//click the window to get the settings of camera
}

//by pressing arrow key up and down you animate movement of previous frames along x axis 
//(originally designed to flow in the left direction-UP arrow key or stay static - program value is 0)
void keyPressed(){
	switch(keyCode) {
	case UP: 
			program --;
			break;
	case DOWN: 
			program ++;
			break;
	case LEFT: 
			threshold --;
			m.sensitivity(threshold);
			break;
	case RIGHT: 
			threshold ++;
			m.sensitivity(threshold);
			break;
	case ' ': 
			saveFrame("diagram-####.jpg"); //tga is the fastest..but you can specify jpg,png...
			break;
	case 'A':
			// m.adapt();
			balls.adapt();
			break;
	case 'D':
			debug = !debug;
			break;
	case 'Q':
			stop();
			break;
	case 27: // ESCAPE
			stop();
			break;

	}
}
//-----------------------------------------------------------------------------------------------------------
public void stop() {
	m.stop();
	super.stop();
}
