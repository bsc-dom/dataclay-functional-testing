from steps.steps import *


@given('"{user_name}" runs make persistent for an object with alias "{alias}"')
def step_impl(context, user_name, alias):
    """ Run make persistent with alias
        :param context: the current feature context
        :param alias: alias
        :param user_name: user name
        :type user_name: string
    """
    from test_namespace.classes import Person, People
    person = Person("Bob", 33)
    person.make_persistent(alias=alias)
    test_user = get_or_create_user(user_name)
    test_user.user_objects["person"] = person

@then('"{user_name}" gets the object with alias "{alias}"')
def step_impl(context, user_name, alias):
    """
    Get object by alias
    :param context: test context
    :param alias: alias of the object to get
    :param user_name: user name
    :type user_name: string
    """
    from test_namespace.classes import Person, People
    person = Person.get_by_alias(alias)
    print(person)