import cl.eye.*;

class Myron {
	// cam access CL-Eye
	boolean usingCL = false;
	PApplet papplet;
	CLCamera cam;
	int[] camPixels;
	int width;
	int height;
	int pixelCount;
	// camera settings (CL-Eye only)
	float gain = 0;
	float exposure = 0.6;

	// image processing
	// - settings
	float threshold = 130;
	int minDensity = 50;

	int[] backgroundPixels;
	boolean[] globPixels;
	int[] globIDs;
	int[][] globBoundingBoxArray;
	int[][][] globPixelsArray;
	// - glob filler
	int[] stackX;
	int[] stackY;
	int[] globBoundingBox;
	int[] globPixelsX;
	int[] globPixelsY;
	int globCount;

	// debug
	PImage img;

	// colors
	color black = color(0);
	color white = color(255);

	Myron(PApplet papplet) {
		this.papplet = papplet;
	}

	boolean start(int resolution, int rate) {
		int numCams = 0;
		try {
			numCams = CLCamera.cameraCount();
		} catch (UnsatisfiedLinkError e) {
			println("CL eye SDK is not installed!");
			println(e.toString());
		}

		println("Found " + numCams + " CL Eye cameras");

		if(resolution == CLCamera.CLEYE_VGA){
			width = 640;
			height = 480;
		}
		if(resolution == CLCamera.CLEYE_QVGA){
			width = 320;
			height = 240;
		}

		if(numCams > 0) {
			println("Starting CL Eye");
			startCLEye(resolution, rate);
		}
		else {
			return false;
		}

		pixelCount = width*height;
		camPixels = new int[pixelCount];
		backgroundPixels = new int[pixelCount];
		globPixels = new boolean[pixelCount];
		globIDs = new int[pixelCount];

		globBoundingBoxArray = new int[0][];
		globPixelsArray = new int[0][][];

		stackX = new int[pixelCount];
		stackY = new int[pixelCount];

		globBoundingBox = new int[4];
		globPixelsX = new int[pixelCount];
		globPixelsY = new int[pixelCount];

		img = createImage(width, height, RGB);

		return true;
	}

	void startCLEye(int resolution, int rate) {
		usingCL = true;

		println("Camera UUID " + CLCamera.cameraUUID(0));
		cam = new CLCamera(papplet);
		// ----------------------(i, CLEYE_GRAYSCALE/COLOR, CLEYE_QVGA/VGA, Framerate)
		cam.createCamera(0, CLCamera.CLEYE_COLOR, resolution, rate);

		cam.setCameraParam(CLCamera.CLEYE_AUTO_GAIN, 0);
		cam.setCameraParam(CLCamera.CLEYE_AUTO_EXPOSURE, 0);
		cam.setCameraParam(CLCamera.CLEYE_AUTO_WHITEBALANCE, 1);

		setGain(gain);
		setExposure(exposure);

		cam.startCamera();
	}

	void setGain(float value) {
		if(!usingCL)
			return;
		gain = value;
		cam.setCameraParam(CLCamera.CLEYE_GAIN, floor(value*79));
	}

	float getGain() {
		if(!usingCL)
			return 0;
		return cam.getCameraParam(CLCamera.CLEYE_GAIN)/79.0;
	}

	void setExposure(float value) {
		if(!usingCL)
			return;
		exposure = value;
		cam.setCameraParam(CLCamera.CLEYE_EXPOSURE, floor(value*511));
	}

	float getExposure() {
		if(!usingCL)
			return 0;
		return cam.getCameraParam(CLCamera.CLEYE_EXPOSURE)/511.0;
	}

	int getMinDensity() {
		return minDensity;
	}

	void setMinDensity(int value) {
		minDensity = value;
	}

	void debugPixels(int[] p) {
		arrayCopy(camPixels, img.pixels);
		img.updatePixels();
		image(img, 0, 0);
	}
	void debugPixels(boolean[] p) {
		for(int i=0; i<p.length; i++){
			img.pixels[i] = p[i] ? white : black;
		}
		img.updatePixels();
		image(img, 0, 0);
	}

	void adapt() {
		// for (int i = 0; i < pixelCount; ++i) {
		// 	backgroundPixels[i] = camPixels[i];
		// }
		arrayCopy(camPixels, backgroundPixels);
	}

	void update() {
		cam.getCameraFrame(camPixels, 1000);

		thresholdFilter();
		processGlobs();
	}

	void thresholdFilter() {
		for(int i=0; i<pixelCount; i++){
			int argb = camPixels[i];
			int r = (argb >> 16) & 0xFF;
			int g = (argb >> 8) & 0xFF;
			int b = argb & 0xFF;
			if(backgroundPixels != null) {
				int brgb = backgroundPixels[i];
				r -= (brgb >> 16) & 0xFF;
				g -= (brgb >> 8) & 0xFF;
				b -= brgb & 0xFF;

				r = abs(r);
				g = abs(g);
				b = abs(b);
			}

			if(r+g+b > threshold)
				globPixels[i] = true;
			else
				globPixels[i] = false;
		}
	}

