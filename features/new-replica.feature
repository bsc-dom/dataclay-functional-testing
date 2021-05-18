Feature: New replica

  Background: dataClay deployment
    Given "UserA" has a configuration file "resources/common/cfgfiles/client.properties" to be used to connect to dataClay
      And "UserA" has a session file "resources/common/cfgfiles/session.properties" to be used in test application
      And "UserA" deploys dataClay with docker-compose.yml file "resources/new-replica/docker-compose.yml"
      And "UserA" waits until dataClay has 3 backends of "java" language
      And "UserA" waits until dataClay has 3 backends of "python" language
      And "UserA" creates an account named "UserA" with password "UserA"
      And "UserA" creates a dataset named "datasetA"
      And "UserA" creates a namespace named "test_namespace"
      And "UserA" creates a datacontract allowing access to dataset "datasetA" to user "UserA"
      And "UserA" registers a model located at "resources/common/model" into namespace "test_namespace"
      And "UserA" get stubs from namespace "test_namespace" into "stubs" directory
      
  Scenario: replica an object
    Given "UserA" starts a new session
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

  Scenario: replica as backup
    Given "UserA" starts a new session
      And "UserA" creates "obj_person" object of class "Person" with constructor params "Bob 33"
      And "UserA" runs make persistent for object "obj_person" with backend name = "DS1"
      And "UserA" sets "obj_person" object to be read only
      And "UserA" calls new replica for object "obj_person" with destination backend named = "DS2"
      And "UserA" gets id of "DS1" backend into "execid_DS1" variable
      And "UserA" gets id of "DS2" backend into "execid_DS2" variable
      And "UserA" calls get all locations for object "obj_person" and check object is located in 2 locations
      And "UserA" calls get all locations for object "obj_person" and check object is located in "execid_DS2" location
      And "UserA" runs "replicaDestIncludes" method with params "execid_DS2" in object "obj_person" and checks that result is "True"
     When "UserA" stops "dspython dsjava" docker services deployed using "resources/new-replica/docker-compose.yml"
      And "UserA" runs "getName" method in object "obj_person" and checks that result is "Bob"
      And "UserA" runs "getAge" method in object "obj_person" and checks that result is "33"
      And "UserA" runs "replicaSourceIs" method with params "execid_DS1" in object "obj_person" and checks that result is "True"
      And "UserA" finishes the session

  @debugging
  Scenario: replica from replica
    Given "UserA" starts a new session
      And "UserA" creates "obj_person" object of class "Person" with constructor params "Bob 33"
      And "UserA" runs make persistent for object "obj_person" with backend name = "DS1"
      And "UserA" sets "obj_person" object to be read only
      And "UserA" calls new replica for object "obj_person" with destination backend named = "DS2"
      And "UserA" gets id of "DS1" backend into "execid_DS1" variable
      And "UserA" gets id of "DS2" backend into "execid_DS2" variable
      And "UserA" gets id of "DS3" backend into "execid_DS3" variable
      And "UserA" calls get all locations for object "obj_person" and check object is located in 2 locations
      And "UserA" runs "replicaDestIncludes" method with params "execid_DS2" in object "obj_person" and checks that result is "True"
     When "UserA" stops "dspython dsjava" docker services deployed using "resources/new-replica/docker-compose.yml"
      And "UserA" sets "obj_person" object hint to "execid_DS2"
      And "UserA" calls new replica for object "obj_person" with destination backend named = "DS3"
      And "UserA" runs "replicaSourceIs" method with params "execid_DS1" in object "obj_person" and checks that result is "True"
      And "UserA" runs "replicaDestIncludes" method with params "execid_DS3" in object "obj_person" and checks that result is "True"
      And "UserA" calls get all locations for object "obj_person" and check object is located in 3 locations
      And "UserA" stops "dspython2 dsjava2" docker services deployed using "resources/new-replica/docker-compose.yml"
      And "UserA" sets "obj_person" object hint to "execid_DS3"
     Then "UserA" runs "getName" method in object "obj_person" and checks that result is "Bob"
      And "UserA" runs "getAge" method in object "obj_person" and checks that result is "33"
      And "UserA" runs "replicaSourceIs" method with params "execid_DS2" in object "obj_person" and checks that result is "True"
      And "UserA" finishes the session

  Scenario: replica recursiveness
    Given "UserA" starts a new session
      And "UserA" creates "obj_person" object of class "Person" with constructor params "Bob 33"
      And "UserA" creates "obj_people" object of class "People"
      And "UserA" creates "obj_people_not_recu" object of class "People"
      And "UserA" runs make persistent for object "obj_person" with backend name = "DS1"
      And "UserA" runs make persistent for object "obj_people_not_recu" with backend name = "DS1"
      And "UserA" runs "add" method with params "obj_person" in object "obj_people"
      And "UserA" runs "add" method with params "obj_person" in object "obj_people_not_recu"
      And "UserA" runs make persistent for object "obj_people" with backend name = "DS1"
      And "UserA" sets "obj_person" object to be read only
      And "UserA" sets "obj_people" object to be read only
      And "UserA" gets id of "DS1" backend into "execid_DS1" variable
      And "UserA" gets id of "DS2" backend into "execid_DS2" variable
      And "UserA" calls new replica for object "obj_person" with destination backend named = "DS2"
      And "UserA" calls new replica for object "obj_people" with destination backend named = "DS2"
      And "UserA" calls new replica for object "obj_people_not_recu" with destination backend named = "DS2" and recursive = "False"
     When "UserA" stops "dspython dsjava" docker services deployed using "resources/new-replica/docker-compose.yml"
      And "UserA" runs "get" method with params "0" in object "obj_people" and store result into "obj_replica_person" variable
      And "UserA" runs "getName" method in object "obj_replica_person" and checks that result is "Bob"
      And "UserA" runs "getAge" method in object "obj_replica_person" and checks that result is "33"
      And "UserA" runs "get" method with params "0" in object "obj_people_not_recu" and store result into "obj_replica_person_not_recu" variable
      And "UserA" runs "getName" method in object "obj_replica_person_not_recu" and checks that result is "Bob"
      And "UserA" runs "getAge" method in object "obj_replica_person_not_recu" and checks that result is "33"
      And "UserA" finishes the session

  Scenario: replica synchronization
    Given "UserA" starts a new session
      And "UserA" creates "obj_sync" object of class "SyncObject" with constructor params "DS1 0"
      And "UserA" runs make persistent for object "obj_sync" with backend name = "DS1"
      And "UserA" sets "obj_sync" object to be read only
      And "UserA" calls new replica for object "obj_sync" with destination backend named = "DS2" and recursive = "True"
      And "UserA" gets id of "DS1" backend into "execid_DS1" variable
      And "UserA" gets id of "DS2" backend into "execid_DS2" variable
      And "UserA" gets id of "DS3" backend into "execid_DS3" variable
      And "UserA" calls get all locations for object "obj_sync" and check object is located in 2 locations
      And "UserA" runs "replicaDestIncludes" method with params "execid_DS2" in object "obj_sync" and checks that result is "True"
     When "UserA" runs "setName" method with params "DS1_Update" in object "obj_sync"
      And "UserA" sets "obj_sync" object hint to "execid_DS2"
      And "UserA" runs "getName" method in object "obj_sync" and checks that result is "DS1_Update"
      And "UserA" runs "setName" method with params "DS2_Update" in object "obj_sync"
      And "UserA" sets "obj_sync" object hint to "execid_DS1"
      And "UserA" runs "getName" method in object "obj_sync" and checks that result is "DS2_Update"
      And "UserA" sets "obj_sync" object hint to "execid_DS2"
      And "UserA" calls new replica for object "obj_sync" with destination backend named = "DS3"
      And "UserA" runs "replicaSourceIs" method with params "execid_DS1" in object "obj_sync" and checks that result is "True"
      And "UserA" runs "replicaDestIncludes" method with params "execid_DS3" in object "obj_sync" and checks that result is "True"
      And "UserA" calls get all locations for object "obj_sync" and check object is located in 3 locations
      And "UserA" runs "setName" method with params "newDS" in object "obj_sync"
      And "UserA" sets "obj_sync" object hint to "execid_DS2"
      And "UserA" runs "getName" method in object "obj_sync" and checks that result is "newDS"
      And "UserA" sets "obj_sync" object hint to "execid_DS3"
      And "UserA" runs "replicaSourceIs" method with params "execid_DS2" in object "obj_sync" and checks that result is "True"
      And "UserA" runs "setName" method with params "finalDS" in object "obj_sync"
      And "UserA" stops "dspython2 dsjava2 dspython3 dsjava3" docker services deployed using "resources/new-replica/docker-compose.yml"
      And "UserA" sets "obj_sync" object hint to "execid_DS1"
     Then "UserA" runs "getName" method in object "obj_sync" and checks that result is "finalDS"
      And "UserA" finishes the session
