class State {
	color scolor;
	PVector sposition;
	PVector ssize;
	int timestamp;

	int globId;
	boolean precise = false;

	State () {
		this.scolor = color(0, 0, 0);
		this.sposition = new PVector();
		this.ssize = new PVector();

		timestamp = frameTimestamp;
	}

	State (color c, PVector p, PVector s) {
		this.scolor = c;
		this.sposition = p;
		this.ssize = s;

		timestamp = frameTimestamp;
	}

	State (State s) {
		this.scolor = s.scolor;
		this.sposition = s.sposition.get();
		this.ssize = s.ssize.get();

		timestamp = frameTimestamp;
	}
};