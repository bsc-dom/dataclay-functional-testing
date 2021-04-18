package model;

import es.bsc.dataclay.DataClayObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class LotsOfObjects extends DataClayObject implements LotsOfObjects_Stub {
	private List<LittleObject_Stub> little_objs;

	public LotsOfObjects() {
		little_objs = new ArrayList<LittleObject_Stub>();
		for (int i = 0; i < 100; ++i) {
			little_objs.add((LittleObject_Stub) new LittleObject());
		}
	}

}
