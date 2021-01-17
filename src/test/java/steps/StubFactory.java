package steps;

import model.People_Stub;
import model.Person_Stub;

public class StubFactory {

	public static People_Stub newPeople() { 
    	return (People_Stub)  StubsClassLoader.newInstance("model.People");
	}
	
	public static Person_Stub newPerson(final String pName, final int pAge) { 
		return (Person_Stub) StubsClassLoader.newInstance("model.Person", 
				new Class<?>[] {String.class, int.class}, pName, pAge);
		
	}


	public static Person_Stub getByAlias(final String alias) {
		return (Person_Stub) StubsClassLoader.getByAlias("model.Person", alias);
	}
	
}
