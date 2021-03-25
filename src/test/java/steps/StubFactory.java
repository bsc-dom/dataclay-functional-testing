package steps;

import model.People_Stub;
import model.Person_Stub;

import java.lang.reflect.Constructor;

public class StubFactory {

	/** Class loader. */
	public StubsClassLoader stubsClassLoader;

	/** Stubs path. */
	public String stubsPath;

	public StubFactory(final String stubsPath) {
		this.stubsPath = stubsPath;
		stubsClassLoader = new StubsClassLoader(stubsPath);
	}

	public Object newInstance(final String className, String constructorParams) {
		String[] paramsStr = new String[0];
		if (constructorParams != null) {
			paramsStr = constructorParams.split(" ");
		}
		return stubsClassLoader.newInstance("model." + className, paramsStr);
	}

	public Object getByAlias(final String className, String alias) {
		return stubsClassLoader.getByAlias("model." + className, alias);
	}

	public Object runMethod(final Object instance, final String methodName, String params) {
		String[] paramsStr = params.split(" ");
		return stubsClassLoader.runMethod(instance, methodName, paramsStr);
	}
	
}
