package steps;

import model.People_Stub;
import model.Person_Stub;

public class StubFactory {

	/** Class loader. */
	public StubsClassLoader stubsClassLoader;

	public StubFactory(final String stubsPath) {
		stubsClassLoader = new StubsClassLoader(stubsPath);
	}

	public People_Stub newPeople() {

		return (People_Stub)  stubsClassLoader.newInstance("model.People");
	}
	
	public Person_Stub newPerson(final String pName, final int pAge) {
		return (Person_Stub) stubsClassLoader.newInstance("model.Person",
				new Class<?>[] {String.class, int.class}, pName, pAge);
		
	}


	public Person_Stub getByAlias(final String alias) {
		return (Person_Stub) stubsClassLoader.getByAlias("model.Person", alias);
	}
	
}
