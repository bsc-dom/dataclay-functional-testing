package steps;


import es.bsc.dataclay.DataClayObject;
import es.bsc.dataclay.util.ids.ExecutionEnvironmentID;
import es.bsc.dataclay.util.ids.ObjectID;
import org.yaml.snakeyaml.constructor.Construct;

import java.io.File;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * This class includes common steps in BDD testing.
 *
 */
public class StubsClassLoader {

	/** Class loader. */
	public ClassLoader theClassLoader;

	private class ParentLastURLClassLoader extends ClassLoader {
		private ChildURLClassLoader childClassLoader;

		/**
		 * This class allows me to call findClass on a classloader
		 */
		private class FindClassClassLoader extends ClassLoader {
			public FindClassClassLoader(ClassLoader parent) {
				super(parent);
			}

			@Override
			public Class<?> findClass(String name) throws ClassNotFoundException {
				return super.findClass(name);
			}
		}

		/**
		 * This class delegates (child then parent) for the findClass method for a URLClassLoader.
		 * We need this because findClass is protected in URLClassLoader
		 */
		private class ChildURLClassLoader extends URLClassLoader {
			private FindClassClassLoader realParent;
			public ChildURLClassLoader( URL[] urls, FindClassClassLoader realParent) {
				super(urls, null);
				this.realParent = realParent;
			}

			@Override
			public Class<?> findClass(String name) throws ClassNotFoundException {
				Class<?> loaded = super.findLoadedClass(name);
                if( loaded != null ) {
					//System.err.println("[CHILD-CL] Found loaded class " + name + ": " + loaded);
					return loaded;
				}
				try {
					// first try to use the URLClassLoader findClass
					if (name.contains("_Stub")) {
						// Stub classes must be loaded from normal class loader
						//System.err.println("[CHILD-CL] Loading from real parent class: " + name);
						Class<?> clazz = realParent.loadClass(name);
						//System.err.println("[CHILD-CL] Loaded " + name + " class: " + clazz);
						return clazz;
					}
					//System.err.println("[CHILD-CL] Loading from parent classloader: " + name);
					Class<?> clazz = super.findClass(name);
					//System.err.println("[CHILD-CL] Loaded " + name + " class: " + clazz);
					return clazz;
				} catch( ClassNotFoundException e ) {
					// if that fails, we ask our real parent classloader to load the class (we give up)
					return realParent.loadClass(name);
				}
			}
		}

		public ParentLastURLClassLoader(List<URL> classpath) {
			super(Orchestrator.ORIGINAL_CLASS_LOADER);
			URL[] urls = classpath.toArray(new URL[classpath.size()]);
			childClassLoader = new ChildURLClassLoader( urls, new FindClassClassLoader(this.getParent()) );
		}

		@Override
		protected synchronized Class<?> loadClass(String name, boolean resolve) throws ClassNotFoundException {
			// first we try to find a class inside the child classloader
			try {
				return childClassLoader.findClass(name);

			} catch( ClassNotFoundException e ) {
				// didn't find it, try the parent
				return super.loadClass(name, resolve);
			}
		}
	}

	public StubsClassLoader(final String stubsClassesFolder) {
		final File clDir = new File(stubsClassesFolder);
		final List<URL> urls = new ArrayList<URL>();
		try {
			urls.add(clDir.toURI().toURL());
		} catch (final Exception e) {
			throw new RuntimeException(e);
		}
		theClassLoader = new ParentLastURLClassLoader(urls);
	}

	public <K extends DataClayObject> K newInstance(final String className,
													final String[] strArgs) {
		K obj = null;
		try {
			System.out.println("Creating instance of class " + className);
			System.out.println("Provided constructor args " + Arrays.toString(strArgs));
			final Class<?> clazz = theClassLoader.loadClass(className);
			Constructor cons = null;
			System.out.println("Looking for constructor in class " + clazz.getName());
			for (Constructor m : clazz.getConstructors()) {
				System.out.println("Checking constructor " + m + " of class " + m.getDeclaringClass() + " with " + m.getParameterCount() + " params == " + strArgs.length);
				if (!m.getDeclaringClass().equals(DataClayObject.class) && m.getParameterCount() == strArgs.length) {

					if (m.getParameterCount() == 1) {
						if (m.getParameterTypes()[0].equals(ObjectID.class)) {
							continue;
						}
					}

					//ONLY ONE CONSTRUCTOR SUPPORTED
					System.out.println("Found constructor " + m + " of class " + m.getDeclaringClass());
					cons = m;
					break;
				}
			}
			Object[] initArgs = null;
			if (cons.getParameterCount() > 0) {
				initArgs = new Object[strArgs.length];
				int i = 0;
				assert cons != null;
				for (Class<?> paramType : cons.getParameterTypes()) {
					// cast
					initArgs[i] = cast(paramType, strArgs[i]);
					i++;
				}
				System.out.println("Calling constructor with args " + Arrays.toString(initArgs));
			}
			cons.setAccessible(true);
			obj = (K) cons.newInstance(initArgs);
		} catch (final Exception e) {
			throw new RuntimeException(e);
		}
		return obj;
	}


