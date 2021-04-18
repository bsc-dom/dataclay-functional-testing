package model;

import es.bsc.dataclay.DataClayObject;

import java.util.Random;

public class BigObject extends DataClayObject implements BigObject_Stub {
	private byte[] obj_bytes;

	public BigObject() {
		obj_bytes = new byte[1000000];
		new Random().nextBytes(obj_bytes);
	}

}
