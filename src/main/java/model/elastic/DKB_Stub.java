package model.elastic;

import model.TestStub;

import java.util.Map;

public interface DKB_Stub extends TestStub {
	void add_events_snapshot(Snapshot_Stub newSnapshot);
	void remove_events_snapshot(long timestamp);
	void add_object(final DetectedObject_Stub object);
	void remove_old_objects_and_snapshots(long timestamp, boolean unfederateObjects);
	Map<Integer, Snapshot_Stub> get_events_snapshots();
	DetectedObject_Stub get_or_create(final String id_object, final String object_class, final int x,
									  final int y, final int w, final int h, final long timestamp);

}
