Feature: New replica

  Background: dataClay deployment
    Given "UserA" has a configuration file "resources/common/cfgfiles/client.properties" to be used to connect to dataClay
      And "UserA" has a session file "resources/common/cfgfiles/session.properties" to be used in test application
      And "UserA" deploys dataClay with docker-compose.yml file "resources/new-replica/docker-compose.yml"
      And "UserA" waits until dataClay has 2 backends of "java" language
      And "UserA" waits until dataClay has 2 backends of "python" language
      And "UserA" creates an account named "UserA" with password "UserA"
      And "UserA" creates a dataset named "datasetA"
      And "UserA" creates a namespace named "test_namespace"
      And "UserA" creates a datacontract allowing access to dataset "datasetA" to user "UserA"
      And "UserA" registers a model located at "resources/common/model" into namespace "test_namespace"
      And "UserA" get stubs from namespace "test_namespace" into "stubs" directory
      
  Scenario: replica an object
    Given "UserA" starts a new session
     Then "UserA" runs make persistent for an object
      And "UserA" sets object to be read only
     When "UserA" calls new replica
     Then "UserA" gets object locations and sees object is located in two locations
      And "UserA" finishes the session
