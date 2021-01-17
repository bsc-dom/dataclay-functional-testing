package steps;


import es.bsc.dataclay.api.DataClay;
import es.bsc.dataclay.api.DataClayException;
import io.qameta.allure.Allure;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

/**
 * This class includes common steps in BDD testing.
 *
 */
public class Utils {

	public static boolean deleteDirectory(File directoryToBeDeleted) {
		File[] allContents = directoryToBeDeleted.listFiles();
		if (allContents != null) {
			for (File file : allContents) {
				deleteDirectory(file);
			}
		}
		return directoryToBeDeleted.delete();
	}

	public static void createModelStr(Path filePath) {
		try {
			String fileName = filePath.getFileName().toString();
			if (fileName.endsWith(".java")) {
				Allure.attachment(fileName, readAllBytes(filePath));
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	//Read file content into string with - Files.readAllBytes(Path path)

	public static String readAllBytes(Path filePath) throws IOException {
		String content = new String ( Files.readAllBytes( filePath ) );
		return content;
	}



}
