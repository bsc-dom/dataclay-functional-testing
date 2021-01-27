Feature: Dynamicity

  Background: dataClay deployment
    Given "UserA" has a configuration file "resources/federation/machine-a/cfgfiles/client.properties" to be used to connect to dataClay
      And "UserA" has a session file "resources/federation/machine-a/cfgfiles/session.properties" to be used in test application
      And "UserA" deploys dataClay with docker-compose.yml file "resources/federation/machine-a/docker-compose.yml"
      And "UserA" waits until dataClay has 1 backends of "java" language
      And "UserA" waits until dataClay has 1 backends of "python" language
      And "UserA" creates an account named "UserA" with password "UserA"
      And "UserA" creates a dataset named "datasetA"
      And "UserA" creates a namespace named "test_namespace"
      And "UserA" creates a datacontract allowing access to dataset "datasetA" to user "UserA"
      And "UserA" registers a model located at "resources/common/model" into namespace "test_namespace"
      And "UserA" get stubs from namespace "test_namespace" into "stubs/userA" directory
      And "UserB" has a configuration file "resources/federation/machine-b/cfgfiles/client.properties" to be used to connect to dataClay
      And "UserB" has a session file "resources/federation/machine-b/cfgfiles/session.properties" to be used in test application
      And "UserB" deploys dataClay with docker-compose.yml file "resources/federation/machine-b/docker-compose.yml"
      And "UserB" waits until dataClay has 1 backends of "java" language
      And "UserB" waits until dataClay has 1 backends of "python" language
      And "UserB" creates an account named "UserB" with password "UserB"
      And "UserB" creates a dataset named "datasetB"
      And "UserB" creates a datacontract allowing access to dataset "datasetB" to user "UserB"
      And "UserB" registers external dataClay with hostname "logicmoduleA" and port 12034
      And "UserB" imports models in namespace "test_namespace" from dataClay at hostname "logicmoduleA" and port 12034
      And "UserB" get stubs from namespace "test_namespace" into "stubs/userB" directory

  Scenario: federates an object with alias
    Given "UserB" starts a new session
      And "UserB" runs make persistent for an object with alias "myobj"
      And "UserB" gets ID of external dataClay named "dataClayA" at hostname "logicmoduleA" and port 12034
      And "UserB" federates object to dataClay "dataClayA"
      And "UserB" finishes the session
      And "UserA" starts a new session
     Then "UserA" gets the object with alias "myobj"
      And "UserA" finishes the session
   