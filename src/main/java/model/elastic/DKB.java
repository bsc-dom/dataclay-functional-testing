package model.elastic;

import es.bsc.dataclay.DataClayObject;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class DKB extends DataClayObject implements DKB_Stub {
	private Map<Integer, Snapshot_Stub> snapshots;
	private Map<String, DetectedObject_Stub> objects;

	public DKB() {
		snapshots = new ConcurrentHashMap<Integer, Snapshot_Stub>();
		objects = new ConcurrentHashMap<String, DetectedObject_Stub>();
	}

	@Override
	public void add_events_snapshot(Snapshot_Stub newSnapshot) {
		snapshots.put(newSnapshot.get_timestamp(), newSnapshot);
	}

	@Override
	public void remove_events_snapshot(long timestamp) {
		snapshots.remove(timestamp);
	}

	public void add_object(final DetectedObject_Stub object) {
		this.objects.put(object.get_id_object(), object);
	}

	@Override
	public Map<Integer, Snapshot_Stub> get_events_snapshots() {
		return this.snapshots;
	}


	@Override
	public DetectedObject_Stub get_or_create(final String id_object, final String object_class, final int x,
											 final int y, final int w, final int h, final long timestamp) {
		synchronized (this) {
			DetectedObject_Stub obj = objects.get(id_object);
			if (obj == null) {
				obj = (DetectedObject_Stub) new DetectedObject(id_object, object_class, x, y, w, h);
				objects.put(id_object, obj);
			}
			return obj;
		}
	}

	@Override
	public void remove_old_objects_and_snapshots(final long timestamp, boolean unfederateObjects) {
		for (Map.Entry<Integer, Snapshot_Stub> curEntry : snapshots.entrySet()) {
			Integer snapTimestamp = curEntry.getKey();
			Snapshot_Stub snapshot = curEntry.getValue();
			if (snapTimestamp < timestamp) {
				synchronized (this) {
					snapshot.delete(unfederateObjects);
					snapshots.remove(snapTimestamp);
				}
			}
		}
		for (Map.Entry<String, DetectedObject_Stub> curEntry : objects.entrySet()) {
			String objectID = curEntry.getKey();
			DetectedObject_Stub object = curEntry.getValue();
			if (object.get_timestamp() < timestamp) {
				synchronized (this) {
					object.delete(unfederateObjects);
					objects.remove(objectID);
				}
			}
		}
	}

}
