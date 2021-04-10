package model.elastic;

import es.bsc.dataclay.DataClayObject;

import java.util.HashMap;
import java.util.Map;

public class DKB extends DataClayObject implements DKB_Stub {
	private Map<Long, Snapshot_Stub> snapshots;
	private ListOfObjects_Stub listOfObjects;

	public DKB() {
		snapshots = new HashMap<Long, Snapshot_Stub>();
		listOfObjects = new ListOfObjects();
	}

	@Override
	public void set_list_of_objects(ListOfObjects_Stub newListOfObjects) {
		this.listOfObjects = newListOfObjects;
	}

	@Override
	public void add_events_snapshot(Snapshot_Stub newSnapshot) {
		snapshots.put(newSnapshot.get_timestamp(), newSnapshot);
	}

	@Override
	public void remove_events_snapshot(long timestamp) {
		snapshots.remove(timestamp);
	}

	@Override
	public void remove_old_objects(final long timestamp) {
		// delete all objects without events after timestamp
		this.listOfObjects.remove_old_objects(timestamp);
	}

	@Override
	public Map<Long, Snapshot_Stub> get_events_snapshots() {
		return this.snapshots;
	}

	@Override
	public DetectedObject_Stub get_or_create(final String id_object, final String object_class, final int x,
											 final int y, final int w, final int h, final long timestamp) {
		return this.listOfObjects.get_or_create(id_object, object_class, x, y, w, h, timestamp);
	}

}
