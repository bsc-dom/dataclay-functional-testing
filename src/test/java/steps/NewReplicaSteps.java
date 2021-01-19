package steps;

import es.bsc.dataclay.api.BackendID;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import model.People_Stub;
import model.Person_Stub;

import java.util.Set;

public class NewReplicaSteps {

	@Given("{string} sets object to be read only")
	public void setsTheObjecToBeReadOnly(final String userName) {
		Orchestrator.TestUser user = Orchestrator.getTestUser(userName);
		Person_Stub person = (Person_Stub) user.userObjects.get("person");
		person.setObjectReadOnly();
	}

	@When("{string} calls new replica")
	public void callsNewReplica(final String userName) {
		Orchestrator.TestUser user = Orchestrator.getTestUser(userName);
		Person_Stub person = (Person_Stub) user.userObjects.get("person");
		BackendID backendID = person.newReplica();
		user.userObjects.put("personBackendID", backendID);

	}

	@Then("{string} gets object locations and sees object is located in two locations")
	public void getsObjectLocationsAndISeeObjectIsLocated(final String userName) {
		Orchestrator.TestUser user = Orchestrator.getTestUser(userName);
		Person_Stub person = (Person_Stub) user.userObjects.get("person");
		BackendID backendID = (BackendID) user.userObjects.get("personBackendID");
		Set<BackendID> backends = person.getAllLocations();
		System.out.println(backends);
		org.junit.Assert.assertEquals(2, backends.size());
		org.junit.Assert.assertTrue(backends.contains(backendID));
	}


}