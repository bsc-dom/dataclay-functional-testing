Feature: Dynamicity

  Background: dataClay deployment
    Given "UserA" has a configuration file "resources/common/cfgfiles/client.properties" to be used to connect to dataClay
      And "UserA" has a session file "resources/common/cfgfiles/session.properties" to be used in test application
      And "UserA" deploys dataClay with docker-compose.yml file "resources/dynamicity/docker-compose.yml"
      And "UserA" waits until dataClay has 1 backends of "java" language
      And "UserA" waits until dataClay has 1 backends of "python" language
      And "UserA" creates an account named "UserA" with password "UserA"
      And "UserA" creates a dataset named "datasetA"
      And "UserA" creates a namespace named "test_namespace"
      And "UserA" creates a datacontract allowing access to dataset "datasetA" to user "UserA"
      And "UserA" registers a model located at "resources/common/model" into namespace "test_namespace"
      And "UserA" get stubs from namespace "test_namespace" into "stubs" directory
      
  Scenario: add a node
    Given "UserA" starts extra nodes using "resources/dynamicity/docker-compose-extra.yml"
      And "UserA" waits until dataClay has 2 backends of "java" language
      And "UserA" waits until dataClay has 2 backends of "python" language
      And "UserA" starts a new session
      And "UserA" creates "obj_person" object of class "Person" with constructor params "Bob 33"
      And "UserA" runs make persistent for object "obj_person" with backend name = "DS1"
      And "UserA" runs "getName" method in object "obj_person" and checks that result is "Bob"
      And "UserA" runs "getAge" method in object "obj_person" and checks that result is "33"
      And "UserA" sets "obj_person" object to be read only
     When "UserA" calls new replica for object "obj_person"
     Then "UserA" gets id of "DS1" backend into "execid_DS2" variable
      And "UserA" calls get all locations for object "obj_person" and check object is located in 2 locations
      And "UserA" calls get all locations for object "obj_person" and check object is located in "execid_DS2" location
      And "UserA" finishes the session