	public <K extends DataClayObject> K getByAlias(final String className, final String alias) {
		K obj = null;
		try {
			final Class<?> clazz = theClassLoader.loadClass(className);
			Method getByAliasMethod = clazz.getMethod("getByAlias", String.class);
			getByAliasMethod.setAccessible(true);
			obj = (K) getByAliasMethod.invoke(null, alias);
		} catch (final Exception e) {
			throw new RuntimeException(e);
		}
		return obj;
	}

	private Object cast(final Class<?> classType, final String objectToCast){
		Object castObject = null;
		System.out.println("Casting " + objectToCast + " to class " + classType.getName());

		if (objectToCast.startsWith("obj_")) {
			// get by ref
			return Orchestrator.userContext.userObjects.get(objectToCast);
		}
		if (objectToCast.startsWith("execid_")) {
			// get by ref
			return (ExecutionEnvironmentID) Orchestrator.userContext.userObjects.get(objectToCast);
		}
		if (classType.equals(String.class)) {
			castObject = objectToCast;
		} else if (classType.equals(Integer.class)) {
			castObject = Integer.valueOf(objectToCast);
		} else if (classType.equals(Float.class)) {
			castObject = Float.valueOf(objectToCast);
		} else if (classType.equals(Double.class)) {
			castObject = Double.valueOf(objectToCast);
		} else if (classType.equals(Boolean.class)) {
			castObject = Boolean.valueOf(objectToCast);
		} else if (classType.equals(Character.class)) {
			castObject = objectToCast.toCharArray()[0];
		} else if (classType.equals(Long.class)) {
			castObject = Long.valueOf(objectToCast);
		} else if (classType.equals(Short.class)) {
			castObject = Short.valueOf(objectToCast);
		} else if (classType.equals(Byte.class)) {
			castObject = Byte.valueOf(objectToCast);
		} else if (classType.equals(int.class)) {
			castObject = Integer.valueOf(objectToCast);
		} else if (classType.equals(float.class)) {
			castObject = Float.valueOf(objectToCast);
		} else if (classType.equals(double.class)) {
			castObject = Double.valueOf(objectToCast);
		} else if (classType.equals(boolean.class)) {
			castObject = Boolean.valueOf(objectToCast);
		} else if (classType.equals(char.class)) {
			castObject = objectToCast.toCharArray()[0];
		} else if (classType.equals(long.class)) {
			castObject = Long.valueOf(objectToCast);
		} else if (classType.equals(short.class)) {
			castObject = Short.valueOf(objectToCast);
		} else if (classType.equals(byte.class)) {
			castObject = Byte.valueOf(objectToCast);
		}
		return castObject;
	}

	public Object runMethod(final Object instance, final String methodName,
							final String[] strArgs) {
		try {
			Method methodToCall = null;
			final Class<?> clazz = instance.getClass();
			for (Method m : clazz.getMethods()) {
				if (m.getName().equals(methodName)) {
					methodToCall = m;
					break;
				}
			}
			Object[] args = null;
			if (methodToCall == null) {
				System.err.println("ERROR: cannot find method " + methodName + " in class " + clazz.getName());

			}
			if (methodToCall.getParameterCount() > 0) {
				args = new Object[strArgs.length];
				int i = 0;
				for (Class<?> paramType : methodToCall.getParameterTypes()) {
					// cast
					args[i] = cast(paramType, strArgs[i]);
					i++;
				}
				System.out.println("Calling method with args " + Arrays.toString(args));
			}
			methodToCall.setAccessible(true);
			return methodToCall.invoke(instance, args);
		} catch (final Exception e) {
			throw new RuntimeException(e);
		}
	}


}
