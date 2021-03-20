package model;

import es.bsc.dataclay.DataClayObject;
import es.bsc.dataclay.api.BackendID;
import es.bsc.dataclay.util.ids.ExecutionEnvironmentID;

public class Person extends DataClayObject implements Person_Stub {
	String name;
	int age;

	public Person(String newName, int newAge) throws Exception {
		name = newName;
		age = newAge;
	}

	public String getName() {
		return name;
	}
	public void setName(String newname) {
		this.name = newname;
	}

	public int getAge() {
		return age;
	}

	public void setAge(int newAge) {
		this.age = newAge;
	}

	public boolean replicaSourceIs(final ExecutionEnvironmentID backendID) {
		return this.getOriginLocation().equals(backendID);
	}

	public boolean replicaDestIncludes(final ExecutionEnvironmentID backendID) {
		return this.getReplicaLocations().contains(backendID);
	}
}
