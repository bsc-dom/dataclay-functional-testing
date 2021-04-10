package model.elastic;

import model.TestStub;

import java.util.Map;

public interface Snapshot_Stub extends TestStub {
	void add_object(DetectedObject_Stub newObject);
	void add_object_refs(String objRef);
	void set_timestamp(long timestamp);
	Map<String, DetectedObject_Stub> get_objects();
	long get_timestamp();
	void add_events_from_trackers(final int numEventsPerObject, final String objectDetected,
								  final String objectType,
								  final int x, final int y, final int w, final int h,
								  final float vel_pred, final float yaw_pred,
								  final float lon, final float lat,
								  final DKB_Stub dkb);
	void delete(DKB_Stub dkb);
}
