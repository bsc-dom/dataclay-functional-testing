package steps;

import es.bsc.dataclay.api.BackendID;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import model.People_Stub;
import model.Person_Stub;

import java.util.Set;

public class GetByAliasSteps {

	@Then("{string} runs make persistent for an object with alias {string}")
	public void runsMakePersistentForAnObjectWithAlias(String userName, String alias) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		String pName = "Bob";
		int pAge = 33;
		Person_Stub p = user.stubsFactory.newPerson(pName, pAge);
		p.makePersistent(alias);
	}

	@Then("{string} gets the object with alias {string}")
	public void getsTheObjectWithAlias(String userName, String alias) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);

		Person_Stub p = user.stubsFactory.getByAlias(alias);
		System.out.println(p);
	}

}