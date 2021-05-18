package model.elastic;

import es.bsc.dataclay.DataClayObject;

import java.util.*;

public class Snapshot extends DataClayObject implements Snapshot_Stub {
	private List<Event_Stub> events;
	private String snap_alias;
	private int timestamp = 0;

	public Snapshot(final String alias) {
		events = new ArrayList<>();
		this.snap_alias = alias;
		this.timestamp = 0;
	}

	@Override
	public void add_event(Event_Stub newEvent) {
		events.add(newEvent);
	}

	@Override
	public void set_timestamp(int timestamp) {
		this.timestamp = timestamp;
	}

	@Override
	public int get_timestamp() {
		return this.timestamp;
	}

	@Override
	public void add_events_from_trackers(final Integer numEventsPerObject, final String id_object,
									     final String obj_class,
										 final Integer x, final Integer y, final Integer w, final Integer h,
										 final Float vel_pred, final Float yaw_pred,
									     final Float lon, final Float lat,
									  final DKB_Stub dkb) {
		for (int i = 0; i < numEventsPerObject; ++i) {
			DetectedObject_Stub obj = dkb.get_or_create(id_object, obj_class, x, y, w, h, this.timestamp);
			// in Java it must be a long
			long id_event = UUID.randomUUID().getMostSignificantBits() & Long.MAX_VALUE;
			Event_Stub event = (Event_Stub) new Event(id_event, obj, this.timestamp + i * 10,
					vel_pred, yaw_pred, lon, lat);
			obj.add_event(event);
			this.add_event(event);

		}
	}

	@Override
	public void delete(boolean unfederateObjects) {
		// unfederate
		if (unfederateObjects) {
			this.unfederate(true);
		}
		this.events.clear();
		this.sessionDetach();
	}

	@Override
	public void whenFederated() {
		try {
			// 			DKB_Stub dkb = (DKB_Stub) DKB.getByAliasExt(DKB.getMetaClassID("test_namespace.model.elastic.DKB"), "DKB", true);
			DKB_Stub dkb = (DKB_Stub) DKB.getByAliasExt("DKB");
			dkb.add_events_snapshot(this);
			for (Event_Stub event : this.events) {
				DetectedObject_Stub obj = event.get_detected_object();
				obj.add_event(event);
				dkb.add_object(obj);
			}

		} catch (Exception e) {
			e.printStackTrace();

		}
	}
}
