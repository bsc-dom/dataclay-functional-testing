
package steps;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

/** Class used for system.err and out of commands. */
public final class StreamGobbler extends Thread {

	/** Input stream. */
	private final InputStream is;
	/** Type. */
	private final String type;
	/** Output builder. */
	private final StringBuilder builder;

	/**
	 * Constructor
	 * @param theis
	 *            Input stream
	 * @param thetype
	 *            Type
	 */
	StreamGobbler(final InputStream theis, final String thetype) {
		this.is = theis;
		this.type = thetype;
		this.builder = new StringBuilder();
		this.setDaemon(true);
	}

	public String getResult() {
		return this.builder.toString();
	}

	@Override
	public void run() {
		try {
			final InputStreamReader isr = new InputStreamReader(is);
			final BufferedReader br = new BufferedReader(isr);
			String line = null;
			while ((line = br.readLine()) != null) {
					if (type.equals("ERROR")) {
						System.err.println(line);
					} else if (type.equals("INFO")) {
						System.out.println(line);
					}
				builder.append(line);
			}
		} catch (final IOException ioe) {
			ioe.printStackTrace();
		}
	}
}
