from steps.steps import *


@given('"{user_name}" runs make persistent for an object')
@then('"{user_name}" runs make persistent for an object')
def step_impl(context, user_name):
    """ Run make persistent
        :param context: the current feature context
        :type context
        :param user_name: user name
        :type user_name: string
    """
    from test_namespace.classes import Person, People
    person = Person("Bob", 33)
    person.make_persistent()
    test_user = get_user(user_name)
    test_user.user_objects["person"] = person
