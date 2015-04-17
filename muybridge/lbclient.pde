import processing.net.*;
import java.nio.ByteBuffer;
import java.util.zip.CRC32;

class Ball {
	ArrayList<State> stateHistory;
	// jak moc jsme si jistí, že je toto opravdu míček?
	boolean isBall = false;
	boolean updated = false;

	int id;
	long timestamp;

	Ball(int id, State state) {
		this.id = id;
		this.timestamp = state.timestamp;

		stateHistory = new ArrayList<State>();
		addState(state);
	}

	void addState(State state) {
		stateHistory.add(0, state);
	}

	State getState() {
		return stateHistory.get(0);
	}

	State getState(int index) {
		return stateHistory.get(index);
	}
};

class State {
	color scolor;
	PVector sposition;
	PVector ssize;
	long timestamp;

	boolean predicted = false;

	State(color c, PVector p, PVector s, long timestamp) {
		this.scolor = c;
		this.sposition = p;
		this.ssize = s;

		this.timestamp = timestamp;
	}
};

class LBClient {
	Client client;
	byte[] data;

	ArrayList<Ball> balls;
	Renderer renderer;
	long timestamp;
	CRC32 crc;

	LBClient(PApplet parent, String host, int port) {
		client = new Client(parent, host, port);
		balls = new ArrayList<Ball>();

		renderer = new Renderer();

		crc = new CRC32();
	}

	Ball updateBall(int id, State state) {
		for (Ball ball : balls) {
			if(ball.id == id){
				ball.addState(state);
				return ball;
			}
		}
		// pokud nenalezen
		Ball ball = new Ball(id, state);
		balls.add(ball);

		return ball;
	}

	void receive() {
		if(client.available() <= 16)
			return;
		data = client.readBytes();
		ByteBuffer buffer = ByteBuffer.wrap(data);
		
		// long checksum (8 bits)
		long checksum = buffer.getLong();
		crc.reset();
		crc.update(buffer.array(), 8, buffer.capacity() - 8);
		// checkování checksumu
		if(crc.getValue() != checksum)
			return;

		// long timestamp (8 bits)
		timestamp = buffer.getLong();

		// kontrola správné délky zprávy
		if((data.length-17) % 25 != 0)
			return;

		int count = (data.length-17)/25;
		// byte count (1 bit)
		byte countCheck = buffer.get();

		// kontrola počtu míčků
		if(count != countCheck)
			return;

		for (int i = 0; i < count; i++) {
			// [int id] (4 bits)
			int id = buffer.getInt();
			// [boolean isBall][boolean updated][boolean predicted] (1 bit)
			byte flags = buffer.get();
			boolean isBall = (flags & 1) != 0;
			boolean updated = (flags & 2) != 0;
			boolean predicted = (flags & 4) != 0;

			PVector sposition = new PVector();
			// [float position.x] (4 bits)
			sposition.x = buffer.getFloat();
			// // [float position.y] (4 bits)
			sposition.y = buffer.getFloat();
			
			PVector ssize = new PVector();
			// // [float size.x] (4 bits)
			ssize.x = buffer.getFloat();
			// // [float size.y] (4 bits)
			ssize.y = buffer.getFloat();
			// [int color] (4 bits)
			int scolor = buffer.getInt();

			State state = new State(scolor, sposition, ssize, timestamp);
			state.predicted = predicted;

			Ball updatedBall = updateBall(id, state);
			updatedBall.isBall = isBall;
			updatedBall.updated = updated;
		}
	}

	void stop() {
		client.stop();
	}

	void debugDraw() {
		for (Ball ball : balls) {
			State state = ball.getState();
			fill(red(state.scolor), green(state.scolor), blue(state.scolor));
			stroke(255);
			rectMode(CENTER);
			rect(state.sposition.x, state.sposition.y, state.ssize.x, state.ssize.y);
		}
	}

	void render(int scene) {
		renderer.render(balls, timestamp, scene);
	}
};
