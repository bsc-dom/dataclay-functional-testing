package model;

import es.bsc.dataclay.DataClayObject;

import java.util.Random;

public class LittleObject extends DataClayObject implements LittleObject_Stub {
	private byte[] obj_bytes;

	public LittleObject() {
		obj_bytes = new byte[100];
		new Random().nextBytes(obj_bytes);
	}

}
