/**
 * "Light beats" version 2.0
 * © 2014, http://lightbeats.cz/
 * Creative commons license BY-NC-SA Attribution-NonCommercial-ShareAlike for more information see: http://creativecommons.org/licenses/by-nc-sa/4.0/
 * Creative commons licence BY-NC-SA Uveďte autora-Neužívejte dílo komerčně-Zachovejte licenci 
 * the author disclaims all warranties with regard to this software including all implied warranties of merchantability and fitness. in no event shall the author be liable for any special, direct, indirect, or consequential damages or any damages whatsoever resulting from loss of use, data or profits, whether in an action of contract, negligence or other tortious action, arising out of or in connection with the use or performance of this software. 
 */

import controlP5.*;
class LB {
	// --------- GLOBAL SETTINGS ---------
	// camera
	int camResX = 640;
	int camResY = 480;
	int camRate = 75;

	// dev
	boolean debug = true;
	int debugView = 0;
	boolean capture = false;

	// threshold filter
	float threshold = 130;
	
	// state storage
	int ballStateCount = 10;
	int avgStateCount = 7;

	// ball detection
	float existingBallThreshold = 0.7;
	float newBallThreshold = 0.3;
	// - probability weights
	float colorWeight = 0.3;
	float positionWeight = 0.5;
	float predictedPositionWeight = 0.5;
	float sizeWeight = 0.4;
	// - maximal delta values
	float dColorMax = 8;
	float dPositionMax = pow(11, 2);
	float dPredictedPositionMax = pow(8, 2);
	float dSizeMax = pow(5, 2);
	
	// finder
	float finderThreshold = 0.7;
	float initialCircleProbability = 0.15;
	float minFoundCircleRatio = 1.5;
	int minPointCount = 40;

	// ball path prediction
	int maxPredictedStates = 3;

	// ball probability
	float ballProbabilityThreshold = 0.2; // po jaké hodnotě se glob považuje za míček
	float ballProbabilitySpeedSq = 100;

	// --------- /GLOBAL SETTINGS ---------

	Myron m;
	int[][] globArray;
	int[][][] globPixels;

	ControlP5 cp5;

	long setupTimestamp;
	long frameTimestamp;
	float deltaTime;

	// processing
	Balls balls;

	// view
	Renderer renderer;

	PApplet parent;

	LB(PApplet parent) {
		this.parent = parent;
	}

