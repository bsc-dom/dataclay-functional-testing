Feature: Make persistent

  Background: dataClay deployment
    Given "UserA" has a configuration file "resources/common/cfgfiles/client.properties" to be used to connect to dataClay
      And "UserA" has a session file "resources/common/cfgfiles/session.properties" to be used in test application
      And "UserA" deploys dataClay with docker-compose.yml file "resources/makepersistent/docker-compose.yml"
      And "UserA" waits until dataClay has 1 backends of "java" language
      And "UserA" waits until dataClay has 1 backends of "python" language
      And "UserA" creates an account named "UserA" with password "UserA"
      And "UserA" creates a dataset named "datasetA"
      And "UserA" creates a namespace named "test_namespace"
      And "UserA" creates a datacontract allowing access to dataset "datasetA" to user "UserA"
      And "UserA" registers a model located at "resources/common/model" into namespace "test_namespace"
      And "UserA" get stubs from namespace "test_namespace" into "stubs" directory


  Scenario: run a simple make persistent
    Given "UserA" starts a new session
     Then "UserA" creates "obj_person" object of class "Person" with constructor params "Bob 33"
      And "UserA" runs make persistent for object "obj_person"
      And "UserA" runs "getName" method in object "obj_person" and checks that result is "Bob"
      And "UserA" runs "getAge" method in object "obj_person" and checks that result is "33"
      And "UserA" finishes the session

  Scenario: run make persistent into backend
    Given "UserA" starts a new session
     Then "UserA" creates "obj_person" object of class "Person" with constructor params "Bob 33"
      And "UserA" runs make persistent for object "obj_person"
      And "UserA" runs "getName" method in object "obj_person" and checks that result is "Bob"
      And "UserA" runs "getAge" method in object "obj_person" and checks that result is "33"
      And "UserA" finishes the session

  #Scenario: run a LOCAL make persistent
  #  Given I start a new session
  #   Then I run a LOCAL make persistent for an object 
  #    And I finish the session   
   