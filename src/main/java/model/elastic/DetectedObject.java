package model.elastic;

import es.bsc.dataclay.DataClayObject;

import java.util.HashMap;
import java.util.Map;

public class DetectedObject extends DataClayObject implements DetectedObject_Stub {
	private String id_object;
	private String type;
	private int timestamp;
	private Map<Integer, Event_Stub> events_history;
	private int pixel_x;
	private int pixel_y;
	private int pixel_w;
	private int pixel_h;
	public DetectedObject(final String id_object, final String object_class, final int x,
						  final int y, final int w, final int h) {
		this.id_object = id_object;
		this.timestamp = 0;
		this.type = object_class;
		this.pixel_x = x;
		this.pixel_x = y;
		this.pixel_x = w;
		this.pixel_x = h;
		events_history = new HashMap<>();
	}

	@Override
	public void set_id_object(String newId) {
		id_object = newId;
	}

	@Override
	public String get_id_object() {
		return this.id_object;
	}

	@Override
	public void set_timestamp(int newtimestamp) {
		timestamp = newtimestamp;
	}

	@Override
	public int get_timestamp() {
		return this.timestamp;
	}

	@Override
	public void add_event(final Event_Stub event) {

		this.events_history.put(event.get_timestamp(), event);
		int eventTimestamp = event.get_timestamp();
		if (eventTimestamp > this.timestamp) {
			this.timestamp = event.get_timestamp();
		}
	}



	@Override
	public void delete(final boolean unfederateObjects) {
		for (Event_Stub event_stub : this.events_history.values()) {
			event_stub.delete();
		}
		if (unfederateObjects) {
			this.unfederate(true);
		}
		this.events_history.clear();
		this.sessionDetach();
	}

}
