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
import controlP5.*;

//---------------------------------------------------------------
// GLOBAL SETTINGS
// camera
int camResX = 640;
int camResY = 480;

// jmyron
float threshold = 130;

// dev
boolean debug = true;
boolean capture = false;

// view
int ballStateCount = 10;
int avgStateCount = 7;

// glob detection
// - probability weights
float colorWeight = 0.3;
float positionWeight = 0.5;
float predictedPositionWeight = 0.5;
float sizeWeight = 0.3;
// - maximal values
float dColorMax = 8;
float dPositionMax = pow(13, 2);
float dPredictedPositionMax = pow(10, 2);
float dSizeMax = pow(5, 2);

// prediction
float correctionWeight = 0.5;

// ball detection
float ballProbabilityThreshold = 0.5; // po jaké hodnotě se glob považuje za míček

JMyron m;
int[][] globArray;
int[][][] globPixels;

ControlP5 cp5;

int frameTimestamp;
int deltaTime;

PImage debugView;

// processing
Balls balls;

// view
Renderer renderer;

int[] lastCamPixels;
int[] camPixels;
//-----------------------------------------------------------------------------------------------------------
//SETUP

void setup() {
	// size(camResX, camResY);
	size(displayWidth, displayHeight);
	
	m = new JMyron();
	m.start(camResX, camResY);
	m.findGlobs(1);
	m.trackNotColor(0,0,0,255);
	m.minDensity(50);
	m.maxDensity(1000);
	m.sensitivity(threshold);

	frameRate(-1);

	debugView = createImage(camResX, camResY, ARGB);

	cp5 = new ControlP5(this);
	cp5.addButton("cameraSettings").setPosition(10,10).setSize(128,15);
	cp5.addSlider("brightnessThreshold", 0, 255, threshold, 10, 40, 128, 15).setNumberOfTickMarks(256);
	cp5.addSlider("ballProbabilityThreshold", 0, 1, ballProbabilityThreshold, 10, 70, 128, 15);
	if(!debug)
		cp5.hide();

	balls = new Balls();
	renderer = new Renderer(balls);

	renderer.init();
}

//-----------------------------------------------------------------------------------------------------------
//DRAW

void draw() {
	m.update();

	// srovnání posledních obrázků
	camPixels = m.image();
	if(lastCamPixels != null){
		boolean same = true;
		// projde 2x každý 10. řádek
		for (int x = 0; x < camResX*camResY; x += 24*camResX-3) {
			if(camPixels[x] - lastCamPixels[x] != 0){
				same = false;
				break;
			}
		}
		if(same){
			return;
		}
	}
	lastCamPixels = camPixels;

	int now = millis();
	deltaTime = now - frameTimestamp;
	frameTimestamp = now;
	
	pushMatrix();

	// scale(min(width/float(camResX), height/float(camResY)));
	background(0); //Set background black

	globArray = m.globBoxes();
	globPixels = m.globEdgePoints(1);
	if(debug){
		// Zobrazí obrázek z webkamery
		m.imageCopy(debugView.pixels);
		debugView.updatePixels();
		image(debugView, 0, 0);

		// Zakreslí okraje globů
		// int globPixels[][][] = m.globPixels();
		
		noFill();
		for(int i=0;i<globArray.length;i++){
			int[][] boundary = globPixels[i];
			int[] globBox = globArray[i];

			boolean inside = false;
			for (int j = i-1; j >= 0; j--) { // zneužívá se tady toho, že pokud glob bude v jiném globu, ten glob je před ním
				int[] glob2 = globArray[j];
				if(glob2[0] < globBox[0] && glob2[1] < globBox[1] && glob2[0]+glob2[2] > globBox[0]+globBox[2] && glob2[1]+glob2[3] > globBox[1]+globBox[3]){
					inside = true;
					break;
				}
			}
			if(inside){
				continue;
			}

			stroke(255, 0, 0, 80);
			strokeWeight(1);
			if(boundary!=null){
				beginShape(POINTS);
				for(int j=0;j<boundary.length;j++){
					vertex(boundary[j][0], boundary[j][1]);
				}
				endShape();
			}

			rect(globBox[0], globBox[1], globBox[2], globBox[3]);

			// ArrayList<State> circles = balls.finder.findCircles(boundary, globBox);
			// strokeWeight(3);
			// for (int j=0; j<circles.size(); j++) {
			// 	State circle = circles.get(j);
			// 	stroke(j*255, 255, 0, 128);
			// 	ellipse(circle.sposition.x, circle.sposition.y, circle.ssize.x, circle.ssize.y);
			// }
		}
	}

	balls.processGlobs(globArray, globPixels);

	if(debug){
		balls.render();
	}
	popMatrix();

	if(!debug){
		renderer.render();
	}

	if(debug) {
		fill(255,255,0);
		textSize(16);
		textAlign(RIGHT, BOTTOM);
		text(int(frameTimestamp), width-10, height-10);
	}

	if(capture){
		saveFrame("frames/####.tga");
	}
	if(debug){
		// FPS
		fill(255,255,0);
		textSize(16);
		textAlign(RIGHT, TOP);
		text(int(frameRate), width-10, 0);
	}

}

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------
//User input - calibrating camera and animation
	
void cameraSettings() {
	m.settings();//click the window to get the settings of camera
}

void brightnessThreshold(float t) {
	threshold = t;
	m.sensitivity(threshold);
}

//by pressing arrow key up and down you animate movement of previous frames along x axis 
//(originally designed to flow in the left direction-UP arrow key or stay static - program value is 0)
void keyPressed() {
	switch(keyCode) {
		case ' ': 
			saveFrame("diagram-####.jpg"); //tga is the fastest..but you can specify jpg,png...
			break;
		case 'A':
			// m.adapt();
			color c = m.average(0, 0, camResX, camResY);
			m.trackNotColor(int(red(c)), int(green(c)), int(blue(c)), 255);
			balls.adapt();
			break;
		case 'D':
			debug = !debug;
			if(debug)
				cp5.show();
			else
				cp5.hide();

			break;
		case 'C':
			capture = !capture;
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