	void processGlobs() {
		ArrayList<int[]> globBoundingBoxList = new ArrayList<int[]>();
		ArrayList<int[][]> globBorderList = new ArrayList<int[][]>();

		// reset glob id array
		for(int i=0; i<pixelCount; i++)
			globIDs[i] = 0;

		int currentGlob = 0;

		for(int x = 0; x<width; x++){
			for(int y = 0; y<height; y++){
				int i = y*width + x;

				if(globPixels[i] && globIDs[i] == 0 && isEdge(x, y)){
					currentGlob++;
					fillGlob(x, y, currentGlob);

					// pokud je glob dostatečně veliký, uložit!
					if(globCount >= minDensity){
						int[] boundingBox = new int[4];
						boundingBox[0] = globBoundingBox[0];
						boundingBox[1] = globBoundingBox[1];
						boundingBox[2] = globBoundingBox[2] - globBoundingBox[0];
						boundingBox[3] = globBoundingBox[3] - globBoundingBox[1];
						// arrayCopy(globBoundingBox, boundingBox, 4);
						globBoundingBoxList.add(boundingBox);

						int[][] border = new int[globCount][2];
						for(int p=0; p<globCount; p++){
							border[p][0] = globPixelsX[p];
							border[p][1] = globPixelsY[p];
						}
						globBorderList.add(border);
					}
				}
			}
		}

		globBoundingBoxArray = globBoundingBoxList.toArray(new int[globBoundingBoxList.size()][4]);
		globPixelsArray = globBorderList.toArray(new int[globBorderList.size()][][]);
	}

	int[][] globBoxes() {
		return globBoundingBoxArray;
	}

	int[][][] globEdgePoints() {
		return globPixelsArray;
	}

	boolean isEdge(int x, int y) {
		if(!((y-1<0)||(y+1>=height)||(x-1<0)||(x+1>=width))){	
			boolean pu  = globPixels[width*(y-1)+(x  )];//up
			boolean pd  = globPixels[width*(y+1)+(x  )];//down
			boolean pl  = globPixels[width*(y  )+(x-1)];//left
			boolean pr  = globPixels[width*(y  )+(x+1)];//right
			boolean pul = globPixels[width*(y-1)+(x-1)];//up left
			boolean pur = globPixels[width*(y-1)+(x+1)];//up right
			boolean pdl = globPixels[width*(y+1)+(x-1)];//down left
			boolean pdr = globPixels[width*(y+1)+(x+1)];//down right
			boolean ps  = globPixels[width*(y  )+(x  )];
			return ((ps!=pu)||(ps!=pd)||(ps!=pl)||(ps!=pr)||(ps!=pul)||(ps!=pur)||(ps!=pdl)||(ps!=pdr));
		}
		else{
			return false;
		}
	}

	void fillGlob(int x, int y, int id) {
		// stack
		int pointer = 0;
		int stackLength = 1;
		stackX[pointer] = x;
		stackY[pointer] = y;

		// info
		globCount = 1;
		globBoundingBox[0] = x;
		globBoundingBox[1] = y;
		globBoundingBox[2] = x;
		globBoundingBox[3] = y;
		globPixelsX[0] = x;
		globPixelsY[0] = y;

		// cell
		int cx;
		int cy;
		int i;
		while(pointer < stackLength){
			cx = stackX[pointer];
			cy = stackY[pointer];
			i = cy*width + cx;

			if(i >= 0 && i < pixelCount && globPixels[i] && globIDs[i] == 0 && isEdge(cx, cy)){
				// zapsání ID do pole
				globIDs[i] = id;

				// zkontrolovat okolní buňky
				// vpravo
				stackX[stackLength]   = cx+1;
				stackY[stackLength]   = cy;
				stackLength++;
				// vlevo
				stackX[stackLength]   = cx-1;
				stackY[stackLength]   = cy;
				stackLength++;
				// nahoře
				stackX[stackLength]   = cx;
				stackY[stackLength]   = cy-1;
				stackLength++;
				// dole
				stackX[stackLength]   = cx;
				stackY[stackLength]   = cy+1;
				stackLength++;

				// info
				// - border pixels
				globPixelsX[globCount] = cx;
				globPixelsY[globCount] = cy;
				// - bounding box
				if(cx < globBoundingBox[0])
					globBoundingBox[0] = cx;
				else if(cx > globBoundingBox[2])
					globBoundingBox[2] = cx;
				if(cy < globBoundingBox[1])
					globBoundingBox[1] = cy;
				else if(cy > globBoundingBox[3])
					globBoundingBox[3] = cy;
				// pixel count
				globCount++;
			}

			pointer++;
		}
	}

	void stop() {
		cam.dispose();
	}

	void threshold(float value) {
		threshold = value;
	}

	color average(int x1, int y1, int x2, int y2) {
		x1 = max(x1, 0);
		y1 = max(y1, 0);
		x2 = min(x2, width-1);
		y2 = min(y2, height-1);

		int r = 0;
		int g = 0;
		int b = 0;
		int counter = 0;
		for(int x = x1; x<=x2; x++){
			for(int y = y1; y<=y2; y++){
				int argb = camPixels[y*width + x];
				r += (argb >> 16) & 0xFF;
				g += (argb >> 8) & 0xFF;
				b += argb & 0xFF;

				counter++;
			}
		}
		r /= counter;
		g /= counter;
		b /= counter;
		return color(r, g, b);
	}
}