package steps;


import es.bsc.dataclay.DataClayObject;

import java.io.File;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.ArrayList;
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
                if( loaded != null )
                    return loaded;
				try {
					// first try to use the URLClassLoader findClass
					if (name.contains("_Stub")) { 
						return realParent.loadClass(name);
					}
					
					return super.findClass(name);
				} catch( ClassNotFoundException e ) {
					// if that fails, we ask our real parent classloader to load the class (we give up)
					return realParent.loadClass(name);
				}
			}
		}

		public ParentLastURLClassLoader(List<URL> classpath) {
			super(Thread.currentThread().getContextClassLoader());
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

	public <K extends DataClayObject> K newInstance(final String className) {
		return newInstance(className, null, null);
	}

	public <K extends DataClayObject> K newInstance(final String className, Class<?>[] paramTypes, final Object ... initArgs) {
		K obj = null;
		try {
			final Class<?> clazz = theClassLoader.loadClass(className);
			Constructor<?> cons = null;
			if (paramTypes != null) {
				cons = clazz.getConstructor(paramTypes);
			} else { 
				cons = clazz.getConstructor();
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


}
