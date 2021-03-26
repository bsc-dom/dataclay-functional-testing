package model;

import es.bsc.dataclay.DataClayObject;

import java.util.ArrayList;

public class ObjectB extends DataClayObject implements ObjectB_Stub {
	private ObjectA_Stub objectA;

	public ObjectB() {

	}

	@Override
	public void setObjectA(ObjectA_Stub newObjectA) {
		objectA = newObjectA;
	}

	@Override
	public ObjectA_Stub getObjectA() {
		return this.objectA;
	}
}
