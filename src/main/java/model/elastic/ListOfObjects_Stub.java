package model.elastic;

import model.TestStub;

public interface ListOfObjects_Stub extends TestStub {
	DetectedObject_Stub get_or_create(final String id_object, final String object_class, final int x,
									  final int y, final int w, final int h, final long timestamp);
	void remove_old_objects(final long timestamp);
}
