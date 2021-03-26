Feature: Dynamicity

  Background: dataClay deployment
    Given "UserA" has a configuration file "resources/common/cfgfiles/client.properties" to be used to connect to dataClay
      And "UserA" has a session file "resources/common/cfgfiles/session.properties" to be used in test application
      And "UserA" sets environment variable "GLOBALGC_COLLECTOR_INITIAL_DELAY_HOURS" to "0"
      And "UserA" sets environment variable "GLOBALGC_MAX_TIME_QUARANTINE" to "0"
      And "UserA" sets environment variable "GLOBALGC_CHECK_REMOTE_PENDING" to "500"
      And "UserA" sets environment variable "GLOBALGC_PROCESS_COUNTINGS_INTERVAL" to "200"
      And "UserA" sets environment variable "GLOBALGC_COLLECT_TIME_INTERVAL" to "2000"
      And "UserA" sets environment variable "GLOBALGC_MAX_OBJECTS_TO_COLLECT_ITERATION" to "1000"
      And "UserA" sets environment variable "MEMMGMT_CHECK_TIME_INTERVAL" to "200"
      And "UserA" sets environment variable "MEMMGMT_PRESSURE_FRACTION" to "0.0"
      And "UserA" sets environment variable "MEMMGMT_MIN_OBJECT_TIME" to "200"
      And "UserA" deploys dataClay with docker-compose.yml file "resources/garbage-collection/docker-compose.yml"
      And "UserA" waits until dataClay has 1 backends of "java" language
      And "UserA" waits until dataClay has 1 backends of "python" language
      And "UserA" creates an account named "UserA" with password "UserA"
      And "UserA" creates a dataset named "datasetA"
      And "UserA" creates a namespace named "test_namespace"
      And "UserA" creates a datacontract allowing access to dataset "datasetA" to user "UserA"
      And "UserA" registers a model located at "resources/common/model" into namespace "test_namespace"
      And "UserA" get stubs from namespace "test_namespace" into "stubs" directory
      
  Scenario: collect an unreferenced object
    Given "UserA" starts a new session
      And "UserA" creates "obj_a" object of class "ObjectA"
      And "UserA" runs make persistent for object "obj_a"
      And "UserA" gets id of "obj_a" object into "oid_a" variable
     When "UserA" finishes the session
     Then "UserA" starts a new session
      And "UserA" waits 10 seconds
      And "UserA" checks that object with id "oid_a" does not exist in dataClay
      And "UserA" finishes the session

  Scenario: collect an object with deleted alias
    Given "UserA" starts a new session
      And "UserA" creates "obj_a" object of class "ObjectA"
      And "UserA" runs make persistent for object "obj_a" with alias = "myobj"
      And "UserA" gets id of "obj_a" object into "oid_a" variable
     When "UserA" deletes alias "myobj"
      And "UserA" finishes the session
     Then "UserA" starts a new session
      And "UserA" waits 10 seconds
      And "UserA" checks that object with id "oid_a" does not exist in dataClay
      And "UserA" finishes the session

  Scenario: recursive collection
    Given "UserA" starts a new session
      And "UserA" creates "obj_a" object of class "ObjectA"
      And "UserA" creates "obj_b" object of class "ObjectB"
      And "UserA" runs "setObjectB" method with params "obj_b" in object "obj_a"
      And "UserA" runs make persistent for object "obj_a"
      And "UserA" gets id of "obj_a" object into "oid_a" variable
      And "UserA" gets id of "obj_b" object into "oid_b" variable
      And "UserA" finishes the session
     Then "UserA" starts a new session
      And "UserA" waits 10 seconds
      And "UserA" checks that object with id "oid_a" does not exist in dataClay
      And "UserA" checks that object with id "oid_b" does not exist in dataClay
      And "UserA" finishes the session

  Scenario: collect unassociated object
    Given "UserA" starts a new session
      And "UserA" creates "obj_a" object of class "ObjectA"
      And "UserA" creates "obj_b" object of class "ObjectB"
      And "UserA" runs "setObjectB" method with params "obj_b" in object "obj_a"
      And "UserA" runs make persistent for object "obj_a" with alias = "myobj"
      And "UserA" gets id of "obj_a" object into "oid_a" variable
      And "UserA" gets id of "obj_b" object into "oid_b" variable
      And "UserA" runs "setObjectB" method with params "null" in object "obj_a"
      And "UserA" finishes the session
     Then "UserA" starts a new session
      And "UserA" waits 10 seconds
      And "UserA" checks that object with id "oid_a" exists in dataClay
      And "UserA" checks that object with id "oid_b" does not exist in dataClay
      And "UserA" finishes the session


  Scenario: collect unreferenced cyclic objects
    Given "UserA" starts a new session
      And "UserA" creates "obj_a" object of class "ObjectA"
      And "UserA" creates "obj_b" object of class "ObjectB"
      And "UserA" runs "setObjectB" method with params "obj_b" in object "obj_a"
      And "UserA" runs "setObjectA" method with params "obj_a" in object "obj_b"
      And "UserA" gets id of "obj_a" object into "oid_a" variable
      And "UserA" gets id of "obj_b" object into "oid_b" variable
      And "UserA" finishes the session
     Then "UserA" starts a new session
      And "UserA" waits 10 seconds
      And "UserA" checks that object with id "oid_a" does not exist in dataClay
      And "UserA" checks that object with id "oid_b" does not exist in dataClay
      And "UserA" finishes the session

  Scenario: collect unreferenced objects in different backends
    Given "UserA" starts a new session
      And "UserA" creates "obj_a" object of class "ObjectA"
      And "UserA" creates "obj_b" object of class "ObjectB"
      And "UserA" creates "obj_a_cycle" object of class "ObjectA"
      And "UserA" creates "obj_b_cycle" object of class "ObjectB"
      And "UserA" creates "obj_a_retained" object of class "ObjectA"
      And "UserA" creates "obj_b_retained" object of class "ObjectB"
      And "UserA" runs make persistent for object "obj_a" with backend name = "DS1"
      And "UserA" runs make persistent for object "obj_b" with backend name = "DS2"
      And "UserA" runs make persistent for object "obj_a_cycle" with backend name = "DS1"
      And "UserA" runs make persistent for object "obj_b_cycle" with backend name = "DS2"
      And "UserA" runs make persistent for object "obj_a_retained" with alias = "myobja", backend name = "DS1" and recursive = "True"
      And "UserA" runs make persistent for object "obj_b_retained" with backend name = "DS2"
      And "UserA" runs "setObjectB" method with params "obj_b" in object "obj_a"
      And "UserA" runs "setObjectB" method with params "obj_b_cycle" in object "obj_a"
      And "UserA" runs "setObjectB" method with params "obj_b_retained" in object "obj_a_retained"
      And "UserA" runs "setObjectA" method with params "obj_a_cycle" in object "obj_b"
      And "UserA" gets id of "obj_a" object into "oid_a" variable
      And "UserA" gets id of "obj_b" object into "oid_b" variable
      And "UserA" gets id of "obj_a_cycle" object into "oid_a_cycle" variable
      And "UserA" gets id of "obj_b_cycle" object into "oid_b_cycle" variable
      And "UserA" gets id of "obj_a_retained" object into "oid_a_retained" variable
      And "UserA" gets id of "obj_b_retained" object into "oid_b_retained" variable
      And "UserA" finishes the session
     Then "UserA" starts a new session
      And "UserA" waits 10 seconds
      And "UserA" checks that object with id "oid_a" does not exists in dataClay
      And "UserA" checks that object with id "oid_b" does not exist in dataClay
      And "UserA" checks that object with id "oid_a_cycle" does not exists in dataClay
      And "UserA" checks that object with id "oid_b_cycle" does not exist in dataClay
      And "UserA" checks that object with id "oid_a_retained" exists in dataClay
      And "UserA" checks that object with id "oid_b_retained" exists in dataClay
      And "UserA" finishes the session

  #Scenario: collect an unfederated object

  #Scenario: collect versions after consolidate

  Scenario: collect an object using user hint
    Given "UserA" starts a new session
      And "UserA" creates "obj_a" object of class "ObjectA"
      And "UserA" runs make persistent for object "obj_a"
      And "UserA" gets id of "obj_a" object into "oid_a" variable
     When "UserA" detaches object "obj_a" from session
      And "UserA" waits 10 seconds
     Then "UserA" checks that object with id "oid_a" does not exist in dataClay
      And "UserA" finishes the session