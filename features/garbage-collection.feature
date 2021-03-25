Feature: Dynamicity

  Background: dataClay deployment
    Given "UserA" has a configuration file "resources/common/cfgfiles/client.properties" to be used to connect to dataClay
      And "UserA" has a session file "resources/common/cfgfiles/session.properties" to be used in test application
      And "UserA" sets environment variable "GLOBALGC_COLLECTOR_INITIAL_DELAY_HOURS" to "0"
      And "UserA" sets environment variable "GLOBALGC_MAX_TIME_QUARANTINE" to "0"
      And "UserA" sets environment variable "GLOBALGC_CHECK_REMOTE_PENDING" to "500"
      And "UserA" sets environment variable "GLOBALGC_PROCESS_COUNTINGS_INTERVAL" to "200"
      And "UserA" sets environment variable "GLOBALGC_COLLECT_TIME_INTERVAL" to "2000"

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
      And "UserA" creates "obj_person" object of class "Person" with constructor params "Bob 33"
      And "UserA" runs make persistent for object "obj_person" with backend name = "DS1"
      And "UserA" gets id of "obj_person" object into "oid_person" variable
     When "UserA" finishes the session
     Then "UserA" starts a new session
      And "UserA" waits 10 seconds
      And "UserA" checks that object with id "oid_person" does not exist in dataClay
      And "UserA" finishes the session

  Scenario: collect an object with deleted alias

  Scenario: collect an unassociated object

  Scenario: collect unreferenced cyclic objects

  Scenario: collect unreferenced objects in different backends

  Scenario: collect an unfederated object

  Scenario: collect versions after consolidate

  Scenario: collect an object using user hint