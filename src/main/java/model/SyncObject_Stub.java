package model;

import es.bsc.dataclay.util.ids.ExecutionEnvironmentID;

public interface SyncObject_Stub extends TestStub {
	String getName();
	int getValue();
	void setValue(int newValue);
	void setName(String newName);
	boolean replicaSourceIs(final ExecutionEnvironmentID backendID);
	boolean replicaDestIncludes(final ExecutionEnvironmentID backendID);
}
