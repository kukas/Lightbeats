class Show {
	int currentAct = 0;
	ArrayList<Act> acts;

	Show() {
		acts = new ArrayList<Act>();
	}

	void init() {
		for (Act act : acts) {
			act.init();
		}
	}

	void draw() {
		act().draw();
	}

	Act act() {
		return acts.get(currentAct);
	}

	void next() {
		if(currentAct+1 < acts.size()){
			act().hide();
			currentAct++;
			act().show();
		}
	}

	void prev() {
		if(currentAct-1 >= 0){
			act().hide();
			currentAct--;
			act().show();
		}
	}

	void addAct(Act act) {
		act.parent = this;
		acts.add(act);
	}

	void keyPressed() {
		act().keyPressed();
	}

	void stop() {
		act().hide();
	}
}