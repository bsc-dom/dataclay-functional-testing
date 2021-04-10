package model.elastic;

import es.bsc.dataclay.DataClayObject;

import java.util.HashMap;
import java.util.Map;

public class ListOfObjects extends DataClayObject implements ListOfObjects_Stub {
	private Map<String, DetectedObject_Stub> objects;
	private Map<Long, String> objects_timestamps;

	public ListOfObjects() {

		objects = new HashMap<String, DetectedObject_Stub>();
		objects_timestamps = new HashMap<Long, String>();
	}

	@Override
	public DetectedObject_Stub get_or_create(final String id_object, final String object_class, final int x,
											 final int y, final int w, final int h, final long timestamp) {
		synchronized (this) {
			DetectedObject_Stub obj = objects.get(id_object);
			if (obj == null) {
				obj = (DetectedObject_Stub) new DetectedObject(id_object, object_class, x, y, w, h);
				objects.put(id_object, obj);
			}
			objects_timestamps.put(timestamp, id_object);
			return obj;
		}
	}

	@Override
	public void remove_old_objects(final long timestamp) {
		for (Map.Entry<Long, String> curEntry : objects_timestamps.entrySet()) {
			Long objTime = curEntry.getKey();
			String objId = curEntry.getValue();
			if (objTime < timestamp) {
				synchronized (this) {
					DetectedObject_Stub obj = objects.get(objId);
					obj.delete();
					objects.remove(objId);
				}
			}
		}
	}
}
