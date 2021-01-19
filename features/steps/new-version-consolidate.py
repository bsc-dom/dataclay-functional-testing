from steps.steps import *

@when('"{user_name}" creates new version of the object in backend "{backend_name}"')
def step_impl(context, user_name, backend_name):
    """
    Call new replica
    :param context: the current feature context
    :type context: context
    :param user_name: user name
    :type user_name: string
    :param backend_name: name of backend in which to create version
    :type backend_name: str
    """
    from dataclay import api
    test_user = get_user(user_name)
    person = test_user.user_objects["person"]
    backend_id = api.get_backend_id_by_name(backend_name)
    version_info =person.new_version(backend_id)
    # FIXME: update this ugly way to get versioned object
    versioned_obj_id = version_info[0].versionOID
    versioned_person = api.getRuntime().get_object_by_id(versioned_obj_id,
                                                                 person.get_class_extradata().class_id,
                                                                 backend_id)
    test_user.user_objects["versioned_person"] = versioned_person
    test_user.user_objects["version_info"] = version_info

@when('"{user_name}" updates the version object')
def step_impl(context, user_name):
    """
    Get object locations and check
    :param context: the current feature context
    :type context: context
    :param user_name: user name
    :type user_name: string
    """
    test_user = get_user(user_name)
    versioned_person = test_user.user_objects["versioned_person"]
    versioned_person.age = 100


@when('"{user_name}" checks that the original object was not modified')
def step_impl(context, user_name):
    """
    Get object locations and check
    :param context: the current feature context
    :type context: context
    :param user_name: user name
    :type user_name: string
    """
    test_user = get_user(user_name)
    versioned_person = test_user.user_objects["versioned_person"]
    person = test_user.user_objects["person"]
    assert person.age == 33
    assert versioned_person.age == 100


@then('"{user_name}" consolidates the version')
def step_impl(context, user_name):
    """
    Get object locations and check
    :param context: the current feature context
    :type context: context
    :param user_name: user name
    :type user_name: string
    """
    test_user = get_user(user_name)
    versioned_person = test_user.user_objects["versioned_person"]
    version_info = test_user.user_objects["version_info"]
    versioned_person.consolidate_version(version_info[1])


@then('"{user_name}" checks that the original object was modified')
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
    assert person.age == 100
