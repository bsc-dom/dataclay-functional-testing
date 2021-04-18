package model.elastic;

import es.bsc.dataclay.DataClayObject;

import java.util.*;

public class Snapshot extends DataClayObject implements Snapshot_Stub {
	private List<String> objects_refs;
	private Map<String, DetectedObject_Stub> objects;
	private String snap_alias;
	private long timestamp = 0L;

	public Snapshot(final String alias) {
		objects = new HashMap<>();
		this.snap_alias = alias;
		this.timestamp = 0L;
	}

	@Override
	public void add_object(DetectedObject_Stub newObject) {
		objects.put(newObject.get_id_object(), newObject);
	}

	@Override
	public void set_timestamp(long timestamp) {
		this.timestamp = timestamp;
	}

	@Override
	public long get_timestamp() {
		return this.timestamp;
	}

	@Override
	public void add_object_refs(String objRef) {
		objects_refs.add(objRef);
	}

	@Override
	public Map<String, DetectedObject_Stub> get_objects() {
		return this.objects;
	}

	@Override
	public void add_events_from_trackers(final int numEventsPerObject, final String id_object,
									     final String obj_class,
										 final int x, final int y, final int w, final int h,
										 final float vel_pred, final float yaw_pred,
									     final float lon, final float lat,
									  final DKB_Stub dkb) {
		for (int i = 0; i < numEventsPerObject; ++i) {
			DetectedObject_Stub obj = dkb.get_or_create(id_object, obj_class, x, y, w, h, this.timestamp);
			// in Java it must be a long
			long id_event = UUID.randomUUID().getMostSignificantBits() & Long.MAX_VALUE;
			Event_Stub event = (Event_Stub) new Event(id_event, obj, this.timestamp + i * 10L, vel_pred, yaw_pred, lon, lat);
			obj.add_event(event);
			if (!objects.containsKey(id_object)) {
				this.objects.put(id_object, obj);
			}

		}
	}

	@Override
	public void delete(DKB_Stub dkb) {
		// unfederate
		this.unfederate(true);
		dkb.remove_events_snapshot(this.timestamp);
		this.sessionDetach();
	}

	@Override
	public void whenUnfederated() {
		/**try {
			DKB_Stub dkb = DKB.getByAliasExt("DKB");
			dkb.remove_events_snapshot(this.timestamp);
		} catch (Exception e) {
			e.printStackTrace();

		}**/
	}

	@Override
	public void whenFederated() {
		try {
			// 			DKB_Stub dkb = (DKB_Stub) DKB.getByAliasExt(DKB.getMetaClassID("test_namespace.model.elastic.DKB"), "DKB", true);
			DKB_Stub dkb = (DKB_Stub) DKB.getByAliasExt("DKB");
			dkb.add_events_snapshot(this);

		} catch (Exception e) {
			e.printStackTrace();

		}
	}
}
