from steps.steps import *


@given('"{user_name}" sets object to be read only')
@then('"{user_name}" sets object to be read only')
def step_impl(context, user_name):
    """ Set object person to be read only
        :param context: the current feature context
        :type context: context
        :param user_name: user name
        :type user_name: string
    """
    #context.person.set_read_only()
    pass


@when('"{user_name}" calls new replica')
def step_impl(context, user_name):
    """
    Call new replica
    :param context: the current feature context
    :type context: context
    :param user_name: user name
    :type user_name: string
    """
    test_user = get_user(user_name)
    person = test_user.user_objects["person"]
    person.new_replica()


@then('"{user_name}" gets object locations and sees object is located in two locations')
def step_impl(context, user_name):
    """
    Get object locations and check
    :param context: the current feature context
    :type context: context
    :param user_name: user name
    :type user_name: string
    """
    test_user = get_user(user_name)
    person = test_user.user_objects["person"]
    locations = person.get_all_locations()
    print(locations)
    assert len(locations) == 2