Feature: New replica

  Background: dataClay deployment
    Given "User A" has a configuration file "resources/common/cfgfiles/client.properties" to be used to connect to dataClay
      And "User A" has a session file "resources/common/cfgfiles/session.properties" to be used in test application
      And "User A" creates a docker network named "dataclay-testing-network"
      And "User A" connect to docker network "dataclay-testing-network"
      And "User A" deploys dataClay with docker-compose.yml file "resources/new-replica/docker-compose.yml"
      And "User A" waits until dataClay has 2 backends of "java" language
      And "User A" waits until dataClay has 2 backends of "python" language
      And "User A" creates an account named "UserA" with password "UserA"
      And "User A" creates a dataset named "datasetA"
      And "User A" creates a namespace named "test_namespace"
      And "User A" creates a datacontract allowing access to dataset "datasetA" to user "UserA"
      And "User A" registers a model located at "resources/common/model" into namespace "test_namespace"
      And "User A" get stubs from namespace "test_namespace" into "stubs" directory
      
  Scenario: replica an object
    Given "User A" starts a new session
     Then "User A" runs make persistent for an object
      And "User A" sets object to be read only
     When "User A" calls new replica
     Then "User A" gets object locations and sees object is located in two locations
      And "User A" finishes the session
      And "User A" disconnects from docker network "dataclay-testing-network"
      And "User A" removes docker network named "dataclay-testing-network"
