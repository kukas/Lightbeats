class State {
	color scolor;
	PVector sposition;
	PVector ssize;
	long timestamp;

	int globId = -1;
	boolean predicted = false;

	State() {
		this.scolor = color(0, 0, 0);
		this.sposition = new PVector();
		this.ssize = new PVector();

		this.timestamp = 0;
	}

	State(color c, PVector p, PVector s, long timestamp) {
		this.scolor = c;
		this.sposition = p;
		this.ssize = s;

		this.timestamp = timestamp;
	}

	State(State s, long timestamp) {
		this.scolor = s.scolor;
		this.sposition = s.sposition.get();
		this.ssize = s.ssize.get();

		this.timestamp = timestamp;
	}
};