package model;

import es.bsc.dataclay.DataClayObject;

import java.util.ArrayList;

public class ObjectA extends DataClayObject implements ObjectA_Stub {
	private ObjectB_Stub objectB;

	public ObjectA() {

	}

	@Override
	public void setObjectB(ObjectB_Stub newObjectB) {
		objectB = newObjectB;
	}

	@Override
	public ObjectB_Stub getObjectB() {
		return this.objectB;
	}
}
