// https://processing.org/examples/animatedsprite.html
class Animation {
	PImage[] images;
	int imageCount;
	int frame;

	int width;
	int height;

	float speed;
	
	Animation(String imagePrefix, int count, float speed) {
		this.speed = speed;
		imageCount = count;
		images = new PImage[imageCount];

		for (int i = 0; i < imageCount; i++) {
			// Use nf() to number format 'i' into four digits
			String filename = imagePrefix + nf(i, 4) + ".png";
			images[i] = loadImage(filename);
		}

		this.width = images[0].width;
		this.height = images[0].height;
	}

	void display(float t, float xpos, float ypos, float w, float h) {
		frame = floor(t / speed) % imageCount;
		// frame = (frame+1) % imageCount;
		imageMode(CENTER);
		image(images[frame], xpos, ypos, w, h);
		imageMode(CORNER);
	}
}