Feature: Garbage Collection

  Background: dataClay deployment
    Given "UserA" has a configuration file "resources/garbage-collection/machine-a/cfgfiles/client.properties" to be used to connect to dataClay
      And "UserA" has a session file "resources/garbage-collection/machine-a/cfgfiles/session.properties" to be used in test application
      And "UserA" sets environment variable "GLOBALGC_COLLECTOR_INITIAL_DELAY_HOURS" to "0"
      And "UserA" sets environment variable "GLOBALGC_MAX_TIME_QUARANTINE" to "0"
      And "UserA" sets environment variable "GLOBALGC_CHECK_REMOTE_PENDING" to "1000"
      And "UserA" sets environment variable "GLOBALGC_PROCESS_COUNTINGS_INTERVAL" to "200"
      And "UserA" sets environment variable "GLOBALGC_COLLECT_TIME_INTERVAL" to "5000"
      And "UserA" sets environment variable "GLOBALGC_MAX_OBJECTS_TO_COLLECT_ITERATION" to "1000"
      And "UserA" sets environment variable "MEMMGMT_CHECK_TIME_INTERVAL" to "1000"
      And "UserA" sets environment variable "MEMMGMT_PRESSURE_FRACTION" to "0.0"
      And "UserA" sets environment variable "MEMMGMT_MIN_OBJECT_TIME" to "500"
      And "UserA" sets environment variable "MEMMGMT_EASE_FRACTION" to "0.0"
      And "UserA" deploys dataClay with docker-compose.yml file "resources/garbage-collection/machine-a/docker-compose.yml"
      And "UserA" waits until dataClay has 2 backends of "java" language
      And "UserA" waits until dataClay has 2 backends of "python" language
      And "UserA" creates an account named "UserA" with password "UserA"
      And "UserA" creates a dataset named "datasetA"
      And "UserA" creates a namespace named "test_namespace"
      And "UserA" creates a datacontract allowing access to dataset "datasetA" to user "UserA"
      And "UserA" registers a model located at "resources/common/model" into namespace "test_namespace"
      And "UserA" get stubs from namespace "test_namespace" into "stubs/userA" directory

  Scenario: collect an unreferenced object
    Given "UserA" starts a new session
      And "UserA" creates "obj_a" object of class "NodeA"
      And "UserA" runs make persistent for object "obj_a"
      And "UserA" gets id of "obj_a" object into "oid_a" variable
      And "UserA" checks that object with id "oid_a" exists in dataClay
      # wait to check number of objects to avoid checking it while objects are being flushed
      And "UserA" waits 60 seconds
      And "UserA" checks that number of objects in dataClay is 1
     When "UserA" finishes the session
     Then "UserA" starts a new session
      And "UserA" waits 60 seconds
      And "UserA" checks that object with id "oid_a" does not exist in dataClay
      And "UserA" checks that number of objects in dataClay is 0
      And "UserA" finishes the session

  Scenario: collect big unreferenced object
    Given "UserA" starts a new session
      And "UserA" creates "obj_a" object of class "BigObject"
      And "UserA" creates "obj_b" object of class "LotsOfObjects"
      And "UserA" runs make persistent for object "obj_a"
      And "UserA" runs make persistent for object "obj_b"
      And "UserA" gets id of "obj_a" object into "oid_a" variable
      And "UserA" gets id of "obj_a" object into "oid_b" variable
      And "UserA" checks that object with id "oid_a" exists in dataClay
      And "UserA" checks that object with id "oid_b" exists in dataClay
     When "UserA" finishes the session
     Then "UserA" starts a new session
      And "UserA" waits 150 seconds
      And "UserA" checks that object with id "oid_a" does not exist in dataClay
      And "UserA" checks that object with id "oid_b" does not exist in dataClay
      And "UserA" checks that number of objects in dataClay is 0
      And "UserA" finishes the session

  Scenario: collect an object with deleted alias
    Given "UserA" starts a new session
      And "UserA" creates "obj_a" object of class "NodeA"
      And "UserA" runs make persistent for object "obj_a" with alias = "myobj"
      And "UserA" gets id of "obj_a" object into "oid_a" variable
      And "UserA" finishes the session
      And "UserA" starts a new session
      And "UserA" waits 100 seconds
      And "UserA" checks that object with id "oid_a" exists in dataClay
     When "UserA" deletes alias "myobj" from object "obj_a"
      And "UserA" finishes the session
     Then "UserA" starts a new session
      And "UserA" waits 100 seconds
      And "UserA" checks that object with id "oid_a" does not exist in dataClay
      And "UserA" finishes the session

  Scenario: recursive collection
    Given "UserA" starts a new session
      And "UserA" creates "obj_a" object of class "NodeA"
      And "UserA" creates "obj_b" object of class "NodeB"
      And "UserA" runs "setNodeB" method with params "obj_b" in object "obj_a"
      And "UserA" runs make persistent for object "obj_a"
      And "UserA" gets id of "obj_a" object into "oid_a" variable
      And "UserA" gets id of "obj_b" object into "oid_b" variable
      And "UserA" finishes the session
     Then "UserA" starts a new session
      And "UserA" waits 60 seconds
      And "UserA" checks that object with id "oid_a" does not exist in dataClay
      And "UserA" checks that object with id "oid_b" does not exist in dataClay
      And "UserA" finishes the session

  Scenario: collect unassociated object
    Given "UserA" starts a new session
      And "UserA" creates "obj_a" object of class "NodeA"
      And "UserA" creates "obj_b" object of class "NodeB"
      And "UserA" runs "setNodeB" method with params "obj_b" in object "obj_a"
      And "UserA" runs make persistent for object "obj_a" with alias = "myobj"
      And "UserA" gets id of "obj_a" object into "oid_a" variable
      And "UserA" gets id of "obj_b" object into "oid_b" variable
      And "UserA" finishes the session
      And "UserA" starts a new session
      And "UserA" waits 60 seconds
      And "UserA" checks that object with id "oid_a" exists in dataClay
      And "UserA" checks that object with id "oid_b" exists in dataClay
      And "UserA" runs "setNodeB" method with params "null" in object "obj_a"
      And "UserA" finishes the session
     Then "UserA" starts a new session
      And "UserA" waits 60 seconds
      And "UserA" checks that object with id "oid_a" exists in dataClay
      And "UserA" checks that object with id "oid_b" does not exist in dataClay
      And "UserA" finishes the session

  Scenario: collect unreferenced cyclic objects
    Given "UserA" starts a new session
      And "UserA" creates "obj_a" object of class "NodeA"
      And "UserA" creates "obj_b" object of class "NodeB"
      And "UserA" runs "setNodeB" method with params "obj_b" in object "obj_a"
      And "UserA" runs "setNodeA" method with params "obj_a" in object "obj_b"
      And "UserA" runs make persistent for object "obj_a"
      And "UserA" gets id of "obj_a" object into "oid_a" variable
      And "UserA" gets id of "obj_b" object into "oid_b" variable
      And "UserA" finishes the session
     Then "UserA" starts a new session
      And "UserA" waits 60 seconds
      And "UserA" checks that object with id "oid_a" does not exist in dataClay
      And "UserA" checks that object with id "oid_b" does not exist in dataClay
      And "UserA" finishes the session

  Scenario: collect unreferenced objects in different backends
    Given "UserA" starts a new session
      And "UserA" creates "obj_a" object of class "NodeA"
      And "UserA" creates "obj_b" object of class "NodeB"
      And "UserA" creates "obj_a_cycle" object of class "NodeA"
      And "UserA" creates "obj_b_cycle" object of class "NodeB"
      And "UserA" creates "obj_a_retained" object of class "NodeA"
      And "UserA" creates "obj_b_retained" object of class "NodeB"
      And "UserA" runs make persistent for object "obj_a" with backend name = "DS1"
      And "UserA" runs make persistent for object "obj_b" with backend name = "DS2"
      And "UserA" runs make persistent for object "obj_a_cycle" with backend name = "DS1"
      And "UserA" runs make persistent for object "obj_b_cycle" with backend name = "DS2"
      And "UserA" runs make persistent for object "obj_a_retained" with alias = "myobja", backend name = "DS1" and recursive = "True"
      And "UserA" runs make persistent for object "obj_b_retained" with backend name = "DS2"
      And "UserA" runs "setNodeB" method with params "obj_b" in object "obj_a"
      And "UserA" runs "setNodeB" method with params "obj_b_cycle" in object "obj_a_cycle"
      And "UserA" runs "setNodeB" method with params "obj_b_retained" in object "obj_a_retained"
      And "UserA" runs "setNodeA" method with params "obj_a_cycle" in object "obj_b_cycle"
      And "UserA" gets id of "obj_a" object into "oid_a" variable
      And "UserA" gets id of "obj_b" object into "oid_b" variable
      And "UserA" gets id of "obj_a_cycle" object into "oid_a_cycle" variable
      And "UserA" gets id of "obj_b_cycle" object into "oid_b_cycle" variable
      And "UserA" gets id of "obj_a_retained" object into "oid_a_retained" variable
      And "UserA" gets id of "obj_b_retained" object into "oid_b_retained" variable
      And "UserA" finishes the session
     Then "UserA" starts a new session
      And "UserA" waits 60 seconds
      And "UserA" checks that object with id "oid_a" does not exist in dataClay
      And "UserA" checks that object with id "oid_b" does not exist in dataClay
      And "UserA" checks that object with id "oid_a_cycle" does not exist in dataClay
      And "UserA" checks that object with id "oid_b_cycle" does not exist in dataClay
      And "UserA" checks that object with id "oid_a_retained" exists in dataClay
      And "UserA" checks that object with id "oid_b_retained" exists in dataClay
      And "UserA" finishes the session

  Scenario: collect an object detached from session
    Given "UserA" starts a new session
      And "UserA" creates "obj_a" object of class "NodeA"
      And "UserA" runs make persistent for object "obj_a"
      And "UserA" gets id of "obj_a" object into "oid_a" variable
     When "UserA" detaches object "obj_a" from session
      And "UserA" waits 60 seconds
     Then "UserA" checks that object with id "oid_a" does not exist in dataClay
      And "UserA" finishes the session

  Scenario: collect an unfederated object
    Given "UserB" has a configuration file "resources/garbage-collection/machine-b/cfgfiles/client.properties" to be used to connect to dataClay
      And "UserB" has a session file "resources/garbage-collection/machine-b/cfgfiles/session.properties" to be used in test application
      And "UserB" sets environment variable "GLOBALGC_COLLECTOR_INITIAL_DELAY_HOURS" to "0"
      And "UserB" sets environment variable "GLOBALGC_MAX_TIME_QUARANTINE" to "0"
      And "UserB" sets environment variable "GLOBALGC_CHECK_REMOTE_PENDING" to "1000"
      And "UserB" sets environment variable "GLOBALGC_PROCESS_COUNTINGS_INTERVAL" to "200"
      And "UserB" sets environment variable "GLOBALGC_COLLECT_TIME_INTERVAL" to "5000"
      And "UserB" sets environment variable "GLOBALGC_MAX_OBJECTS_TO_COLLECT_ITERATION" to "1000"
      And "UserB" sets environment variable "MEMMGMT_CHECK_TIME_INTERVAL" to "1000"
      And "UserB" sets environment variable "MEMMGMT_PRESSURE_FRACTION" to "0.0"
      And "UserB" sets environment variable "MEMMGMT_MIN_OBJECT_TIME" to "500"
      And "UserB" sets environment variable "MEMMGMT_EASE_FRACTION" to "0.0"
      And "UserB" deploys dataClay with docker-compose.yml file "resources/garbage-collection/machine-b/docker-compose.yml"
      And "UserB" waits until dataClay has 1 backends of "java" language
      And "UserB" waits until dataClay has 1 backends of "python" language
      And "UserB" creates an account named "UserB" with password "UserB"
      And "UserB" creates a dataset named "datasetB"
      And "UserB" creates a datacontract allowing access to dataset "datasetB" to user "UserB"
      And "UserB" registers external dataClay with hostname "logicmoduleA" and port 12034
      And "UserB" imports models in namespace "test_namespace" from dataClay at hostname "logicmoduleA" and port 12034
      And "UserB" get stubs from namespace "test_namespace" into "stubs/userB" directory
      And "UserB" starts a new session
      And "UserB" creates "obj_person" object of class "Person" with constructor params "Bob 33"
      And "UserB" runs make persistent for object "obj_person"
      And "UserB" gets id of "obj_person" object into "oid_person" variable
      And "UserB" gets ID of external dataClay at hostname "logicmoduleA" and port 12034 into "dataclayid_A" variable
      And "UserB" federates "obj_person" object to dataClay with ID "dataclayid_A"
      And "UserB" finishes the session
      And "UserB" starts a new session
      And "UserB" waits 100 seconds
      And "UserB" checks that object with id "oid_person" exists in dataClay
     When "UserB" unfederates "obj_person" object with dataClay with ID "dataclayid_A"
      And "UserB" finishes the session
      And "UserB" starts a new session
      And "UserB" waits 100 seconds
      And "UserB" checks that object with id "oid_person" does not exist in dataClay
      And "UserB" finishes the session

  @debugging
  Scenario: collect detached unreferenced cyclic objects in distributed environment
    Given "UserB" has a configuration file "resources/garbage-collection/machine-b/cfgfiles/client.properties" to be used to connect to dataClay
      And "UserB" has a session file "resources/garbage-collection/machine-b/cfgfiles/session.properties" to be used in test application
      And "UserB" sets environment variable "GLOBALGC_COLLECTOR_INITIAL_DELAY_HOURS" to "0"
      And "UserB" sets environment variable "GLOBALGC_MAX_TIME_QUARANTINE" to "0"
      And "UserB" sets environment variable "GLOBALGC_CHECK_REMOTE_PENDING" to "1000"
      And "UserB" sets environment variable "GLOBALGC_PROCESS_COUNTINGS_INTERVAL" to "200"
      And "UserB" sets environment variable "GLOBALGC_COLLECT_TIME_INTERVAL" to "5000"
      And "UserB" sets environment variable "GLOBALGC_MAX_OBJECTS_TO_COLLECT_ITERATION" to "1000"
      And "UserB" sets environment variable "MEMMGMT_CHECK_TIME_INTERVAL" to "1000"
      And "UserB" sets environment variable "MEMMGMT_PRESSURE_FRACTION" to "0.0"
      And "UserB" sets environment variable "MEMMGMT_MIN_OBJECT_TIME" to "100"
      And "UserB" sets environment variable "MEMMGMT_EASE_FRACTION" to "0.0"
      And "UserB" deploys dataClay with docker-compose.yml file "resources/garbage-collection/machine-b/docker-compose.yml"
      And "UserB" waits until dataClay has 1 backends of "java" language
      And "UserB" waits until dataClay has 1 backends of "python" language
      And "UserB" creates an account named "UserB" with password "UserB"
      And "UserB" creates a dataset named "datasetB"
      And "UserB" creates a datacontract allowing access to dataset "datasetB" to user "UserB"
      And "UserB" registers external dataClay with hostname "logicmoduleA" and port 12034
      And "UserB" imports models in namespace "test_namespace" from dataClay at hostname "logicmoduleA" and port 12034
      And "UserB" get stubs from namespace "test_namespace" into "stubs/userB" directory
      And "UserA" starts a new session
      And "UserA" creates "obj_dkb_a" object of class "elastic.DKB"
      And "UserA" runs make persistent for object "obj_dkb_a" with alias = "DKB", backend name = "DS1" and recursive = "True"
      And "UserA" gets id of "obj_dkb_a" object into "oid_dkb_a" variable
      And "UserA" finishes the session
      And "UserB" starts a new session
      And "UserB" creates "obj_dkb_b" object of class "elastic.DKB"
      And "UserB" runs make persistent for object "obj_dkb_b" with alias = "DKB", backend name = "DS1" and recursive = "True"
      And "UserB" gets id of "obj_dkb_b" object into "oid_dkb_b" variable
      And "UserB" gets ID of external dataClay at hostname "logicmoduleA" and port 12034 into "dataclayid_A" variable
      And "UserB" finishes the session
      And "UserA" starts a new session
      And "UserA" gets ID of external dataClay at hostname "logicmoduleB" and port 22034 into "dataclayid_B" variable
      # create snapshot
      And "UserA" creates "obj_snapshot_begin" object of class "elastic.Snapshot" with constructor params "snapshot_0"
      # TODO: create snapshot in DS2 for distribute events (DS2 with snapshot) and objects (DS1 with DKB)
      And "UserA" runs make persistent for object "obj_snapshot_begin" with backend name = "DS1"
      And "UserA" runs "add_events_snapshot" method with params "obj_snapshot_begin" in object "obj_dkb_a"
      And "UserA" runs "add_events_from_trackers" method with params "2 car_oid car 10 5 0 0 50.3 20.2 33.2 44.1 obj_dkb_a" in object "obj_snapshot_begin"
      # wait to check number of objects to avoid checking it while objects are being flushed: dkb, list, snapshot, 2 events, 1 object = 6 objs
      And "UserA" waits 100 seconds
      And "UserA" checks that number of objects in dataClay is 5
      # federate snapshot
      And "UserA" federates "obj_snapshot_begin" object to dataClay with ID "dataclayid_B"
      # remove old objects and snapshot
      And "UserA" runs "remove_old_objects_and_snapshots" method with params "100 True" in object "obj_dkb_a"
      And "UserA" waits 100 seconds
      And "UserA" checks that number of objects in dataClay is 1
      And "UserA" finishes the session
      # check objects were federated
      And "UserB" starts a new session
      And "UserB" checks that number of objects in dataClay is 5
      And "UserB" runs "remove_old_objects_and_snapshots" method with params "100 False" in object "obj_dkb_b"
      And "UserB" waits 100 seconds
      And "UserB" checks that number of objects in dataClay is 1
      And "UserB" finishes the session

  #Scenario: collect versions after consolidate
  #Scenario: collect all replicas
