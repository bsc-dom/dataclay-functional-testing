package model;

import es.bsc.dataclay.DataClayObject;
import es.bsc.dataclay.util.ids.ExecutionEnvironmentID;
import es.bsc.dataclay.util.replication.Replication;

public class SyncObject extends DataClayObject implements SyncObject_Stub {
	@Replication.InMaster
	@Replication.AfterUpdate(method = "replicateToSlaves", clazz = "es.bsc.dataclay.util.replication.SequentialConsistency")
	String name;
	@Replication.InMaster
	@Replication.AfterUpdate(method = "replicateToSlaves", clazz = "es.bsc.dataclay.util.replication.SequentialConsistency")
	int value;

	public SyncObject(String newName, int newValue) throws Exception {
		name = newName;
		value = newValue;
	}

	public String getName() {
		return name;
	}

	public void setName(String newname) {
		this.name = newname;
	}

	public int getValue() {
		return value;
	}

	public void setValue(int newValue) {
		this.value = newValue;
	}

	public boolean replicaSourceIs(final ExecutionEnvironmentID backendID) {
		return this.getOriginLocation().equals(backendID);
	}

	public boolean replicaDestIncludes(final ExecutionEnvironmentID backendID) {
		return this.getReplicaLocations().contains(backendID);
	}
}
