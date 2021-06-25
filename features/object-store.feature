Feature: Object Store

  Background: dataClay deployment
    Given "UserA" has a configuration file "resources/common/cfgfiles/client.properties" to be used to connect to dataClay
      And "UserA" has a session file "resources/common/cfgfiles/session.properties" to be used in test application
      And "UserA" deploys dataClay with docker-compose.yml file "resources/object-store/docker-compose.yml"
      And "UserA" waits until dataClay has 1 backends of "java" language
      And "UserA" waits until dataClay has 1 backends of "python" language
      And "UserA" creates an account named "UserA" with password "UserA"
      And "UserA" creates a dataset named "datasetA"
      And "UserA" creates a namespace named "test_namespace"
      And "UserA" creates a datacontract allowing access to dataset "datasetA" to user "UserA"
      And "UserA" registers a model located at "resources/common/model" into namespace "test_namespace"
      And "UserA" get stubs from namespace "test_namespace" into "stubs" directory


  Scenario: run a simple dcPut
    Given "UserA" starts a new session
      And "UserA" creates "obj_person" object of class "Person" with constructor params "Bob 33"
     Then "UserA" runs dcPut for object "obj_person" with alias "myperson"
      And "UserA" runs "getName" method in object "obj_person" and checks that result is "Bob"
      And "UserA" runs "getAge" method in object "obj_person" and checks that result is "33"
      And "UserA" finishes the session

  Scenario: run dcPut into backend
    Given "UserA" starts a new session
      And "UserA" creates "obj_person" object of class "Person" with constructor params "Bob 33"
     Then "UserA" runs dcPut for object "obj_person" with alias = "myperson" and backend name = "DS1"
      And "UserA" runs "getName" method in object "obj_person" and checks that result is "Bob"
      And "UserA" runs "getAge" method in object "obj_person" and checks that result is "33"
      And "UserA" finishes the session

  Scenario: run a simple dcUpdate
    Given "UserA" starts a new session
     And "UserA" creates "obj_person" object of class "Person" with constructor params "Bob 33"
     And "UserA" runs dcPut for object "obj_person" with alias "myperson"
     And "UserA" creates "obj_person_update" object of class "Person" with constructor params "John 55"
    Then "UserA" runs dcUpdate in object "obj_person" with "obj_person_update" parameter
     And "UserA" runs "getName" method in object "obj_person" and checks that result is "John"
     And "UserA" runs "getAge" method in object "obj_person" and checks that result is "55"
     And "UserA" finishes the session

  Scenario: run a simple dcClone
    Given "UserA" starts a new session
     And "UserA" creates "obj_person" object of class "Person" with constructor params "Bob 33"
     And "UserA" runs dcPut for object "obj_person" with alias "myperson"
    Then "UserA" runs dcClone in object "obj_person" and store result into "obj_clon_person"
     And "UserA" runs "getName" method in object "obj_clon_person" and checks that result is "Bob"
     And "UserA" runs "getAge" method in object "obj_clon_person" and checks that result is "33"
     And "UserA" finishes the session