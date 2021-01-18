package steps;

import es.bsc.dataclay.api.BackendID;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import model.People_Stub;
import model.Person_Stub;

import java.util.Set;

public class GetByAliasSteps {

	@Then("I run make persistent for an object with alias {string}")
	public void iRunMakePersistentForAnObjectWithAlias(String alias) {
		String pName = "Bob";
		int pAge = 33;
		Person_Stub p = StubFactory.newPerson(pName, pAge);
		p.makePersistent(alias);
	}

	@Then("I get the object with alias {string}")
	public void iGetTheObjectWithAlias(String alias) {
		Person_Stub p = StubFactory.getByAlias(alias);
		System.out.println(p);
	}

}