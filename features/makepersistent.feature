Feature: Make persistent

  Background: dataClay deployment
    Given A configuration file "resources/common/cfgfiles/mgmclient.properties" to be used in management operations
      And A docker-compose.yml file for deployment at "resources/makepersistent/docker-compose.yml"
      And I deploy dataClay with docker-compose
      #Then I have 1 java dataservice
      #Then I have 1 python execution environment 
      And A configuration file "resources/common/cfgfiles/client.properties" to be used in test application
      And A session file "resources/common/cfgfiles/session.properties" to be used in test application
      And I create an account named "test_account" and password "test_pwd"
      And I create a dataset named "test_dataset"
      And I create a namespace named "test_namespace"
      And I create a datacontract allowing access to dataset "test_dataset" to user "test_account"
      And I register a model located at "resources/common/model" into namespace "test_namespace"
      And I get stubs from namespace "test_namespace" into "stubs" directory
      
  Scenario: run a simple make persistent
    Given I start a new session
     Then I run make persistent for an object 
      And I finish the session
      
  #Scenario: run a LOCAL make persistent
  #  Given I start a new session
  #   Then I run a LOCAL make persistent for an object 
  #    And I finish the session   
   