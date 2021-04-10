package model.elastic;

import model.NodeB_Stub;
import model.TestStub;

public interface DetectedObject_Stub extends TestStub {
	void set_id_object(String newId);
	String get_id_object();
	void add_event(final Event_Stub event);
	void delete();
}
