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
      And "UserA" creates "obj_person" object of class "Person" with constructor params "Bob 33"
      And "UserA" runs make persistent for object "obj_person"
     When "UserA" creates "obj_version_person" object as a version of "obj_person" object
      And "UserA" runs "setName" method with params "BobVersion" in object "obj_version_person"
      And "UserA" runs "getName" method in object "obj_person" and checks that result is "Bob"
     Then "UserA" consolidates "obj_version_person" version object
      And "UserA" runs "getName" method in object "obj_person" and checks that result is "BobVersion"
      And "UserA" finishes the session

  Scenario: create version of version and consolidate
    Given "UserA" starts a new session
      And "UserA" creates "obj_person" object of class "Person" with constructor params "Bob 33"
      And "UserA" runs make persistent for object "obj_person"
     When "UserA" creates "obj_version_person" object as a version of "obj_person" object
      And "UserA" runs "setName" method with params "BobVersion" in object "obj_version_person"
      And "UserA" runs "getName" method in object "obj_person" and checks that result is "Bob"
      And "UserA" creates "obj_version_person2" object as a version of "obj_version_person" object
      And "UserA" runs "setName" method with params "BobVersion2" in object "obj_version_person2"
      And "UserA" runs "getName" method in object "obj_version_person" and checks that result is "BobVersion"
     Then "UserA" consolidates "obj_version_person2" version object
      And "UserA" runs "getName" method in object "obj_person" and checks that result is "BobVersion2"
      And "UserA" finishes the session