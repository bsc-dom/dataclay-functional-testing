import threading
import traceback

from dataclay import DataClayObject, dclayMethod
"""
City Knowledge Base: collection of Events Snapshots
"""
class DKB(DataClayObject):
    """
    @ClassField kb dict<int, test_namespace.elastic.Snapshot>
    @ClassField list_objects test_namespace.elastic.ListOfObjects
    """
    @dclayMethod()
    def __init__(self):
        self.kb = dict()
        self.list_objects = ListOfObjects()

    @dclayMethod(event_snp='test_namespace.elastic.Snapshot')
    def add_events_snapshot(self, event_snp):
        self.kb[event_snp.timestamp] = event_snp

    @dclayMethod(timestamp='int')
    def remove_events_snapshot(self, timestamp: int):
        del self.kb[timestamp]

    @dclayMethod(object_id='str', object_class='str', x='int', y='int', w='int', h='int', timestamp='int',
                 return_='test_namespace.elastic.DetectedObject')
    def get_or_create(self, object_id: str, object_class: str, x: int, y: int, w: int, h: int, timestamp: int):
        return self.list_objects.get_or_create(object_id, object_class, x, y, w, h, timestamp)

    @dclayMethod(timestamp='int')
    def remove_old_objects(self, timestamp: int):
        self.list_objects.remove_old_objects(timestamp)

class ListOfObjects(DataClayObject):
    """
    @ClassField objects dict<str, test_namespace.elastic.DetectedObject>
    @ClassField objects_timestamps dict<int, str>
    @dclayImport threading
    @dclayImport traceback
    """

    @dclayMethod()
    def __init__(self):
        self.objects = dict()
        self.objects_timestamps = dict()
        self.global_lock = threading.Lock()

    @dclayMethod(object_id='str', object_class='str', x='int', y='int', w='int', h='int', timestamp='int',
                 return_='test_namespace.elastic.DetectedObject')
    def get_or_create(self, object_id: str, object_class: str, x: int, y: int, w: int, h: int, timestamp: int):
        with self.global_lock:
            if object_id not in self.objects:
                obj = DetectedObject(object_id, object_class, timestamp, x, y, w, h)
                self.objects[object_id] = obj
            self.objects_timestamps[object_id] = timestamp
            return self.objects[object_id]

    @dclayMethod(timestamp='int')
    def remove_old_objects(self, timestamp: int):
        for object_id, obj_timestamp in self.objects_timestamps.items():
            if obj_timestamp < timestamp:
                with self.global_lock:
                    obj = self.objects[object_id]
                    obj.delete()
                    del self.objects[object_id]


    @dclayMethod(return_="dict<str, anything>")
    def __getstate__(self):
        return {"objects": self.objects, "objects_timestamps": self.objects_timestamps}

    @dclayMethod(state="dict<str, anything>")
    def __setstate__(self, state):
        self.objects = state["objects"]
        self.objects_timestamps = state["objects_timestamps"]
        self.global_lock = threading.Lock()

