package model.elastic;

import model.TestStub;

import java.util.Map;

public interface Snapshot_Stub extends TestStub {
	void add_event(Event_Stub newEvent);
	void set_timestamp(int timestamp);
	int get_timestamp();
	void add_events_from_trackers(final Integer numEventsPerObject, final String objectDetected,
								  final String objectType,
								  final Integer x, final Integer y, final Integer w, final Integer h,
								  final Float vel_pred, final Float yaw_pred,
								  final Float lon, final Float lat,
								  final DKB_Stub dkb);
	void delete(boolean unfederateObjects);
}
