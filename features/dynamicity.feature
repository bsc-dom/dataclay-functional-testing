Feature: Dynamicity

  Background: dataClay deployment
    Given "User A" has a configuration file "resources/common/cfgfiles/client.properties" to be used to connect to dataClay
      And "User A" has a session file "resources/common/cfgfiles/session.properties" to be used in test application
      And "User A" deploys dataClay with docker-compose.yml file "resources/dynamicity/docker-compose.yml"
      And "User A" creates an account named "UserA" with password "UserA"
      And "User A" creates a dataset named "datasetA"
      And "User A" creates a namespace named "test_namespace"
      And "User A" creates a datacontract allowing access to dataset "datasetA" to user "UserA"
      And "User A" registers a model located at "resources/common/model" into namespace "test_namespace"
      And "User A" get stubs from namespace "test_namespace" into "stubs" directory
      
  Scenario: add a node
    Given "User A" starts extra nodes using "resources/dynamicity/docker-compose-extra.yml"
      And "User A" waits until dataClay has "2" backends
      And "User A" starts a new session
      And "User A" runs make persistent for an object
      And "User A" sets object to be read only
     When "User A" calls new replica
     Then "User A" gets object locations and sees object is located in two locations
      And "User A" finishes the session
   