"""
Snapshot: List of the objects detected in an snapshot. Each object
contains a list of events (last event for current snapshot and events history).
"""
class Snapshot(DataClayObject):
    """
    @ClassField objects_refs list<str>
    @ClassField objects dict<str, test_namespace.elastic.DetectedObject>
    @ClassField snap_alias str
    @ClassField timestamp int
    """

    @dclayMethod(alias='str')
    def __init__(self, alias):
        self.objects_refs = []
        self.objects = dict()
        self.snap_alias = alias
        self.timestamp = 0

    @dclayMethod(object_alias="str")
    def add_object_refs(self, object_alias: str):
        self.objects_refs.append(object_alias)

    ## FOR THE SIMULATOR ONLY ##
    @dclayMethod(obj="test_namespace.elastic.DetectedObject")
    def add_object(self, obj):
        self.objects[obj.id_object] = obj

    # Returns the list of Object refs
    @dclayMethod(return_='list<str>')
    def get_objects_refs(self):
        return self.objects_refs

    # Returns the list of Object ids
    @dclayMethod(return_='list<str>')
    def get_objects_ids(self):
        return self.objects.keys()

    @dclayMethod(num_events_per_obj='int', id_object='str', obj_class='str',
                 x='int', y='int', w='int',h='int', vel_pred='anything', yaw_pred='anything',
                 lon='anything', lat='anything',
                 kb='test_namespace.elastic.DKB')
    def add_events_from_trackers(self, num_events_per_obj: int, id_object: str, obj_class: str, x: int, y: int, w: int, h: int, vel_pred: float, yaw_pred: float,
                                 lon: float, lat: float, kb):
        import uuid
        for i in range(num_events_per_obj):
            obj = kb.get_or_create(id_object, obj_class, x, y, w, h, self.timestamp + i)
            event = Event(uuid.uuid4().int, obj, self.timestamp + i, vel_pred, yaw_pred, float(lon), float(lat))
            obj.add_event(event)
            if obj.id_object not in self.objects:
                self.objects[obj.id_object] = obj

    @dclayMethod()
    def when_unfederated(self):
        pass
        #kb = DKB.get_by_alias("DKB")
        #kb.remove_events_snapshot(self)

    @dclayMethod(kb='test_namespace.elastic.DKB')
    def delete(self, kb):
        self.unfederate()
        kb.remove_events_snapshot(self.timestamp)
        self.session_detach()

    @dclayMethod(return_='str')
    def __repr__(self):
        return f"Events Snapshot: \n\tobjects: {self.objects}, \n\tobjects_refs: {self.objects_refs}, \n\tsnap_alias: " \
               f"{self.snap_alias}, timestamp: {self.timestamp}"


    @dclayMethod()
    def when_federated(self):
        try:
            kb = DKB.get_by_alias("DKB")
            kb.add_events_snapshot(self)
        except Exception:
            traceback.print_exc()

"""
Object: Vehicle or Pedestrian detected
        Objects are classified by type: Pedestrian, Bicycle, Car, Track, ...
        Only if it is not a pedestrian, the values speed and yaw are set.
"""
class DetectedObject(DataClayObject):
    """
    @ClassField id_object str
    @ClassField type str
    @ClassField events_history dict<int, test_namespace.elastic.Event>
    @ClassField pixel_x int
    @ClassField pixel_y int
    @ClassField pixel_w int
    @ClassField pixel_h int
    """

    @dclayMethod(id_object='str', obj_type='str', timestamp='int', x='int', y='int', w='int', h='int')
    def __init__(self, id_object: str, obj_type: str, timestamp: int, x: int, y: int, w: int, h: int):
        self.id_object = id_object
        self.type = obj_type
        self.events_history = dict()
        self.pixel_x = x
        self.pixel_y = y
        self.pixel_w = w
        self.pixel_h = h

    @dclayMethod(event='test_namespace.elastic.Event')
    def add_event(self, event):
        # self.events_history.append(event)
        self.events_history[event.timestamp] = event

    @dclayMethod()
    def delete(self):
        for event in self.events_history.values():
            event.delete() 
        self.session_detach()
"""
Event: Instantiation of an Object for a given position and time.
"""
class Event(DataClayObject):
    """
    @ClassField id_event int
    @ClassField detected_object test_namespace.elastic.DetectedObject
    @ClassField timestamp int
    @ClassField speed anything
    @ClassField yaw anything
    @ClassField longitude_pos anything
    @ClassField latitude_pos anything
    """
    @dclayMethod(id_event='int', detected_object='test_namespace.elastic.DetectedObject', timestamp='int', speed='anything',
                 yaw='anything', longitude_pos='anything', latitude_pos='anything')
    def __init__(self, id_event: int, detected_object, timestamp: int, speed: float, yaw: float, longitude_pos: float, latitude_pos: float):
        self.id_event = id_event
        #FIXME: gc distributed bug
        #self.detected_object = detected_object
        self.timestamp = timestamp
        self.speed = speed
        self.yaw = yaw
        self.longitude_pos = longitude_pos
        self.latitude_pos = latitude_pos

    @dclayMethod()
    def delete(self):
        self.session_detach()