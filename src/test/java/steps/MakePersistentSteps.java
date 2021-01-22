package steps;

import es.bsc.dataclay.api.BackendID;
import es.bsc.dataclay.api.DataClay;
import es.bsc.dataclay.api.DataClayException;
import io.cucumber.java.After;
import io.cucumber.java.Before;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.qameta.allure.Allure;
import io.qameta.allure.Attachment;
import io.qameta.allure.model.Parameter;
import io.qameta.allure.util.ResultsUtils;
import model.People_Stub;
import model.Person_Stub;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class MakePersistentSteps {

	@Then("{string} runs make persistent for an object")
    public void runsMakePersistentForAnObject(final String userName) {

		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);

    	String pName = "Bob";
    	int pAge = 33;
		Person_Stub person = user.stubsFactory.newPerson(pName, pAge);
		person.makePersistent();
    	
    	People_Stub people = user.stubsFactory.newPeople();
    	people.add(person);
    	people.makePersistent();
    	
    	System.out.println(people);

		user.userObjects.put("person", person);

    	
    }

}