	void setup() {
		setupTimestamp = System.nanoTime();
		m = new Myron(parent);

		int res = CLCamera.CLEYE_VGA;
		if(camResX == 320 && camResY == 240)
			res = CLCamera.CLEYE_QVGA;
		if(! m.start(res, camRate) ) // 640x480, 60fps
			exit();

		loadSettings();

		m.threshold(threshold);

		cp5 = new ControlP5(parent);
		cp5.getTab("default").setLabel("camera settings");
		cp5.addTab("ball detection");
		cp5.addTab("circle finder");
		cp5.addTab("other");

		// debug
		// debugView 0 = camera image + balls + prediction
		// debugView 1 = globs image + glob bounding boxes + glob boundaries
		// debugView 2 = globs image + circle finder debug
		cp5.addSlider("debugView", 0, 2, debugView, 10, 20, 128, 15)
			.moveTo("global")
			.setNumberOfTickMarks(3)
			.plugTo(this);
		cp5.addButton("saveSettings", 0, 200, 20, 70, 15)
			.moveTo("global")
			.plugTo(this);

		// camera gui
		if(m.usingCL){
			cp5.addTextlabel("label1").setPosition(10, 38).setText("CL Eye settings");
			float gain = m.getGain();
			cp5.addSlider("gain", 0, 100, gain*100, 10, 50, 128, 15).plugTo(this);

			float exposure = m.getExposure();
			cp5.addSlider("exposure", 0, 100, exposure*100, 10, 70, 128, 15).plugTo(this);
		}
		else {
			cp5.addTextlabel("label1").setPosition(10, 38).setText("JMyron settings");
			cp5.addButton("cameraSettings", 0, 10, 50, 128, 15).plugTo(this);
		}

		// threshold filter
		cp5.addTextlabel("labelthreshold").setPosition(10, 88).setText("Glob finder");
		cp5.addSlider("brightnessThreshold", 0, 1024, threshold, 10, 100, 128, 15)
			.setNumberOfTickMarks(256)
			.plugTo(this);
		cp5.addButton("adapt", 0, 10, 140, 128, 15).plugTo(this);

		// glob finding
		int globSize = m.getMinDensity();
		cp5.addSlider("minGlobSize", 0, 512, globSize, 10, 120, 128, 15).plugTo(this);
		
		cp5.addTextlabel("label2").setPosition(10, 38).setText("Ball state storage").moveTo("ball detection");
		cp5.addSlider("ballStateCount", 0, 32, ballStateCount, 10, 50, 128, 15).plugTo(this).moveTo("ball detection");
		cp5.addSlider("avgStateCount", 0, 32, avgStateCount, 10, 70, 128, 15).plugTo(this).moveTo("ball detection");

		cp5.addTextlabel("label3").setPosition(10, 88).setText("Ball detection thresholds").moveTo("ball detection");
		cp5.addSlider("existingBallThreshold", 0, 1, existingBallThreshold, 10, 100, 128, 15).plugTo(this).moveTo("ball detection");
		cp5.addSlider("newBallThreshold", 0, 1, newBallThreshold, 10, 120, 128, 15).plugTo(this).moveTo("ball detection");

		cp5.addTextlabel("label6").setPosition(10, 138).setText("Ball identification").moveTo("ball detection");
		cp5.addSlider("colorWeight", 0, 1, colorWeight, 10, 150, 128, 15).plugTo(this).moveTo("ball detection");
		cp5.addSlider("positionWeight", 0, 1, positionWeight, 10, 170, 128, 15).plugTo(this).moveTo("ball detection");
		cp5.addSlider("predictedPositionWeight", 0, 1, predictedPositionWeight, 10, 190, 128, 15).plugTo(this).moveTo("ball detection");
		cp5.addSlider("sizeWeight", 0, 1, sizeWeight, 10, 210, 128, 15).plugTo(this).moveTo("ball detection");

		cp5.addSlider("dColorMax", 1, 100, dColorMax, 10, 230, 128, 15).plugTo(this).moveTo("ball detection");
		cp5.addSlider("dPositionMax", 1, 300, dPositionMax, 10, 250, 128, 15).plugTo(this).moveTo("ball detection");
		cp5.addSlider("dPredictedPositionMax", 1, 300, dPredictedPositionMax, 10, 270, 128, 15).plugTo(this).moveTo("ball detection");
		cp5.addSlider("dSizeMax", 1, 300, dSizeMax, 10, 290, 128, 15).plugTo(this).moveTo("ball detection");
		
		cp5.addTextlabel("label4").setPosition(10, 38).setText("Ball prediction and probability").moveTo("other");
		cp5.addSlider("maxPredictedStates", 0, 30, maxPredictedStates, 10, 50, 128, 15).plugTo(this).moveTo("other");
		cp5.addSlider("ballProbabilityThreshold", 0, 1, ballProbabilityThreshold, 10, 70, 128, 15).plugTo(this).moveTo("other");
		cp5.addSlider("ballProbabilitySpeed", 0, 128, sqrt(ballProbabilitySpeedSq), 10, 90, 128, 15).plugTo(this).moveTo("other");

		cp5.addTextlabel("label5").setPosition(10, 38).setText("Circle finder").moveTo("circle finder");
		cp5.addSlider("finderThreshold", 0, 1, finderThreshold, 10, 50, 128, 15).plugTo(this).moveTo("circle finder");
		cp5.addSlider("initialCircleProbability", 0, 1, initialCircleProbability, 10, 70, 128, 15).plugTo(this).moveTo("circle finder");
		cp5.addSlider("minFoundCircleRatio", 0, 16, minFoundCircleRatio, 10, 90, 128, 15).plugTo(this).moveTo("circle finder");
		cp5.addSlider("minPointCount", 3, 100, minPointCount, 10, 110, 128, 15).plugTo(this).moveTo("circle finder");

		if(!debug)
			cp5.hide();

		balls = new Balls(this);
		renderer = new Renderer(this);

		renderer.init();
	}

	void draw() {
		m.update();

		long now = System.nanoTime() - setupTimestamp;
		deltaTime = (now - frameTimestamp)*1E-6;
		frameTimestamp = now;
		
		background(0); //Set background black

		globArray = m.globBoxes();
		globPixels = m.globEdgePoints();
		if(debug){
			// Zobrazí obrázek z webkamery
			if(debugView == 0){
				m.debugPixels(m.camPixels);
			}
			if(debugView == 1){
				m.debugPixels(m.globPixels);
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

					fill(255, 255, 0);
					textAlign(LEFT, BOTTOM);
					text(i, globBox[0], globBox[1]);
					stroke(255, 0, 0);
					noFill();
					rect(globBox[0], globBox[1], globBox[2], globBox[3]);
				}
			}
		}

		balls.processGlobs(globArray, globPixels);

		if(debug && debugView != 1){
			balls.render();
		}

		if(!debug){
			renderer.render();
		}

