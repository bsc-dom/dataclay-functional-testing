package model;

import es.bsc.dataclay.util.ids.ExecutionEnvironmentID;

public interface Person_Stub extends TestStub {
	String getName();
	int getAge();
	void setAge(int newAge);
	void setName(String newName);
	boolean replicaSourceIs(final ExecutionEnvironmentID backendID);
	boolean replicaDestIncludes(final ExecutionEnvironmentID backendID);
}
