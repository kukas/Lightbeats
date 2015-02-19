class State {
	color scolor;
	PVector sposition;
	PVector ssize;

	State () {
		this.scolor = color(0, 0, 0);
		this.sposition = new PVector();
		this.ssize = new PVector();
	}

	State (color c, PVector p, PVector s) {
		this.scolor = c;
		this.sposition = p;
		this.ssize = s;
	}

	State (State s) {
		this.scolor = s.scolor;
		this.sposition = s.sposition.get();
		this.ssize = s.ssize.get();
	}
};