		if(debug) {
			fill(255,255,0);
			textSize(16);
			textAlign(RIGHT, BOTTOM);
			text(round(frameTimestamp*1E-6), width-10, height-10);
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

	// saving/loading settings
	void saveSettings() {
		JSONObject props = new JSONObject();

		props.setInt("camResX", camResX);
		props.setInt("camResY", camResY);
		props.setInt("camRate", camRate);
		props.setBoolean("debug", debug);
		props.setFloat("threshold", threshold);
		props.setInt("ballStateCount", ballStateCount);
		props.setInt("avgStateCount", avgStateCount);
		props.setFloat("existingBallThreshold", existingBallThreshold);
		props.setFloat("newBallThreshold", newBallThreshold);
		props.setFloat("colorWeight", colorWeight);
		props.setFloat("positionWeight", positionWeight);
		props.setFloat("predictedPositionWeight", predictedPositionWeight);
		props.setFloat("sizeWeight", sizeWeight);
		props.setFloat("dColorMax", dColorMax);
		props.setFloat("dPositionMax", dPositionMax);
		props.setFloat("dPredictedPositionMax", dPredictedPositionMax);
		props.setFloat("dSizeMax", dSizeMax);
		props.setFloat("finderThreshold", finderThreshold);
		props.setFloat("initialCircleProbability", initialCircleProbability);
		props.setFloat("minFoundCircleRatio", minFoundCircleRatio);
		props.setInt("minPointCount", minPointCount);
		props.setInt("maxPredictedStates", maxPredictedStates);
		props.setFloat("ballProbabilityThreshold", ballProbabilityThreshold);
		props.setFloat("ballProbabilitySpeedSq", ballProbabilitySpeedSq);
		props.setFloat("gain", m.getGain());
		props.setFloat("exposure", m.getExposure());
		props.setInt("minDensity", m.getMinDensity());

		saveJSONObject(props, "settings.json");
	}

	void loadSettings() {
		JSONObject props;
		try {
			props = loadJSONObject("settings.json");
		} catch (NullPointerException e) {
			e.printStackTrace();
			return;
		}

		camResX = props.getInt("camResX", camResX);
		camResY = props.getInt("camResY", camResY);
		camRate = props.getInt("camRate", camRate);
		debug = props.getBoolean("debug", debug);
		threshold = props.getFloat("threshold", threshold);
		ballStateCount = props.getInt("ballStateCount", ballStateCount);
		avgStateCount = props.getInt("avgStateCount", avgStateCount);
		existingBallThreshold = props.getFloat("existingBallThreshold", existingBallThreshold);
		newBallThreshold = props.getFloat("newBallThreshold", newBallThreshold);
		colorWeight = props.getFloat("colorWeight", colorWeight);
		positionWeight = props.getFloat("positionWeight", positionWeight);
		predictedPositionWeight = props.getFloat("predictedPositionWeight", predictedPositionWeight);
		sizeWeight = props.getFloat("sizeWeight", sizeWeight);
		dColorMax = props.getFloat("dColorMax", dColorMax);
		dPositionMax = props.getFloat("dPositionMax", dPositionMax);
		dPredictedPositionMax = props.getFloat("dPredictedPositionMax", dPredictedPositionMax);
		dSizeMax = props.getFloat("dSizeMax", dSizeMax);
		finderThreshold = props.getFloat("finderThreshold", finderThreshold);
		initialCircleProbability = props.getFloat("initialCircleProbability", initialCircleProbability);
		minFoundCircleRatio = props.getFloat("minFoundCircleRatio", minFoundCircleRatio);
		minPointCount = props.getInt("minPointCount", minPointCount);
		maxPredictedStates = props.getInt("maxPredictedStates", maxPredictedStates);
		ballProbabilityThreshold = props.getFloat("ballProbabilityThreshold", ballProbabilityThreshold);
		ballProbabilitySpeedSq = props.getFloat("ballProbabilitySpeedSq", ballProbabilitySpeedSq);
		m.setGain(props.getFloat("gain", m.getGain()));
		m.setExposure(props.getFloat("exposure", m.getExposure()));
		m.setMinDensity(props.getInt("minDensity", m.getMinDensity()));
	}

	// User input - calibrating camera and animation
		
	void brightnessThreshold(float t) {
		threshold = t;
		m.threshold(threshold);
	}

	void cameraSettings() {
		if(!m.usingCL)
			m.m.settings();
	}

	void gain(float value) {
		m.setGain(value/100.0);
	}

	void exposure(float value) {
		m.setExposure(value/100.0);
	}

	void minGlobSize(float value) {
		m.setMinDensity((int) value);
	}

	void ballProbabilitySpeed(float value) {
		ballProbabilitySpeedSq = value*value;
	}

	void adapt() {
		m.adapt();
		balls.adapt();
	}

	void keyPressed() {
		switch(keyCode) {
			case ' ': 
				saveFrame("diagram-####.jpg"); //tga is the fastest..but you can specify jpg,png...
				break;
			case 'A':
				adapt();				
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
	void stop() {
		m.stop();
	}
};
// -----------------------------------------

// zapne fullscreen
boolean sketchFullScreen() {
	return true;
}
LB lightbeats;
void setup() {
	size(640, 480);
	// size(displayWidth, displayHeight);
	frameRate(-1);

	lightbeats = new LB(this);
	lightbeats.setup();
}

void draw() {
	lightbeats.draw();
}

void keyPressed() {
	lightbeats.keyPressed();
}

public void stop() {
	lightbeats.stop();
	super.stop();
}