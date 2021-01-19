package steps;

import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.qameta.allure.Allure;

import java.io.IOException;
import java.nio.file.Paths;

public class Federation {

	@Given("{string} register external dataClay named {string} with hostname {string} and port {string}")
	public void registerExternalDataClayWithHostnameAndPort(String userName,
															String externalDCName,
															String hostname,
															final String port) {

	}

	@And("{string} imports models in namespace {string} from dataClay named {string}")
	public void importsModelFromDataClayNamed(String userName,
											  String externalNamespace,
											  String externalDCName) {

	}


	@Given("{string} get id of dataclay with hostname {string} and port {string}")
	public void getIDofDataClayWithHostnameAndPort(String userName, String hostname,
												   final String port) {

	}

	@When("{string} federates object to dataClay {string}")
	public void getIDofDataClayWithHostnameAndPort(String userName, String externalDCName) {

	}

}