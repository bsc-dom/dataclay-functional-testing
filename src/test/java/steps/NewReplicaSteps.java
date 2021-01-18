package steps;

import es.bsc.dataclay.api.BackendID;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import model.People_Stub;
import model.Person_Stub;

import java.util.Set;

public class NewReplicaSteps {

	@Given("I set object to be read only")
	public void iSetTheObjecToBeReadOnly() {
		CommonSteps.person.setObjectReadOnly();
	}

	@When("I call new replica")
	public void iCallNewReplica() {
		CommonSteps.backendID = CommonSteps.person.newReplica();
	}

	@Then("I get object locations and I see object is located in two locations")
	public void iGetObjectLocationsAndISeeObjectIsLocated() {
		Set<BackendID> backends = CommonSteps.person.getAllLocations();
		System.out.println(backends);
		org.junit.Assert.assertEquals(2, backends.size());
		org.junit.Assert.assertTrue(backends.contains(CommonSteps.backendID));
	}


}