package model.elastic;

import model.TestStub;

public interface Event_Stub extends TestStub {
	DetectedObject_Stub get_detected_object();
	int get_timestamp();
	void delete();
}
