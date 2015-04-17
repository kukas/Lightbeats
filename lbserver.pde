import processing.net.*;
import java.nio.ByteBuffer;
import java.util.zip.CRC32;

class LBServer {
	Server server;
	CRC32 crc;

	LBServer(PApplet parent, int port) {
		server = new Server(parent, port);
		crc = new CRC32();
	}

	void send(ArrayList<Ball> balls, long timestamp) {
		int count = balls.size();
		// 25 bits per ball + 8 for timestamp + 1 for count
		ByteBuffer buffer = ByteBuffer.allocate(25*count + 17);
		// long checksum (8 bits) (pouze vyhrazené místo)
		buffer.position(8);
		// long timestamp (8 bits)
		buffer.putLong(timestamp);
		// ball count (1 bit)
		buffer.put((byte) count);
		for (int i = 0; i < count; i++) {
			Ball ball = balls.get(i);
			State state = ball.getState();
			// [int id] (4 bits)
			buffer.putInt(ball.id);
			// [boolean isBall][boolean updated][boolean predicted] (1 bit)
			byte isBall = (byte)((ball.ballProbability == 1) ? 1 : 0);
			byte updated = (byte)(ball.updated ? 2 : 0);
			byte predicted = (byte)(state.predicted ? 4 : 0);
			byte flags = (byte)(isBall | updated | predicted);
			buffer.put(flags);

			// [float position.x] (4 bits)
			buffer.putFloat(state.sposition.x);
			// // [float position.y] (4 bits)
			buffer.putFloat(state.sposition.y);
			// // [float size.x] (4 bits)
			buffer.putFloat(state.ssize.x);
			// // [float size.y] (4 bits)
			buffer.putFloat(state.ssize.y);
			// [int color] (4 bits)
			buffer.putInt(state.scolor);
		}
		// přetočí buffer na začátek, vynechá prvních 8 bitů jako místo pro checksum
		// buffer.position(7);
		// připraví crc
		crc.reset();
		// vypočítá crc od position na konec
		// println(buffer.array().length, buffer.capacity());
		crc.update(buffer.array(), 8, buffer.capacity() - 8);
		// přidá na začátek crc
		buffer.putLong(0, crc.getValue());

		byte[] data = buffer.array();
		server.write(data);
	}

	void stop() {
		server.stop();
	}
};
