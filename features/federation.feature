Feature: Federation

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
      And "UserB" waits until dataClay has 2 backends of "java" language
      And "UserB" waits until dataClay has 2 backends of "python" language
      And "UserB" creates an account named "UserB" with password "UserB"
      And "UserB" creates a dataset named "datasetB"
      And "UserB" creates a datacontract allowing access to dataset "datasetB" to user "UserB"
      And "UserB" registers external dataClay with hostname "logicmoduleA" and port 12034
      And "UserB" imports models in namespace "test_namespace" from dataClay at hostname "logicmoduleA" and port 12034
      And "UserB" get stubs from namespace "test_namespace" into "stubs/userB" directory
      And "UserC" has a configuration file "resources/federation/machine-c/cfgfiles/client.properties" to be used to connect to dataClay
      And "UserC" has a session file "resources/federation/machine-c/cfgfiles/session.properties" to be used in test application
      And "UserC" deploys dataClay with docker-compose.yml file "resources/federation/machine-c/docker-compose.yml"
      And "UserC" waits until dataClay has 1 backends of "java" language
      And "UserC" waits until dataClay has 1 backends of "python" language
      And "UserC" creates an account named "UserC" with password "UserC"
      And "UserC" creates a dataset named "datasetC"
      And "UserC" creates a datacontract allowing access to dataset "datasetC" to user "UserC"
      And "UserC" registers external dataClay with hostname "logicmoduleB" and port 22034
      And "UserC" imports models in namespace "test_namespace" from dataClay at hostname "logicmoduleB" and port 22034
      And "UserC" get stubs from namespace "test_namespace" into "stubs/userC" directory


  Scenario: federates an object with alias
    Given "UserA" starts a new session
      And "UserA" creates "obj_person" object of class "Person" with constructor params "Bob 33"
      And "UserA" runs make persistent for object "obj_person" with alias = "myobj"
      And "UserA" registers external dataClay with hostname "logicmoduleB" and port 22034
      And "UserA" gets ID of external dataClay at hostname "logicmoduleB" and port 22034 into "dataclayid_B" variable
     When "UserA" federates "obj_person" object to dataClay with ID "dataclayid_B"
      And "UserA" finishes the session
      And "UserB" starts a new session
     Then "UserB" creates "obj_federated_obj" of class "Person" using alias "myobj"
      And "UserB" finishes the session

  Scenario: unfederation of object with alias
    Given "UserA" starts a new session
      And "UserA" creates "obj_person" object of class "Person" with constructor params "Bob 33"
      And "UserA" runs make persistent for object "obj_person" with alias = "myobj"
      And "UserA" registers external dataClay with hostname "logicmoduleB" and port 22034
      And "UserA" gets ID of external dataClay at hostname "logicmoduleB" and port 22034 into "dataclayid_B" variable
      And "UserA" federates "obj_person" object to dataClay with ID "dataclayid_B"
      And "UserA" finishes the session
      And "UserB" starts a new session
     Then "UserB" creates "obj_federated_obj" of class "Person" using alias "myobj"
      And "UserB" finishes the session
      And "UserA" starts a new session
      And "UserA" creates "obj_person" of class "Person" using alias "myobj"
      And "UserA" unfederates "obj_person" object with dataClay with ID "dataclayid_B"
      And "UserA" finishes the session
      And "UserB" starts a new session
      And "UserB" checks that there is no object of class "Person" with alias "myobj"
      And "UserB" finishes the session


  Scenario: federation recursiveness
    Given "UserA" starts a new session
      And "UserA" creates "obj_person" object of class "Person" with constructor params "Bob 33"
      And "UserA" creates "obj_people" object of class "People"
      And "UserA" creates "obj_people_not_recu" object of class "People"
      And "UserA" runs make persistent for object "obj_person"
      And "UserA" runs make persistent for object "obj_people_not_recu" with alias = "people_not_recu"
      And "UserA" runs "add" method with params "obj_person" in object "obj_people"
      And "UserA" runs "add" method with params "obj_person" in object "obj_people_not_recu"
      And "UserA" runs make persistent for object "obj_people" with alias = "mypeople"
      And "UserA" registers external dataClay with hostname "logicmoduleB" and port 22034
      And "UserA" gets ID of external dataClay at hostname "logicmoduleB" and port 22034 into "dataclayid_B" variable
      And "UserA" gets ID of "DS1" backend from external dataClay with ID "dataclayid_B" into "execid_DS1_B" variable
     When "UserA" federates "obj_person" object to external dataClay backend with ID "execid_DS1_B"
      And "UserA" federates "obj_people" object to external dataClay backend with ID "execid_DS1_B"
      And "UserA" federates "obj_people_not_recu" object with recursive = "False" to external dataClay backend with ID "execid_DS1_B"
      And "UserA" finishes the session
      And "UserB" starts a new session
     Then "UserB" creates "obj_federated_people" of class "People" using alias "mypeople"
      And "UserB" creates "obj_federated_people_not_recu" of class "People" using alias "people_not_recu"
      And "UserB" runs "get" method with params "0" in object "obj_federated_people" and store result into "obj_federated_person" variable
      And "UserB" runs "getName" method in object "obj_federated_person" and checks that result is "Bob"
      And "UserB" runs "getAge" method in object "obj_federated_person" and checks that result is "33"
      And "UserB" runs "get" method with params "0" in object "obj_federated_people_not_recu" and store result into "obj_fed_person_not_recu" variable
      And "UserB" runs "getName" method in object "obj_fed_person_not_recu" and checks that result is "Bob"
      And "UserB" runs "getAge" method in object "obj_fed_person_not_recu" and checks that result is "33"
      And "UserB" finishes the session

  Scenario: refederation
    Given "UserA" starts a new session
      And "UserA" creates "obj_person" object of class "Person" with constructor params "Bob 33"
      And "UserA" runs make persistent for object "obj_person" with alias = "myobj"
      And "UserA" registers external dataClay with hostname "logicmoduleB" and port 22034
      And "UserA" gets ID of external dataClay at hostname "logicmoduleB" and port 22034 into "dataclayid_B" variable
      And "UserA" gets ID of "DS1" backend from external dataClay with ID "dataclayid_B" into "execid_DS1_B" variable
     When "UserA" federates "obj_person" object to external dataClay backend with ID "execid_DS1_B"
      And "UserA" finishes the session
      And "UserB" starts a new session
      And "UserB" creates "obj_federated_person" of class "Person" using alias "myobj"
      And "UserB" runs "getName" method in object "obj_federated_person" and checks that result is "Bob"
      And "UserB" runs "getAge" method in object "obj_federated_person" and checks that result is "33"
      And "UserB" registers external dataClay with hostname "logicmoduleC" and port 42034
      And "UserB" gets ID of external dataClay at hostname "logicmoduleA" and port 12034 into "dataclayid_A" variable
      And "UserB" gets ID of external dataClay at hostname "logicmoduleC" and port 42034 into "dataclayid_C" variable
      And "UserB" gets ID of "DS1" backend from external dataClay with ID "dataclayid_A" into "execid_DS1_A" variable
      And "UserB" gets ID of "DS1" backend from external dataClay with ID "dataclayid_C" into "execid_DS1_C" variable
      And "UserB" runs "replicaSourceIs" method with params "execid_DS1_A" in object "obj_federated_person" and checks that result is "True"
      And "UserB" runs "replicaDestIncludes" method with params "execid_DS1_C" in object "obj_federated_person" and checks that result is "False"
      And "UserB" federates "obj_federated_person" object to external dataClay backend with ID "execid_DS1_C"
     Then "UserB" runs "replicaDestIncludes" method with params "execid_DS1_C" in object "obj_federated_person" and checks that result is "True"
      And "UserB" finishes the session
      And "UserC" starts a new session
      And "UserC" gets ID of external dataClay at hostname "logicmoduleB" and port 22034 into "dataclayid_B" variable
      And "UserC" gets ID of "DS1" backend from external dataClay with ID "dataclayid_B" into "execid_DS1_B" variable
      And "UserC" creates "obj_federated_person_c" of class "Person" using alias "myobj"
      And "UserC" runs "getName" method in object "obj_federated_person_c" and checks that result is "Bob"
      And "UserC" runs "getAge" method in object "obj_federated_person_c" and checks that result is "33"
      And "UserC" runs "replicaSourceIs" method with params "execid_DS1_B" in object "obj_federated_person_c" and checks that result is "True"
      And "UserC" finishes the session

  @debugging
  Scenario: federation synchronization
    Given "UserA" starts a new session
      And "UserA" creates "obj_person" object of class "SyncObject" with constructor params "Bob 33"
      And "UserA" runs make persistent for object "obj_person" with alias = "myobj"
      And "UserA" registers external dataClay with hostname "logicmoduleB" and port 22034
      And "UserA" gets ID of external dataClay at hostname "logicmoduleB" and port 22034 into "dataclayid_B" variable
      And "UserA" gets ID of "DS1" backend from external dataClay with ID "dataclayid_B" into "execid_DS1_B" variable
      And "UserA" federates "obj_person" object to external dataClay backend with ID "execid_DS1_B"
      And "UserA" finishes the session
      And "UserB" starts a new session
      And "UserB" creates "obj_federated_person" of class "SyncObject" using alias "myobj"
      And "UserB" registers external dataClay with hostname "logicmoduleC" and port 42034
      And "UserB" gets ID of external dataClay at hostname "logicmoduleA" and port 12034 into "dataclayid_A" variable
      And "UserB" gets ID of external dataClay at hostname "logicmoduleC" and port 42034 into "dataclayid_C" variable
      And "UserB" gets ID of "DS1" backend from external dataClay with ID "dataclayid_A" into "execid_DS1_A" variable
      And "UserB" gets ID of "DS1" backend from external dataClay with ID "dataclayid_C" into "execid_DS1_C" variable
      And "UserB" runs "replicaSourceIs" method with params "execid_DS1_A" in object "obj_federated_person" and checks that result is "True"
      And "UserB" runs "replicaDestIncludes" method with params "execid_DS1_C" in object "obj_federated_person" and checks that result is "False"
      And "UserB" federates "obj_federated_person" object to external dataClay backend with ID "execid_DS1_C"
      And "UserB" runs "replicaDestIncludes" method with params "execid_DS1_C" in object "obj_federated_person" and checks that result is "True"
      And "UserB" finishes the session
      And "UserC" starts a new session
      And "UserC" gets ID of external dataClay at hostname "logicmoduleB" and port 22034 into "dataclayid_B" variable
      And "UserC" gets ID of "DS1" backend from external dataClay with ID "dataclayid_B" into "execid_DS1_B" variable
      And "UserC" creates "obj_federated_person_c" of class "SyncObject" using alias "myobj"
      And "UserC" runs "getName" method in object "obj_federated_person_c" and checks that result is "Bob"
      And "UserC" runs "getValue" method in object "obj_federated_person_c" and checks that result is "33"
      And "UserC" runs "replicaSourceIs" method with params "execid_DS1_B" in object "obj_federated_person_c" and checks that result is "True"
      And "UserC" finishes the session
     Then "UserA" starts a new session
      And "UserA" creates "obj_person" of class "SyncObject" using alias "myobj"
      And "UserA" runs "setName" method with params "update_from_A" in object "obj_person"
      And "UserA" finishes the session
      And "UserB" starts a new session
      And "UserB" creates "obj_person_b" of class "SyncObject" using alias "myobj"
      And "UserB" runs "getName" method in object "obj_person_b" and checks that result is "update_from_A"
      And "UserB" finishes the session
      And "UserC" starts a new session
      And "UserC" creates "obj_person_c" of class "SyncObject" using alias "myobj"
      And "UserC" runs "getName" method in object "obj_person_c" and checks that result is "update_from_A"
      And "UserC" runs "setName" method with params "update_from_C" in object "obj_person_c"
      And "UserC" finishes the session
      And "UserB" starts a new session
      And "UserB" creates "obj_person_b" of class "SyncObject" using alias "myobj"
      And "UserB" runs "getName" method in object "obj_person_b" and checks that result is "update_from_C"
      And "UserB" finishes the session
      And "UserA" starts a new session
      And "UserA" creates "obj_person_a" of class "SyncObject" using alias "myobj"
      And "UserA" runs "getName" method in object "obj_person_a" and checks that result is "update_from_C"
      And "UserA" finishes the session
