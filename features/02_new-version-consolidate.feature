Feature: New version and Consolidate

  Background: dataClay deployment
    Given "UserA" has a configuration file "resources/common/cfgfiles/client.properties" to be used to connect to dataClay
      And "UserA" has a session file "resources/common/cfgfiles/session.properties" to be used in test application
      And "UserA" deploys dataClay with docker-compose.yml file "resources/new-version-consolidate/docker-compose.yml"
      And "UserA" waits until dataClay has 2 backends of "java" language
      And "UserA" waits until dataClay has 2 backends of "python" language
      And "UserA" creates an account named "UserA" with password "UserA"
      And "UserA" creates a dataset named "datasetA"
      And "UserA" creates a namespace named "test_namespace"
      And "UserA" creates a datacontract allowing access to dataset "datasetA" to user "UserA"
      And "UserA" registers a model located at "resources/common/model" into namespace "test_namespace"
      And "UserA" get stubs from namespace "test_namespace" into "stubs" directory
      
  Scenario: create new version and consolidate
    Given "UserA" starts a new session
      And "UserA" runs make persistent for an object
     When "UserA" creates new version of the object in backend "DS2"
      And "UserA" updates the version object
      And "UserA" checks that the original object was not modified
     Then "UserA" consolidates the version
      And "UserA" checks that the original object was modified
      And "UserA" finishes the session
