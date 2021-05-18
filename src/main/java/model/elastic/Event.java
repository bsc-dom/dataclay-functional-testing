package model.elastic;

import es.bsc.dataclay.DataClayObject;

public class Event extends DataClayObject implements Event_Stub {
	private long id_event;
	private DetectedObject_Stub detected_object;
	private int timestamp;
	private float speed;
	private float yaw;
	private float longitude_pos;
	private float latitude_pos;

	public Event(final long id_event, DetectedObject_Stub newdetectedObject, final int timestamp,
				 final float speed, final float yaw, final float longitude_pos,
				 final float latitude_pos) {
		this.id_event= id_event;
		this.detected_object = newdetectedObject;
		this.timestamp = timestamp;
		this.speed = speed;
		this.yaw = yaw;
		this.longitude_pos = longitude_pos;
		this.latitude_pos = latitude_pos;
	}

	@Override
	public int get_timestamp() {
		return this.timestamp;
	}

	@Override
	public DetectedObject_Stub get_detected_object() {
		return this.detected_object;
	}


	@Override
	public void delete() {
		this.sessionDetach();
	}
}
