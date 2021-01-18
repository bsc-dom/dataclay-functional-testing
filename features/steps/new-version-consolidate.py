import os
from behave import *
import allure
import sys


@when('I create new version of the object in backend "{backend_name}"')
def step_impl(context, backend_name):
    """
    Call new replica
    :param context: the current feature context
    :type context: context
    :param backend_name: name of backend in which to create version
    :type backend_name: str
    """
    from dataclay import api
    backend_id = api.get_backend_id_by_name(backend_name)
    context.version_info = context.person.new_version(backend_id)
    # FIXME: update this ugly way to get versioned object
    versioned_obj_id = context.version_info[0].versionOID
    context.versioned_person = api.getRuntime().get_object_by_id(versioned_obj_id,
                                                                 context.person.get_class_extradata().class_id,
                                                                 backend_id)

@when('I update the version object')
def step_impl(context):
    """
    Get object locations and check
    :param context: the current feature context
    :type context: context
    """

    context.versioned_person.age = 100


@when('I check that the original object was not modified')
def step_impl(context):
    """
    Get object locations and check
    :param context: the current feature context
    :type context: context
    """
    assert context.person.age == 33
    assert context.versioned_person.age == 100


@then('I consolidate the version')
def step_impl(context):
    """
    Get object locations and check
    :param context: the current feature context
    :type context: context
    """
    context.versioned_person.consolidate_version(context.version_info[1])


@then('I check that the original object was modified')
def step_impl(context):
    """
    Get object locations and check
    :param context: the current feature context
    :type context: context
    """
    assert context.person.age == 100
